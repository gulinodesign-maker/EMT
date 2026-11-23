"""Build 127: physical roll/pitch views, full 360° ticks and two rotating car supports."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
code = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
motion = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 133;") == 2

panel = code.split("private struct GPSInclinationPanel: View {", 1)[1]
assert 'dialView(label: "ROLLIO", value: motion.inclinationRollDegrees,' in panel
assert 'dialView(label: "BECCHEGGIO", value: motion.inclinationPitchDegrees,' in panel
assert 'Image(systemName: roll ? "car.rear.fill" : "car.side.fill")' in panel
assert 'Image(systemName: roll ? "car.side.fill" : "car.rear.fill")' not in panel

# Every 5° around the whole 360°, not the historical -6...6 partial arc.
dial = panel.split("private func dialView(label:", 1)[1]
assert "ForEach(0..<72, id: \\.self) { tick in" in dial
assert ".rotationEffect(.degrees(Double(tick) * 5))" in dial
assert "tick.isMultiple(of: 6)" in dial
assert "ForEach(-6...6" not in dial
assert sorted({(i * 5) % 360 for i in range(72)}) == list(range(0, 360, 5))

# Shared rotation wraps BOTH the real horizon bar and the chosen vehicle.
group = dial.split("// Veicolo e barra condividono la medesima rotazione", 1)[1]
assert group.index("ZStack {") < group.index("Capsule()") < group.index("Image(systemName:")
assert group.index("Image(systemName:") < group.index(".rotationEffect(.degrees(roll ? (value ?? 0) : -(value ?? 0)))")
assert dial.count(".rotationEffect(.degrees(roll ? (value ?? 0) : -(value ?? 0)))") == 1
assert ".animation(.easeOut(duration: 0.16), value: value)" in group
assert ".offset(y: roll ?" not in dial
assert "CGFloat(max(-1.0, min(1.0, value / 45.0)))" not in dial
assert "value == nil ? 0.35 : 1" in group

# Build 131: no visible title above dials; circles remain above degree readouts.
assert "Text(label)" not in dial
circle_at = dial.index("ZStack {")
degrees_at = dial.index('Text(value.map { String(format: "%+.1f°", $0) } ?? "—°")')
assert circle_at < degrees_at
assert degrees_at > dial.index(".frame(width: side, height: side)")
assert 'accessibilityLabel(label + ": "' in dial
assert 'Text("INCLINOMETRO")' in panel
assert 'Label("AZZERA", systemImage: "scope")' in panel
assert "motion.zeroInclination()" in panel
assert "motion.setInclinationActive(true)" in panel
assert "motion.setInclinationActive(false)" in panel
assert "let baseDial = max(48, min((w - 42) * 0.46, h * 0.48))" in panel
assert "let enlargedDial = baseDial * 1.20" in panel
assert "let dial = min(enlargedDial, dialWidthLimit, dialHeightLimit)" in panel
assert "telemetryStyleBackground" in panel
assert "inclinometerRingColor" in panel
assert "inclinometerHorizonColor" in panel
assert "inclinometerVehicleColor" in panel

# Inertial data must remain from true sensor relative attitude and never GPS-speed estimates.
assert "VehicleInclinationMath.angles(" in motion
assert "let roll = angles.rollDegrees" in motion
assert "let pitch = angles.pitchDegrees" in motion
assert "inclinationRollDegrees = (inclinationRollDegrees ?? roll)" in motion
assert "inclinationPitchDegrees = (inclinationPitchDegrees ?? pitch)" in motion
assert "sensor.isDeviceMotionAvailable" in motion

# Enough vertical room for title, circle, angle, header and reset on common landscape heights.
for w, h in ((736, 414), (844, 390), (932, 430), (1179, 510),
             (1536, 706), (1806, 831)):
    margin = max(8, h * 0.018)
    top = h * 0.099 + margin
    dock = max(51, min(83, h * 0.105))
    bottom = h - max(4, h * 0.006) - dock - margin
    metal = h * 0.099 + min(h * .965, w * .55) * (.992 - .965)/2 + 3
    clearance = max(18, metal + max(12, h * .020) - top)
    card_height = bottom - top - clearance
    dial_size = min(card_height * .48, (w * .34 - 42) * .46)
    title_and_degrees = max(14, dial_size * .095) + max(16, dial_size * .17)
    assert dial_size + title_and_degrees + 6 < card_height * .72, (w,h)
print("OK — build 127: full circumference, rear roll / side pitch, labels outside dials and both rotating bars")
