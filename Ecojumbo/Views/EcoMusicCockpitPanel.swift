import SwiftUI

// Pannello musicale nel medesimo rettangolo della Telemetria;
// non copre il tachimetro, la top bar, la lettura kW o il dock.
@MainActor
struct EcoMusicCockpitPanel: View {
    @StateObject private var music = EcoMusicManager.shared
    @AppStorage("ecojumbo.music.provider") private var providerName = EcoMusicProvider.apple.rawValue
    let theme: CockpitTheme

    private var provider: EcoMusicProvider {
        EcoMusicProvider(rawValue: providerName) ?? .apple
    }

    private var controlsAvailable: Bool {
        switch provider {
        case .apple: music.appleAuthorized
        case .spotify: music.spotifyConnected
        case .youtube: false
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let coverSide = min(w * 0.32, h * 0.67)
            let spacing = max(10, min(23, w * 0.024))
            VStack(spacing: max(7, h * 0.025)) {
                HStack(spacing: max(8, w * 0.02)) {
                    Rectangle().fill(theme.accent.opacity(0.78)).frame(width: max(12, w * 0.048), height: 1)
                    Text("MUSICA · \(provider.rawValue.uppercased())")
                        .font(.system(size: max(11, min(17, h * 0.042)),
                                      weight: .semibold, design: .rounded))
                        .tracking(1.7)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .foregroundStyle(.secondary)
                    Rectangle().fill(theme.accent.opacity(0.78)).frame(width: max(12, w * 0.048), height: 1)
                }
                .frame(maxWidth: .infinity)

                HStack(alignment: .center, spacing: spacing) {
                    albumArtwork
                        .frame(width: coverSide, height: coverSide)
                    VStack(alignment: .leading, spacing: max(6, h * 0.025)) {
                        Text(music.title)
                            .font(.system(size: max(15, min(29, w * 0.038)),
                                          weight: .bold, design: .rounded))
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(.primary)
                        Text(music.artist)
                            .font(.system(size: max(11, min(17, w * 0.023)), weight: .medium))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        HStack(spacing: max(11, w * 0.035)) {
                            playbackButton("backward.end.fill", label: "Brano precedente",
                                           enabled: controlsAvailable) { music.previous() }
                            playbackButton(music.isPlaying ? "pause.fill" : "play.fill",
                                           label: music.isPlaying ? "Pausa" : "Riproduci",
                                           enabled: controlsAvailable, prominent: true) { music.togglePlayback() }
                            playbackButton("forward.end.fill", label: "Brano successivo",
                                           enabled: controlsAvailable) { music.next() }
                        }
                        .padding(.top, max(5, h * 0.028))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if !music.message.isEmpty {
                    Text(music.message)
                        .font(.system(size: max(10, min(13, h * 0.032))))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                HStack(spacing: 12) {
                    if provider == .apple && !music.appleAuthorized {
                        secondaryButton("Autorizza Apple Music", icon: "checkmark.shield") { music.requestAppleAccess() }
                    }
                    if provider == .spotify && !music.spotifyConnected {
                        secondaryButton("Collega Spotify", icon: "link") { music.connectSpotify() }
                    }
                    secondaryButton(provider == .youtube ? "Apri YouTube Music" : "Apri \(provider.rawValue)",
                                    icon: "arrow.up.right.square") { music.openSelectedApp() }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(width: max(1, w - 24), height: max(1, h - 18))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(width: w, height: h)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Lettore musicale \(provider.rawValue)")
        .onAppear { music.select(provider) }
        .onChange(of: providerName) { _, _ in music.select(provider) }
        .onReceive(Timer.publish(every: 3, on: .main, in: .common).autoconnect()) { _ in
            music.refresh()
        }
    }

    @ViewBuilder private var albumArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.ecoCard)
            if let cover = music.cover {
                Image(uiImage: cover)
                    .resizable()
                    .scaledToFill()
            } else if let url = music.coverURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        placeholderCover
                    }
                }
            } else {
                placeholderCover
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(theme.accent.opacity(0.48), lineWidth: 1)
        }
        .accessibilityLabel(music.cover == nil && music.coverURL == nil
                            ? "Copertina non disponibile" : "Copertina del brano")
    }

    private var placeholderCover: some View {
        Image(systemName: "music.note")
            .resizable()
            .scaledToFit()
            .padding(32)
            .foregroundStyle(theme.accent.opacity(0.8))
    }

    private func playbackButton(_ symbol: String, label: String, enabled: Bool,
                                prominent: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: prominent ? 25 : 19, weight: .semibold))
                .foregroundStyle(prominent ? Color.black : theme.accent)
                .frame(width: prominent ? 53 : 41, height: prominent ? 53 : 41)
                .background(prominent ? theme.accent : Color.ecoCard,
                            in: Circle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
        .accessibilityLabel(label)
    }

    private func secondaryButton(_ label: String, icon: String,
                                 action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(theme.accent)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(Color.ecoCard, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
