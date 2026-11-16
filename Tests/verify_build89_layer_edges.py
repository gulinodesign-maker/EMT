"""Build 89: left layer touches the display bottom; right wedge cannot render."""
from pathlib import Path
from math import sqrt

root = Path(__file__).resolve().parents[1]
src = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
theme = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
proj = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

assert proj.count("CURRENT_PROJECT_VERSION = 93;") == 2
assert "Build 89" in state
footprint = src.split("private struct GPSUpperLayerFootprint: Shape {", 1)[1].split(
    "private struct GPSUpperGradientLayer: View {", 1)[0]
layer = src.split("private struct GPSUpperGradientLayer: View {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1)[0]
gps = src.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]

# Remove the original right-hand vertical curtain from build 88.
assert "corners.rightContact.x, y: h" not in footprint
assert "CGPoint(x: corners.rightContact.x, y: h)" not in footprint
assert "upper.addLine(to: CGPoint(x: w, y: 0))" in footprint
assert "upper.addLine(to: CGPoint(x: centerX, y: centerY - circleRadius))" in footprint
assert "left.addPath(upper)" in footprint

# The left lobe ends at the actual bottom, not the bridge's 93.7% cutoff.
assert "GPSLowerLineGeometry.points(in: rect)" in footprint
assert "let leftFoot = bridge[0]" in footprint
assert "let leftShoulder = bridge[1]" in footprint
assert "let intersection = bridgePoint((low + high) / 2)" in footprint
assert "Darwin.atan2(" in footprint
assert "for step in 1...96" in footprint
assert "left.addLine(to: CGPoint(x: leftBottomX, y: h))" in footprint
assert "left.addLine(to: CGPoint(x: 0, y: h))" in footprint
assert "left.addEllipse(in: CGRect(" not in footprint
assert "GPSDialExteriorMask()" in layer
assert "GPSBridgeExteriorMask()" in layer
assert "circleRadius = d * 0.965 / 2" in footprint
assert "+ GPSMetalContourStyle.strokeWidth(for: d) / 2 + 3" in footprint

# No translation of the entire surface: 3pt applies only at gray contours.
assert "offset(y:" not in layer
assert ".mask(GPSBridgeUpperMask())" not in layer
assert ".mask(GPSUpperLayerFootprint()" in layer
assert ".mask(GPSDialExteriorMask().fill(style: FillStyle(eoFill: true)))" in layer
assert ".mask(GPSBridgeExteriorMask().fill(style: FillStyle(eoFill: true)))" in layer
assert "FillStyle(eoFill: true)" in layer
assert "theme.topBarUnderGlow" in layer
assert "theme.topBarGradientStart" in layer
assert "theme.topBarGradientEnd" in layer
assert "GPSUpperGradientLayer(theme: theme)" in gps
assert "GPSHorizonLine(theme: theme)" in gps
assert "GPSLowerGlow(theme: theme)" in gps
assert "GPSMetalInnerRing()" in gps
assert ".mask(GPSBridgeUpperMask())" in gps  # dial mask retained

# Saved theme slots and other cockpit features still exist.
assert '("Layer top bar", [15, 16, 19, 20, 2])' in theme
assert "powerWatts: live.map { -$0.power }" in gps
assert "GPSPowerHorizontalGauge(d: dialSize," in gps

# Across supported landscape geometries the foot always lies outside the
# circle and meets the left bridge side exactly before the bottom edge.
for w, h in ((736, 414), (844, 390), (932, 430), (1179, 510),
             (1536, 706), (1806, 831)):
    d = min(h * .965, w * .55)
    cx = max(d * .51 + w * .010, w * .168 + d * .30)
    cy = h * .494
    radius = d * .965 / 2 + max(1.5, d * .0035) / 2 + 3
    top_y = min(h * .790, h * .494 + d * (.889 - .50 - .065)
                - max(12, h * .014))
    foot_y = h * .937
    shoulder_x = cx - d * .195
    run = w * (.385 - .323) * ((foot_y - top_y) / (h * (.985 - .790)))
    foot_x = shoulder_x - run
    dist_shoulder = (shoulder_x - cx)**2 + (top_y - cy)**2
    dist_foot = (foot_x - cx)**2 + (foot_y - cy)**2
    assert dist_shoulder < radius**2 < dist_foot
    assert 0 < foot_x - 3 < cx - radius / 3
    assert foot_y < h  # but layer bottom is ALWAYS h

print("OK — build 89: no right colored wedge, left layer reaches bottom, UI retained")
