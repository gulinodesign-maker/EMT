import SwiftUI
import Combine
import UIKit

// Modalità persistente condivisa fra cruscotto, mappe e schermate tecniche.
enum EcoAppearanceMode: String, CaseIterable, Identifiable {
    case dark = "Scuro", light = "Chiaro", automatic = "Automatico"
    var id: String { rawValue }
    var preferredScheme: ColorScheme? {
        switch self {
        case .dark: .dark
        case .light: .light
        case .automatic: nil // segue l'aspetto e l'orario impostati su iOS
        }
    }
}

extension Color {
    static let ecoBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.026, green: 0.030, blue: 0.038, alpha: 1)
            : UIColor(red: 0.945, green: 0.957, blue: 0.975, alpha: 1)
    })
    static let ecoCard = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.095, green: 0.104, blue: 0.119, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    })
    static let ecoGreen = Color(red: 0.98, green: 0.48, blue: 0.08)
}

struct EcoCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 16))
    }
}

enum EcoTab: Int, CaseIterable, Identifiable {
    case gps, trips, battery, bms, settings, themes
    var id: Int { rawValue }
    var symbol: String {
        switch self {
        case .trips: "chart.bar.fill"
        case .gps: "point.topleft.down.curvedto.point.bottomright.up"
        case .battery: "battery.100percent"
        case .bms: "bluetooth"
        case .settings: "gearshape"
        case .themes: "paintpalette"
        }
    }
    var label: String {
        switch self {
        case .trips: "Viaggi"
        case .gps: "GPS"
        case .battery: "Batteria"
        case .bms: "BMS"
        case .settings: "Impostazioni"
        case .themes: "Kit colori"
        }
    }
}

// Geometria condivisa: i sette tasti e le quattro card hanno gli stessi bordi.
enum EcoCockpitDockGeometry {
    static func gap(width: CGFloat) -> CGFloat { width * 0.008 }
    static func rightInset(width: CGFloat) -> CGFloat { max(12, width * 0.018) }

    static func standardSide(width: CGFloat, height: CGFloat) -> CGFloat {
        let dial = min(height * 0.965, width * 0.55)
        let dialX = max(dial * 0.51 + width * 0.010, width * 0.168 + dial * 0.30)
        let safeLeft = dialX + dial * 0.50 + max(10, width * 0.010)
        let idealSide = min(max(51, min(83, height * 0.105)) * 0.96, width * 0.052)
        let available = width - rightInset(width: width) - safeLeft - 6 * gap(width: width)
        return min(idealSide, max(20, available / 7))
    }

    static func standardLeft(width: CGFloat, height: CGFloat) -> CGFloat {
        width - rightInset(width: width) - 7 * standardSide(width: width, height: height)
            - 6 * gap(width: width)
    }
}

struct EcojumboRootView: View {
    @Environment(\.colorScheme) private var systemAppearance
    @EnvironmentObject private var gps: GPSRideManager
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    @AppStorage("ecojumbo.theme") private var themeName = "Rame"
    @AppStorage("ecojumbo.appearanceMode") private var appearanceMode = EcoAppearanceMode.dark.rawValue
    @State private var selected: EcoTab = .gps
    @State private var lastMenu: EcoTab = .trips
    @AppStorage("ecojumbo.mapEnabled") private var mapEnabled = true
    @State private var tick = Date()
    // Il movimento fisico in portrait apre Impostazioni, anche con GPS bloccato landscape.

    private var theme: CockpitTheme { CockpitTheme(rawValue: themeName) ?? .copper }
    private var selectedAppearance: EcoAppearanceMode {
        EcoAppearanceMode(rawValue: appearanceMode) ?? .dark
    }
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let dockHeight = max(51, min(83, h * 0.105))
            // La barra resta SEMPRE dentro la finestra. Il margine in basso
            // riserva spazio anche alle zone home/safe-area landscape.
            let dockBottom = selected == .gps
                ? max(4, h * 0.006)
                : max(28, geometry.safeAreaInsets.bottom + 14, h * 0.055)
            let contentHeight = selected == .gps
                ? h : max(1, h - dockHeight - dockBottom - 10)
            // Non si disegna mai il tachimetro in un rettangolo verticale.
            // Il blocco landscape qui sotto mantiene invariata la build 57.
            if selected != .gps && w < h {
                portraitMenus(in: geometry)
            } else if selected == .gps && w < h {
                landscapeDashboardGuard(width: w, height: h)
            } else {
                ZStack(alignment: .topLeading) {
                    Group {
                        switch selected {
                    case .trips:
                        NavigationStack { TripsPanel() }
                    case .gps:
                        GPSCockpitDashboard(theme: theme, now: tick, mapEnabled: mapEnabled)
                    case .battery:
                        NavigationStack { CellsView() }
                    case .bms:
                        NavigationStack { BluetoothView() }
                    case .settings:
                        NavigationStack { EcoSettingsView() }
                    case .themes:
                        NavigationStack { ThemePickerView() }
                    }
                }
                .frame(width: w, height: contentHeight)
                .position(x: w / 2, y: contentHeight / 2)

                // Dock flottante, NON parte del contenuto scrollabile. La posizione
                // dipende dal bordo inferiore dello schermo, mai da padding esterni.
                CockpitCornerControls(selected: $selected, mapEnabled: $mapEnabled,
                                      appearanceMode: $appearanceMode, theme: theme,
                                      screenHeight: h)
                    .frame(width: w, height: dockHeight)
                    .position(x: w / 2, y: h - dockBottom - dockHeight / 2)
                    .zIndex(50)
                }
                .frame(width: w, height: h)
                .background(Color.ecoBackground)
            }
        }
        .ignoresSafeArea(.container, edges: .all)
        .background(Color.ecoBackground.ignoresSafeArea())
        .statusBarHidden(true)
        .preferredColorScheme(selectedAppearance.preferredScheme)
        .onAppear {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            EcojumboOrientationPolicy.update(for: selected, force: true)
            gps.start()
            bluetooth.applyFormat(JKFrameFormat(rawValue: UserDefaults.standard.string(forKey: "ecojumbo.frameFormat") ?? "Automatico") ?? .automatic,
                                  cells: UserDefaults.standard.integer(forKey: "ecojumbo.cellCount") == 0 ? 20 : UserDefaults.standard.integer(forKey: "ecojumbo.cellCount"))
        }
        .onChange(of: selected) { _, newTab in
            if newTab != .gps { lastMenu = newTab }
            EcojumboOrientationPolicy.update(for: newTab)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            // La notifica fisica funziona anche quando UIKit blocca il GPS in landscape.
            if selected == .gps && UIDevice.current.orientation == .portrait {
                selected = .settings
            }
        }
        .onDisappear {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        .onReceive(bluetooth.$snapshot) { snapshot in
            if snapshot != nil { bluetooth.session.observeDistance(gps.tripKm) }
        }
        .onReceive(gps.$tripKm) { km in
            if bluetooth.snapshot != nil { bluetooth.session.observeDistance(km) }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { newDate in
            tick = newDate
        }
    }

    // Le pagine di servizio usano NavigationStack e scorrono normalmente.
    // Il dock portrait è separato dal cockpit landscape originale.
    private func portraitMenus(in geometry: GeometryProxy) -> some View {
        let insets = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero

        return VStack(spacing: 0) {
            portraitMenuPage
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            PortraitServiceTabBar(selected: $selected, theme: theme)
        }
        .padding(.top, max(16, geometry.safeAreaInsets.top, insets.top))
        .padding(.bottom, max(8, geometry.safeAreaInsets.bottom, insets.bottom))
        .frame(width: geometry.size.width, height: geometry.size.height)
        .background(Color.ecoBackground)
    }

    @ViewBuilder private var portraitMenuPage: some View {
        switch selected {
        case .gps:
            EmptyView()
        case .trips:
            NavigationStack { TripsPanel() }
        case .battery:
            NavigationStack { CellsView(portrait: true) }
        case .bms:
            NavigationStack { BluetoothView() }
        case .settings:
            NavigationStack { EcoSettingsView() }
        case .themes:
            NavigationStack { ThemePickerView(portrait: true) }
        }
    }

    // Se UIKit non può ruotare immediatamente, nessun quadrante viene
    // deformato: questo stato temporaneo resta navigabile.
    private func landscapeDashboardGuard(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 18) {
            Image(systemName: "iphone.landscape")
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(theme.accent)
            Text("Tachimetro in orizzontale")
                .font(.title2.bold())
            Text("Ruota l'iPhone per aprire il cruscotto GPS.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                selected = lastMenu
            } label: {
                Label("Torna ai menù", systemImage: "arrow.left")
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.accent)
        }
        .padding(24)
        .frame(width: width, height: height)
        .background(Color.ecoBackground)
    }

}


// Trattamento condiviso: icone piatte, etichette brevi e colore attivo.
// Nessuna sfumatura, rilievo o bordo lucido.
private struct EcoMinimalNavigationLabel: View {
    let symbol: String
    let title: String
    let active: Bool
    let theme: CockpitTheme
    let iconSize: CGFloat
    let captionSize: CGFloat

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: symbol)
                .font(.system(size: iconSize, weight: .semibold))
                .frame(height: iconSize + 2)
            Text(title)
                .font(.system(size: captionSize, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(active ? theme.accent : Color.secondary)
        .frame(maxWidth: .infinity)
    }
}

// Dock solo per i menu portrait: non compare mai sopra il tachimetro.
private struct PortraitServiceTabBar: View {
    @Binding var selected: EcoTab
    let theme: CockpitTheme

    var body: some View {
        HStack(spacing: 2) {
            ForEach([EcoTab.gps, .trips, .settings, .themes]) { tab in
                Button { selected = tab } label: {
                    EcoMinimalNavigationLabel(
                        symbol: tab == .gps ? "speedometer" : tab.symbol,
                        title: tab == .gps ? "Cockpit" :
                            (tab == .settings ? "Setup" :
                             (tab == .themes ? "Temi" : tab.label)),
                        active: selected == tab,
                        theme: theme,
                        iconSize: 20,
                        captionSize: 10
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab == .gps ? "Tachimetro GPS" : tab.label)
                .accessibilityAddTraits(selected == tab ? .isSelected : [])
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .background(Color.ecoCard)
        .overlay(alignment: .top) {
            Rectangle().fill(theme.accent.opacity(0.35)).frame(height: 1)
        }
    }
}

// Cockpit di guida con comandi essenziali a destra.
// Batteria e BMS sono disponibili sotto Setup, non nel dock del tachimetro.
@MainActor
private struct CockpitCornerControls: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var gps: GPSRideManager
    @StateObject private var mapControls = GPSMapControlStore.shared
    @StateObject private var navigation = EcoNavigationStore.shared
    @Binding var selected: EcoTab
    @Binding var mapEnabled: Bool
    @Binding var appearanceMode: String
    let theme: CockpitTheme
    let screenHeight: CGFloat

    private var isDay: Bool {
        let preference = EcoAppearanceMode(rawValue: appearanceMode)?.preferredScheme
        return (preference ?? colorScheme) == .light
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let buttonSide = min(height * 0.96, width * 0.059)
            let gpsSide = (mapEnabled && selected == .gps)
                ? min(buttonSide, width * 0.052)
                : EcoCockpitDockGeometry.standardSide(width: width, height: screenHeight)
            let gpsGap = width * 0.008
            // Stessa larghezza e margini della telemetria del cockpit GPS.
            // Con mappa nascosta i cinque tasti sono giustificati sui due bordi;
            // gli otto comandi della mappa e i menù mantengono il layout esistente.
            let telemetryDock = selected == .gps && !mapEnabled
            let telemetryPanelLeft = EcoCockpitDockGeometry.standardLeft(width: width, height: screenHeight)
            let telemetryPanelWidth = max(1, width - EcoCockpitDockGeometry.rightInset(width: width)
                                               - telemetryPanelLeft)
            let justifiedGap = max(0, (telemetryPanelWidth - 5 * gpsSide) / 4)
            HStack(alignment: .center, spacing: 0) {
                // Tachimetro: dock a destra. Altri menu: gruppo centrato.
                Spacer(minLength: 0)
                HStack(spacing: telemetryDock ? justifiedGap : gpsGap) {
                    gpsButton("map.fill", active: mapEnabled,
                              accessibility: mapEnabled ? "Disattiva la mappa" : "Attiva la mappa",
                              side: gpsSide) {
                        if selected == .gps { mapEnabled.toggle() }
                        selected = .gps
                    }
                    if mapEnabled && selected == .gps {
                        gpsButton("play.fill", alternate: "stop.fill",
                                  active: navigation.isNavigating,
                                  enabled: navigation.isNavigating ||
                                      (navigation.route != nil && gps.currentCoordinate() != nil),
                                  accessibility: navigation.isNavigating
                                      ? "Ferma navigazione GPS" : "Avvia navigazione GPS",
                                  side: gpsSide) { mapControls.send(.toggleNavigation) }
                        gpsButton("square.3.layers.3d", text: mapControls.is3D ? "2D" : "3D",
                                  active: mapControls.is3D,
                                  accessibility: mapControls.is3D
                                      ? "Passa alla mappa 2D" : "Passa alla mappa 3D",
                                  side: gpsSide) { mapControls.send(.toggleProjection) }
                        gpsButton("location.north.line.fill", active: mapControls.headingUp,
                                  accessibility: "Vista dal muso dello scooter, direzione di marcia",
                                  side: gpsSide) { mapControls.send(.noseView) }
                        gpsButton("scope", accessibility: "Ricentra sulla posizione GPS",
                                  side: gpsSide) { mapControls.send(.recenter) }
                        gpsButton("plus.magnifyingglass", accessibility: "Ingrandisci la mappa",
                                  side: gpsSide) { mapControls.send(.zoomIn) }
                        gpsButton("minus.magnifyingglass", accessibility: "Riduci zoom mappa",
                                  side: gpsSide) { mapControls.send(.zoomOut) }
                    } else {
                        ForEach([EcoTab.trips, .settings, .themes]) { tab in
                            iconButton(tab, side: gpsSide)
                        }
                    }
                    gpsButton(isDay ? "moon.stars.fill" : "sun.max.fill",
                              accessibility: isDay ? "Attiva modalità scura" : "Attiva modalità chiara",
                              side: gpsSide) {
                        appearanceMode = isDay
                            ? EcoAppearanceMode.dark.rawValue
                            : EcoAppearanceMode.light.rawValue
                    }
                }
                .frame(width: telemetryDock ? telemetryPanelWidth : nil, alignment: .leading)
                if selected != .gps {
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, max(12, width * 0.018))
            .frame(width: width, height: height)
        }
    }

    private func iconButton(_ tab: EcoTab, side: CGFloat) -> some View {
        Button { selected = selected == tab ? .gps : tab } label: {
            EcoMinimalNavigationLabel(
                symbol: tab.symbol,
                title: tab == .settings ? "Setup" :
                    (tab == .themes ? "Temi" : tab.label),
                active: selected == tab,
                theme: theme,
                iconSize: min(20, side * 0.43),
                captionSize: max(9, min(10, side * 0.20))
            )
            .frame(width: side, height: side)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(tab == selected ? .isSelected : [])
    }

    // Stesso design portrait; azioni, dimensioni e ordine GPS invariati.
    private func gpsButton(_ symbol: String, alternate: String? = nil,
                           text: String? = nil, active: Bool = false,
                           enabled: Bool = true, accessibility: String,
                           side: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            EcoMinimalNavigationLabel(
                symbol: active ? (alternate ?? symbol) : symbol,
                title: text ?? gpsCaption(for: symbol),
                active: active,
                theme: theme,
                iconSize: min(20, side * 0.43),
                captionSize: max(9, min(10, side * 0.20))
            )
            .frame(width: side, height: side)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.45)
        .accessibilityLabel(accessibility)
        .accessibilityAddTraits(active ? [.isSelected] : [])
    }

    private func gpsCaption(for symbol: String) -> String {
        switch symbol {
        case "map.fill": "Mappa"
        case "play.fill": "Naviga"
        case "location.north.line.fill": "Direz."
        case "scope": "Centra"
        case "plus.magnifyingglass": "Zoom +"
        case "minus.magnifyingglass": "Zoom −"
        case "moon.stars.fill", "sun.max.fill": "Tema"
        default: ""
        }
    }

}


/// EJ 1.19: stesso raggio di curvatura della top bar, lati inferiori meno inclinati.
/// I due terminali sono segmenti RETTI e non proseguono sotto i pulsanti.
struct ContinuousLowerLine: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let controlsHeight = max(51, min(83, h * 0.105))
        let buttonSide = min(controlsHeight * 0.96, w * 0.059)
        let groupEnd = max(12, w * 0.018) + 4 * buttonSide + 3 * w * 0.010
        let footX = min(CGFloat(0.342), max(CGFloat(0.323), groupEnd / w + 0.035))
        let leftFoot = CGPoint(x: w * footX, y: h * 0.985)
        let rightFoot = CGPoint(x: w * (1 - footX), y: h * 0.985)
        return CockpitContourGeometry.roundedPath(points: [
            leftFoot,
            CGPoint(x: w * 0.385, y: h * 0.790),
            CGPoint(x: w * 0.615, y: h * 0.790),
            rightFoot
        ], corners: [1, 2], radius: CockpitContourGeometry.cornerRadius(in: rect.size))
    }
}

// Ombreggiatura neutra e discreta sotto il profilo A/kW.
// La maschera segue il profilo originale: nessuna banda sotto i pulsanti.
private struct LowerPanelShade: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let controlsHeight = max(51, min(83, h * 0.105))
        let buttonSide = min(controlsHeight * 0.96, w * 0.059)
        let groupEnd = max(12, w * 0.018) + 4 * buttonSide + 3 * w * 0.010
        let footX = min(CGFloat(0.342), max(CGFloat(0.323), groupEnd / w + 0.035))
        var p = ContinuousLowerLine().path(in: rect)
        p.addLine(to: CGPoint(x: w * (1 - footX), y: h))
        p.addLine(to: CGPoint(x: w * footX, y: h))
        p.closeSubpath()
        return p
    }
}

// Maschera equivalente al ponte GPS: solo i due terminali della
// linea arancione scompaiono gradualmente, non l'intero contorno.
private struct ContinuousLowerTerminalFade: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let controlsHeight = max(51, min(83, h * 0.105))
            let buttonSide = min(controlsHeight * 0.96, w * 0.059)
            // Si conserva esattamente la geometria della build 29.
            let groupEnd = max(12, w * 0.018) + 4 * buttonSide + 3 * w * 0.010
            let footX = min(CGFloat(0.342), max(CGFloat(0.323),
                                              groupEnd / w + 0.035))
            LinearGradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .white, location: 0.17),
                .init(color: .white, location: 0.83),
                .init(color: .clear, location: 1)
            ], startPoint: UnitPoint(x: footX, y: 0.5),
               endPoint: UnitPoint(x: 1 - footX, y: 0.5))
        }
    }
}

struct ContinuousLowerGlow: View {
    let theme: CockpitTheme
    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            ZStack {
                LowerPanelShade()
                    .fill(LinearGradient(stops: [
                        .init(color: .clear, location: 0.72),
                        .init(color: Color(white: 0.29).opacity(0.24), location: 0.81),
                        .init(color: Color(white: 0.16).opacity(0.17), location: 0.93),
                        .init(color: .clear, location: 1.0)
                    ], startPoint: .top, endPoint: .bottom))
                ZStack {
                    ContinuousLowerLine()
                        .stroke(theme.accent.opacity(0.33),
                                style: StrokeStyle(lineWidth: max(4, h * 0.018), lineCap: .round))
                        .blur(radius: max(3, h * 0.017))
                    ContinuousLowerLine()
                        .stroke(theme.accent.opacity(0.76),
                                style: StrokeStyle(lineWidth: max(2.5, h * 0.007), lineCap: .round))
                        .blur(radius: max(1.5, h * 0.005))
                    ContinuousLowerLine()
                        .stroke(LinearGradient(stops: [
                            .init(color: theme.accent, location: 0),
                            .init(color: theme.accent.opacity(0.94), location: 0.25),
                            .init(color: theme.accent.opacity(0.97), location: 0.50),
                            .init(color: theme.accent.opacity(0.94), location: 0.75),
                            .init(color: theme.accent, location: 1)
                        ], startPoint: .leading, endPoint: .trailing),
                                style: StrokeStyle(lineWidth: max(1.2, h * 0.004), lineCap: .round))
                }
                .mask(ContinuousLowerTerminalFade())
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .accessibilityHidden(true)
    }
}
