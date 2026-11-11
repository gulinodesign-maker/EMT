import SwiftUI
import MapKit
import Combine
import UIKit
import CoreText
import Darwin


// EJ 1.24 — temperatura esterna da dati meteo, NON dal telefono.
// Open-Meteo: temperatura a 2 metri; inviamo soltanto coordinate arrotondate
// a 0,01 gradi (~1 km), con cache di 15 minuti e fonte attribuita.
@MainActor
final class EcoOutsideWeather: ObservableObject {
    static let shared = EcoOutsideWeather()

    @Published private(set) var temperatureC: Double?
    @Published private(set) var updatedAt: Date?

    private var lastRequestAt: Date?
    private var lastRequestedPosition: CLLocation?
    private var isLoading = false

    private struct WeatherReply: Decodable {
        struct Current: Decodable {
            let temperature_2m: Double
        }
        let current: Current
    }

    private init() {}

    func refreshIfNeeded(at coordinate: CLLocationCoordinate2D?) {
        guard let coordinate, CLLocationCoordinate2DIsValid(coordinate) else { return }
        guard !isLoading else { return }
        let date = Date()
        let approximate = CLLocation(latitude: (coordinate.latitude * 100).rounded() / 100,
                                     longitude: (coordinate.longitude * 100).rounded() / 100)
        if let lastRequestAt, let lastRequestedPosition,
           date.timeIntervalSince(lastRequestAt) < 15 * 60,
           approximate.distance(from: lastRequestedPosition) < 5_000 { return }

        isLoading = true
        lastRequestAt = date
        lastRequestedPosition = approximate
        Task { await fetchTemperature(latitude: approximate.coordinate.latitude,
                                      longitude: approximate.coordinate.longitude) }
    }

    private func fetchTemperature(latitude: Double, longitude: Double) async {
        defer { isLoading = false }
        var url = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        url?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m"),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "forecast_days", value: "1")
        ]
        guard let endpoint = url?.url else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: endpoint)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return }
            let result = try JSONDecoder().decode(WeatherReply.self, from: data)
            guard result.current.temperature_2m.isFinite,
                  (-90...65).contains(result.current.temperature_2m) else { return }
            temperatureC = result.current.temperature_2m
            updatedAt = Date()
        } catch {
            // Niente temperature ipotetiche in caso di errore o mancanza di rete.
        }
    }
}

@MainActor
private struct EcoOutsideTemperature: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var gps: GPSRideManager
    @StateObject private var weather = EcoOutsideWeather.shared
    let now: Date

    private var currentTemperature: Double? {
        guard gps.currentCoordinate(at: now) != nil,
              let updatedAt = weather.updatedAt,
              now.timeIntervalSince(updatedAt) >= 0,
              now.timeIntervalSince(updatedAt) < 60 * 60 else { return nil }
        return weather.temperatureC
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "thermometer.medium")
                .foregroundStyle(colorScheme == .light ? Color(white: 0.22) : Color.white.opacity(0.82))
            Text(currentTemperature.map { String(format: "%.0f°C", $0) } ?? "—°C")
                .monospacedDigit()
                .foregroundStyle(colorScheme == .light ? Color(white: 0.14) : .white)
        }
        .font(.system(size: 15, weight: .semibold))
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(colorScheme == .light ? Color.white.opacity(0.85) : Color.black.opacity(0.58),
                    in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(currentTemperature.map {
            "Temperatura esterna: \(Int($0.rounded())) gradi Celsius."
        } ?? "Temperatura esterna non disponibile. Serve GPS e connessione Internet.")
        .onAppear {
            weather.refreshIfNeeded(at: gps.currentCoordinate(at: now))
        }
        .onReceive(gps.$lastGPSCoordinate) { _ in
            weather.refreshIfNeeded(at: gps.currentCoordinate())
        }
    }
}

// EJ 1.19 — raccordi top/down bar a raggio identico; schede sinistre speculari.
// Geometry, rings, numerals and panels are real SwiftUI controls (no reference bitmap as UI).
// Misure esclusivamente da Core Location / JK BLE, senza campioni sintetici.
enum CockpitTheme: String, CaseIterable, Identifiable {
    // Sei kit colore persistenti: due righe per tre colonne nel menu.
    case copper = "Rame"
    case glacier = "Ghiaccio"
    case green = "Verde"
    case aquamarine = "Acquamarina"
    case brown = "Marrone"
    case racing = "Racing"

    var id: String { rawValue }
    var accent: Color {
        switch self {
        case .copper: Color(red: 1.00, green: 0.44, blue: 0.03)
        case .glacier: Color(red: 0.69, green: 0.88, blue: 0.98)
        case .green: Color(red: 0.26, green: 0.86, blue: 0.41)
        case .aquamarine: Color(red: 0.28, green: 0.88, blue: 0.81)
        case .brown: Color(red: 0.73, green: 0.43, blue: 0.22)
        case .racing: Color(red: 0.97, green: 0.23, blue: 0.22)
        }
    }
    var secondary: Color {
        switch self {
        case .copper: Color(red: 0.75, green: 0.24, blue: 0.09)
        case .glacier: Color(red: 0.19, green: 0.51, blue: 0.73)
        case .green: Color(red: 0.10, green: 0.48, blue: 0.26)
        case .aquamarine: Color(red: 0.10, green: 0.47, blue: 0.49)
        case .brown: Color(red: 0.37, green: 0.19, blue: 0.12)
        case .racing: Color(red: 0.63, green: 0.09, blue: 0.15)
        }
    }
    var steel: Color { Color(red: 0.85, green: 0.87, blue: 0.89) }
    var shadowAccent: Color { accent.opacity(0.68) }
    static let barDark = Color(red: 0.55, green: 0.02, blue: 0.13)
    static let barMid = Color(red: 0.91, green: 0.06, blue: 0.23)
    static let barBright = Color(red: 0.99, green: 0.20, blue: 0.32)
    static let regenAccent = Color(red: 0.17, green: 0.73, blue: 1.00)
    static let dischargeAccent = Color(red: 0.98, green: 0.17, blue: 0.18)
    var previewPalette: [Color] {
        // Fondo carbonio, luce, ombra, acciaio e tutte e tre le tinte della barra più la rigenerazione.
        [Color(red: 0.015, green: 0.016, blue: 0.019),
         accent, secondary, steel, Self.barDark, Self.barMid, Self.barBright, Self.regenAccent]
    }
}

// Le due barre arancioni usano l'identico raggio in punti, non solo una curva simile.
// Path.addArc(...) imposta archi circolari tangenti ai segmenti, senza gradini.
enum CockpitContourGeometry {
    static func cornerRadius(in size: CGSize) -> CGFloat {
        min(size.height * 0.075, size.width * 0.032)
    }

    static func roundedPath(points: [CGPoint], corners: Set<Int>, radius: CGFloat) -> Path {
        var path = Path()
        guard points.count >= 2 else { return path }
        path.move(to: points[0])
        for i in 1..<(points.count - 1) {
            if corners.contains(i) {
                path.addArc(tangent1End: points[i], tangent2End: points[i + 1], radius: radius)
            } else {
                path.addLine(to: points[i])
            }
        }
        path.addLine(to: points[points.count - 1])
        return path
    }
}

// Carbonio reale come texture ripetuta, indipendente dalle metriche e dalle preferenze.
private struct CarbonBackdrop: View {
    @Environment(\.colorScheme) private var colorScheme
    let theme: CockpitTheme
    var body: some View {
        GeometryReader { geo in
            ZStack {
                colorScheme == .light
                    ? Color(red: 0.94, green: 0.96, blue: 0.985)
                    : Color(red: 0.015, green: 0.016, blue: 0.019)
                Image("CarbonWeave")
                    .resizable(resizingMode: .tile)
                    .opacity(colorScheme == .light ? 0.08 : 0.52)
                LinearGradient(colors: colorScheme == .light
                    ? [Color.white.opacity(0.45), .clear, Color(red: 0.75, green: 0.80, blue: 0.88).opacity(0.25)]
                    : [.black.opacity(0.55), .clear, .black.opacity(0.70)],
                    startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: colorScheme == .light
                    ? [theme.accent.opacity(0.07), .clear, .white.opacity(0.08)]
                    : [theme.secondary.opacity(0.14), .clear, .black.opacity(0.56)],
                    center: .center, startRadius: 0,
                    endRadius: max(geo.size.width, geo.size.height) * 0.62)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
    }
}

// EJ 1.23 — sfumatura grigio antracite SOPRA la top bar, presente in entrambe le
// modalità e indipendente dal tema colore selezionato.
private struct CockpitTopSoftShade: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        GeometryReader { geo in
            LinearGradient(stops: [
                .init(color: colorScheme == .light ? Color.white.opacity(0.83) : Color(white: 0.30).opacity(0.38), location: 0),
                .init(color: colorScheme == .light ? Color.white.opacity(0.34) : Color(white: 0.23).opacity(0.26), location: 0.48),
                .init(color: colorScheme == .light ? Color.white.opacity(0.08) : Color(white: 0.14).opacity(0.08), location: 0.82),
                .init(color: .clear, location: 1)
            ], startPoint: .top, endPoint: .bottom)
            .frame(width: geo.size.width, height: geo.size.height * 0.125,
                   alignment: .top)
            .frame(width: geo.size.width, height: geo.size.height,
                   alignment: .top)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// Un'unica ala per lato; bordo morbido e due sottili fenditure luminose.
// L'ala è disegnata sotto il disco opaco della strumentazione, come nel riferimento.
// Barre reali sotto ciascuna lettura: se il valore manca non c'è alcun riempimento.
// I riferimenti di scala sono configurabili e NON modificano limiti di sicurezza.
private struct WingReading {
    let value: String
    let title: String
    let icon: String
    let showsBar: Bool
    let fraction: Double?
}

private struct MetricGlowBar: View {
    let fraction: Double?
    let theme: CockpitTheme

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let progress = fraction.map { Swift.min(1, Swift.max(0, $0)) }
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LinearGradient(colors: [Color(white: 0.09), Color(white: 0.25), Color(white: 0.14)],
                                         startPoint: .top, endPoint: .bottom))
                Capsule()
                    .stroke(LinearGradient(colors: [.white.opacity(0.34), .white.opacity(0.12)],
                                           startPoint: .top, endPoint: .bottom),
                            lineWidth: Swift.max(0.8, h * 0.08))
                if let progress, progress > 0 {
                    let fillWidth = Swift.min(w - h * 0.18,
                                              Swift.max(1.0, w * CGFloat(progress) - h * 0.18))
                    Capsule()
                        .fill(LinearGradient(stops: [
                            .init(color: CockpitTheme.barDark, location: 0),
                            .init(color: CockpitTheme.barMid, location: 0.70),
                            .init(color: CockpitTheme.barBright, location: 1)
                        ], startPoint: .leading, endPoint: .trailing))
                        .frame(width: fillWidth, height: h * 0.84)
                        .padding(.leading, h * 0.10)
                        .shadow(color: Color.red.opacity(0.45), radius: h * 0.7)
                }
            }
            .frame(width: w, height: h)
        }
        .animation(.easeInOut(duration: 0.35), value: fraction)
        .accessibilityValue(fraction.map { "\(Int(($0 * 100).rounded())) percento della scala grafica" } ?? "Nessun dato")
    }
}

// Sei schede indipendenti, come nel cockpit finale approvato.
// Le tre letture in chilometri NON hanno barre, neppure quando il GPS è attivo.
private struct PremiumWing: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var gps: GPSRideManager
    let readings: [WingReading]
    let theme: CockpitTheme
    let left: Bool

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let gap = max(6, h * 0.029)
            let tileHeight = (h - 2 * gap) / 3
            VStack(spacing: gap) {
                ForEach(readings.indices, id: \.self) { index in
                    let reading = readings[index]
                    if reading.title == "Trip parziale" {
                        metricTile(reading, width: w, height: tileHeight)
                            .contentShape(Rectangle())
                            .onLongPressGesture(minimumDuration: 1.3) {
                                gps.resetTrip()
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Chilometri parziali: \(reading.value)")
                            .accessibilityHint("Tieni premuto per 1,3 secondi per azzerare il parziale.")
                            .accessibilityAction(named: "Azzera chilometri parziali") {
                                gps.resetTrip()
                            }
                    } else {
                        metricTile(reading, width: w, height: tileHeight)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(reading.title): \(reading.value)")
                    }
                }
            }
            .frame(width: w, height: h)
        }
        .accessibilityElement(children: .contain)
    }

    private func metricTile(_ reading: WingReading, width: CGFloat, height: CGFloat) -> some View {
        let inset = width * 0.355
        let iconSide = min(height * 0.38, width * 0.095)
        let icon = ZStack {
            Circle()
                .stroke(theme.accent, lineWidth: max(1.5, height * 0.020))
                .shadow(color: theme.accent.opacity(0.35), radius: 3)
            if reading.icon == "voltage" {
                Text("V")
                    .font(.system(size: iconSide * 0.54, weight: .bold))
                    .foregroundStyle(colorScheme == .light ? Color(white: 0.15) : .white)
            } else {
                Image(systemName: reading.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSide * 0.54, height: iconSide * 0.54)
                    .foregroundStyle(theme.accent)
            }
        }
        .frame(width: iconSide, height: iconSide)

        return ZStack {
            RoundedRectangle(cornerRadius: height * 0.28, style: .continuous)
                .fill(LinearGradient(colors: colorScheme == .light
                    ? [Color.white, Color(red: 0.86, green: 0.89, blue: 0.94)]
                    : [Color(white: 0.105), Color(white: 0.045)],
                    startPoint: .top, endPoint: .bottom))
                .overlay {
                    RoundedRectangle(cornerRadius: height * 0.28, style: .continuous)
                        .stroke(LinearGradient(colors: [.white.opacity(0.52), .white.opacity(0.09),
                                                        .white.opacity(0.36)],
                                               startPoint: .top, endPoint: .bottom), lineWidth: 1.0)
                }
                .shadow(color: .black.opacity(0.75), radius: height * 0.08, y: 3)
            VStack(alignment: left ? .trailing : .leading, spacing: 0) {
                HStack(spacing: max(7, width * 0.024)) {
                    if left { Spacer(minLength: 0) }
                    // Sinistra: VALORE + ICONA, destra: ICONA + VALORE.
                    if !left { icon }
                    Text(reading.value)
                        .font(.system(size: min(height * 0.31, width * 0.075), weight: .bold))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.48)
                        .foregroundStyle(colorScheme == .light ? Color(white: 0.15) : .white)
                        .shadow(color: .black.opacity(colorScheme == .light ? 0.08 : 0.85), radius: 2, y: 2)
                    if left { icon }
                    if !left { Spacer(minLength: 0) }
                }
                .frame(maxWidth: .infinity)
                .frame(height: reading.showsBar ? height * 0.72 : height * 0.97)
                if reading.showsBar {
                    MetricGlowBar(fraction: reading.fraction, theme: theme)
                        .frame(width: width * 0.54, height: max(5, height * 0.085))
                }
            }
            .padding(.leading, left ? width * 0.035 : inset)
            .padding(.trailing, left ? inset : width * 0.035)
        }
        .frame(width: width, height: height)
    }
}

// EJ 1.17 — unica linea di top bar, con raccordi laterali C1 attorno alla corona.
// Si estende su tutta la larghezza ed è coperta naturalmente dal quadrante opaco.
private struct ContinuousHorizonLine: View {
    let theme: CockpitTheme
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            // Due raccordi della top bar con lo stesso raggio circolare della downbar.
            // Il centro rimane dietro al quadrante grazie alla maschera esistente.
            let line = CockpitContourGeometry.roundedPath(points: [
                CGPoint(x: 0, y: h * 0.085),
                CGPoint(x: w * 0.255, y: h * 0.085),
                CGPoint(x: w * 0.355, y: h * 0.238),
                CGPoint(x: w * 0.645, y: h * 0.238),
                CGPoint(x: w * 0.745, y: h * 0.085),
                CGPoint(x: w, y: h * 0.085)
            ], corners: [1, 4], radius: CockpitContourGeometry.cornerRadius(in: geometry.size))
            // Il contorno della top bar scompare dietro il tachimetro.
            // Maschera a foro centrale con bordo oltre il LED esterno: nessuna
            // diagonale arancione attraversa gli anelli visibili del quadrante.
            let ringCenter = CGPoint(x: w * 0.50, y: h * 0.507)
            let ringRadius = min(h * 0.982, w * 0.57) * 0.506
            let visibleOutsideRing = Path { p in
                p.addRect(CGRect(x: 0, y: 0, width: w, height: h))
                p.addEllipse(in: CGRect(x: ringCenter.x - ringRadius,
                                        y: ringCenter.y - ringRadius,
                                        width: ringRadius * 2, height: ringRadius * 2))
            }
            ZStack {
                line.stroke(theme.accent.opacity(0.31), lineWidth: max(5, h * 0.010))
                    .blur(radius: max(4, h * 0.012))
                line.stroke(theme.accent.opacity(0.77), lineWidth: max(2.5, h * 0.004))
                    .blur(radius: max(2, h * 0.004))
                line.stroke(theme.accent,
                            style: StrokeStyle(lineWidth: max(1.4, h * 0.002), lineCap: .round))
            }
            .frame(width: w, height: h)
            .mask(visibleOutsideRing.fill(style: FillStyle(eoFill: true)))
            // Dissolvi i due fianchi della top bar poco prima dell'anello
            // arancione: evita l'interruzione luminosa netta segnata in rosso.
            .mask(RadialGradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .white, location: 1)
            ], center: UnitPoint(x: 0.50, y: 0.507),
               startRadius: ringRadius, endRadius: ringRadius + max(18, h * 0.070)))
        }
        .allowsHitTesting(false)
    }
}

// Disegniamo il pittogramma: alcuni iOS non possiedono 'bluetooth' fra gli SF Symbols.
struct BluetoothGlyph:View {
    var body:some View {
        GeometryReader { proxy in
            let w=proxy.size.width, h=proxy.size.height
            Path { p in
                p.move(to:CGPoint(x:w*0.50,y:h*0.04))
                p.addLine(to:CGPoint(x:w*0.50,y:h*0.96))
                p.move(to:CGPoint(x:w*0.50,y:h*0.04))
                p.addLine(to:CGPoint(x:w*0.79,y:h*0.27))
                p.addLine(to:CGPoint(x:w*0.23,y:h*0.74))
                p.move(to:CGPoint(x:w*0.23,y:h*0.27))
                p.addLine(to:CGPoint(x:w*0.79,y:h*0.73))
                p.addLine(to:CGPoint(x:w*0.50,y:h*0.96))
            }
            .stroke(.white,style:StrokeStyle(lineWidth:max(1.5,w*0.105),lineCap:.round,lineJoin:.round))
        }
        .accessibilityLabel("Bluetooth")
    }
}

// L'anello arancione della Home rimane circolare, ma termina ESATTAMENTE
// quando incontra il profilo del ponte kW: stessa geometria del ponte,
// non un arco abbreviato arbitrariamente e non un cerchio completo.
// Sottraiamo con even-odd l'area sottostante al ContinuousLowerLine.
private struct HomeRingBridgeMask: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let controlsHeight = max(51, min(83, h * 0.105))
        let buttonSide = min(controlsHeight * 0.96, w * 0.059)
        let groupEnd = max(12, w * 0.018) + 4 * buttonSide + 3 * w * 0.010
        let footX = min(CGFloat(0.342), max(CGFloat(0.323),
                                             groupEnd / w + 0.035))
        var beneathBridge = ContinuousLowerLine().path(in: rect)
        beneathBridge.addLine(to: CGPoint(x: w * (1 - footX), y: h))
        beneathBridge.addLine(to: CGPoint(x: w * footX, y: h))
        beneathBridge.closeSubpath()
        var visible = Path()
        visible.addRect(rect)
        visible.addPath(beneathBridge)
        return visible
    }
}

// Sfumatura limitata agli ultimi centimetri visivi dei due fianchi
// arancioni: l'intersezione reale con il ponte kW stabilisce il punto
// finale, senza ripristinare il vecchio arco né sfumare la parte alta.
private struct HomeRingTerminalFade: View {
    var body: some View {
        GeometryReader { geometry in
            let h = geometry.size.height
            let contactY = Self.ringBridgeContactY(in: geometry.size)
            let fadeStart = max(0, (contactY - max(20, h * 0.075)) / h)
            let fadeEnd = min(1, contactY / h)
            LinearGradient(stops: [
                .init(color: .white, location: 0),
                .init(color: .white, location: fadeStart),
                .init(color: .clear, location: fadeEnd),
                .init(color: .clear, location: 1)
            ], startPoint: .top, endPoint: .bottom)
        }
        .allowsHitTesting(false)
    }

    private static func ringBridgeContactY(in size: CGSize) -> CGFloat {
        let w = size.width, h = size.height
        let dialSize = min(h * 0.982, w * 0.57)
        let radius = dialSize * 0.985 * 0.5
        let center = CGPoint(x: w * 0.5, y: h * 0.507)
        let controlsHeight = max(51, min(83, h * 0.105))
        let buttonSide = min(controlsHeight * 0.96, w * 0.059)
        let groupEnd = max(12, w * 0.018) + 4 * buttonSide + 3 * w * 0.010
        let footX = min(CGFloat(0.342), max(CGFloat(0.323), groupEnd / w + 0.035))
        let foot = CGPoint(x: w * footX, y: h * 0.985)
        let knee = CGPoint(x: w * 0.385, y: h * 0.790)
        func distanceSquaredMinusRadius(_ fraction: CGFloat) -> CGFloat {
            let x = foot.x + (knee.x - foot.x) * fraction - center.x
            let y = foot.y + (knee.y - foot.y) * fraction - center.y
            return x * x + y * y - radius * radius
        }
        // Bisezione robusta: i terminali sono simmetrici rispetto al centro.
        guard distanceSquaredMinusRadius(0) > 0,
              distanceSquaredMinusRadius(1) < 0 else { return h * 0.92 }
        var lo: CGFloat = 0
        var hi: CGFloat = 1
        for _ in 0..<30 {
            let middle = (lo + hi) / 2
            if distanceSquaredMinusRadius(middle) > 0 { lo = middle }
            else { hi = middle }
        }
        return foot.y + (knee.y - foot.y) * ((lo + hi) / 2)
    }
}

// Condiviso fra Home e GPS: una manovra ha sempre la stessa icona.
private enum GPSManeuverIcon {
    static func symbol(for instruction: String) -> String {
        let hint = instruction.lowercased()
        if hint.contains("inversion") || hint.contains("uturn") || hint.contains("u-turn") {
            return "arrow.uturn.left"
        }
        if hint.contains("rotond") || hint.contains("roundabout") { return "arrow.clockwise" }
        if hint.contains("sinistr") || hint.contains("left") { return "arrow.turn.up.left" }
        if hint.contains("destr") || hint.contains("right") { return "arrow.turn.up.right" }
        return "arrow.up"
    }
}

// Ritaglio geometrico per le sei schede Home: le card restano
// completamente FUORI dal disco tachimetro anche in modalità chiara.
// Si ritaglia dal gruppo delle ali, senza introdurre un disco bianco opaco.
private struct DayWingOutsideDial: Shape {
    let center: CGPoint
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                                  width: radius * 2, height: radius * 2))
        return path
    }
}

struct CockpitDashboard:View {
    @StateObject private var navigation = EcoNavigationStore.shared
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var gps:GPSRideManager
    @EnvironmentObject private var bluetooth:JKBluetoothManager
    let theme:CockpitTheme
    let now:Date
    @AppStorage("ecojumbo.bars.averagePowerMaxKW") private var averagePowerMaxKW = 5.0
    private var live:JKSnapshot? {
        guard bluetooth.isConnected, let snap=bluetooth.snapshot,
              abs(now.timeIntervalSince(snap.date)) < 10 else {return nil}
        return snap
    }
    private var liveSpeed:Double? { gps.currentSpeed(at:now) }
    private var rangeKm:Double? {
        guard let live, let km=bluetooth.session.observedTripKm,
              km>=5, bluetooth.session.dischargedKWh>0.1 else {return nil}
        let spent=bluetooth.session.dischargedKWh/km
        guard spent>0.001 else {return nil}
        return min(999,live.remainingAh*live.voltage/1000/spent)
    }

    private var leftRows: [WingReading] {
        [
            WingReading(value: live.map { "\($0.soc)%" } ?? "—%",
                        title: "Carica residua", icon: "bolt.fill", showsBar: true,
                        fraction: CockpitBarMath.unit(live.map { Double($0.soc) }, maximum: 100)),
            WingReading(value: live.map { String(format: "%.1f V", $0.voltage) } ?? "— V",
                        title: "Tensione batteria", icon: "voltage", showsBar: true,
                        fraction: CockpitBarMath.unit(live?.voltage, minimum: 50, maximum: 73)),
            WingReading(value: rangeKm.map { String(format: "%.0f km", $0) } ?? "— km",
                        title: "Autonomia stimata", icon: "road.lanes", showsBar: false,
                        fraction: nil)
        ]
    }
    private var rightRows: [WingReading] {
        // Potenza istantanea: dalla lettura corrente del JK BMS, non da una media.
        let instantKW = live.map { -($0.power) / 1000.0 }
        // Il valore persistito è valido anche senza segnale GPS: dopo il reset mostra 0,0.
        let partial = gps.tripKm
        let total = gps.hasOdometer ? gps.totalKm : nil
        return [
            WingReading(value: instantKW.map { String(format: "%.1f kW", $0) } ?? "— kW",
                        title: "Potenza istantanea", icon: "chart.bar.fill", showsBar: true,
                        fraction: CockpitBarMath.unit(instantKW.map { abs($0) }, maximum: averagePowerMaxKW)),
            WingReading(value: String(format: "%.1f km", partial),
                        title: "Trip parziale", icon: "mappin", showsBar: false,
                        fraction: nil),
            WingReading(value: total.map { String(format: "%.0f km", $0) } ?? "— km",
                        title: "Chilometraggio scooter", icon: "speedometer", showsBar: false,
                        fraction: nil)
        ]
    }

    var body:some View {
        GeometryReader { geo in
            let w=geo.size.width,h=geo.size.height
            let headerHeight = h * 0.125
            let wingHeight = h * 0.455
            let wingWidth = w * 0.390
            // Margine reale su entrambi i lati: le ali non toccano il display.
            let wingInset = max(5, w * 0.006)
            // Diametro al 98,2% dell’altezza; centro al 50,7% in landscape.
            // Intero quadrante all’interno del display su tutti gli iPhone supportati.
            let dialSize = min(h * 0.982, w * 0.57)
            ZStack(alignment: .topLeading) {
                CarbonBackdrop(theme: theme)
                CockpitTopSoftShade()
                    .frame(width: w, height: h)
                    .zIndex(0)


                ZStack {
                    PremiumWing(readings: leftRows, theme: theme, left: true)
                        .frame(width: wingWidth, height: wingHeight)
                        .position(x: wingInset + wingWidth / 2, y: h * 0.490)
                    PremiumWing(readings: rightRows, theme: theme, left: false)
                        .frame(width: wingWidth, height: wingHeight)
                        .position(x: w - wingInset - wingWidth / 2, y: h * 0.490)
                }
                .frame(width: w, height: h)
                .mask {
                    if colorScheme == .light {
                        DayWingOutsideDial(center: CGPoint(x: w * 0.50, y: h * 0.507),
                                           radius: dialSize * 0.495)
                            .fill(style: FillStyle(eoFill: true))
                    } else {
                        Rectangle().fill(.white)
                    }
                }
                .zIndex(1)

                // Disco carbonio opaco in PRIMO PIANO: i dati laterali restano dietro.
                OpenSpeedCluster(speed: liveSpeed,
                                 incomingPower: live.map { Swift.max(0, $0.power) },
                                 outgoingPower: live.map { Swift.max(0, -$0.power) },
                                 theme: theme,
                                 navigationArrow: navigation.isNavigating
                                     ? GPSManeuverIcon.symbol(for: navigation.guidanceInstruction)
                                     : nil,
                                 navigationInstruction: navigation.guidanceInstruction)
                    .frame(width: dialSize, height: dialSize)
                    .position(x: w / 2, y: h * 0.507)
                    .zIndex(30)

                // Il cerchio resta concentricamente IDENTICO alla build 30,
                // ma i fianchi terminano sul ponte inferiore sopra i kW,
                // come nell'immagine: non ripristiniamo l'arco corto della 25.
                ZStack {
                    Circle()
                        .stroke(theme.accent.opacity(0.53), lineWidth: max(3, h * 0.009))
                        .blur(radius: h * 0.014)
                        .frame(width: dialSize * 0.985, height: dialSize * 0.985)
                        .position(x: w * 0.50, y: h * 0.507)
                    Circle()
                        .stroke(theme.accent.opacity(0.96), lineWidth: max(1.4, h * 0.002))
                        .frame(width: dialSize * 0.985, height: dialSize * 0.985)
                        .position(x: w * 0.50, y: h * 0.507)
                }
                .frame(width: w, height: h)
                .mask(HomeRingBridgeMask().fill(style: FillStyle(eoFill: true)))
                .mask(HomeRingTerminalFade())
                .allowsHitTesting(false)
                .zIndex(33)
                ContinuousHorizonLine(theme: theme)
                    .frame(width: w, height: h)
                    .zIndex(2)
                topInfoBar(height: headerHeight, width: w)
                    .frame(width: w, height: headerHeight)
                    .zIndex(40)
                // Temperatura sotto il logo e sotto la top bar, lontano dal tachimetro.
                EcoOutsideTemperature(now: now)
                    .frame(width: min(136, w * 0.108))
                    .position(x: max(12, w * 0.016) + min(136, w * 0.108) / 2,
                              y: h * 0.158)
                    .zIndex(41)
            }
            .frame(width:w,height:h)
            .clipped()
        }
        .accessibilityElement(children:.contain)
        .accessibilityLabel("Cruscotto Ecojumbo")
    }

    private func topInfoBar(height: CGFloat, width: CGFloat) -> some View {
        HStack(spacing: max(7, height * 0.20)) {
            Image("EcojumboMark")
                .resizable().scaledToFit()
                .frame(width: height * 0.73, height: height * 0.72)
                .accessibilityLabel("Ecojumbo")
            Rectangle().fill(.white.opacity(0.55))
                .frame(width: 1, height: height * 0.40)
            Text(now.formatted(date: .omitted, time: .shortened))
                .font(.system(size: height * 0.44, weight: .bold))
                .monospacedDigit()
                .lineLimit(1)
                .accessibilityLabel("Ora corrente")
            Spacer(minLength: 0)
            Image(systemName: "location.north.fill")
                .foregroundStyle(colorScheme == .light ? Color(white: 0.16) : .white)
                .accessibilityLabel("GPS")
            Circle().fill(liveSpeed == nil ? Color.gray : theme.accent)
                .frame(width: max(5, height * 0.14), height: max(5, height * 0.14))
                .accessibilityLabel(liveSpeed == nil ? "GPS non disponibile" : "GPS attivo")
            Rectangle().fill(.white.opacity(0.55))
                .frame(width: 1, height: height * 0.43).padding(.horizontal, 2)
            BluetoothGlyph().frame(width: height * 0.27, height: height * 0.43)
            Circle().fill(live == nil ? Color.gray : theme.accent)
                .frame(width: max(5, height * 0.14), height: max(5, height * 0.14))
                .accessibilityLabel(live == nil ? "BMS non disponibile" : "BMS collegato")
            Rectangle().fill(.white.opacity(0.55))
                .frame(width: 1, height: height * 0.43).padding(.horizontal, 2)
            PhoneChargeMeter()
        }
        .font(.system(size: max(13, height * 0.34), weight: .medium))
        .foregroundStyle(colorScheme == .light ? Color(white: 0.15) : .white)
        .padding(.horizontal, max(14, width * 0.031))
        .padding(.bottom, height * 0.08)
    }
}

private struct PhoneChargeMeter:View {
    @State private var batteryLevel:Float = -1
    var body:some View {
        HStack(spacing:6) {
            Image(systemName:"battery.100percent")
            Text(batteryLevel < 0 ? "—%" : "\(Int((batteryLevel*100).rounded()))%")
                .monospacedDigit()
        }
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled=true
            batteryLevel=UIDevice.current.batteryLevel
        }
        .onReceive(NotificationCenter.default.publisher(for:UIDevice.batteryLevelDidChangeNotification)) {_ in
            batteryLevel=UIDevice.current.batteryLevel
        }
    }
}

// Arco in coordinate di schermo: zero gradi = destra, 90 = basso.
private struct GaugeArc: Shape {
    let start: Double
    let end: Double
    var fraction: Double = 1
    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }
    func path(in rect: CGRect) -> Path {
        let f=max(0,min(1,fraction))
        guard f>0 else {return Path()}
        let rad=min(rect.width,rect.height)*0.5
        var path=Path()
        for i in 0...120 {
            let a=(start+(end-start)*Double(i)/120*f)*Double.pi/180
            let pt=CGPoint(x: rect.midX + rad * CGFloat(Darwin.cos(a)), y: rect.midY + rad * CGFloat(Darwin.sin(a)))
            if i==0 {path.move(to:pt)} else {path.addLine(to:pt)}
        }
        return path
    }
}

// Tacche della velocità: nessun numero predefinito da 0 a 120.
// Il LED rosso sottostante indica la quota della scala già percorsa.
private struct SpeedScaleTicks: View {
    @Environment(\.colorScheme) private var colorScheme
    let d: CGFloat

    var body: some View {
        Canvas { context, _ in
            drawTicks(into: &context)
        }
        .frame(width: d, height: d)
        .accessibilityHidden(true)
    }

    private func drawTicks(into context: inout GraphicsContext) {
        let outerRadius: CGFloat = d * 0.393
        for index in 0...48 {
            let radians: Double = (146.0 + Double(index) * (248.0 / 48.0)) * .pi / 180.0
            let isMajor = index.isMultiple(of: 8)
            let isMedium = index.isMultiple(of: 4)
            let length: CGFloat = isMajor ? d * 0.030 : (isMedium ? d * 0.021 : d * 0.013)
            let innerRadius: CGFloat = outerRadius - length
            let cosAngle: CGFloat = CGFloat(Darwin.cos(radians))
            let sinAngle: CGFloat = CGFloat(Darwin.sin(radians))
            let from = CGPoint(x: d / 2 + cosAngle * innerRadius,
                               y: d / 2 + sinAngle * innerRadius)
            let to = CGPoint(x: d / 2 + cosAngle * outerRadius,
                             y: d / 2 + sinAngle * outerRadius)
            var tick = Path()
            tick.move(to: from)
            tick.addLine(to: to)
            let color = colorScheme == .light
                ? Color(white: 0.22).opacity(isMajor ? 1.0 : 0.72)
                : Color.white.opacity(isMajor ? 1.0 : 0.77)
            let thickness: CGFloat = isMajor ? d * 0.005 : d * 0.0022
            context.stroke(tick, with: .color(color),
                           style: StrokeStyle(lineWidth: thickness, lineCap: .round))
        }
    }
}

/// Stream LED ARANCIONE progressivo: accesa solo quando esiste una misura GPS valida.
/// L'arco è posto all'interno delle tacche bianche, sotto le due corone segmentate.
/// Il punto luminoso segue la punta effettiva dell'arco; a 0 km/h resta spento.
private struct SpeedLEDStream: View {
    let d: CGFloat
    let speed: Double?
    private let ledOrange = Color(red: 1.00, green: 0.44, blue: 0.03)

    private var progress: Double? {
        guard let speed, speed.isFinite, speed >= 0 else { return nil }
        return min(1, max(0, speed / 120))
    }

    var body: some View {
        ZStack {
            // Anima inerte: si vede la forma della pista ma NON un valore simulato.
            GaugeArc(start: 146, end: 394)
                .stroke(Color(red: 0.28, green: 0.11, blue: 0.02).opacity(0.28),
                        style: StrokeStyle(lineWidth: d * 0.009, lineCap: .round))
                .frame(width: d * 0.722, height: d * 0.722)
            if let progress, progress > 0 {
                GaugeArc(start: 146, end: 394, fraction: progress)
                    .stroke(ledOrange.opacity(0.80),
                            style: StrokeStyle(lineWidth: d * 0.034, lineCap: .round))
                    .blur(radius: d * 0.027)
                    .frame(width: d * 0.722, height: d * 0.722)
                GaugeArc(start: 146, end: 394, fraction: progress)
                    .stroke(ledOrange, style: StrokeStyle(lineWidth: d * 0.015, lineCap: .round))
                    .shadow(color: ledOrange.opacity(0.94), radius: d * 0.010)
                    .frame(width: d * 0.722, height: d * 0.722)
                GaugeArc(start: 146, end: 394, fraction: progress)
                    .stroke(Color.white.opacity(0.65),
                            style: StrokeStyle(lineWidth: d * 0.003, lineCap: .round))
                    .frame(width: d * 0.722, height: d * 0.722)
                let angle = (146 + 248 * progress) * Double.pi / 180
                let radius = d * 0.361
                let endPoint = CGPoint(x: d/2 + radius * CGFloat(Darwin.cos(angle)),
                                       y: d/2 + radius * CGFloat(Darwin.sin(angle)))
                Circle()
                    .fill(.white)
                    .frame(width: d * 0.020, height: d * 0.020)
                    .shadow(color: ledOrange, radius: d * 0.027)
                    .shadow(color: ledOrange.opacity(0.95), radius: d * 0.014)
                    .position(endPoint)
            }
        }
        .frame(width: d, height: d)
        .animation(.easeInOut(duration: 0.38), value: progress)
        .accessibilityLabel(progress.map { "Indicatore LED velocità: \(Int(($0 * 100).rounded()))% della scala" }
                            ?? "GPS non disponibile")
    }
}

private struct SegmentedGaugeBar: View {
    let d: CGFloat
    let fraction: Double?
    let start: Double
    let end: Double
    let count: Int
    let radiusFactor: CGFloat
    let activeColor: Color
    let idleColor: Color

    var body: some View {
        Canvas { context, _ in
            drawSegments(into: &context)
        }
        .frame(width: d, height: d)
        .animation(.easeOut(duration: 0.40), value: fraction)
        .accessibilityHidden(true)
    }

    private func drawSegments(into context: inout GraphicsContext) {
        guard count > 0 else { return }
        let radius: CGFloat = d * radiusFactor
        let stepAngle: Double = (end - start) / Double(count)
        let thickness: CGFloat = d * 0.017
        for index in 0..<count {
            let firstAngle: Double = (start + Double(index) * stepAngle + 0.40) * .pi / 180
            let lastAngle: Double = (start + Double(index + 1) * stepAngle - 0.40) * .pi / 180
            var segment = Path()
            for pointIndex in 0...5 {
                let angle = firstAngle + (lastAngle - firstAngle) * Double(pointIndex) / 5.0
                let cosAngle = CGFloat(Darwin.cos(angle))
                let sinAngle = CGFloat(Darwin.sin(angle))
                let point = CGPoint(x: d / 2 + radius * cosAngle,
                                    y: d / 2 + radius * sinAngle)
                if pointIndex == 0 { segment.move(to: point) }
                else { segment.addLine(to: point) }
            }
            let progress: Double = Double(index) / Double(count)
            let active = fraction.map { progress < $0 } ?? false
            let color = active ? activeColor : idleColor
            context.stroke(segment, with: .color(color),
                           style: StrokeStyle(lineWidth: thickness, lineCap: .butt))
        }
    }
}

// Il contorno delle cifre usa il percorso vettoriale del glifo, non
// NSAttributedString.strokeWidth: quest'ultimo crea punte/miter all'interno
// di alcuni caratteri (in particolare il "2"), simili a stelline.
private final class SpeedGlyphOutlineView: UIView {
    var digits = "" { didSet { setNeedsDisplay() } }
    var pointSize: CGFloat = 80 { didSet { setNeedsDisplay() } }
    var strokeColor: UIColor = .orange { didSet { setNeedsDisplay() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        contentMode = .redraw
        isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) { fatalError("Storyboard non supportato") }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !digits.isEmpty else { return }
        let uiFont = UIFont.monospacedDigitSystemFont(ofSize: pointSize, weight: .medium)
        let font = CTFontCreateWithName(uiFont.fontName as CFString, pointSize, nil)
        let characters = Array(digits.utf16)
        var glyphs = [CGGlyph](repeating: 0, count: characters.count)
        guard CTFontGetGlyphsForCharacters(font, characters, &glyphs, characters.count) else { return }
        var advances = [CGSize](repeating: .zero, count: glyphs.count)
        CTFontGetAdvancesForGlyphs(font, .horizontal, glyphs, &advances, glyphs.count)

        let path = CGMutablePath()
        var penX: CGFloat = 0
        for index in glyphs.indices {
            if let outline = CTFontCreatePathForGlyph(font, glyphs[index], nil) {
                let transform = CGAffineTransform(translationX: penX, y: 0)
                path.addPath(outline, transform: transform)
            }
            penX += advances[index].width
        }
        let glyphBounds = path.boundingBoxOfPath
        guard !glyphBounds.isEmpty else { return }
        let fit = min(1, rect.width * 0.93 / glyphBounds.width,
                     rect.height * 0.91 / glyphBounds.height)

        context.saveGState()
        context.translateBy(x: rect.midX, y: rect.midY)
        context.scaleBy(x: fit, y: -fit)
        context.translateBy(x: -glyphBounds.midX, y: -glyphBounds.midY)
        context.addPath(path)
        context.setFillColor(UIColor.clear.cgColor)
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(max(1.7, pointSize * 0.022))
        // ROUND join elimina gli spigoli acuti prodotti dai miter dei glifi.
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShadow(offset: .zero, blur: max(2, pointSize * 0.028),
                          color: strokeColor.withAlphaComponent(0.70).cgColor)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
}

private struct HollowSpeedNumber: UIViewRepresentable {
    let text: String
    let size: CGFloat
    let accent: UIColor

    func makeUIView(context: Context) -> SpeedGlyphOutlineView {
        SpeedGlyphOutlineView(frame: .zero)
    }
    func updateUIView(_ view: SpeedGlyphOutlineView, context: Context) {
        view.digits = text
        view.pointSize = size
        view.strokeColor = accent
    }
}

// Geometria netta delle frecce: segmenti a spigoli e testate squadrate.
// Mantiene tutte le manovre nell'area interna delle tacche del tachimetro.
private struct GPSAngularManeuverArrow: Shape {
    let symbol: String
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: w * x, y: h * y) }
        var path = Path()
        switch symbol {
        case "arrow.turn.up.left":
            path.move(to: p(0.83, 0.90))
            path.addLines([p(0.83, 0.50), p(0.28, 0.50), p(0.28, 0.13)])
            path.move(to: p(0.10, 0.32))
            path.addLines([p(0.28, 0.13), p(0.46, 0.32)])
        case "arrow.turn.up.right":
            path.move(to: p(0.17, 0.90))
            path.addLines([p(0.17, 0.50), p(0.72, 0.50), p(0.72, 0.13)])
            path.move(to: p(0.54, 0.32))
            path.addLines([p(0.72, 0.13), p(0.90, 0.32)])
        case "arrow.uturn.left":
            path.move(to: p(0.79, 0.88))
            path.addLines([p(0.79, 0.19), p(0.27, 0.19), p(0.27, 0.71)])
            path.move(to: p(0.10, 0.54))
            path.addLines([p(0.27, 0.71), p(0.44, 0.54)])
        case "arrow.clockwise":
            // Rotatoria: poligono aperto, anziché cerchio molto smussato.
            path.move(to: p(0.17, 0.78))
            path.addLines([p(0.17, 0.26), p(0.77, 0.26), p(0.77, 0.72)])
            path.move(to: p(0.59, 0.54))
            path.addLines([p(0.77, 0.72), p(0.95, 0.54)])
        default:
            path.move(to: p(0.50, 0.88))
            path.addLine(to: p(0.50, 0.12))
            path.move(to: p(0.27, 0.34))
            path.addLines([p(0.50, 0.12), p(0.73, 0.34)])
        }
        return path
    }
}

// Scala strumentazione e corona a elementi discreti, non una immagine fissa.
// Il numero di velocità è disegnato a contorno; la lettura proviene solo dal GPS.
private struct OpenSpeedCluster: View {
    @Environment(\.colorScheme) private var colorScheme
    let speed: Double?
    let incomingPower: Double?
    let outgoingPower: Double?
    let theme: CockpitTheme
    // Layout unico per Home e GPS. Freccia visibile solo se la rotta è attiva.
    var navigationArrow: String? = nil
    var navigationInstruction: String? = nil

    private func magnitude(_ input: Double, limit: Double) -> Double {
        Swift.max(0, Swift.min(1, abs(input) / limit))
    }

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            // Corrente positiva: ingresso; corrente negativa: uscita.
            // Entrambi gli strumenti mostrano solo dati reali del JK BMS.
            let outputFill = outgoingPower.map { magnitude($0, limit: 13_000) }
            let inputFill = incomingPower.map { magnitude($0, limit: 13_000) }
            ZStack {
                // Il carbonio chiude completamente il quadrante sopra le ali sottostanti.
                // In modalità diurna il fondo si fonde nel cockpit: non
                // compare il disco bianco pieno sopra mappa o pannelli.
                if colorScheme == .light {
                    Circle()
                        .fill(Color(red: 0.94, green: 0.96, blue: 0.985).opacity(0.95))
                        .frame(width: d * 0.986, height: d * 0.986)
                        .mask(RadialGradient(stops: [
                            .init(color: .white, location: 0),
                            .init(color: .white, location: 0.77),
                            .init(color: .white.opacity(0.58), location: 0.91),
                            .init(color: .clear, location: 1)
                        ], center: .center, startRadius: 0, endRadius: d * 0.493))
                } else {
                    Circle()
                        .fill(Color(red: 0.016, green: 0.015, blue: 0.017))
                        .frame(width: d * 0.986, height: d * 0.986)
                        .shadow(color: .black.opacity(0.88), radius: d * 0.025)
                }
                Image("CarbonWeave")
                    .resizable(resizingMode: .tile)
                    .opacity(colorScheme == .light ? 0 : 0.74)
                    .frame(width: d * 0.982, height: d * 0.982)
                    .clipShape(Circle())
                Circle()
                    .fill(RadialGradient(colors: colorScheme == .light
                        ? [Color(white: 0.85).opacity(0.20), .clear, Color(white: 0.72).opacity(0.11)]
                        : [.black.opacity(0.36), .clear, .black.opacity(0.55)], center: .center,
                                         startRadius: d * 0.06, endRadius: d * 0.49))
                    .frame(width: d * 0.98, height: d * 0.98)
                    .opacity(colorScheme == .light ? 0 : 1)

                // Le due scale hanno un'anima grigia per tutta la corsa; solo dati REALI
                // attivano segmenti luminosi e colorati (mai valori inventati).
                SegmentedGaugeBar(d: d, fraction: outputFill,
                                  start: 149, end: 391, count: 64, radiusFactor: 0.469,
                                  activeColor: CockpitTheme.dischargeAccent,
                                  idleColor: CockpitTheme.dischargeAccent.opacity(0.22))
                    .shadow(color: CockpitTheme.dischargeAccent.opacity(outputFill == nil ? 0.04 : 0.72),
                            radius: d * 0.014)
                SegmentedGaugeBar(d: d, fraction: inputFill,
                                  start: 149, end: 391, count: 64, radiusFactor: 0.427,
                                  activeColor: CockpitTheme.regenAccent,
                                  idleColor: CockpitTheme.regenAccent.opacity(0.20))
                    .shadow(color: CockpitTheme.regenAccent.opacity(inputFill == nil ? 0.02 : 0.48),
                            radius: d * 0.011)

                // La striscia LED arancione della velocità richiede GPS valido.
                SpeedLEDStream(d: d, speed: speed)
                SpeedScaleTicks(d: d)

                // Stessa strumentazione nella Home e nella mappa.
                // La freccia bianca occupa la zona superiore, lontana dalle
                // cifre; nessun pannello testuale e nessuna scritta GPS.
                if let navigationArrow {
                    GPSAngularManeuverArrow(symbol: navigationArrow)
                        .stroke(Color.white, style: StrokeStyle(
                            lineWidth: max(3, d * 0.012),
                            lineCap: .square, lineJoin: .miter, miterLimit: 2))
                        .shadow(color: colorScheme == .light
                                ? .black.opacity(0.72) : .black.opacity(0.34),
                                radius: colorScheme == .light ? 2.5 : 1.2)
                        .frame(width: d * 0.175, height: d * 0.125)
                        .position(x: d * 0.5, y: d * 0.245)
                        .accessibilityLabel(navigationInstruction ?? "Prossima manovra")
                }

                // UNA SOLA istanza di UILabel a tracciato: niente sovrapposizione
                // di contorni, niente stella o artefatto nelle cifre neon.
                Group {
                    if let speed {
                        HollowSpeedNumber(text: String(Int(speed.rounded())),
                                          size: d * 0.275,
                                          accent: UIColor(theme.accent))
                            .frame(width: d * 0.60, height: d * 0.285)
                            .accessibilityLabel("Velocità GPS: \(Int(speed.rounded())) chilometri orari")
                    } else {
                        Text("—")
                            .font(.system(size: d * 0.22, weight: .light))
                            .foregroundStyle(colorScheme == .light
                                             ? Color(white: 0.25) : .white.opacity(0.90))
                            .frame(width: d * 0.60, height: d * 0.285)
                            .accessibilityLabel("GPS non disponibile")
                    }
                }
                .position(x: d * 0.5, y: d * 0.495)

                Text("km/h")
                    .font(.system(size: d * 0.047, weight: .medium))
                    .foregroundStyle(colorScheme == .light
                                     ? Color(white: 0.24) : .white.opacity(0.85))
                    .frame(width: d * 0.20, height: d * 0.065)
                    .position(x: d * 0.5, y: d * 0.755)

                // Due potenze separate, invece di corrente A e potenza con segno:
                // azzurro = ingresso batteria, rosso = uscita batteria.
                // L'ingresso non identifica da solo l'origine rigenerativa.
                HStack(spacing: 0) {
                    Text(incomingPower.map { String(format: "%.2f kW", $0 / 1000) } ?? "— kW")
                        .foregroundStyle(CockpitTheme.regenAccent)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Potenza in ingresso alla batteria")
                    Rectangle().fill(colorScheme == .light ? Color(white: 0.34) : .white.opacity(0.70))
                        .frame(width: 1, height: d * 0.086)
                    Text(outgoingPower.map { String(format: "%.2f kW", $0 / 1000) } ?? "— kW")
                        .foregroundStyle(CockpitTheme.dischargeAccent)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Potenza erogata dalla batteria")
                }
                .font(.system(size: d * 0.066, weight: .semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .frame(width: d * 0.66, height: d * 0.13)
                .position(x: d * 0.50, y: d * 0.889)
            }
            .frame(width: d, height: d)
        }
        .accessibilityElement(children: .contain)
    }
}



// Calcola la posizione più a sinistra possibile senza tagliare il
// quadrante e conservando una zona di rispetto per orario/Dynamic Island.
private enum GPSDialLayout {
    static func size(width: CGFloat, height: CGFloat) -> CGFloat {
        min(height * 0.965, width * 0.55)
    }
    static func centerX(width: CGFloat, height: CGFloat) -> CGFloat {
        let d = size(width: width, height: height)
        return max(d * 0.51 + width * 0.010, width * 0.168 + d * 0.30)
    }
}

// Anello esterno luminoso del tachimetro GPS. Il segmento inferiore
// scompare progressivamente prima dei raccordi A/kW: nessun incrocio.
private struct GPSGaugeHalo: View {
    let theme: CockpitTheme
    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            Circle()
                .stroke(theme.accent,
                        style: StrokeStyle(lineWidth: max(1.8, d * 0.0038)))
                .frame(width: d * 0.992, height: d * 0.992)
                .shadow(color: theme.accent.opacity(0.78), radius: d * 0.012)
                .frame(width: d, height: d)
                .mask(LinearGradient(stops: [
                    .init(color: .white, location: 0.0),
                    .init(color: .white, location: 0.65),
                    .init(color: .white.opacity(0.65), location: 0.72),
                    .init(color: .clear, location: 0.80)
                ], startPoint: .top, endPoint: .bottom))
        }
        .allowsHitTesting(false)
    }
}


// EJ 1.23 — linea A/kW specifica del cockpit GPS, larga quanto i due valori.
// Due raccordi con lo stesso raggio della top bar; terminali dritti, lontani
// dal testo e dai pulsanti di navigazione. Mai sovrapporre il disco del tachimetro.
// Stessa inclinazione fisica dei fianchi della Home standard
// (ContinuousLowerLine), adattata alla posizione del quadrante GPS.
private enum GPSLowerLineGeometry {
    static func points(in rect: CGRect) -> [CGPoint] {
        let w = rect.width
        let h = rect.height
        let d = GPSDialLayout.size(width: w, height: h)
        let center = GPSDialLayout.centerX(width: w, height: h)
        // Ponte raccolto sotto il quadrante: fianchi più corti e stessa
        // pendenza di riferimento della Home, raggio circolare invariato.
        let textTop = h * 0.494 + d * (0.889 - 0.50 - 0.065)
        let topY = min(h * 0.790, textTop - max(12, h * 0.014))
        let footY = h * 0.937
        let topHalfWidth = d * 0.325
        let leftTopX = center - topHalfWidth
        let controlsHeight = max(51, min(83, h * 0.105))
        let controlSide = min(controlsHeight * 0.96, w * 0.059, w * 0.052)
        let buttonStart = w - max(12, w * 0.018) - 8 * controlSide - 7 * w * 0.008
        let standardFootX: CGFloat = 0.323
        let standardHorizontalRun = w * (0.385 - standardFootX)
        let standardVerticalRun = h * (0.985 - 0.790)
        let idealRun = standardHorizontalRun * ((footY - topY) / standardVerticalRun)
        let maxRightFoot = buttonStart - max(9, w * 0.012)
        // Riduci soltanto la larghezza del ponte sui display stretti:
        // mantieni la stessa pendenza del fianco e non toccare il dock.
        let rightTopX = min(center + topHalfWidth, maxRightFoot - idealRun)
        let run = min(idealRun, max(0, maxRightFoot - rightTopX))
        return [
            CGPoint(x: leftTopX - run, y: footY),
            CGPoint(x: leftTopX, y: topY),
            CGPoint(x: rightTopX, y: topY),
            CGPoint(x: rightTopX + run, y: footY)
        ]
    }
}

private struct GPSLowerContour: Shape {
    func path(in rect: CGRect) -> Path {
        CockpitContourGeometry.roundedPath(
            points: GPSLowerLineGeometry.points(in: rect),
            corners: [1, 2],
            radius: CockpitContourGeometry.cornerRadius(in: rect.size)
        )
    }
}

private struct GPSLowerShade: Shape {
    func path(in rect: CGRect) -> Path {
        let points = GPSLowerLineGeometry.points(in: rect)
        var shape = GPSLowerContour().path(in: rect)
        if let leftFoot = points.first, let rightFoot = points.last {
            shape.addLine(to: CGPoint(x: rightFoot.x, y: rect.height))
            shape.addLine(to: CGPoint(x: leftFoot.x, y: rect.height))
            shape.closeSubpath()
        }
        return shape
    }
}

// Maschera orizzontale ancorata ai terminali reali del ponte:
// il tratto centrale resta pieno, le due estremità si dissolvono.
private struct GPSLowerTerminalFade: View {
    var body: some View {
        GeometryReader { geo in
            let points = GPSLowerLineGeometry.points(
                in: CGRect(origin: .zero, size: geo.size))
            let leftX = points.first?.x ?? 0
            let rightX = points.last?.x ?? geo.size.width
            let width = max(1, geo.size.width)
            LinearGradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .white, location: 0.17),
                .init(color: .white, location: 0.83),
                .init(color: .clear, location: 1)
            ], startPoint: UnitPoint(x: leftX / width, y: 0.5),
               endPoint: UnitPoint(x: rightX / width, y: 0.5))
        }
    }
}

private struct GPSLowerGlow: View {
    let theme: CockpitTheme

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            ZStack {
                // Luce grigio-antracite subito sotto il ponte: sfuma
                // verso il basso senza creare un pannello separato.
                GPSLowerShade()
                    .fill(LinearGradient(stops: [
                        .init(color: Color(white: 0.42).opacity(0.36), location: 0),
                        .init(color: Color(white: 0.29).opacity(0.22), location: 0.42),
                        .init(color: Color(white: 0.17).opacity(0.07), location: 0.78),
                        .init(color: .clear, location: 1)
                    ], startPoint: UnitPoint(x: 0.5, y: 0.78),
                       endPoint: UnitPoint(x: 0.5, y: 0.985)))
                ZStack {
                    GPSLowerContour()
                        .stroke(theme.accent.opacity(0.30),
                                style: StrokeStyle(lineWidth: max(4, h * 0.018), lineCap: .round))
                        .blur(radius: max(3, h * 0.015))
                    GPSLowerContour()
                        .stroke(theme.accent.opacity(0.79),
                                style: StrokeStyle(lineWidth: max(2.3, h * 0.006), lineCap: .round))
                        .blur(radius: max(1.2, h * 0.004))
                    GPSLowerContour()
                        .stroke(theme.accent,
                                style: StrokeStyle(lineWidth: max(1.4, h * 0.003), lineCap: .round))
                }
                .mask(GPSLowerTerminalFade())
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// EJ 1.22 — modalità GPS nello STESSO cockpit: tachimetro a sinistra,
// mappa stradale Apple a destra, sette tasti sempre visibili in basso.
// Le misure non sono simulate; la rotta MKDirections resta condivisa.
@MainActor
struct GPSCockpitDashboard: View {
    @EnvironmentObject private var gps: GPSRideManager
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    @StateObject private var navigation = EcoNavigationStore.shared
    let theme: CockpitTheme
    let now: Date

    private var maneuverSymbol: String? {
        navigation.isNavigating
            ? GPSManeuverIcon.symbol(for: navigation.guidanceInstruction)
            : nil
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let dialSize = GPSDialLayout.size(width: w, height: h)
            let dialCenterX = GPSDialLayout.centerX(width: w, height: h)
            let live = bluetooth.snapshot
            ZStack {
                CarbonBackdrop(theme: theme)
                CockpitTopSoftShade()
                    .frame(width: w, height: h)
                    .zIndex(1)

                // Mappa 3D a tutta area, senza riquadro: parte sotto il
                // cruscotto e arriva fino al margine destro, con bordi sfumati.
                GPSCockpitMap(theme: theme)
                    .frame(width: w * 0.64, height: h * 0.89)
                    .position(x: w * 0.68, y: h * 0.49)
                    .zIndex(5)

                GPSHorizonLine(theme: theme)
                    .frame(width: w, height: h)
                    .zIndex(8)

                OpenSpeedCluster(speed: gps.currentSpeed(at: now),
                                 incomingPower: live.map { Swift.max(0, $0.power) },
                                 outgoingPower: live.map { Swift.max(0, -$0.power) },
                                 theme: theme,
                                 navigationArrow: maneuverSymbol,
                                 navigationInstruction: navigation.guidanceInstruction)
                    .frame(width: dialSize, height: dialSize)
                    .position(x: dialCenterX, y: h * 0.494)
                    .zIndex(25)

                GPSGaugeHalo(theme: theme)
                    .frame(width: dialSize, height: dialSize)
                    .position(x: dialCenterX, y: h * 0.494)
                    .zIndex(27)

                // Ponte più corto, raccordato al bordo inferiore del tachimetro;
                // la sfumatura scende dietro le letture kW, senza coprirne il testo.
                GPSLowerGlow(theme: theme)
                    .frame(width: w, height: h)
                    .allowsHitTesting(false)
                    .zIndex(28)

                GPSHeader(theme: theme, now: now,
                          speedAvailable: gps.currentSpeed(at: now) != nil,
                          bmsAvailable: live != nil)
                    .frame(width: w, height: h * 0.125)
                    .position(x: w * 0.5, y: h * 0.0625)
                    .zIndex(40)
                EcoOutsideTemperature(now: now)
                    .frame(width: min(136, w * 0.108))
                    .position(x: max(12, w * 0.016) + min(136, w * 0.108) / 2,
                              y: h * 0.158)
                    .zIndex(41)
            }
            .frame(width: w, height: h)
            .clipped()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Cockpit GPS Ecojumbo con percorso stradale MapKit")
    }
}

private struct GPSHorizonLine: View {
    let theme: CockpitTheme

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let radius = CockpitContourGeometry.cornerRadius(in: geo.size)
            let left = CockpitContourGeometry.roundedPath(points: [
                CGPoint(x: 0, y: h * 0.085),
                CGPoint(x: w * 0.16, y: h * 0.085),
                CGPoint(x: w * 0.25, y: h * 0.23),
                CGPoint(x: w * 0.32, y: h * 0.23)
            ], corners: [1], radius: radius)
            let right = CockpitContourGeometry.roundedPath(points: [
                CGPoint(x: w * 0.45, y: h * 0.23),
                CGPoint(x: w * 0.54, y: h * 0.085),
                CGPoint(x: w, y: h * 0.085)
            ], corners: [1], radius: radius)
            let line = Path { path in
                path.addPath(left)
                path.addPath(right)
            }
            let dialSize = GPSDialLayout.size(width: w, height: h)
            let dialCenterX = GPSDialLayout.centerX(width: w, height: h)
            let visibleOutsideRing = Path { p in
                p.addRect(CGRect(x: 0, y: 0, width: w, height: h))
                p.addEllipse(in: CGRect(x: dialCenterX - dialSize * 0.508,
                                        y: h * 0.494 - dialSize * 0.508,
                                        width: dialSize * 1.016,
                                        height: dialSize * 1.016))
            }
            ZStack {
                line.stroke(theme.accent.opacity(0.30), lineWidth: max(5, h * 0.011))
                    .blur(radius: max(3, h * 0.012))
                line.stroke(theme.accent.opacity(0.83), lineWidth: max(2.0, h * 0.004))
                    .blur(radius: max(1, h * 0.004))
                line.stroke(theme.accent, lineWidth: max(1.2, h * 0.0023))
            }
            .mask(visibleOutsideRing.fill(style: FillStyle(eoFill: true)))
            // Stessa sfumatura radiale per i terminali delle diagonali GPS.
            .mask(RadialGradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .white, location: 1)
            ], center: UnitPoint(x: dialCenterX / w, y: 0.494),
               startRadius: dialSize * 0.508,
               endRadius: dialSize * 0.508 + max(18, h * 0.070)))
        }
        .allowsHitTesting(false)
    }
}

@MainActor
private struct GPSHeader: View {
    @Environment(\.colorScheme) private var colorScheme
    let theme: CockpitTheme
    let now: Date
    let speedAvailable: Bool
    let bmsAvailable: Bool

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            HStack(spacing: max(7, h * 0.20)) {
                Image("EcojumboMark")
                    .resizable().scaledToFit()
                    .frame(width: h * 0.73, height: h * 0.72)
                Rectangle().fill(.white.opacity(0.55))
                    .frame(width: 1, height: h * 0.40)
                Text(now.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: h * 0.44, weight: .bold))
                    .monospacedDigit()
                Spacer(minLength: 0)
                Image(systemName: "location.north.fill")
                Circle().fill(speedAvailable ? theme.accent : .gray)
                    .frame(width: max(5, h * 0.14), height: max(5, h * 0.14))
                Rectangle().fill(.white.opacity(0.55))
                    .frame(width: 1, height: h * 0.43)
                BluetoothGlyph()
                    .frame(width: h * 0.27, height: h * 0.43)
                Circle().fill(bmsAvailable ? theme.accent : .gray)
                    .frame(width: max(5, h * 0.14), height: max(5, h * 0.14))
                Rectangle().fill(.white.opacity(0.55))
                    .frame(width: 1, height: h * 0.43)
                PhoneChargeMeter()
            }
            .font(.system(size: max(13, h * 0.34), weight: .medium))
            .foregroundStyle(colorScheme == .light ? Color(white: 0.15) : .white)
            .padding(.horizontal, max(14, w * 0.031))
            .padding(.bottom, h * 0.08)
            .frame(width: w, height: h)
        }
    }
}

// Il dock GPS inferiore controlla la mappa senza duplicare i tasti sopra
// la cartografia; Home rimane gestita dalla RootView.
enum GPSMapCommand {
    case toggleNavigation, toggleProjection, noseView, focusRoute
    case recenter, zoomIn, zoomOut
}

@MainActor
final class GPSMapControlStore: ObservableObject {
    static let shared = GPSMapControlStore()
    @Published var is3D = true
    @Published var headingUp = false
    let commands = PassthroughSubject<GPSMapCommand, Never>()
    private init() {}
    func send(_ command: GPSMapCommand) { commands.send(command) }
}

// Fascia nera della ricerca GPS: la sommità coincide con il tratto
// inclinato e con il ginocchio della linea arancione della top bar.
// Le coordinate sono la proiezione esatta del GPSHorizonLine nel MapKit
// esteso (larghezza 0,64 e altezza 0,89 del cockpit, centro 0,68/0,49).
private struct GPSSearchTopBand: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let fullW = w / 0.64, fullH = h / 0.89
        let mapLeft = fullW * 0.36, mapTop = fullH * 0.045
        let left = CGPoint(x: fullW * 0.45 - mapLeft,
                           y: fullH * 0.23 - mapTop)
        let knee = CGPoint(x: fullW * 0.54 - mapLeft,
                           y: fullH * 0.085 - mapTop)
        let right = CGPoint(x: w, y: knee.y)
        let rowHeight = max(43, min(60, h * 0.089))
        // Solo il BORDO SUPERIORE segue la diagonale e il ginocchio.
        // Quello INFERIORE è una singola linea orizzontale, senza punta:
        // resta qualche punto sotto l'estremità sinistra della diagonale.
        let bottomY = max(left.y + max(2, h * 0.008),
                          knee.y + rowHeight + 3)
        var p = Path()
        p.move(to: left)
        p.addArc(tangent1End: knee, tangent2End: right,
                 radius: CockpitContourGeometry.cornerRadius(
                     in: CGSize(width: fullW, height: fullH)))
        p.addLine(to: right)
        p.addLine(to: CGPoint(x: w, y: bottomY))
        p.addLine(to: CGPoint(x: left.x, y: bottomY))
        p.closeSubpath()
        return p
    }
}

// La forma dell'indirizzo ha il bordo superiore a ginocchio e la
// base orizzontale; solo gli ultimi punti in basso si dissolvono
// progressivamente nella mappa, senza cancellare le icone di ricerca.
private struct GPSSearchBottomFade: View {
    var body: some View {
        GeometryReader { geometry in
            let h = geometry.size.height
            let fullH = h / 0.89
            let mapTop = fullH * 0.045
            let leftY = fullH * 0.23 - mapTop
            let kneeY = fullH * 0.085 - mapTop
            let rowHeight = max(43, min(60, h * 0.089))
            let bottomY = max(leftY + max(2, h * 0.008),
                              kneeY + rowHeight + 3)
            let fadeStart = max(0, (bottomY - max(16, h * 0.045)) / h)
            let fadeEnd = min(1, bottomY / h)
            LinearGradient(stops: [
                .init(color: .white, location: 0),
                .init(color: .white, location: fadeStart),
                .init(color: .clear, location: fadeEnd),
                .init(color: .clear, location: 1)
            ], startPoint: .top, endPoint: .bottom)
        }
        .allowsHitTesting(false)
    }
}

// Ricerca e anteprima della navigazione NON presentano NavigationStack né
// aprono un'altra pagina: la mappa è figlia del cockpit GPS.
@MainActor
private struct GPSCockpitMap: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var gps: GPSRideManager
    @StateObject private var navigation = EcoNavigationStore.shared
    @AppStorage("ecojumbo.mapsDestination") private var destination = ""
    @State private var camera: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    @State private var visibleCamera: MapCamera?
    @State private var hasCenteredOnGPS = false
    @State private var followsUser = true
    @State private var followDistance: CLLocationDistance = 2600
    @StateObject private var mapControls = GPSMapControlStore.shared
    @State private var lastKnownHeading: CLLocationDirection?
    let theme: CockpitTheme

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack(alignment: .top) {
                Map(position: $camera) {
                    UserAnnotation()
                    if let roadRoute = navigation.route {
                        MapPolyline(roadRoute.polyline)
                            .stroke(theme.accent, lineWidth: 5)
                    }
                    if let coordinate = navigation.destinationCoordinate {
                        Marker(navigation.destinationName, coordinate: coordinate)
                    }
                }
                // Terreno ed edifici 3D dove Apple Maps li rende disponibili.
                .mapStyle(.standard(elevation: mapControls.is3D ? .realistic : .flat))
                // La mappa standard eredita il tema diurno/notturno dalla WindowGroup.
                .environment(\.colorScheme, colorScheme)
                .mapControls { MapCompass() }
                .onMapCameraChange(frequency: .onEnd) { context in
                    visibleCamera = context.camera
                    // Se l'utente trascina la mappa, non riportarla subito
                    // sulla posizione dello scooter.
                    if camera.positionedByUser { followsUser = false }
                }
                // Soltanto il contenuto mappa sfuma nel carbonio a sinistra:
                // la barra di ricerca e i comandi restano nitidi e cliccabili.
                .mask(LinearGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white.opacity(0.60), location: 0.15),
                    .init(color: .white, location: 0.34),
                    .init(color: .white, location: 1)
                ], startPoint: .leading, endPoint: .trailing))
                LinearGradient(stops: [
                    .init(color: colorScheme == .light ? Color.white.opacity(0.72) : .black.opacity(0.80), location: 0),
                    .init(color: colorScheme == .light ? Color.white.opacity(0.20) : .black.opacity(0.26), location: 0.20),
                    .init(color: .clear, location: 0.39),
                    .init(color: .clear, location: 1)
                ], startPoint: .leading, endPoint: .trailing)
                    .allowsHitTesting(false)
                LinearGradient(stops: [
                    .init(color: colorScheme == .light ? Color.white.opacity(0.67) : .black.opacity(0.82), location: 0),
                    .init(color: .clear, location: 0.22),
                    .init(color: .clear, location: 0.76),
                    .init(color: colorScheme == .light ? Color.white.opacity(0.34) : .black.opacity(0.85), location: 1)
                ], startPoint: .top, endPoint: .bottom)
                    .allowsHitTesting(false)
                GPSSearchTopBand()
                    .fill(LinearGradient(colors: colorScheme == .light ? [
                        Color.white.opacity(0.96),
                        Color(red: 0.90, green: 0.93, blue: 0.97).opacity(0.90)
                    ] : [
                        Color.black.opacity(0.50),
                        Color.black.opacity(0.50)
                    ], startPoint: .top, endPoint: .bottom))
                    .frame(width: w, height: h)
                    .mask(GPSSearchBottomFade())
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 7) {
                    // GPS e ricerca indirizzo nella STESSA barra, non su due fasce.
                    HStack(spacing: max(6, w * 0.008)) {
                        Label("GPS", systemImage: "location.north.fill")
                            .font(.system(size: min(19, max(12, h * 0.028)), weight: .bold))
                            .fixedSize()
                        Rectangle()
                            .fill(colorScheme == .light ? Color.black.opacity(0.36) : .white.opacity(0.40))
                            .frame(width: 1, height: min(25, h * 0.038))
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(colorScheme == .light ? Color(white: 0.30) : .white.opacity(0.70))
                        TextField("Indirizzo di destinazione", text: $destination)
                            .font(.system(size: min(19, max(12, h * 0.030))))
                            .foregroundStyle(colorScheme == .light ? Color(white: 0.15) : .white)
                            .tint(theme.accent)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .submitLabel(.search)
                            .onSubmit(calculateRoute)
                            .accessibilityLabel("Cerca destinazione GPS")
                        if navigation.route != nil && w > 780 {
                            Text(navigation.distanceLabel)
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(colorScheme == .light ? Color(white: 0.25) : .white.opacity(0.77))
                        }
                        Button(action: calculateRoute) {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                .foregroundStyle(theme.accent)
                        }
                        .disabled(navigation.isLoading ||
                                  destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityLabel("Calcola itinerario stradale")
                        if navigation.route != nil {
                            Button {
                                navigation.clear()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(colorScheme == .light ? Color(white: 0.15) : .white)
                            }
                            .accessibilityLabel("Cancella itinerario")
                        }
                    }
                    .font(.system(size: min(22, max(14, h * 0.034)), weight: .semibold))
                    .buttonStyle(.plain)
                    .padding(.horizontal, max(10, w * 0.017))
                    .frame(height: max(43, min(60, h * 0.089)))
                    // La fascia sagomata sottostante fornisce il fondo:
                    // nessun riquadro nero arrotondato che stacchi il ginocchio.
                    .background(Color.clear)
                    // La mappa parte dietro al quadrante; la ricerca rimane
                    // a destra del bordo del tachimetro, sempre cliccabile.
                    .padding(.leading, w * 0.285)
                    .padding(.trailing, max(10, w * 0.022))

                    // In assenza di posizione non nascondere la causa dietro
                    // al trattino del tachimetro: permessi, precisione e retry.
                    if gps.currentCoordinate() == nil {
                        HStack(spacing: 7) {
                            Image(systemName: "location.slash")
                                .foregroundStyle(.orange)
                            Text(gps.state)
                                .font(.system(size: max(11, h * 0.023), weight: .medium))
                                .lineLimit(2)
                                .foregroundStyle(colorScheme == .light ? Color(white: 0.15) : .white)
                            Spacer(minLength: 3)
                            Button(gps.isPermissionDenied ? "Impostazioni" : "Riprova") {
                                if gps.isPermissionDenied,
                                   let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                } else {
                                    gps.retryLocation()
                                }
                            }
                            .font(.system(size: max(11, h * 0.024), weight: .bold))
                            .foregroundStyle(theme.accent)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 7)
                        .background(colorScheme == .light ? Color.white.opacity(0.91) : Color.black.opacity(0.83),
                                    in: RoundedRectangle(cornerRadius: 9))
                        .padding(.leading, w * 0.285)
                        .padding(.trailing, max(10, w * 0.022))
                    }

                    // Nessun pannello manovra sopra la mappa:
                    // solo il simbolo dentro il tachimetro.
                    if navigation.isLoading {
                        ProgressView("Calcolo il percorso…")
                            .font(.caption)
                            .padding(8)
                            .background(colorScheme == .light ? Color.white.opacity(0.88) : .black.opacity(0.78),
                                        in: RoundedRectangle(cornerRadius: 8))
                            .padding(.leading, w * 0.255)
                    } else if let errorMessage = navigation.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.orange)
                            .lineLimit(2)
                            .padding(8)
                            .background(colorScheme == .light ? Color.white.opacity(0.88) : .black.opacity(0.78),
                                        in: RoundedRectangle(cornerRadius: 8))
                            .padding(.leading, w * 0.255)
                    }
                    Spacer(minLength: 0)
                }
                // Il bordo superiore si allinea alla top bar della Home GPS.
                .padding(.top, h * 0.045)
                .frame(width: w, height: h, alignment: .topLeading)

                // Sei letture leggermente più grandi, ma raccolte nel bordo destro;
                // solo il trip parziale intercetta il gesto di pressione prolungata.
                let glassWidth = w * 0.265 * 0.70
                let glassHeight = h * 0.60
                GPSCompactReadings(theme: theme)
                    .frame(width: glassWidth, height: glassHeight)
                    .position(x: w - max(6, w * 0.012) - glassWidth / 2,
                              y: h * (0.21 + 0.60 / 2))

            }
            .frame(width: w, height: h)
            // Nessuna clip arrotondata e nessun bordo rettangolare sulla mappa.
            .onAppear {
                gps.start()
                hasCenteredOnGPS = gps.currentCoordinate() != nil
                if navigation.isNavigating {
                    mapControls.headingUp = true
                    activateNoseView()
                } else {
                    focusOnRoute()
                }
                if navigation.isWaitingForGPS {
                    Task {
                        await navigation.resumePendingRoute(origin: gps.currentCoordinate())
                    }
                }
            }
            .onReceive(gps.$lastGPSCoordinate) { coordinate in
                guard let coordinate, gps.currentCoordinate() != nil else { return }
                if navigation.isWaitingForGPS {
                    Task {
                        await navigation.resumePendingRoute(origin: gps.currentCoordinate())
                    }
                }
                navigation.updateProgress(at: coordinate)
                if let course = gps.currentCourse() { lastKnownHeading = course }
                if !hasCenteredOnGPS {
                    hasCenteredOnGPS = true
                    if navigation.route == nil { recenterOnUser() }
                } else if followsUser {
                    followCamera(at: coordinate)
                }
            }
            .onChange(of: navigation.routeRevision) { _, _ in focusOnRoute() }
            .onReceive(mapControls.commands) { command in
                switch command {
                case .toggleNavigation:
                    if navigation.isNavigating { navigation.stopNavigation() }
                    else { startNavigation() }
                case .toggleProjection: toggleProjection()
                case .noseView: activateNoseView()
                case .focusRoute: focusOnRoute()
                case .recenter: recenterOnUser()
                case .zoomIn: zoom(inward: true)
                case .zoomOut: zoom(inward: false)
                }
            }
        }
    }

    private func startNavigation() {
        guard navigation.startNavigation(at: gps.currentCoordinate()) else { return }
        activateNoseView()
    }

    private func activateNoseView() {
        guard let point = gps.currentCoordinate() else { return }
        mapControls.headingUp = true
        followsUser = true
        followDistance = min(followDistance, 950)
        if let course = gps.currentCourse() { lastKnownHeading = course }
        followCamera(at: point)
    }

    // La mappa 3D usa inclinazione 55°, la 2D è realmente vista dall'alto.
    private func toggleProjection() {
        mapControls.is3D.toggle()
        if followsUser, let point = gps.currentCoordinate() {
            followCamera(at: point)
        } else if let current = visibleCamera {
            camera = .camera(MapCamera(centerCoordinate: current.centerCoordinate,
                                       distance: current.distance,
                                       heading: current.heading, pitch: mapControls.is3D ? 55 : 0))
        }
    }

    private func followCamera(at coordinate: CLLocationCoordinate2D) {
        guard CLLocationCoordinate2DIsValid(coordinate) else { return }
        let course = gps.currentCourse()
        if let course { lastKnownHeading = course }
        let heading = mapControls.headingUp ? (course ?? lastKnownHeading ?? 0) : 0
        // Visuale dal muso: sposta lievemente il centro della telecamera
        // in avanti nella direzione di marcia, mantenendo il veicolo più in basso.
        let lookAhead = mapControls.headingUp && (course != nil || lastKnownHeading != nil)
            ? min(230, max(45, followDistance * 0.14)) : 0
        let bearing = heading * .pi / 180
        let longitudeScale = max(0.2, abs(cos(coordinate.latitude * .pi / 180)))
        let center = CLLocationCoordinate2D(
            latitude: coordinate.latitude + lookAhead * cos(bearing) / 111_320,
            longitude: coordinate.longitude + lookAhead * sin(bearing) / (111_320 * longitudeScale))
        camera = .camera(MapCamera(centerCoordinate: center,
                                   distance: followDistance,
                                   heading: heading, pitch: mapControls.is3D ? 55 : 0))
    }

    private func recenterOnUser() {
        guard let point = gps.currentCoordinate() else {
            focusOnRoute()
            return
        }
        followsUser = true
        mapControls.headingUp = false
        followDistance = 1100
        followCamera(at: point)
    }

    private func zoom(inward: Bool) {
        let factor: CLLocationDistance = inward ? 0.64 : 1.56
        if let current = visibleCamera {
            let distance = min(90_000, max(150, current.distance * factor))
            if followsUser, let point = gps.currentCoordinate() {
                followDistance = distance
                followCamera(at: point)
            } else {
                camera = .camera(MapCamera(centerCoordinate: current.centerCoordinate,
                                           distance: distance,
                                           heading: current.heading, pitch: mapControls.is3D ? 55 : 0))
            }
        } else if let point = gps.currentCoordinate() {
            let distance: CLLocationDistance = inward ? 650 : 2400
            followDistance = distance
            followCamera(at: point)
        } else {
            focusOnRoute()
        }
    }

    private func calculateRoute() {
        Task {
            await navigation.plan(destination: destination, origin: gps.currentCoordinate())
        }
    }

    private func focusOnRoute() {
        if let route = navigation.route {
            followsUser = false
            let region = MKCoordinateRegion(route.polyline.boundingMapRect)
            let sw = CLLocation(latitude: region.center.latitude - region.span.latitudeDelta / 2,
                                longitude: region.center.longitude - region.span.longitudeDelta / 2)
            let ne = CLLocation(latitude: region.center.latitude + region.span.latitudeDelta / 2,
                                longitude: region.center.longitude + region.span.longitudeDelta / 2)
            let diagonal = sw.distance(from: ne)
            camera = .camera(MapCamera(centerCoordinate: region.center,
                                       distance: min(90_000, max(1600, diagonal * 1.8)),
                                       heading: 0, pitch: mapControls.is3D ? 55 : 0))
        } else if let point = gps.currentCoordinate() {
            followsUser = true
            followDistance = 2600
            followCamera(at: point)
        } else if let destinationPoint = navigation.destinationCoordinate {
            // Se manca il GPS, mostra la destinazione realmente trovata:
            // non una vista continentale indistinta né una partenza inventata.
            followsUser = false
            camera = .camera(MapCamera(centerCoordinate: destinationPoint,
                                       distance: 4500, heading: 0,
                                       pitch: mapControls.is3D ? 55 : 0))
        } else {
            followsUser = true
            // Non inventare coordinate in assenza di un fix GPS reale.
            camera = .userLocation(followsHeading: false, fallback: .automatic)
        }
    }
}

// Le sei letture continuano a usare dati reali dal BMS e dal GPS.
// Ogni valore è in un pannello di vetro indipendente, non su banda nera.
@MainActor
private struct GPSCompactReadings: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var gps: GPSRideManager
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    let theme: CockpitTheme

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let gap = max(5, h * 0.018)
            // La somma delle sei altezze e dei cinque intervalli resta
            // sempre identica allo spazio disponibile: niente sovrapposizioni.
            let tileHeight = max(1, (h - 5 * gap) / 6)
            let live = bluetooth.snapshot
            VStack(spacing: gap) {
                glassReading(live.map { "\($0.soc)%" } ?? "—%",
                             icon: "bolt.fill", height: tileHeight)
                glassReading(live.map { String(format: "%.0f V", $0.voltage) } ?? "— V",
                             icon: "v.circle", height: tileHeight)
                glassReading(live.map { String(format: "%.0f A", -$0.current) } ?? "— A",
                             icon: "a.circle", height: tileHeight)
                glassReading(live.map { String(format: "%.1f kW", -$0.power / 1000) } ?? "— kW",
                             icon: "chart.bar.fill", height: tileHeight)
                glassReading(String(format: "%.1f km", gps.tripKm),
                             icon: "point.topleft.down.curvedto.point.bottomright.up",
                             height: tileHeight, resettable: true)
                glassReading(gps.hasOdometer ? String(format: "%.0f km", gps.totalKm) : "— km",
                             icon: "speedometer", height: tileHeight)
            }
            .frame(width: geo.size.width, height: h, alignment: .trailing)
        }
    }

    private func glassReading(_ value: String, icon: String, height: CGFloat,
                              resettable: Bool = false) -> some View {
        let corner = max(10, height * 0.21)
        return HStack(spacing: max(4, height * 0.07)) {
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: min(37, max(12, height * 0.38)), weight: .semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.54)
                .foregroundStyle(colorScheme == .light ? Color(white: 0.16) : .white)
                .shadow(color: .black.opacity(0.65), radius: 2, y: 1)
            Rectangle()
                .fill(colorScheme == .light ? Color.black.opacity(0.29) : .white.opacity(0.53))
                .frame(width: 1, height: height * 0.44)
            Image(systemName: icon)
                .font(.system(size: min(30, max(12, height * 0.34))))
                .foregroundStyle(theme.accent)
                .frame(width: height * 0.40)
        }
        .padding(.horizontal, max(4, height * 0.07))
        .frame(height: height)
        .background(colorScheme == .light ? .regularMaterial : .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: corner, style: .continuous))
        .background {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(LinearGradient(colors: [
                    .white.opacity(0.17),
                    .white.opacity(0.06),
                    .black.opacity(0.05)
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .overlay {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(LinearGradient(colors: [
                    .white.opacity(0.48),
                    .white.opacity(0.12),
                    .white.opacity(0.27)
                ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1)
                .allowsHitTesting(false)
        }
        .shadow(color: .black.opacity(0.28), radius: 5, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: corner))
        .onLongPressGesture(minimumDuration: 1.3) {
            guard resettable else { return }
            gps.resetTrip()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .allowsHitTesting(resettable)
        .accessibilityHint(resettable
            ? "Tieni premuto per 1,3 secondi per azzerare il viaggio parziale." : "")
        .accessibilityAction(named: "Azzera chilometri parziali") {
            if resettable { gps.resetTrip() }
        }
    }
}
