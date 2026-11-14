import SwiftUI

// EMT hyperrealistic material primitives. Geometry is vector-based and reactive;
// decorative light is deliberately separate from real GPS/JK telemetry.
enum EMTMaterialPalette {
    static let black = Color(red: 3 / 255, green: 4 / 255, blue: 5 / 255)
    static let glass = Color(red: 16 / 255, green: 17 / 255, blue: 20 / 255)
    static let orange = Color(red: 1, green: 106 / 255, blue: 0)
    static let amber = Color(red: 1, green: 172 / 255, blue: 86 / 255)
    static let ivory = Color(red: 1, green: 244 / 255, blue: 229 / 255)
    static let steel = Color(red: 173 / 255, green: 176 / 255, blue: 181 / 255)
    static let recovery = Color(red: 8 / 255, green: 125 / 255, blue: 1)
    static let discharge = Color(red: 1, green: 72 / 255, blue: 26 / 255)
}

// Multi-pass neon: atmospheric diffusion, focused spill, crisp tube,
// warm specular glint. No blur is applied to text, icons or hit targets.
struct EMTNeonStroke<Contour: Shape>: View {
    let contour: Contour
    let color: Color
    let thickness: CGFloat
    var intensity: Double = 0.65
    var highlights: Bool = true

    var body: some View {
        ZStack {
            contour.stroke(color.opacity(0.22 * intensity),
                           style: StrokeStyle(lineWidth: thickness * 6.5, lineCap: .round, lineJoin: .round))
                .blur(radius: max(3, thickness * 2.4))
            contour.stroke(color.opacity(0.53 * intensity),
                           style: StrokeStyle(lineWidth: thickness * 3.0, lineCap: .round, lineJoin: .round))
                .blur(radius: max(1.2, thickness * 0.88))
            contour.stroke(color,
                           style: StrokeStyle(lineWidth: thickness, lineCap: .round, lineJoin: .round))
            if highlights {
                contour.stroke(EMTMaterialPalette.ivory.opacity(0.70),
                               style: StrokeStyle(lineWidth: max(0.35, thickness * 0.23),
                                                  lineCap: .round, lineJoin: .round))
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct EMTMetallicRim: View {
    let diameter: CGFloat
    var widthFactor: CGFloat = 0.004

    var body: some View {
        Circle()
            .stroke(AngularGradient(stops: [
                .init(color: Color(white: 0.13), location: 0),
                .init(color: EMTMaterialPalette.steel.opacity(0.54), location: 0.15),
                .init(color: .white.opacity(0.94), location: 0.28),
                .init(color: Color(white: 0.21), location: 0.40),
                .init(color: EMTMaterialPalette.steel.opacity(0.64), location: 0.56),
                .init(color: Color(white: 0.09), location: 0.74),
                .init(color: EMTMaterialPalette.steel.opacity(0.78), location: 0.91),
                .init(color: Color(white: 0.13), location: 1)
            ], center: .center),
            lineWidth: max(0.9, diameter * widthFactor))
            .frame(width: diameter, height: diameter)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

// Asymmetrical ring reflections: specular upper-left highlight and
// independent weaker lower reflection, masked to the glass annulus.
struct EMTDialSpecularReflection: View {
    let diameter: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(AngularGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .clear, location: 0.44),
                    .init(color: EMTMaterialPalette.orange.opacity(0.15), location: 0.51),
                    .init(color: EMTMaterialPalette.amber.opacity(0.63), location: 0.58),
                    .init(color: EMTMaterialPalette.ivory.opacity(0.96), location: 0.64),
                    .init(color: EMTMaterialPalette.amber.opacity(0.40), location: 0.71),
                    .init(color: .clear, location: 0.79),
                    .init(color: .clear, location: 1)
                ], center: .center), lineWidth: diameter * 0.075)
                .blur(radius: diameter * 0.008)
            Circle()
                .stroke(AngularGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: EMTMaterialPalette.orange.opacity(0.07), location: 0.16),
                    .init(color: EMTMaterialPalette.amber.opacity(0.30), location: 0.25),
                    .init(color: EMTMaterialPalette.orange.opacity(0.07), location: 0.37),
                    .init(color: .clear, location: 0.47),
                    .init(color: .clear, location: 1)
                ], center: .center), lineWidth: diameter * 0.028)
                .blur(radius: diameter * 0.010)
        }
        .frame(width: diameter * 0.950, height: diameter * 0.950)
        .mask {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: diameter * 0.105))
                .frame(width: diameter * 0.950, height: diameter * 0.950)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct EMTGlossyGlassSurface: View {
    @Environment(\.colorScheme) private var scheme
    let cornerRadius: CGFloat
    var glowColor: Color = EMTMaterialPalette.orange
    var illumination: Double = 0.55

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let rectangle = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            ZStack {
                rectangle.fill(LinearGradient(stops: [
                    .init(color: scheme == .light ? Color.white : Color(white: 0.095), location: 0),
                    .init(color: scheme == .light ? Color(white: 0.94) : Color(white: 0.043), location: 0.52),
                    .init(color: scheme == .light ? Color(white: 0.88) : Color(white: 0.018), location: 1)
                ], startPoint: .top, endPoint: .bottom))
                rectangle.fill(RadialGradient(colors: [
                    glowColor.opacity(scheme == .light ? 0.10 : min(0.88, illumination * 1.20)),
                    glowColor.opacity(scheme == .light ? 0.04 : illumination * 0.29),
                    .clear
                ], center: UnitPoint(x: 0.045, y: 0.96),
                   startRadius: 0, endRadius: max(size.width * 0.26, size.height * 1.0)))
                rectangle.fill(LinearGradient(stops: [
                    .init(color: .white.opacity(scheme == .light ? 0.18 : 0.17), location: 0),
                    .init(color: .white.opacity(0.025), location: 0.12),
                    .init(color: .clear, location: 0.44)
                ], startPoint: .top, endPoint: .bottom))
                rectangle.stroke(LinearGradient(stops: [
                    .init(color: .white.opacity(scheme == .light ? 0.53 : 0.57), location: 0),
                    .init(color: EMTMaterialPalette.steel.opacity(0.36), location: 0.24),
                    .init(color: Color(white: 0.24).opacity(0.35), location: 0.55),
                    .init(color: glowColor.opacity(scheme == .light ? 0.14 : 0.51), location: 0.91),
                    .init(color: .white.opacity(0.37), location: 1)
                ], startPoint: .top, endPoint: .bottom), lineWidth: 0.95)
                rectangle.inset(by: 2.0)
                    .stroke(.white.opacity(scheme == .light ? 0.06 : 0.085), lineWidth: 0.55)
            }
            .frame(width: size.width, height: size.height)
            .clipShape(rectangle)
            .shadow(color: .black.opacity(scheme == .light ? 0.09 : 0.62), radius: 7, y: 4)
        }
        .allowsHitTesting(false)
    }
}

struct EMTTelemetryRail: View {
    @Environment(\.colorScheme) private var scheme
    let fraction: Double?
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let progress = fraction.flatMap { $0.isFinite ? min(1, max(0, $0)) : nil }
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LinearGradient(colors: [
                        Color(white: 0.10), Color(white: 0.31), Color(white: 0.12)
                    ], startPoint: .top, endPoint: .bottom))
                Capsule()
                    .stroke(.white.opacity(scheme == .light ? 0.26 : 0.20),
                            lineWidth: max(0.4, h * 0.075))
                if let progress, progress > 0 {
                    Capsule()
                        .fill(LinearGradient(stops: [
                            .init(color: EMTMaterialPalette.amber, location: 0),
                            .init(color: color, location: 0.38),
                            .init(color: EMTMaterialPalette.orange, location: 1)
                        ], startPoint: .top, endPoint: .bottom))
                        .frame(width: max(1, w * progress), height: h * 0.88)
                        .shadow(color: color.opacity(0.55), radius: h * 0.62)
                }
            }
            .frame(width: w, height: h)
        }
        .animation(.easeInOut(duration: 0.34), value: fraction)
        .accessibilityValue(fraction.map {
            "\(Int(($0 * 100).rounded())) percento della scala grafica"
        } ?? "Dato non disponibile")
    }
}

struct EMTDockGlassShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.092, y: h * 0.015))
        p.addLine(to: CGPoint(x: w * 0.971, y: h * 0.015))
        p.addQuadCurve(to: CGPoint(x: w * 0.996, y: h * 0.23),
                       control: CGPoint(x: w * 0.995, y: h * 0.01))
        p.addLine(to: CGPoint(x: w * 0.996, y: h * 0.79))
        p.addQuadCurve(to: CGPoint(x: w * 0.970, y: h * 0.99),
                       control: CGPoint(x: w * 0.997, y: h * 0.99))
        p.addLine(to: CGPoint(x: w * 0.030, y: h * 0.99))
        p.addQuadCurve(to: CGPoint(x: w * 0.004, y: h * 0.79),
                       control: CGPoint(x: w * 0.002, y: h * 0.98))
        p.addLine(to: CGPoint(x: w * 0.043, y: h * 0.20))
        p.addQuadCurve(to: CGPoint(x: w * 0.092, y: h * 0.015),
                       control: CGPoint(x: w * 0.063, y: h * 0.015))
        p.closeSubpath()
        return p
    }
}

private struct EMTDockBottomLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.width * 0.033, y: rect.height * 0.972))
            p.addLine(to: CGPoint(x: rect.width * 0.97, y: rect.height * 0.972))
        }
    }
}

struct EMTDockGlassSurface: View {
    @Environment(\.colorScheme) private var scheme
    let color: Color
    let intensity: Double

    var body: some View {
        GeometryReader { geometry in
            let shape = EMTDockGlassShape()
            let h = geometry.size.height
            ZStack {
                shape.fill(LinearGradient(stops: [
                    .init(color: scheme == .light ? Color.white : Color(white: 0.115), location: 0),
                    .init(color: scheme == .light ? Color(white: 0.93) : Color(white: 0.047), location: 0.30),
                    .init(color: scheme == .light ? Color(white: 0.85) : Color(white: 0.018), location: 1)
                ], startPoint: .top, endPoint: .bottom))
                shape.fill(LinearGradient(colors: [
                    .white.opacity(scheme == .light ? 0.18 : 0.13),
                    .clear, .black.opacity(scheme == .light ? 0.0 : 0.35)
                ], startPoint: .top, endPoint: .bottom))
                shape.stroke(LinearGradient(stops: [
                    .init(color: EMTMaterialPalette.ivory.opacity(0.62), location: 0),
                    .init(color: EMTMaterialPalette.steel.opacity(0.38), location: 0.37),
                    .init(color: color.opacity(0.65), location: 0.98)
                ], startPoint: .top, endPoint: .bottom), lineWidth: 1.1)
                EMTNeonStroke(contour: EMTDockBottomLine(), color: color,
                              thickness: max(0.8, h * 0.013), intensity: intensity * 0.39,
                              highlights: false)
                    .mask(LinearGradient(colors: [.clear, .white, .white, .clear],
                                         startPoint: .leading, endPoint: .trailing))
            }
            .frame(width: geometry.size.width, height: h)
            .shadow(color: .black.opacity(0.55), radius: 7, y: 3)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// Draws ONLY recorded Core Location altitudes (never a synthetic wave).
// Echoes of the same path create the multi-line topographic light.
struct EMTTopographicAltitude: View {
    let points: [TripAltitudePoint]
    let color: Color

    var body: some View {
        Canvas { context, size in
            guard points.count >= 2, let first = points.first, let last = points.last else {
                return
            }
            let low = points.map(\.altitudeMeters).min() ?? first.altitudeMeters
            let high = points.map(\.altitudeMeters).max() ?? last.altitudeMeters
            let span = max(2, high - low)
            let width = max(0.001, last.distanceKm - first.distanceKm)
            func terrainPath(displacement: CGFloat) -> Path {
                var path = Path()
                for (index, point) in points.enumerated() {
                    let x = CGFloat((point.distanceKm - first.distanceKm) / width) * size.width
                    let norm = (point.altitudeMeters - low) / span
                    let y = size.height * (0.14 + (1 - norm) * 0.40) + displacement
                    let pos = CGPoint(x: x, y: y)
                    if index == 0 { path.move(to: pos) }
                    else { path.addLine(to: pos) }
                }
                return path
            }
            for layer in (1...23).reversed() {
                let depth = CGFloat(layer) * size.height * 0.019
                let opacity = pow(1 - Double(layer) / 25, 2) * 0.37
                context.stroke(terrainPath(displacement: depth),
                               with: .color(color.opacity(opacity)),
                               style: StrokeStyle(lineWidth: 0.55, lineJoin: .round))
            }
            let main = terrainPath(displacement: 0)
            context.stroke(main, with: .color(color.opacity(0.36)),
                           style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
            context.stroke(main, with: .color(color.opacity(0.75)),
                           style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
            context.stroke(main, with: .color(EMTMaterialPalette.ivory.opacity(0.68)),
                           style: StrokeStyle(lineWidth: 0.6, lineCap: .round, lineJoin: .round))
        }
        .mask(LinearGradient(stops: [
            .init(color: .white, location: 0),
            .init(color: .white.opacity(0.92), location: 0.42),
            .init(color: .white.opacity(0.52), location: 0.70),
            .init(color: .clear, location: 1)
        ], startPoint: .top, endPoint: .bottom))
        .accessibilityLabel("Profilo altimetrico GPS realmente registrato")
    }
}
