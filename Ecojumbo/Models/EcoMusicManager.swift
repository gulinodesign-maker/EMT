import Foundation
import SwiftUI
import Combine
import MediaPlayer
import Security
import UIKit

// Apple Music è l'unico servizio musicale di Ecojumbo.
// MusicKit gestisce il catalogo; questo manager controlla il lettore di sistema
// e i brani già presenti nella libreria dell'iPhone.
enum EcoMusicProvider: String, CaseIterable, Identifiable {
    case apple = "Apple Music"
    var id: String { rawValue }
}

@MainActor
final class EcoMusicManager: ObservableObject {
    static let shared = EcoMusicManager()

    @Published private(set) var title = "Nessun brano"
    @Published private(set) var artist = "Avvia un brano in Apple Music"
    @Published private(set) var cover: UIImage?
    @Published private(set) var coverURL: URL?
    @Published private(set) var isPlaying = false
    @Published private(set) var message = ""
    @Published private(set) var appleAuthorized = false

    private let applePlayer = MPMusicPlayerController.systemMusicPlayer
    private var playbackObservers: [AnyCancellable] = []

    private init() {
        // Migrazione una tantum: non conservare più credenziali di provider rimossi.
        Self.clearLegacyExternalMusicCredentials()
        appleAuthorized = MPMediaLibrary.authorizationStatus() == .authorized
        applePlayer.beginGeneratingPlaybackNotifications()
        for name in [Notification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
                     Notification.Name.MPMusicPlayerControllerPlaybackStateDidChange] {
            NotificationCenter.default.publisher(for: name)
                .sink { [weak self] _ in
                    Task { @MainActor [weak self] in self?.refreshApple() }
                }
                .store(in: &playbackObservers)
        }
    }

    private static func clearLegacyExternalMusicCredentials() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "ecojumbo.music.provider")
        defaults.removeObject(forKey: "ecojumbo.spotifyClientID")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "it.ecojumbo.battery.spotify.token",
            kSecAttrService as String: "Ecojumbo Music"
        ]
        SecItemDelete(query as CFDictionary)
    }

    func select(_ provider: EcoMusicProvider) { refreshApple() }
    func refresh() { refreshApple() }

    // Fallback Apple: ricerca la libreria iPhone senza token catalogo MusicKit.
    func searchLocalLibrary(_ term: String, limit: Int = 35) -> [MPMediaItem] {
        appleAuthorized = MPMediaLibrary.authorizationStatus() == .authorized
        guard appleAuthorized else { return [] }
        let search = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard search.count >= 2 else { return [] }
        let items = MPMediaQuery.songs().items ?? []
        return Array(items.lazy.filter { item in
            (item.title?.localizedStandardContains(search) ?? false)
                || (item.artist?.localizedStandardContains(search) ?? false)
                || (item.albumTitle?.localizedStandardContains(search) ?? false)
        }.prefix(limit))
    }

    @discardableResult
    func playLocalLibrary(_ song: MPMediaItem) -> Bool {
        appleAuthorized = MPMediaLibrary.authorizationStatus() == .authorized
        guard appleAuthorized else {
            message = "Autorizza la libreria musicale nelle impostazioni dell'iPhone."
            return false
        }
        applePlayer.setQueue(with: MPMediaItemCollection(items: [song]))
        applePlayer.play()
        refreshApple()
        return true
    }

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

    private func clearTrack() {
        title = "Nessun brano"
        artist = "Avvia un brano in Apple Music"
        cover = nil
        coverURL = nil
        isPlaying = false
    }

    func togglePlayback() {
        guard appleAuthorized else { requestAppleAccess(); return }
        if applePlayer.playbackState == .playing {
            applePlayer.pause()
        } else {
            applePlayer.play()
        }
        refreshApple()
    }

    func previous() {
        guard appleAuthorized else { requestAppleAccess(); return }
        applePlayer.skipToPreviousItem()
        refreshApple()
    }

    func next() {
        guard appleAuthorized else { requestAppleAccess(); return }
        applePlayer.skipToNextItem()
        refreshApple()
    }
}
