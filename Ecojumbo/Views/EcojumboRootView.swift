import SwiftUI
import Combine
import UIKit

// Colori dell'interfaccia tecnica secondaria: quelli del cockpit sono modificabili.
extension Color {
    static let ecoBackground = Color(red: 0.026, green: 0.030, blue: 0.038)
    static let ecoCard = Color(red: 0.095, green: 0.104, blue: 0.119)
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
    case dashboard, trips, routes, battery, bms, maps, settings, themes
    var id: Int { rawValue }
    var symbol: String {
        switch self {
        case .dashboard: "gauge.with.dots.needle.67percent"
        case .trips: "chart.bar.fill"
        case .routes: "point.topleft.down.curvedto.point.bottomright.up"
        case .battery: "battery.100percent"
        case .bms: "bluetooth"
        case .maps: "location.north.line.fill"
        case .settings: "gearshape"
        case .themes: "paintpalette"
        }
    }
    var label: String {
        switch self {
        case .dashboard: "Cruscotto"
        case .trips: "Viaggi"
        case .routes: "Percorsi"
        case .battery: "Batteria"
        case .bms: "BMS"
        case .maps: "Navigazione Google Maps"
        case .settings: "Impostazioni"
        case .themes: "Kit colori"
        }
    }
}

struct EcojumboRootView: View {
    @EnvironmentObject private var gps: GPSRideManager
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    @AppStorage("ecojumbo.theme") private var themeName = "Rame"
    @State private var selected: EcoTab = .dashboard
    @State private var tick = Date()

    private var theme: CockpitTheme { CockpitTheme(rawValue: themeName) ?? .copper }
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Group {
                    switch selected {
                    case .dashboard:
                        CockpitDashboard(theme: theme, now: tick)
                    case .trips:
                        NavigationStack { TripsPanel() }
                    case .routes:
                        NavigationStack { RoutesPanel() }
                    case .battery:
                        NavigationStack { CellsView() }
                    case .bms:
                        NavigationStack { BluetoothView() }
                    case .maps:
                        NavigationStack { GoogleMapsPanel() }
                    case .settings:
                        NavigationStack { EcoSettingsView() }
                    case .themes:
                        NavigationStack { ThemePickerView() }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .padding(.bottom, selected == .dashboard ? 0 : 56)

                // Profilo luminoso SOLO sopra il gruppo A/kW, con due discese laterali.
                // Nessuna linea orizzontale prosegue sotto i tasti funzione.
                if selected == .dashboard {
                    ContinuousLowerGlow(theme: theme)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .allowsHitTesting(false)
                        .zIndex(45)
                }

                // Otto comandi reali, indipendenti e divisi ai due angoli inferiori;
                // niente barra piena che schiaccia il tachimetro in landscape.
                CockpitCornerControls(selected: $selected, theme: theme)
                    .frame(width: geometry.size.width,
                           height: max(51, min(83, geometry.size.height * 0.105)))
                    .padding(.bottom, max(7, geometry.size.height * 0.075))
                    .zIndex(50)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
        }
        .ignoresSafeArea(.container, edges: .all)
        .background(Color.black.ignoresSafeArea())
        .statusBarHidden(true)
        .preferredColorScheme(.dark)
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

// EJ 1.08: due gruppi da quattro pulsanti metallici nell'angolo inferiore,
// con icone solo bianche, senza titoli; il tachimetro occupa tutto lo spazio centrale.
private struct CockpitCornerControls: View {
    @Binding var selected: EcoTab
    let theme: CockpitTheme

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let buttonSide = min(height * 0.96, width * 0.059)
            let gap = width * 0.010
            HStack(alignment: .center, spacing: 0) {
                HStack(spacing: gap) {
                    ForEach(EcoTab.allCases.prefix(4)) { tab in
                        iconButton(tab, side: buttonSide)
                    }
                }
                Spacer(minLength: 0)
                HStack(spacing: gap) {
                    ForEach(EcoTab.allCases.suffix(4)) { tab in
                        iconButton(tab, side: buttonSide)
                    }
                }
            }
            .padding(.horizontal, max(12, width * 0.018))
            .frame(width: width, height: height)
        }
    }

    private func iconButton(_ tab: EcoTab, side: CGFloat) -> some View {
        Button { selected = tab } label: {
            ZStack {
                RoundedRectangle(cornerRadius: side * 0.23, style: .continuous)
                    .fill(LinearGradient(stops: [
                        .init(color: Color(white: 0.37), location: 0),
                        .init(color: Color(white: 0.19), location: 0.21),
                        .init(color: Color(white: 0.08), location: 0.78),
                        .init(color: Color(white: 0.14), location: 1)
                    ], startPoint: .top, endPoint: .bottom))
                RoundedRectangle(cornerRadius: side * 0.23, style: .continuous)
                    .stroke(LinearGradient(colors: [
                        selected == tab ? theme.accent : .white.opacity(0.80),
                        .white.opacity(0.13),
                        selected == tab ? theme.accent.opacity(0.80) : .white.opacity(0.38)
                    ], startPoint: .top, endPoint: .bottom), lineWidth: selected == tab ? 1.6 : 0.9)
                if tab == .bms {
                    BluetoothGlyph()
                        .frame(width: side * 0.42, height: side * 0.57)
                } else {
                    Image(systemName: tab.symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: side * 0.57, height: side * 0.55)
                        .foregroundStyle(.white)
                }
            }
            .frame(width: side, height: side)
            .shadow(color: .black.opacity(0.90), radius: side * 0.16, y: 2)
            .shadow(color: selected == tab ? theme.accent.opacity(0.31) : .clear, radius: 5)
            .contentShape(RoundedRectangle(cornerRadius: side * 0.23))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(tab == selected ? .isSelected : [])
    }
}


/// EJ 1.17 — smussatura AMPIA solo negli angoli SUPERIORI di A / kW.
/// Lati inferiori rettilinei, estremita nette; nessuna linea sotto i tasti.
/// Tangente cubica C1 ai lati retti e al tratto orizzontale centrale.
struct ContinuousLowerLine: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: w * x, y: h * y)
        }
        let controlsHeight = max(51, min(83, h * 0.105))
        let buttonSide = min(controlsHeight * 0.96, w * 0.059)
        let groupEnd = max(12, w * 0.018) + 4 * buttonSide + 3 * w * 0.010
        let footX = min(CGFloat(0.320), max(CGFloat(0.272), groupEnd / w + 0.013))
        let shoulderX: CGFloat = 0.353
        let tangentX = shoulderX + (shoulderX - footX) * 0.16
        var p = Path()
        p.move(to: pt(footX, 0.987))
        p.addLine(to: pt(shoulderX, 0.805))
        p.addCurve(to: pt(0.412, 0.740),
                   control1: pt(tangentX, 0.77588), control2: pt(0.384, 0.740))
        p.addLine(to: pt(0.588, 0.740))
        p.addCurve(to: pt(1 - shoulderX, 0.805),
                   control1: pt(0.616, 0.740), control2: pt(1 - tangentX, 0.77588))
        p.addLine(to: pt(1 - footX, 0.987))
        return p
    }
}

struct ContinuousLowerGlow: View {
    let theme: CockpitTheme
    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
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
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .accessibilityHidden(true)
    }
}
