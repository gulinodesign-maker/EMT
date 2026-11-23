"""Build 131: bigger decluttered inclination dials while preserving access and physics."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
view = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text().split(
    "private struct GPSInclinationPanel: View {", 1)[1]
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
motion = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
math = (root / "Ecojumbo/Models/VehicleInclinationMath.swift").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 132;") == 2
assert "let enlargedDial = baseDial * 1.20" in view
assert "let dial = min(enlargedDial, dialWidthLimit, dialHeightLimit)" in view
assert "let dialWidthLimit = (w - 2 * horizontalInset - dialGap) / 2" in view
assert "let dialHeightLimit = h * 0.73" in view
assert "HStack(spacing: dialGap)" in view
assert ".padding(.horizontal, horizontalInset)" in view
assert ".frame(height: h * 0.11)" in view
assert ".frame(height: h * 0.16)" in view
assert "Text(label)" not in view
assert 'dialView(label: "ROLLIO", value: motion.inclinationRollDegrees,' in view
assert 'dialView(label: "BECCHEGGIO", value: motion.inclinationPitchDegrees,' in view
assert 'accessibilityLabel(label + ": "' in view
assert 'Text("INCLINOMETRO")' in view
assert 'Text(value.map { String(format: "%+.1f°", $0) } ?? "—°")' in view
assert 'Label("AZZERA", systemImage: "scope")' in view
assert 'ForEach(0..<72, id: \\.self) { tick in' in view
assert '.rotationEffect(.degrees(roll ? (value ?? 0) : -(value ?? 0)))' in view
assert 'Image(systemName: roll ? "car.rear.fill" : "car.side.fill")' in view
assert "VehicleInclinationMath.angles(" in motion
assert "let pitch = atan2(longitudinal, hypot(lateral, vertical))" in math

# Geometry constraints: a 20% target on ordinary landscape sizes; if the
# available width/height becomes tighter, keep both complete rings inside.
for w, h in [(205, 185), (245, 205), (295, 230), (350, 260),
             (450, 325), (600, 430), (760, 560)]:
    base = max(48, min((w - 42) * .46, h * .48))
    target = base * 1.20
    gap = max(4, w * .010)
    inset = max(4, w * .012)
    width_limit = (w - 2 * inset - gap) / 2
    height_limit = h * .73 - 2 * max(4, h * .014) - max(16, target * .17) - max(3, target * .020)
    diameter = min(target, width_limit, height_limit)
    assert diameter > 0
    assert 2 * diameter + gap + 2 * inset <= w + 1e-7, (w, h)
    assert diameter + max(16, target * .17) + max(3, target * .020) + 2 * max(4, h * .014) <= h * .73 + 1e-7
    assert diameter <= target + 1e-7

print("OK — build131: 120% dial target with responsive safe bounds, visible degrees and accessible names")
