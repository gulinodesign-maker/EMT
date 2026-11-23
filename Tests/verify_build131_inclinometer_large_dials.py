"""Build 131: bigger decluttered inclination dials while preserving access and physics."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
view = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text().split(
    "private struct GPSInclinationPanel: View {", 1)[1]
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
motion = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
math = (root / "Ecojumbo/Models/VehicleInclinationMath.swift").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 135;") == 2
assert "let enlargedDial = baseDial * 1.20" in view
assert "let dial = max(1, min(enlargedDial, dialWidthLimit, dialHeightLimit))" in view
assert "let dialWidthLimit = (w - 2 * horizontalInset - 2 * dialGap - resetWidth) / 2" in view
assert "let dialHeightLimit = min(h * 0.70, h - 2 * verticalInset" in view
assert "HStack(alignment: .top, spacing: dialGap)" in view
assert "let dialGroupCenterY = h / 2 + (valueGap + valueHeight) / 2" in view
assert ".frame(width: w - 2 * horizontalInset)" in view
assert ".frame(height: h * 0.11)" in view
assert "Text(label)" not in view
assert 'dialView(label: compassGForce ? "BUSSOLA" : "ROLLIO",' in view
assert 'dialView(label: compassGForce ? "FORZA G" : "BECCHEGGIO",' in view
assert 'accessibilityLabel(label + ": "' in view
assert 'Text("INCLINOMETRO")' in view
assert 'Text(value.map { String(format: "%+.1f°", $0) } ?? "—°")' in view
assert 'Text("AZZERA")' in view
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
    v_inset = max(4, h * .014)
    reset_width = max(40, min(46, w * .145))
    width_limit = (w - 2 * inset - 2 * gap - reset_width) / 2
    value_height = max(18, min(29, h * .095))
    height_limit = min(h * .70, h - 2 * v_inset - value_height - max(3, target * .020))
    diameter = max(1, min(target, width_limit, height_limit))
    assert diameter > 0
    assert 2 * diameter + 2 * gap + reset_width + 2 * inset <= w + 1e-7, (w,h)
    assert diameter + value_height + max(3, diameter*.020) + 2*v_inset <= h + 1e-7
    assert diameter <= target + 1e-7

print("OK — build131: 120% dial target with responsive safe bounds, visible degrees and accessible names")
