import SwiftUI
import MapKit
import UIKit
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
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 4) {
                Image(systemName: "thermometer.medium")
                    .foregroundStyle(Color.white.opacity(0.82))
                Text(currentTemperature.map { String(format: "%.0f°C", $0) } ?? "—°C")
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .font(.system(size: 15, weight: .semibold))
            Link("Meteo · Open-Meteo",
                 destination: URL(string: "https://open-meteo.com")!)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(.black.opacity(0.58),
                    in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(currentTemperature.map {
            "Temperatura meteo esterna stimata: \(Int($0.rounded())) gradi Celsius. Fonte Open-Meteo."
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
    static let regenAccent = Color(red: 0.20, green: 0.83, blue: 0.65)
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
    let theme: CockpitTheme
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.015, green: 0.016, blue: 0.019)
                Image("CarbonWeave").resizable(resizingMode: .tile).opacity(0.52)
                LinearGradient(colors: [.black.opacity(0.55), .clear, .black.opacity(0.70)],
                               startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: [theme.secondary.opacity(0.14), .clear, .black.opacity(0.56)],
                               center: .center, startRadius: 0, endRadius: max(geo.size.width, geo.size.height) * 0.62)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
    }
}

// EJ 1.23 — sfumatura grigio antracite SOPRA la top bar, presente in entrambe le
// modalità e indipendente dal tema colore selezionato.
private struct CockpitTopSoftShade: View {
    var body: some View {
        GeometryReader { geo in
            LinearGradient(stops: [
                .init(color: Color(white: 0.30).opacity(0.38), location: 0),
                .init(color: Color(white: 0.23).opacity(0.26), location: 0.48),
                .init(color: Color(white: 0.14).opacity(0.08), location: 0.82),
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
                    .foregroundStyle(.white)
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
                .fill(LinearGradient(colors: [Color(white: 0.105), Color(white: 0.045)],
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
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.85), radius: 2, y: 2)
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

struct CockpitDashboard:View {
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


                PremiumWing(readings: leftRows, theme: theme, left: true)
                    .frame(width: wingWidth, height: wingHeight)
                    .position(x: wingInset + wingWidth / 2, y: h * 0.490)
                    .zIndex(1)
                PremiumWing(readings: rightRows, theme: theme, left: false)
                    .frame(width: wingWidth, height: wingHeight)
                    .position(x: w - wingInset - wingWidth / 2, y: h * 0.490)
                    .zIndex(1)

                // Disco carbonio opaco in PRIMO PIANO: i dati laterali restano dietro.
                OpenSpeedCluster(speed: liveSpeed,
                                 current: live.map { -($0.current) },
                                 power: live.map { -($0.power) },
                                 theme: theme)
                    .frame(width: dialSize, height: dialSize)
                    .position(x: w / 2, y: h * 0.507)
                    .zIndex(30)

                // Raccordo luminoso superiore concentrico al tachimetro, in primo piano.
                GaugeArc(start: 208, end: 332)
                    .stroke(theme.accent.opacity(0.48), lineWidth: max(3, h * 0.009))
                    .blur(radius: h * 0.014)
                    .frame(width: dialSize * 0.992, height: dialSize * 0.992)
                    .position(x: w * 0.50, y: h * 0.507)
                    .zIndex(33)
                GaugeArc(start: 208, end: 332)
                    .stroke(theme.accent.opacity(0.90), lineWidth: 1.4)
                    .frame(width: dialSize * 0.992, height: dialSize * 0.992)
                    .position(x: w * 0.50, y: h * 0.507)
                    .zIndex(34)
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
                .foregroundStyle(.white)
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
        .foregroundStyle(.white)
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
            let color = Color.white.opacity(isMajor ? 1.0 : 0.77)
            let thickness: CGFloat = isMajor ? d * 0.005 : d * 0.0022
            context.stroke(tick, with: .color(color),
                           style: StrokeStyle(lineWidth: thickness, lineCap: .round))
        }
    }
}

/// Stream LED ROSSO progressivo: accesa solo quando esiste una misura GPS valida.
/// L'arco è posto all'interno delle tacche bianche, sotto le due corone segmentate.
/// Il punto luminoso segue la punta effettiva dell'arco; a 0 km/h resta spento.
private struct SpeedLEDStream: View {
    let d: CGFloat
    let speed: Double?
    private let ledRed = Color(red: 1, green: 0.11, blue: 0.09)

    private var progress: Double? {
        guard let speed, speed.isFinite, speed >= 0 else { return nil }
        return min(1, max(0, speed / 120))
    }

    var body: some View {
        ZStack {
            // Anima inerte: si vede la forma della pista ma NON un valore simulato.
            GaugeArc(start: 146, end: 394)
                .stroke(Color(red: 0.29, green: 0.085, blue: 0.07).opacity(0.28),
                        style: StrokeStyle(lineWidth: d * 0.009, lineCap: .round))
                .frame(width: d * 0.722, height: d * 0.722)
            if let progress, progress > 0 {
                GaugeArc(start: 146, end: 394, fraction: progress)
                    .stroke(ledRed.opacity(0.80),
                            style: StrokeStyle(lineWidth: d * 0.034, lineCap: .round))
                    .blur(radius: d * 0.027)
                    .frame(width: d * 0.722, height: d * 0.722)
                GaugeArc(start: 146, end: 394, fraction: progress)
                    .stroke(ledRed, style: StrokeStyle(lineWidth: d * 0.015, lineCap: .round))
                    .shadow(color: ledRed.opacity(0.94), radius: d * 0.010)
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
                    .shadow(color: ledRed, radius: d * 0.027)
                    .shadow(color: ledRed.opacity(0.95), radius: d * 0.014)
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

// UILabel disegna veramente il contorno delle cifre (non testo bianco con un'ombra arancio).
private struct HollowSpeedNumber:UIViewRepresentable {
    let text:String
    let size:CGFloat
    let accent:UIColor
    func makeUIView(context:Context)->UILabel {
        let label=UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.55
        label.numberOfLines = 1
        return label
    }
    func updateUIView(_ uiView:UILabel,context:Context) {
        let font=UIFont.systemFont(ofSize:size,weight:.thin)
        uiView.attributedText = NSAttributedString(string:text,attributes:[
            .font:font,
            .foregroundColor:UIColor.clear,
            .strokeColor:accent,
            .strokeWidth:2.7
        ])
    }
}

// Scala strumentazione e corona a elementi discreti, non una immagine fissa.
// Il numero di velocità è disegnato a contorno; la lettura proviene solo dal GPS.
private struct OpenSpeedCluster: View {
    let speed: Double?
    let current: Double?
    let power: Double?
    let theme: CockpitTheme

    private func magnitude(_ input: Double, limit: Double) -> Double {
        Swift.max(0, Swift.min(1, abs(input) / limit))
    }

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let isRegen = (power ?? 0) < 0
            let outerColor = isRegen ? Color(red: 0.20, green: 0.83, blue: 0.65) : theme.accent
            let innerColor = isRegen ? Color(red: 0.54, green: 0.88, blue: 0.77) : theme.steel
            let powerFill = power.map { magnitude($0, limit: 13_000) }
            let currentFill = current.map { magnitude($0, limit: 206) }
            ZStack {
                // Il carbonio chiude completamente il quadrante sopra le ali sottostanti.
                Circle()
                    .fill(Color(red: 0.016, green: 0.015, blue: 0.017))
                    .frame(width: d * 0.986, height: d * 0.986)
                    .shadow(color: .black.opacity(0.88), radius: d * 0.025)
                Image("CarbonWeave")
                    .resizable(resizingMode: .tile)
                    .opacity(0.74)
                    .frame(width: d * 0.982, height: d * 0.982)
                    .clipShape(Circle())
                Circle()
                    .fill(RadialGradient(colors: [.black.opacity(0.36), .clear,
                                                  .black.opacity(0.55)], center: .center,
                                         startRadius: d * 0.06, endRadius: d * 0.49))
                    .frame(width: d * 0.98, height: d * 0.98)

                // Le due scale hanno un'anima grigia per tutta la corsa; solo dati REALI
                // attivano segmenti luminosi e colorati (mai valori inventati).
                SegmentedGaugeBar(d: d, fraction: powerFill,
                                  start: 149, end: 391, count: 64, radiusFactor: 0.469,
                                  activeColor: outerColor, idleColor: theme.accent.opacity(0.25))
                    .shadow(color: outerColor.opacity(powerFill == nil ? 0.04 : 0.72),
                            radius: d * 0.014)
                SegmentedGaugeBar(d: d, fraction: currentFill,
                                  start: 149, end: 391, count: 64, radiusFactor: 0.427,
                                  activeColor: innerColor, idleColor: .white.opacity(0.36))
                    .shadow(color: innerColor.opacity(currentFill == nil ? 0.02 : 0.28),
                            radius: d * 0.011)

                // Niente numeri fissi della scala 0–120: la striscia LED rossa
                // si estende solo in presenza di velocità GPS valida.
                SpeedLEDStream(d: d, speed: speed)
                SpeedScaleTicks(d: d)

                VStack(spacing: d * 0.004) {
                    if let speed {
                        Text(String(Int(speed.rounded())))
                            .font(.system(size: d * 0.245, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.55)
                            .frame(height: d * 0.245)
                            .accessibilityLabel("Velocità GPS: \(Int(speed.rounded())) chilometri orari")
                    } else {
                        Text("—")
                            .font(.system(size: d * 0.19, weight: .light))
                            .foregroundStyle(.white.opacity(0.90))
                            .frame(height: d * 0.245)
                            .accessibilityLabel("GPS non disponibile")
                    }
                    Text("km/h")
                        .font(.system(size: d * 0.070, weight: .medium))
                        .foregroundStyle(.white.opacity(0.81))
                    Rectangle().fill(.white)
                        .frame(width: d * 0.215, height: max(1.2, d * 0.006))
                        .padding(.top, d * 0.017)
                    Text("GPS")
                        .font(.system(size: d * 0.062, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: d * 0.165, height: d * 0.087)
                        .background(Color.black.opacity(0.88), in:
                            RoundedRectangle(cornerRadius: d * 0.030, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: d * 0.030, style: .continuous)
                                .stroke(theme.accent, lineWidth: max(1, d * 0.003))
                        }
                        .shadow(color: theme.accent.opacity(0.34), radius: d * 0.012)
                        .padding(.top, d * 0.025)
                }
                .frame(width: d * 0.52, height: d * 0.46)
                .position(x: d * 0.50, y: d * 0.485)

                // Il profilo unico sopra A/kW è aperto alle estremita, senza
                // alcuna linea orizzontale sotto i pulsanti di navigazione.

                HStack(spacing: 0) {
                    Text(current.map { String(format: "%.0f A", $0) } ?? "— A")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                    Rectangle().fill(.white.opacity(0.70))
                        .frame(width: 1, height: d * 0.086)
                    Text(power.map { String(format: "%.1f kW", $0 / 1000) } ?? "— kW")
                        .foregroundStyle(isRegen ? Color(red: 0.20, green: 0.83, blue: 0.65) : theme.accent)
                        .frame(maxWidth: .infinity)
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
private struct GPSLowerContour: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let d = GPSDialLayout.size(width: w, height: h)
        let center = GPSDialLayout.centerX(width: w, height: h)
        // Protezione della riga A/kW: la linea resta almeno 12 pt SOPRA i caratteri.
        let textTop = h * 0.494 + d * (0.889 - 0.50 - 0.065)
        let topY = min(h * 0.790, textTop - max(12, h * 0.014))
        let controlH = max(51, min(83, h * 0.105))
        let controlSide = min(controlH * 0.96, w * 0.059, w * 0.052)
        let buttonStart = w - max(12, w * 0.018) - 7 * controlSide - 6 * w * 0.008
        let upperRight = min(center + d * 0.405, w * 0.525 - max(9, w * 0.012))
        let lowerRight = min(center + d * 0.455, buttonStart - max(9, w * 0.012))
        return CockpitContourGeometry.roundedPath(points: [
            CGPoint(x: center - d * 0.455, y: h * 0.985),
            CGPoint(x: center - d * 0.405, y: topY),
            CGPoint(x: upperRight, y: topY),
            CGPoint(x: lowerRight, y: h * 0.985)
        ], corners: [1, 2], radius: CockpitContourGeometry.cornerRadius(in: rect.size))
    }
}

private struct GPSLowerShade: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let d = GPSDialLayout.size(width: w, height: h)
        let center = GPSDialLayout.centerX(width: w, height: h)
        let controlH = max(51, min(83, h * 0.105))
        let controlSide = min(controlH * 0.96, w * 0.059, w * 0.052)
        let buttonStart = w - max(12, w * 0.018) - 7 * controlSide - 6 * w * 0.008
        let rightFoot = min(center + d * 0.455, buttonStart - max(9, w * 0.012))
        var shape = GPSLowerContour().path(in: rect)
        shape.addLine(to: CGPoint(x: rightFoot, y: h))
        shape.addLine(to: CGPoint(x: center - d * 0.455, y: h))
        shape.closeSubpath()
        return shape
    }
}

private struct GPSLowerGlow: View {
    let theme: CockpitTheme

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            ZStack {
                GPSLowerShade()
                    .fill(LinearGradient(stops: [
                        .init(color: .clear, location: 0.74),
                        .init(color: Color(white: 0.31).opacity(0.34), location: 0.83),
                        .init(color: Color(white: 0.16).opacity(0.21), location: 0.93),
                        .init(color: .clear, location: 1)
                    ], startPoint: .top, endPoint: .bottom))
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
    let theme: CockpitTheme
    let now: Date

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

                // MapKit occupa la metà destra ma rimane parte di questo cockpit.
                GPSCockpitMap(theme: theme)
                    .frame(width: w * 0.475, height: h * 0.725)
                    .position(x: w * 0.7625, y: h * 0.455)
                    .zIndex(5)

                GPSHorizonLine(theme: theme)
                    .frame(width: w, height: h)
                    .zIndex(8)

                OpenSpeedCluster(speed: gps.currentSpeed(at: now),
                                 current: live.map { -($0.current) },
                                 power: live.map { -($0.power) },
                                 theme: theme)
                    .frame(width: dialSize, height: dialSize)
                    .position(x: dialCenterX, y: h * 0.494)
                    .zIndex(25)

                GPSGaugeHalo(theme: theme)
                    .frame(width: dialSize, height: dialSize)
                    .position(x: dialCenterX, y: h * 0.494)
                    .zIndex(27)

                // Tratto A/kW più largo e ombreggiato, con piedi esterni ai testi.
                GPSLowerGlow(theme: theme)
                    .frame(width: w, height: h)
                    .allowsHitTesting(false)
                    .zIndex(35)

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
        }
        .allowsHitTesting(false)
    }
}

@MainActor
private struct GPSHeader: View {
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
            .foregroundStyle(.white)
            .padding(.horizontal, max(14, w * 0.031))
            .padding(.bottom, h * 0.08)
            .frame(width: w, height: h)
        }
    }
}

// Ricerca e anteprima della navigazione NON presentano NavigationStack né
// aprono un'altra pagina: la mappa è figlia del cockpit GPS.
@MainActor
private struct GPSCockpitMap: View {
    @EnvironmentObject private var gps: GPSRideManager
    @StateObject private var navigation = EcoNavigationStore.shared
    @AppStorage("ecojumbo.mapsDestination") private var destination = ""
    @State private var camera: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
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
                .mapStyle(.standard(elevation: .flat))
                .mapControls {
                    MapCompass()
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    visibleRegion = context.region
                }

                // Sfumatura su bordo sinistro, superiore e inferiore:
                // il dettaglio stradale resta nitido al centro della mappa.
                LinearGradient(stops: [
                    .init(color: .black.opacity(0.83), location: 0),
                    .init(color: .black.opacity(0.32), location: 0.16),
                    .init(color: .clear, location: 0.37),
                    .init(color: .clear, location: 1)
                ], startPoint: .leading, endPoint: .trailing)
                    .allowsHitTesting(false)
                LinearGradient(stops: [
                    .init(color: .black.opacity(0.55), location: 0),
                    .init(color: .clear, location: 0.24),
                    .init(color: .clear, location: 0.72),
                    .init(color: .black.opacity(0.36), location: 1)
                ], startPoint: .top, endPoint: .bottom)
                    .allowsHitTesting(false)

                VStack(spacing: 5) {
                    HStack(spacing: 6) {
                        Label("GPS", systemImage: "location.north.fill")
                            .font(.system(size: max(12, h * 0.037), weight: .bold))
                        Spacer(minLength: 0)
                        if navigation.route != nil {
                            Text(navigation.distanceLabel)
                            Text(navigation.travelTimeLabel)
                                .foregroundStyle(.white.opacity(0.70))
                        } else {
                            Text("Percorsi")
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        Button {
                            focusOnRoute()
                        } label: {
                            Image(systemName: "scope")
                                .font(.system(size: max(15, h * 0.041)))
                        }
                        .accessibilityLabel("Inquadra percorso e posizione")
                    }
                    .font(.system(size: max(11, h * 0.030), weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 13)
                    .frame(height: max(35, h * 0.12))
                    .background(Color.black.opacity(0.66))

                    HStack(spacing: 7) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white.opacity(0.75))
                        TextField("Indirizzo di destinazione", text: $destination)
                            .font(.system(size: max(12, h * 0.036)))
                            .foregroundStyle(.white)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .submitLabel(.search)
                            .onSubmit(calculateRoute)
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
                                    .foregroundStyle(.white)
                            }
                            .accessibilityLabel("Cancella itinerario")
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: max(34, h * 0.095))
                    .background(Color.black.opacity(0.86), in: RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 8)

                    if navigation.isLoading {
                        ProgressView("Calcolo il percorso…")
                            .font(.caption)
                            .padding(8)
                            .background(.black.opacity(0.86), in: RoundedRectangle(cornerRadius: 8))
                    } else if let errorMessage = navigation.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: max(10, h * 0.027)))
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.leading)
                            .padding(7)
                            .background(.black.opacity(0.86), in: RoundedRectangle(cornerRadius: 8))
                    }

                    Spacer(minLength: 0)
                }
                // Soltanto la riga dei km parziali intercetta il long press;
                // gli altri valori e la sfumatura lasciano usare la mappa.
                GPSCompactReadings(theme: theme)
                    .frame(width: w * 0.31, height: h * 0.72)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .padding(.trailing, 8)
                    .padding(.top, h * 0.18)

                // Comandi mappa sempre visibili: ricentra GPS e zoom + / −.
                VStack {
                    Spacer(minLength: 0)
                    VStack(spacing: 7) {
                        mapAction("scope", accessibility: "Ricentra sulla posizione GPS") {
                            recenterOnUser()
                        }
                        mapAction("plus.magnifyingglass", accessibility: "Ingrandisci mappa") {
                            zoom(inward: true)
                        }
                        mapAction("minus.magnifyingglass", accessibility: "Riduci zoom mappa") {
                            zoom(inward: false)
                        }
                    }
                    .padding(6)
                    .background(Color.black.opacity(0.70),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.leading, 9)
                    .padding(.bottom, 9)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(width: w, height: h)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 0.8)
                    .allowsHitTesting(false)
            }
            .onAppear {
                gps.start()
                focusOnRoute()
            }
            .onChange(of: navigation.routeRevision) { _, _ in focusOnRoute() }
        }
    }

    private func mapAction(_ symbol: String, accessibility: String,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 33, height: 31)
                .background(Color(white: 0.20).opacity(0.80),
                            in: RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibility)
    }

    private func recenterOnUser() {
        guard let point = gps.currentCoordinate() else {
            focusOnRoute()
            return
        }
        camera = .region(MKCoordinateRegion(center: point,
                                             latitudinalMeters: 1200,
                                             longitudinalMeters: 1200))
    }

    private func zoom(inward: Bool) {
        let point = gps.currentCoordinate() ?? navigation.destinationCoordinate
        guard let region = visibleRegion ?? point.map({
            MKCoordinateRegion(center: $0, latitudinalMeters: 3500,
                               longitudinalMeters: 3500)
        }) else { return }
        let factor: CLLocationDegrees = inward ? 0.62 : 1.62
        camera = .region(MKCoordinateRegion(
            center: region.center,
            span: MKCoordinateSpan(
                latitudeDelta: min(60, max(0.0005, region.span.latitudeDelta * factor)),
                longitudeDelta: min(60, max(0.0005, region.span.longitudeDelta * factor))
            )
        ))
    }

    private func calculateRoute() {
        Task {
            await navigation.plan(destination: destination, origin: gps.currentCoordinate())
        }
    }

    private func focusOnRoute() {
        if let route = navigation.route {
            camera = .rect(route.polyline.boundingMapRect)
        } else if let coordinate = gps.currentCoordinate() {
            camera = .region(MKCoordinateRegion(center: coordinate,
                                                 latitudinalMeters: 3500,
                                                 longitudinalMeters: 3500))
        } else {
            camera = .userLocation(followsHeading: false, fallback: .automatic)
        }
    }
}

// Le sei misure rimangono reali: SOC, V, A, potenza, km parziali e totali.
// Lato destro della mappa con icone arancioni come nello screenshot approvato.
@MainActor
private struct GPSCompactReadings: View {
    @EnvironmentObject private var gps: GPSRideManager
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    let theme: CockpitTheme

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let live = bluetooth.snapshot
            VStack(alignment: .trailing, spacing: h * 0.022) {
                reading(live.map { "\($0.soc)%" } ?? "—%", icon: "bolt.fill", height: h)
                reading(live.map { String(format: "%.0f V", $0.voltage) } ?? "— V", icon: "v.circle", height: h)
                reading(live.map { String(format: "%.0f A", -$0.current) } ?? "— A", icon: "a.circle", height: h)
                reading(live.map { String(format: "%.1f kW", -$0.power / 1000) } ?? "— kW", icon: "chart.bar.fill", height: h)
                reading(String(format: "%.1f km", gps.tripKm),
                        icon: "point.topleft.down.curvedto.point.bottomright.up",
                        height: h, resettable: true)
                reading(gps.hasOdometer ? String(format: "%.0f km", gps.totalKm) : "— km",
                        icon: "speedometer", height: h)
            }
            .padding(.vertical, h * 0.07)
            .padding(.horizontal, 7)
            .frame(width: geo.size.width, height: h, alignment: .trailing)
            .background {
                LinearGradient(colors: [.clear, .black.opacity(0.62), .black.opacity(0.87)],
                               startPoint: .leading, endPoint: .trailing)
                    .allowsHitTesting(false)
            }
        }
    }

    private func reading(_ value: String, icon: String, height: CGFloat,
                         resettable: Bool = false) -> some View {
        HStack(spacing: 6) {
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: max(11, height * 0.065), weight: .semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .foregroundStyle(.white)
            Rectangle()
                .fill(.white.opacity(0.55))
                .frame(width: 1, height: height * 0.052)
            Image(systemName: icon)
                .font(.system(size: max(12, height * 0.060)))
                .foregroundStyle(theme.accent)
                .frame(width: height * 0.085)
        }
        .frame(height: hRow(height))
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 1.3) {
            guard resettable else { return }
            gps.resetTrip()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .allowsHitTesting(resettable)
        .accessibilityHint(resettable ? "Tieni premuto per 1,3 secondi per azzerare il viaggio parziale." : "")
        .accessibilityAction(named: "Azzera chilometri parziali") {
            if resettable { gps.resetTrip() }
        }
    }

    private func hRow(_ height: CGFloat) -> CGFloat {
        height * 0.12
    }
}
