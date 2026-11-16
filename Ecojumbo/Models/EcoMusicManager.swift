import Foundation
import SwiftUI
import Combine
import MediaPlayer
import CryptoKit
import Security
import UIKit

// La scelta del provider è locale e non modifica GPS, Bluetooth o navigazione.
enum EcoMusicProvider: String, CaseIterable, Identifiable {
    case apple = "Apple Music"
    case spotify = "Spotify"
    case youtube = "YouTube Music"

    var id: String { rawValue }
}

// Nessuna sorgente audio fittizia: tutte le informazioni provengono dal
// player di sistema Apple o dall'API autenticata di Spotify.
@MainActor
final class EcoMusicManager: ObservableObject {
    static let shared = EcoMusicManager()

    @Published private(set) var title = "Nessun brano"
    @Published private(set) var artist = "Apri il servizio musicale per iniziare"
    @Published private(set) var cover: UIImage?
    @Published private(set) var coverURL: URL?
    @Published private(set) var isPlaying = false
    @Published private(set) var message = ""
    @Published private(set) var spotifyConnected = false
    @Published private(set) var appleAuthorized = false

    private let applePlayer = MPMusicPlayerController.systemMusicPlayer
    private static let spotifyKeychainAccount = "it.ecojumbo.battery.spotify.token"
    private static let callbackURL = "ecojumbo-spotify://callback"
    private var spotifyToken: SpotifyToken?
    private var loginVerifier: String?
    private var loginState: String?
    private var spotifyRequestInFlight = false
    private var activeProvider: EcoMusicProvider = .apple

    private struct SpotifyToken: Codable {
        let accessToken: String
        let refreshToken: String
        let expiresAt: Date
    }

    private struct TokenResponse: Decodable {
        let access_token: String
        let refresh_token: String?
        let expires_in: Int
    }

    private struct SpotifyPlayback: Decodable {
        let is_playing: Bool
        let item: SpotifyTrack?
    }

    private struct SpotifyTrack: Decodable {
        let name: String
        let artists: [SpotifyArtist]?
        let album: SpotifyAlbum?
    }

    private struct SpotifyArtist: Decodable { let name: String }
    private struct SpotifyAlbum: Decodable { let images: [SpotifyImage]? }
    private struct SpotifyImage: Decodable { let url: String }

    private enum SpotifyError: LocalizedError {
        case noClient, notConnected, invalidReply, http(Int)
        var errorDescription: String? {
            switch self {
            case .noClient: "Configura il Client ID Spotify in Setup → Musica."
            case .notConnected: "Collega Spotify da Setup → Musica."
            case .invalidReply: "Risposta non valida dal servizio musicale."
            case .http(401): "Accesso Spotify scaduto: riconnetti l'account."
            case .http(403): "Spotify non autorizza questo comando. Può servire Premium."
            case .http(429): "Troppe richieste Spotify: riprova più tardi."
            case .http(let code): "Spotify ha restituito l'errore \(code)."
            }
        }
    }

    private init() {
        appleAuthorized = MPMediaLibrary.authorizationStatus() == .authorized
        applePlayer.beginGeneratingPlaybackNotifications()
        spotifyToken = Self.readTokenFromKeychain()
        spotifyConnected = spotifyToken != nil
    }

    func select(_ provider: EcoMusicProvider) {
        if activeProvider != provider {
            activeProvider = provider
            clearTrack()
            message = ""
        }
        refresh()
    }

    func refresh() {
        switch activeProvider {
        case .apple: refreshApple()
        case .spotify:
            guard !spotifyRequestInFlight else { return }
            Task { await refreshSpotify() }
        case .youtube:
            clearTrack()
            message = "YouTube Music si apre nella sua app; i comandi integrati non sono disponibili."
        }
    }

    private func clearTrack() {
        title = "Nessun brano"
        artist = "Avvia un brano dal servizio selezionato"
        cover = nil
        coverURL = nil
        isPlaying = false
    }

    // Apple Music: controlla la vera app Musica, non un player isolato.
    func requestAppleAccess() {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            Task { @MainActor [weak self] in
                self?.appleAuthorized = status == .authorized
                self?.refreshApple()
            }
        }
    }

    private func refreshApple() {
        appleAuthorized = MPMediaLibrary.authorizationStatus() == .authorized
        guard appleAuthorized else {
            clearTrack()
            message = "Autorizza l'accesso alla libreria di Apple Music."
            return
        }
        let item = applePlayer.nowPlayingItem
        title = item?.title ?? "Nessun brano"
        artist = item?.artist ?? "Avvia un brano nell'app Musica"
        cover = item?.artwork?.image(at: CGSize(width: 420, height: 420))
        coverURL = nil
        isPlaying = applePlayer.playbackState == .playing
        message = item == nil ? "Nessun brano Apple Music disponibile." : ""
    }

    func togglePlayback() {
        switch activeProvider {
        case .apple:
            guard appleAuthorized else { requestAppleAccess(); return }
            if applePlayer.playbackState == .playing {
                applePlayer.pause()
            } else {
                applePlayer.play()
            }
            refreshApple()
        case .spotify:
            Task { await spotifyCommand(path: isPlaying ? "/me/player/pause" : "/me/player/play", method: "PUT") }
        case .youtube:
            openYouTubeMusic()
        }
    }

    func previous() {
        switch activeProvider {
        case .apple:
            guard appleAuthorized else { requestAppleAccess(); return }
            applePlayer.skipToPreviousItem()
            refreshApple()
        case .spotify:
            Task { await spotifyCommand(path: "/me/player/previous", method: "POST") }
        case .youtube: openYouTubeMusic()
        }
    }

    func next() {
        switch activeProvider {
        case .apple:
            guard appleAuthorized else { requestAppleAccess(); return }
            applePlayer.skipToNextItem()
            refreshApple()
        case .spotify:
            Task { await spotifyCommand(path: "/me/player/next", method: "POST") }
        case .youtube: openYouTubeMusic()
        }
    }

    func openSelectedApp() {
        switch activeProvider {
        case .apple: UIApplication.shared.open(URL(string: "music://")!)
        case .spotify: openSpotify()
        case .youtube: openYouTubeMusic()
        }
    }

    private func openSpotify() {
        guard let deepLink = URL(string: "spotify://"), let fallback = URL(string: "https://open.spotify.com") else { return }
        UIApplication.shared.open(deepLink) { opened in
            if !opened { UIApplication.shared.open(fallback) }
        }
    }

    private func openYouTubeMusic() {
        guard let url = URL(string: "https://music.youtube.com") else { return }
        UIApplication.shared.open(url)
    }

    // Spotify Web API con OAuth Authorization Code + PKCE: nessun client secret
    // incluso nell'app. Il Client ID pubblico e la URI vanno registrati su Spotify.
    func connectSpotify() {
        let id = spotifyClientID
        guard !id.isEmpty else {
            message = SpotifyError.noClient.localizedDescription
            return
        }
        if spotifyToken != nil {
            Task { await refreshSpotify() }
            return
        }
        let verifier = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let state = UUID().uuidString
        let challengeBytes = SHA256.hash(data: Data(verifier.utf8))
        let challenge = Data(challengeBytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        var url = URLComponents(string: "https://accounts.spotify.com/authorize")!
        url.queryItems = [
            URLQueryItem(name: "client_id", value: id),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: Self.callbackURL),
            URLQueryItem(name: "scope", value: "user-read-playback-state user-read-currently-playing user-modify-playback-state"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: challenge)
        ]
        loginVerifier = verifier
        loginState = state
        guard let target = url.url else { message = "Autorizzazione Spotify non disponibile."; return }
        UIApplication.shared.open(target)
    }

    func handleSpotifyCallback(_ url: URL) {
        guard url.scheme == "ecojumbo-spotify", url.host == "callback" else { return }
        let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let get: (String) -> String? = { name in params.first { $0.name == name }?.value }
        guard let state = loginState, let verifier = loginVerifier,
              get("state") == state, let code = get("code") else {
            loginState = nil
            loginVerifier = nil
            message = "Accesso Spotify annullato o risposta non valida."
            return
        }
        loginState = nil
        loginVerifier = nil
        Task {
            do {
                let token = try await exchangeSpotifyToken([
                    ("grant_type", "authorization_code"),
                    ("code", code),
                    ("redirect_uri", Self.callbackURL),
                    ("code_verifier", verifier),
                    ("client_id", spotifyClientID)
                ], oldRefreshToken: nil)
                spotifyToken = token
                Self.saveTokenToKeychain(token)
                spotifyConnected = true
                message = "Spotify collegato."
                await refreshSpotify()
            } catch {
                message = "Connessione Spotify: \(error.localizedDescription)"
            }
        }
    }

    func disconnectSpotify() {
        spotifyToken = nil
        spotifyConnected = false
        clearTrack()
        message = "Spotify scollegato."
        Self.deleteTokenFromKeychain()
    }

    private var spotifyClientID: String {
        (UserDefaults.standard.string(forKey: "ecojumbo.spotifyClientID") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func form(_ pairs: [(String, String)]) -> Data {
        var components = URLComponents()
        components.queryItems = pairs.map { URLQueryItem(name: $0.0, value: $0.1) }
        return Data((components.percentEncodedQuery ?? "").utf8)
    }

    private func exchangeSpotifyToken(_ pairs: [(String, String)],
                                      oldRefreshToken: String?) async throws -> SpotifyToken {
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Self.form(pairs)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SpotifyError.invalidReply }
        guard (200..<300).contains(http.statusCode) else { throw SpotifyError.http(http.statusCode) }
        let reply = try JSONDecoder().decode(TokenResponse.self, from: data)
        guard let refresh = reply.refresh_token ?? oldRefreshToken, !refresh.isEmpty else {
            throw SpotifyError.invalidReply
        }
        return SpotifyToken(accessToken: reply.access_token, refreshToken: refresh,
                            expiresAt: Date().addingTimeInterval(TimeInterval(max(30, reply.expires_in - 60))))
    }

    private func validSpotifyToken() async throws -> String {
        guard var token = spotifyToken else { throw SpotifyError.notConnected }
        if Date() >= token.expiresAt {
            guard !spotifyClientID.isEmpty else { throw SpotifyError.noClient }
            token = try await exchangeSpotifyToken([
                ("grant_type", "refresh_token"),
                ("refresh_token", token.refreshToken),
                ("client_id", spotifyClientID)
            ], oldRefreshToken: token.refreshToken)
            spotifyToken = token
            Self.saveTokenToKeychain(token)
        }
        return token.accessToken
    }

    private func spotifyAPI(path: String, method: String = "GET") async throws -> (Data, Int) {
        let token = try await validSpotifyToken()
        guard let url = URL(string: "https://api.spotify.com/v1\(path)") else { throw SpotifyError.invalidReply }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SpotifyError.invalidReply }
        guard (200..<300).contains(http.statusCode) else { throw SpotifyError.http(http.statusCode) }
        return (data, http.statusCode)
    }

    private func refreshSpotify() async {
        guard !spotifyRequestInFlight else { return }
        spotifyRequestInFlight = true
        defer { spotifyRequestInFlight = false }
        guard spotifyToken != nil else {
            clearTrack()
            spotifyConnected = false
            message = "Collega Spotify da Setup → Musica."
            return
        }
        do {
            let (data, code) = try await spotifyAPI(path: "/me/player")
            guard activeProvider == .spotify else { return }
            if code == 204 || data.isEmpty {
                clearTrack()
                message = "Nessun dispositivo Spotify attivo. Avvia la musica in Spotify."
                return
            }
            let reply = try JSONDecoder().decode(SpotifyPlayback.self, from: data)
            title = reply.item?.name ?? "Nessun brano"
            artist = reply.item?.artists?.map(\.name).joined(separator: ", ") ?? "Spotify"
            cover = nil
            coverURL = reply.item?.album?.images?.first.flatMap { URL(string: $0.url) }
            isPlaying = reply.is_playing
            spotifyConnected = true
            message = reply.item == nil ? "Avvia un brano in Spotify." : ""
        } catch {
            guard activeProvider == .spotify else { return }
            clearTrack()
            message = error.localizedDescription
        }
    }

    private func spotifyCommand(path: String, method: String) async {
        do {
            _ = try await spotifyAPI(path: path, method: method)
            // Spotify aggiorna lo stato in modo asincrono.
            try? await Task.sleep(nanoseconds: 450_000_000)
            await refreshSpotify()
        } catch {
            message = error.localizedDescription
        }
    }

    private static func readTokenFromKeychain() -> SpotifyToken? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: spotifyKeychainAccount,
            kSecAttrService as String: "Ecojumbo Music",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(SpotifyToken.self, from: data)
    }

    private static func saveTokenToKeychain(_ token: SpotifyToken) {
        guard let data = try? JSONEncoder().encode(token) else { return }
        deleteTokenFromKeychain()
        let entry: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: spotifyKeychainAccount,
            kSecAttrService as String: "Ecojumbo Music",
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData as String: data
        ]
        SecItemAdd(entry as CFDictionary, nil)
    }

    private static func deleteTokenFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: spotifyKeychainAccount,
            kSecAttrService as String: "Ecojumbo Music"
        ]
        SecItemDelete(query as CFDictionary)
    }
}
