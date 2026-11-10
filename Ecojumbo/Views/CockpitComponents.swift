import SwiftUI
import UIKit

// EJ 1.09 — cockpit premium nativo ispirato al riferimento fornito dall'utente.
// Geometry, rings, numerals and panels are real SwiftUI controls (no reference bitmap as UI).
// Misure esclusivamente da Core Location / JK BLE, senza campioni sintetici.
enum CockpitTheme: String, CaseIterable, Identifiable {
    case copper = "Rame"
    case glacier = "Ghiaccio"
    case graphite = "Grafite"
    case racing = "Racing"
    var id: String { rawValue }
    var accent: Color {
        switch self {
        case .copper: Color(red: 1, green: 0.47, blue: 0.04)
        case .glacier: Color(red: 0.18, green: 0.79, blue: 0.91)
        case .graphite: Color(red: 0.80, green: 0.82, blue: 0.85)
        case .racing: Color(red: 0.95, green: 0.18, blue: 0.17)
        }
    }
    var secondary: Color {
        switch self {
        case .copper: Color(red: 0.72, green: 0.21, blue: 0.13)
        case .glacier: Color(red: 0.13, green: 0.44, blue: 0.68)
        case .graphite: Color(red: 0.38, green: 0.43, blue: 0.48)
        case .racing: Color(red: 0.69, green: 0.12, blue: 0.13)
        }
    }
    var steel: Color { Color(red: 0.85, green: 0.87, blue: 0.89) }
    var shadowAccent: Color { accent.opacity(0.68) }
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

// Un'unica ala per lato; bordo morbido e due sottili fenditure luminose.
// L'ala è disegnata sotto il disco opaco della strumentazione, come nel riferimento.
// Barre reali sotto ciascuna lettura: se il valore manca non c'è alcun riempimento.
// I riferimenti di scala sono configurabili e NON modificano limiti di sicurezza.
private struct WingReading {
    let value: String
    let title: String
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
                            .init(color: theme.accent.opacity(0.86), location: 0),
                            .init(color: theme.accent, location: 0.70),
                            .init(color: Color(red: 1.0, green: 0.77, blue: 0.38), location: 1)
                        ], startPoint: .leading, endPoint: .trailing))
                        .frame(width: fillWidth, height: h * 0.84)
                        .padding(.leading, h * 0.10)
                        .shadow(color: theme.accent.opacity(0.90), radius: h * 1.2)
                        .shadow(color: theme.accent.opacity(0.55), radius: h * 0.52)
                }
            }
            .frame(width: w, height: h)
        }
        .animation(.easeInOut(duration: 0.35), value: fraction)
        .accessibilityValue(fraction.map { "\(Int(($0 * 100).rounded())) percento della scala grafica" } ?? "Nessun dato")
    }
}

// Un'unica ala per lato, con tre strumenti e relative barre di valore luminose.
// Il quadrante viene renderizzato sopra le ali: la sua superficie è opaca.
private struct PremiumWing: View {
    let readings: [WingReading]
    let theme: CockpitTheme
    let left: Bool

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                RoundedRectangle(cornerRadius: h * 0.16, style: .continuous)
                    .fill(LinearGradient(stops: [
                        .init(color: Color(white: 0.23), location: 0),
                        .init(color: Color(white: 0.10), location: 0.24),
                        .init(color: Color(white: 0.12), location: 0.60),
                        .init(color: Color(white: 0.16), location: 1)
                    ], startPoint: .top, endPoint: .bottom))
                    .overlay {
                        RoundedRectangle(cornerRadius: h * 0.16, style: .continuous)
                            .stroke(LinearGradient(colors: [.white.opacity(0.35),
                                                           .white.opacity(0.035), .white.opacity(0.30)],
                                                   startPoint: .top, endPoint: .bottom), lineWidth: 1.0)
                    }
                    .shadow(color: .black.opacity(0.83), radius: h * 0.08, y: 5)

                ForEach(readings.indices, id: \.self) { index in
                    let reading = readings[index]
                    VStack(spacing: h * 0.028) {
                        Text(reading.value)
                            .font(.system(size: Swift.min(h * 0.144, w * 0.135),
                                          weight: .semibold, design: .default))
                            .monospacedDigit()
                            .tracking(-0.5)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.49)
                            .shadow(color: .black.opacity(0.83), radius: 2, y: 2)
                            .frame(height: h * 0.145)
                        MetricGlowBar(fraction: reading.fraction, theme: theme)
                            .frame(height: Swift.max(5, h * 0.038))
                    }
                    .frame(width: w * 0.65, height: h / 3)
                    .position(x: w * (left ? 0.345 : 0.655),
                              y: h * (CGFloat(index) + 0.48) / 3)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(reading.title): \(reading.value)")
                }
            }
            .frame(width: w, height: h)
        }
        .accessibilityElement(children: .contain)
    }
}

// La top bar orizzontale si interrompe prima degli anelli del tachimetro.
// Le estremità si affievoliscono nei pressi della strumentazione, senza chiuderne la corona.
private struct SplitHorizonLine: View {
    let theme: CockpitTheme
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let y = h * 0.74
            ZStack {
                ForEach([true, false], id: \.self) { left in
                    let path = Path { p in
                        if left {
                            p.move(to: CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: w * 0.320, y: y))
                        } else {
                            p.move(to: CGPoint(x: w * 0.680, y: y))
                            p.addLine(to: CGPoint(x: w, y: y))
                        }
                    }
                    let glow = LinearGradient(stops: left ? [
                        .init(color: theme.accent, location: 0),
                        .init(color: theme.accent, location: 0.70),
                        .init(color: theme.accent.opacity(0.02), location: 1)
                    ] : [
                        .init(color: theme.accent.opacity(0.02), location: 0),
                        .init(color: theme.accent, location: 0.30),
                        .init(color: theme.accent, location: 1)
                    ], startPoint: .leading, endPoint: .trailing)
                    path.stroke(glow, lineWidth: h * 0.21).blur(radius: h * 0.16)
                    path.stroke(glow, lineWidth: h * 0.07).blur(radius: h * 0.045)
                    path.stroke(glow, style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
                }
            }
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
    @AppStorage("ecojumbo.bars.rangeMaxKm") private var rangeMaxKm = 200.0
    @AppStorage("ecojumbo.bars.averagePowerMaxKW") private var averagePowerMaxKW = 5.0
    @AppStorage("ecojumbo.bars.tripMaxKm") private var tripMaxKm = 100.0
    @AppStorage("ecojumbo.bars.odometerCycleKm") private var odometerCycleKm = 1000.0
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
                        title: "Carica residua",
                        fraction: CockpitBarMath.unit(live.map { Double($0.soc) }, maximum: 100)),
            WingReading(value: live.map { String(format: "%.1f V", $0.voltage) } ?? "— V",
                        title: "Tensione batteria",
                        fraction: CockpitBarMath.unit(live?.voltage, minimum: 50, maximum: 73)),
            WingReading(value: rangeKm.map { String(format: "%.0f km", $0) } ?? "— km",
                        title: "Autonomia stimata",
                        fraction: CockpitBarMath.unit(rangeKm, maximum: rangeMaxKm))
        ]
    }
    private var rightRows: [WingReading] {
        let average = bluetooth.session.averageDischargeKW
        let partial = (gps.isReceiving || gps.tripKm > 0) ? gps.tripKm : nil
        let total = gps.hasOdometer ? gps.totalKm : nil
        return [
            WingReading(value: average.map { String(format: "%.1f kW", $0) } ?? "— kW",
                        title: "Potenza media del viaggio",
                        fraction: CockpitBarMath.unit(average, maximum: averagePowerMaxKW)),
            WingReading(value: partial.map { String(format: "%.1f km", $0) } ?? "— km",
                        title: "Trip parziale",
                        fraction: CockpitBarMath.unit(partial, maximum: tripMaxKm)),
            WingReading(value: total.map { String(format: "%.0f km", $0) } ?? "— km",
                        title: "Chilometraggio scooter",
                        fraction: CockpitBarMath.odometerCycle(total, cycle: odometerCycleKm))
        ]
    }

    var body:some View {
        GeometryReader { geo in
            let w=geo.size.width,h=geo.size.height
            let headerHeight = h * 0.125
            let wingHeight = h * 0.560
            let wingWidth = w * 0.390
            // Un cerchio di diametro <= 93% della dimensione verticale:
            // evita i tagli in landscape anche con le corone e il loro alone.
            let dialSize = min(h * 0.93, w * 0.57)
            ZStack(alignment: .topLeading) {
                CarbonBackdrop(theme: theme)

                PremiumWing(readings: leftRows, theme: theme, left: true)
                    .frame(width: wingWidth, height: wingHeight)
                    .position(x: wingWidth / 2, y: h * 0.475)
                    .zIndex(1)
                PremiumWing(readings: rightRows, theme: theme, left: false)
                    .frame(width: wingWidth, height: wingHeight)
                    .position(x: w - wingWidth / 2, y: h * 0.475)
                    .zIndex(1)

                // Disco carbonio opaco in PRIMO PIANO: i dati laterali restano dietro.
                OpenSpeedCluster(speed: liveSpeed,
                                 current: live.map { -($0.current) },
                                 power: live.map { -($0.power) },
                                 theme: theme)
                    .frame(width: dialSize, height: dialSize)
                    .position(x: w / 2, y: h * 0.50)
                    .zIndex(30)

                // Raccordo luminoso superiore concentrico al tachimetro, in primo piano.
                GaugeArc(start: 208, end: 332)
                    .stroke(theme.accent.opacity(0.48), lineWidth: max(3, h * 0.009))
                    .blur(radius: h * 0.014)
                    .frame(width: dialSize * 0.992, height: dialSize * 0.992)
                    .position(x: w * 0.50, y: h * 0.50)
                    .zIndex(33)
                GaugeArc(start: 208, end: 332)
                    .stroke(theme.accent.opacity(0.90), lineWidth: 1.4)
                    .frame(width: dialSize * 0.992, height: dialSize * 0.992)
                    .position(x: w * 0.50, y: h * 0.50)
                    .zIndex(34)
                SplitHorizonLine(theme: theme)
                    .frame(width: w, height: headerHeight)
                    .zIndex(35)
                topInfoBar(height: headerHeight, width: w)
                    .frame(width: w, height: headerHeight)
                    .zIndex(40)
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
            let pt=CGPoint(x:rect.midX+rad*cos(a),y:rect.midY+rad*sin(a))
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
            let radius = d * 0.393
            for index in 0...48 {
                let angle = (146.0 + Double(index) * 248.0 / 48) * Double.pi / 180
                let major = index.isMultiple(of: 8)
                let medium = index.isMultiple(of: 4)
                let inner = radius - (major ? d * 0.030 : medium ? d * 0.021 : d * 0.013)
                var tick = Path()
                tick.move(to: CGPoint(x: d/2 + cos(angle) * inner,
                                      y: d/2 + sin(angle) * inner))
                tick.addLine(to: CGPoint(x: d/2 + cos(angle) * radius,
                                        y: d/2 + sin(angle) * radius))
                context.stroke(tick, with: .color(.white.opacity(major ? 1 : 0.77)),
                               style: StrokeStyle(lineWidth: major ? d * 0.005 : d * 0.0022,
                                                  lineCap: .round))
            }
        }
        .frame(width: d, height: d)
        .accessibilityHidden(true)
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
                let endPoint = CGPoint(x: d/2 + radius * cos(angle),
                                       y: d/2 + radius * sin(angle))
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

private struct SegmentedGaugeBar:View {
    let d:CGFloat
    let fraction:Double?
    let start:Double
    let end:Double
    let count:Int
    let radiusFactor:CGFloat
    let activeColor:Color
    let idleColor:Color

    var body:some View {
        Canvas { ctx, _ in
            for index in 0..<count {
                let t=Double(index)/Double(count)
                let a1=(start+(end-start)*t+0.40)*Double.pi/180
                let a2=(start+(end-start)*Double(index+1)/Double(count)-0.40)*Double.pi/180
                let radius=d*radiusFactor
                var path=Path()
                for step in 0...5 {
                    let a=a1+(a2-a1)*Double(step)/5
                    let pt=CGPoint(x:d/2+radius*cos(a),y:d/2+radius*sin(a))
                    if step==0 {path.move(to:pt)} else {path.addLine(to:pt)}
                }
                let active=fraction.map{t<$0} ?? false
                ctx.stroke(path,with:.color(active ? activeColor : idleColor),
                           style:StrokeStyle(lineWidth:d*0.017,lineCap:.butt))
            }
        }
        .frame(width:d,height:d)
        .animation(.easeOut(duration:0.40),value:fraction)
        .accessibilityHidden(true)
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

                if let speed {
                    HollowSpeedNumber(text: String(Int(speed.rounded())), size: d * 0.390,
                                      accent: UIColor(theme.accent))
                        .frame(width: d * 0.54, height: d * 0.325)
                        .shadow(color: theme.accent.opacity(0.85), radius: d * 0.026)
                        .shadow(color: theme.accent.opacity(0.68), radius: d * 0.009)
                        .position(x: d * 0.50, y: d * 0.505)
                        .accessibilityLabel("Velocità GPS: \(Int(speed.rounded())) chilometri orari")
                } else {
                    Text("—")
                        .font(.system(size: d * 0.24, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.83))
                        .position(x: d * 0.50, y: d * 0.50)
                        .accessibilityLabel("GPS non disponibile")
                }

                // Il profilo luminoso sopra A/kW e quello sotto ai pulsanti
                // sono ORA una sola ContinuousLowerLine in EcojumboRootView.
                // Nessuna curva o decorazione viene più duplicata qui.

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
                .font(.system(size: d * 0.075, weight: .semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .frame(width: d * 0.66, height: d * 0.13)
                .position(x: d * 0.50, y: d * 0.910)
            }
            .frame(width: d, height: d)
        }
        .accessibilityElement(children: .contain)
    }
}

