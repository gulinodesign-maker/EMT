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

// Geometria condivisa: i sette tasti e le sei card hanno gli stessi bordi.
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
    @AppStorage("ecojumbo.mapEnabled") private var mapEnabled = true
    @State private var tick = Date()

    private var theme: CockpitTheme { CockpitTheme(rawValue: themeName) ?? .copper }
    private var selectedAppearance: EcoAppearanceMode {
        EcoAppearanceMode(rawValue: appearanceMode) ?? .dark
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
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
                .frame(width: geometry.size.width, height: geometry.size.height)
                .padding(.bottom, selected == .gps ? 0 : max(110, geometry.size.height * 0.18))

                // Il cockpit GPS è unico: il dock controlla mappa, sezioni e aspetto.
                CockpitCornerControls(selected: $selected, mapEnabled: $mapEnabled,
                                      appearanceMode: $appearanceMode, theme: theme,
                                      screenHeight: geometry.size.height)
                    .frame(width: geometry.size.width,
                           height: max(51, min(83, geometry.size.height * 0.105)))
                    .padding(.bottom, selected == .gps
                              ? max(4, geometry.size.height * 0.006)
                              : max(30, geometry.size.height * 0.055))
                    .zIndex(50)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.ecoBackground)
        }
        .ignoresSafeArea(.container, edges: .all)
        .background(Color.ecoBackground.ignoresSafeArea())
        .statusBarHidden(true)
        .preferredColorScheme(selectedAppearance.preferredScheme)
        .onAppear {
            gps.start()
            bluetooth.applyFormat(JKFrameFormat(rawValue: UserDefaults.standard.string(forKey: "ecojumbo.frameFormat") ?? "Automatico") ?? .automatic,
                                  cells: UserDefaults.standard.integer(forKey: "ecojumbo.cellCount") == 0 ? 20 : UserDefaults.standard.integer(forKey: "ecojumbo.cellCount"))
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
}

// Build 41: un solo cockpit, con mappa attivabile e comandi sempre a destra.
// Quando la mappa è nascosta tornano i cinque pulsanti delle sezioni tecniche.
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
            HStack(alignment: .center, spacing: 0) {
                Spacer(minLength: 0)
                HStack(spacing: gpsGap) {
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
                        ForEach([EcoTab.trips, .battery, .bms, .settings, .themes]) { tab in
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
            }
            .padding(.horizontal, max(12, width * 0.018))
            .frame(width: width, height: height)
        }
    }

    private func iconButton(_ tab: EcoTab, side: CGFloat) -> some View {
        Button { selected = selected == tab ? .gps : tab } label: {
            ZStack {
                RoundedRectangle(cornerRadius: side * 0.23, style: .continuous)
                    .fill(LinearGradient(stops: [
                        .init(color: colorScheme == .light ? .white : Color(white: 0.37), location: 0),
                        .init(color: colorScheme == .light ? Color(white: 0.96) : Color(white: 0.19), location: 0.21),
                        .init(color: colorScheme == .light ? Color(white: 0.92) : Color(white: 0.08), location: 0.78),
                        .init(color: colorScheme == .light ? Color(white: 0.84) : Color(white: 0.14), location: 1)
                    ], startPoint: .top, endPoint: .bottom))
                RoundedRectangle(cornerRadius: side * 0.23, style: .continuous)
                    .stroke(LinearGradient(colors: [
                        selected == tab ? theme.accent : (colorScheme == .light ? Color.black.opacity(0.16) : .white.opacity(0.80)),
                        .white.opacity(0.13),
                        selected == tab ? theme.accent.opacity(0.80) : (colorScheme == .light ? Color.black.opacity(0.10) : .white.opacity(0.38))
                    ], startPoint: .top, endPoint: .bottom), lineWidth: selected == tab ? 1.6 : 0.9)
                if tab == .bms {
                    BluetoothGlyph()
                        .frame(width: side * 0.42, height: side * 0.57)
                } else {
                    Image(systemName: tab.symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: side * 0.57, height: side * 0.55)
                        .foregroundStyle(colorScheme == .light ? Color(white: 0.16) : .white)
                }
            }
            .frame(width: side, height: side)


            .contentShape(RoundedRectangle(cornerRadius: side * 0.23))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(tab == selected ? .isSelected : [])
    }
    // Stessa finitura, bordo, altezza e ombreggiatura del tasto Home.
    private func gpsButton(_ symbol: String, alternate: String? = nil,
                           text: String? = nil, active: Bool = false,
                           enabled: Bool = true, accessibility: String,
                           side: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: side * 0.23, style: .continuous)
                    .fill(LinearGradient(stops: [
                        .init(color: colorScheme == .light ? .white : Color(white: 0.37), location: 0),
                        .init(color: colorScheme == .light ? Color(white: 0.96) : Color(white: 0.19), location: 0.21),
                        .init(color: colorScheme == .light ? Color(white: 0.92) : Color(white: 0.08), location: 0.78),
                        .init(color: colorScheme == .light ? Color(white: 0.84) : Color(white: 0.14), location: 1)
                    ], startPoint: .top, endPoint: .bottom))
                RoundedRectangle(cornerRadius: side * 0.23, style: .continuous)
                    .stroke(LinearGradient(colors: [
                        active ? theme.accent : (colorScheme == .light ? Color.black.opacity(0.16) : .white.opacity(0.80)),
                        .white.opacity(0.13),
                        active ? theme.accent.opacity(0.80) : (colorScheme == .light ? Color.black.opacity(0.10) : .white.opacity(0.38))
                    ], startPoint: .top, endPoint: .bottom),
                            lineWidth: active ? 1.6 : 0.9)
                if let text {
                    Text(text)
                        .font(.system(size: side * 0.28, weight: .heavy, design: .rounded))
                        .foregroundStyle(colorScheme == .light ? Color(white: 0.16) : .white)
                } else {
                    Image(systemName: active ? (alternate ?? symbol) : symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: side * 0.55, height: side * 0.55)
                        .foregroundStyle(colorScheme == .light ? Color(white: 0.16) : .white)
                }
            }
            .frame(width: side, height: side)


            .contentShape(RoundedRectangle(cornerRadius: side * 0.23))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.68)
        .accessibilityLabel(accessibility)
        .accessibilityAddTraits(active ? [.isSelected] : [])
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
