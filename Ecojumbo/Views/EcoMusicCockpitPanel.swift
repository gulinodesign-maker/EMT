import SwiftUI
import Combine
import MusicKit

// Catalogo e riproduzione Apple Music restano all'interno di EMT.
// Nessun brano, album o artista fittizio.
@MainActor
final class EcoAppleMusicPlayback: ObservableObject {
    static let shared = EcoAppleMusicPlayback()
    private let player = ApplicationMusicPlayer.shared

    @Published private(set) var hasChosenTrack = false
    @Published private(set) var title = "Nessun brano"
    @Published private(set) var artist = "Cerca un brano in Apple Music"
    @Published private(set) var artworkURL: URL?
    @Published private(set) var isPlaying = false
    @Published private(set) var errorMessage = ""

    private init() {}

    var isAuthorized: Bool { MusicAuthorization.currentStatus == .authorized }

    func requestAuthorization() {
        Task {
            let status = await MusicAuthorization.request()
            if status != .authorized {
                errorMessage = "Consenti l'accesso ad Apple Music nelle impostazioni di iOS."
            } else {
                errorMessage = ""
            }
        }
    }

    func search(_ text: String) async throws -> [Song] {
        guard isAuthorized else {
            throw MusicSearchError.unauthorized
        }
        var request = MusicCatalogSearchRequest(term: text, types: [Song.self])
        request.limit = 35
        let response = try await request.response()
        return Array(response.songs)
    }

    @discardableResult
    func play(_ song: Song) async -> Bool {
        guard isAuthorized else {
            requestAuthorization()
            return false
        }
        do {
            player.queue = ApplicationMusicPlayer.Queue(for: [song])
            try await player.play()
            hasChosenTrack = true
            title = song.title
            artist = song.artistName
            artworkURL = song.artwork?.url(width: 1100, height: 1100)
            errorMessage = ""
            refresh()
            return true
        } catch {
            errorMessage = "Riproduzione non disponibile: verifica l'abbonamento Apple Music. " + error.localizedDescription
            return false
        }
    }

    func refresh() {
        guard hasChosenTrack else { return }
        if let current = player.queue.currentEntry {
            title = current.title
            artist = current.subtitle ?? artist
            artworkURL = current.artwork?.url(width: 1100, height: 1100) ?? artworkURL
        }
        isPlaying = player.state.playbackStatus == .playing
    }

    func togglePlayback() {
        guard hasChosenTrack else { return }
        if isPlaying {
            player.pause()
            refresh()
        } else {
            Task {
                do {
                    try await player.play()
                    errorMessage = ""
                } catch {
                    errorMessage = error.localizedDescription
                }
                refresh()
            }
        }
    }

    func previous() {
        guard hasChosenTrack else { return }
        Task {
            do { try await player.skipToPreviousEntry() }
            catch { errorMessage = error.localizedDescription }
            refresh()
        }
    }

    func next() {
        guard hasChosenTrack else { return }
        Task {
            do { try await player.skipToNextEntry() }
            catch { errorMessage = error.localizedDescription }
            refresh()
        }
    }

    enum MusicSearchError: LocalizedError {
        case unauthorized
        var errorDescription: String? {
            "Autorizza Apple Music per cercare nel catalogo senza uscire da EMT."
        }
    }
}

// Stessa finestra, dimensioni e maschere della mappa GPS; il ritaglio
// condiviso viene applicato in GPSCockpitDashboard ai due contenuti.
@MainActor
struct EcoMusicCockpitPanel: View {
    @StateObject private var music = EcoMusicManager.shared
    @StateObject private var apple = EcoAppleMusicPlayback.shared
    @AppStorage("ecojumbo.music.provider") private var providerName = EcoMusicProvider.apple.rawValue
    @Binding var searchVisible: Bool
    @State private var query = ""
    @State private var results: [Song] = []
    @State private var searchError = ""
    @State private var searching = false
    let theme: CockpitTheme

    private var provider: EcoMusicProvider {
        EcoMusicProvider(rawValue: providerName) ?? .apple
    }

    private var usesInAppPlayer: Bool { provider == .apple && apple.hasChosenTrack }

    private var trackTitle: String {
        usesInAppPlayer ? apple.title : music.title
    }

    private var trackArtist: String {
        usesInAppPlayer ? apple.artist : music.artist
    }

    private var artworkURL: URL? {
        usesInAppPlayer ? apple.artworkURL : music.coverURL
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack(alignment: .topLeading) {
                fullBleedArtwork(width: w, height: h)
                LinearGradient(colors: [
                    .black.opacity(0.22), .black.opacity(0.40),
                    .black.opacity(0.72)
                ], startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)

                if searchVisible {
                    searchLayer(width: w, height: h)
                } else {
                    informationLayer(width: w, height: h)
                }
            }
            .frame(width: w, height: h)
        }
        .accessibilityElement(children: .contain)
        .onAppear {
            music.select(provider)
            apple.refresh()
        }
        .onChange(of: providerName) { _, _ in
            music.select(provider)
            searchVisible = false
            query = ""
            results.removeAll()
        }
        .onReceive(Timer.publish(every: 3, on: .main, in: .common).autoconnect()) { _ in
            music.refresh()
            apple.refresh()
        }
        .task(id: searchVisible ? query : "") {
            guard searchVisible, provider == .apple else {
                results = []
                searchError = ""
                return
            }
            let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard term.count >= 2 else {
                results = []
                searchError = ""
                return
            }
            searching = true
            do {
                try await Task.sleep(nanoseconds: 320_000_000)
                let songs = try await apple.search(term)
                guard !Task.isCancelled else { return }
                results = songs
                searchError = songs.isEmpty ? "Nessun risultato trovato." : ""
            } catch is CancellationError {
                return
            } catch {
                if !Task.isCancelled {
                    results = []
                    searchError = error.localizedDescription
                }
            }
            searching = false
        }
    }

    private func fullBleedArtwork(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Color.ecoCard
            if usesInAppPlayer, let url = artworkURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    placeholder
                }
            } else if let artwork = music.cover, provider == .apple {
                Image(uiImage: artwork).resizable().scaledToFill()
            } else if let url = artworkURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    placeholder
                }
            } else {
                placeholder
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .accessibilityLabel("Copertina del brano, se disponibile")
    }

    private var placeholder: some View {
        Image(systemName: "music.note")
            .resizable()
            .scaledToFit()
            .frame(width: 130, height: 130)
            .foregroundStyle(theme.accent.opacity(0.70))
    }

    private func informationLayer(width w: CGFloat, height h: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: max(6, h * 0.018)) {
            Text("MUSICA · " + provider.rawValue.uppercased())
                .font(.system(size: max(12, h * 0.035), weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.83))
            Spacer(minLength: 0)
            Text(trackTitle)
                .font(.system(size: min(36, max(19, w * 0.045)), weight: .bold))
                .lineLimit(2).minimumScaleFactor(0.75)
                .foregroundStyle(.white)
            Text(trackArtist)
                .font(.system(size: max(13, w * 0.025), weight: .medium))
                .lineLimit(2)
                .foregroundStyle(.white.opacity(0.82))
            if provider == .apple && !apple.isAuthorized {
                Button("Autorizza Apple Music") {
                    apple.requestAuthorization()
                    music.requestAppleAccess()
                }
                .foregroundStyle(theme.accent)
                .buttonStyle(.plain)
            } else if provider == .spotify && !music.spotifyConnected {
                Text("Collega Spotify in Setup → Musica.")
                    .foregroundStyle(.white.opacity(0.8))
            } else if provider == .youtube {
                Text("YouTube Music non dispone di riproduzione integrata tramite API pubblica.")
                    .foregroundStyle(.white.opacity(0.8))
            }
            let note = usesInAppPlayer ? apple.errorMessage : music.message
            if !note.isEmpty {
                Text(note).font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(3)
            }
        }
        .padding(.leading, w * 0.33)
        .padding(.trailing, max(18, w * 0.045))
        .padding(.top, max(36, h * 0.12))
        .padding(.bottom, max(60, h * 0.14))
        .frame(width: w, height: h)
    }

    private func searchLayer(width w: CGFloat, height h: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: max(8, h * 0.018)) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Cerca brano o artista", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                Button {
                    searchVisible = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .accessibilityLabel("Chiudi ricerca musicale")
            }
            .font(.system(size: max(14, h * 0.035)))
            .foregroundStyle(.white)
            .tint(theme.accent)
            .padding(11)
            .background(.black.opacity(0.70), in: RoundedRectangle(cornerRadius: 10))

            if provider != .apple {
                Text("La ricerca musicale interna è attualmente disponibile con Apple Music.")
                    .foregroundStyle(.white)
                    .font(.footnote)
            } else if !apple.isAuthorized {
                Button("Autorizza Apple Music") {
                    apple.requestAuthorization()
                }
                .foregroundStyle(theme.accent)
            } else {
                if searching {
                    ProgressView("Ricerca nel catalogo Apple Music…")
                        .tint(theme.accent)
                        .foregroundStyle(.white)
                }
                if !searchError.isEmpty {
                    Text(searchError)
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(results) { song in
                            Button {
                                Task {
                                    if await apple.play(song) {
                                        searchVisible = false
                                    } else {
                                        searchError = apple.errorMessage
                                    }
                                }
                            } label: {
                                HStack(spacing: 11) {
                                    AsyncImage(url: song.artwork?.url(width: 100, height: 100)) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "music.note").foregroundStyle(theme.accent)
                                    }
                                    .frame(width: 45, height: 45).clipped()
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(song.title).font(.subheadline.bold()).lineLimit(1)
                                        Text(song.artistName).font(.caption).lineLimit(1)
                                    }
                                    Spacer(minLength: 0)
                                    Image(systemName: "play.fill")
                                }
                                .foregroundStyle(.white)
                                .padding(.vertical, 5)
                            }
                            .buttonStyle(.plain)
                            Divider().overlay(.white.opacity(0.15))
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, w * 0.32)
        .padding(.trailing, max(15, w * 0.045))
        .padding(.top, max(36, h * 0.12))
        .padding(.bottom, max(40, h * 0.12))
        .frame(width: w, height: h)
    }
}
