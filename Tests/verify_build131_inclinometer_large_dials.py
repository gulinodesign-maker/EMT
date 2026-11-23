"""Build 131: bigger decluttered inclination dials while preserving access and physics."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
view = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text().split(
    "private struct GPSInclinationPanel: View {", 1)[1]
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
motion = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
math = (root / "Ecojumbo/Models/VehicleInclinationMath.swift").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 133;") == 2
assert "let enlargedDial = baseDial * 1.20" in view
assert "let dial = max(28, min(enlargedDial, dialWidthLimit, dialHeightLimit))" in view
assert "let dialWidthLimit = (w - 2 * horizontalInset - resetWidth - 2 * dialGap) / 2" in view
assert "let dialHeightLimit = h - 2 * verticalInset - headerHeight" in view
assert "HStack(spacing: dialGap)" in view
assert ".padding(.horizontal, horizontalInset)" in view
assert ".frame(height: headerHeight)" in view
assert ".frame(width: resetWidth)" in view
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

# Restore the 120% growth target, but reserve a separate reset button column.
for w,h in [(205,185),(245,205),(295,230),(350,260),(450,325),(600,430),(760,560)]:
    base=max(48,min((w-42)*.46,h*.48))
    target=base*1.20
    gap=max(4,w*.012)
    inset=max(4,w*.010)
    reset=max(58,min(78,w*.23))
    head=max(24,min(35,h*.12))
    vertical=max(4,h*.014)
    width_limit=(w-2*inset-reset-2*gap)/2
    height_limit=h-2*vertical-head-max(22,target*.20)
    dial=max(28,min(target,width_limit,height_limit))
    assert 2*dial+reset+2*gap+2*inset <=w+1e-7,(w,h)
    assert dial+head+max(22,target*.20)+2*vertical <=h+1e-7
    assert dial<=target+1e-7
print("OK — build131/133: enlarged dial target with central reset and no overlap")
