import SwiftUI
import Combine
import MusicKit
import MediaPlayer

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
    @Published private(set) var authorized = MusicAuthorization.currentStatus == .authorized

    private init() {}

    var isAuthorized: Bool { authorized }

    func requestAuthorization() {
        Task {
            let status = await MusicAuthorization.request()
            authorized = status == .authorized
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
            // Non conservare la copertina del brano precedente quando cambia la coda.
            artworkURL = current.artwork?.url(width: 1100, height: 1100)
        }
        isPlaying = player.state.playbackStatus == .playing
    }

    func surrenderToSystemPlayer() {
        if hasChosenTrack { player.pause() }
        hasChosenTrack = false
        errorMessage = ""
    }

    func togglePlayback() {
        guard hasChosenTrack else { return }
        if player.state.playbackStatus == .playing {
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
    @State private var libraryResults: [MPMediaItem] = []
    @State private var searchError = ""
    @State private var searching = false
    @State private var catalogTokenUnavailable = false
    @State private var searchRevision = 0
    @FocusState private var searchFieldFocused: Bool
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
            libraryResults.removeAll()
            catalogTokenUnavailable = false
        }
        .onChange(of: searchVisible) { _, visible in
            searchFieldFocused = visible
        }
        .onChange(of: apple.authorized) { _, value in
            if value { searchRevision += 1 }
        }
        .onChange(of: music.appleAuthorized) { _, value in
            if value { searchRevision += 1 }
        }
        // MusicKit + lettore di sistema: polling breve anche mentre suona;
        // i comandi non sono necessari per aggiornare copertina/Play-Pausa.
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if provider == .apple {
                music.refresh()
                apple.refresh()
            }
        }
        .onReceive(Timer.publish(every: 3, on: .main, in: .common).autoconnect()) { _ in
            if provider == .spotify { music.refresh() }
        }
        .task(id: searchVisible ? "\(query)|\(searchRevision)" : "") {
            guard searchVisible, provider == .apple else {
                results.removeAll()
                libraryResults.removeAll()
                searchError = ""
                searching = false
                return
            }
            let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard term.count >= 2 else {
                results.removeAll()
                libraryResults.removeAll()
                searchError = ""
                searching = false
                return
            }
            searching = true
            do { try await Task.sleep(nanoseconds: 320_000_000) }
            catch { searching = false; return }
            guard !Task.isCancelled else { return }

            // Ricerca realmente disponibile anche quando Apple non ha ancora
            // abilitato il developer token per il catalogo MusicKit di EMT.
            // I risultati locali sono veri MPMediaItem, mai dati di esempio.
            libraryResults = music.searchLocalLibrary(term)
            results.removeAll()
            guard apple.isAuthorized else {
                searchError = "Per cercare nel catalogo autorizza Apple Music; puoi già cercare nella libreria del tuo iPhone."
                searching = false
                return
            }
            guard !catalogTokenUnavailable else {
                searching = false
                searchError = "Catalogo online non disponibile: abilita MusicKit per it.ecojumbo.battery in Apple Developer → Identifiers → App Services. La ricerca nella libreria locale resta attiva."
                return
            }

            do {
                let songs = try await apple.search(term)
                guard !Task.isCancelled else { return }
                results = songs
                searchError = songs.isEmpty && libraryResults.isEmpty
                    ? "Nessun brano trovato nel catalogo Apple Music." : ""
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                let tokenFailure = (error as? MusicTokenRequestError) == .developerTokenRequestFailed
                    || error.localizedDescription.localizedCaseInsensitiveContains("developer token")
                if tokenFailure {
                    catalogTokenUnavailable = true
                    searchError = "Catalogo Apple Music non abilitato per EMT. Attiva MusicKit nell'App ID it.ecojumbo.battery su Apple Developer. Nel frattempo puoi cercare e riprodurre i brani presenti nella libreria iPhone."
                } else {
                    searchError = "Ricerca nel catalogo non disponibile: \(error.localizedDescription). I brani nella libreria iPhone restano utilizzabili."
                }
            }
            searching = false
        }
    }

    private func fullBleedArtwork(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Color.ecoCard
            if usesInAppPlayer {
                // Mai mostrare la copertina (eventualmente vecchia) del player di sistema.
                if let url = artworkURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        placeholder
                    }
                    .id(url)
                } else {
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
                .id(url)
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

    // Il campo e i risultati sono interamente interni a EMT.
    // La ricerca locale funziona anche se MusicKit non riceve il token Apple.
    private func searchLayer(width w: CGFloat, height h: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: max(8, h * 0.018)) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Cerca brano, artista o album", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .focused($searchFieldFocused)
                    .onSubmit { searchRevision += 1 }
                    .accessibilityLabel("Cerca nella musica senza uscire da EMT")
                Button {
                    searchFieldFocused = false
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
            .background(.black.opacity(0.76), in: RoundedRectangle(cornerRadius: 10))

            if provider != .apple {
                Text("La ricerca musicale interna è attualmente disponibile con Apple Music.")
                    .foregroundStyle(.white)
                    .font(.footnote)
            } else {
                if !apple.isAuthorized || !music.appleAuthorized {
                    Button("Autorizza Apple Music e la libreria") {
                        apple.requestAuthorization()
                        music.requestAppleAccess()
                    }
                    .buttonStyle(.plain)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.accent)
                    .accessibilityLabel("Autorizza l'accesso alla libreria e al catalogo musicale")
                }
                if searching {
                    ProgressView("Ricerca musicale…")
                        .font(.footnote)
                        .tint(theme.accent)
                        .foregroundStyle(.white)
                }
                if !searchError.isEmpty {
                    Text(searchError)
                        .font(.system(size: max(11, h * 0.027)))
                        .foregroundStyle(.white.opacity(0.91))
                        .fixedSize(horizontal: false, vertical: true)
                }
                if catalogTokenUnavailable {
                    Button("Riprova catalogo Apple Music") {
                        catalogTokenUnavailable = false
                        searchRevision += 1
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(theme.accent)
                    .buttonStyle(.plain)
                }
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 5) {
                        if !results.isEmpty {
                            Text("CATALOGO APPLE MUSIC")
                                .font(.caption2.weight(.bold))
                                .tracking(1)
                                .foregroundStyle(.white.opacity(0.72))
                            ForEach(results) { song in
                                Button {
                                    searchFieldFocused = false
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
                                        .frame(width: 43, height: 43).clipped()
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(song.title).font(.subheadline.bold()).lineLimit(1)
                                            Text(song.artistName).font(.caption).lineLimit(1)
                                        }
                                        Spacer(minLength: 0)
                                        Image(systemName: "play.fill")
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 3)
                                }
                                .buttonStyle(.plain)
                                Divider().overlay(.white.opacity(0.12))
                            }
                        }
                        if !libraryResults.isEmpty {
                            Text("NELLA LIBRERIA IPHONE")
                                .font(.caption2.weight(.bold))
                                .tracking(1)
                                .foregroundStyle(.white.opacity(0.72))
                                .padding(.top, 5)
                            ForEach(libraryResults, id: \.persistentID) { item in
                                Button {
                                    apple.surrenderToSystemPlayer()
                                    if music.playLocalLibrary(item) {
                                        searchFieldFocused = false
                                        searchVisible = false
                                    } else {
                                        searchError = music.message
                                    }
                                } label: {
                                    HStack(spacing: 11) {
                                        if let image = item.artwork?.image(at: CGSize(width: 100, height: 100)) {
                                            Image(uiImage: image)
                                                .resizable().scaledToFill()
                                                .frame(width: 43, height: 43).clipped()
                                        } else {
                                            Image(systemName: "music.note")
                                                .foregroundStyle(theme.accent)
                                                .frame(width: 43, height: 43)
                                        }
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(item.title ?? "Brano senza titolo")
                                                .font(.subheadline.bold()).lineLimit(1)
                                            Text(item.artist ?? "Artista non disponibile")
                                                .font(.caption).lineLimit(1)
                                        }
                                        Spacer(minLength: 0)
                                        Image(systemName: "play.fill")
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 3)
                                }
                                .buttonStyle(.plain)
                                Divider().overlay(.white.opacity(0.12))
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                if !searching && query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
                    && results.isEmpty && libraryResults.isEmpty {
                    Text("Nessun risultato disponibile. Il catalogo online richiede MusicKit attivo; la libreria può essere vuota.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }
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
