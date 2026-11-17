"""Build 94: miniature icons constrained to header/dock and 10% smaller GPS black circle."""
from pathlib import Path
import math

root = Path(__file__).resolve().parents[1]
c = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
t = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
p = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
status = (root / "STATO_PROGETTO.md").read_text()

assert p.count("CURRENT_PROJECT_VERSION = 105;") == 2
assert p.count("MARKETING_VERSION = 1.0;") == 2
assert "Build 94" in status

layout = c.split("private enum GPSDialLayout {", 1)[1].split(
    "private enum GPSMetalContourStyle", 1)[0]
assert "static let metalRingDiameterFactor: CGFloat = 0.965 * 0.90" in layout
assert "static let outerProfileDiameterFactor: CGFloat = 0.986 * 0.90" in layout
assert "static let carbonProfileDiameterFactor: CGFloat = 0.982 * 0.90" in layout
assert "static let speedScaleMagnification: CGFloat = 1.08" in layout

cluster = c.split("private struct OpenSpeedCluster: View {", 1)[1].split(
    "private struct CockpitPowerReadings: View {", 1)[0]
assert "maximizesGPSSpeedScale ? GPSDialLayout.outerProfileDiameterFactor : 0.986" in cluster
assert "maximizesGPSSpeedScale ? GPSDialLayout.carbonProfileDiameterFactor : 0.982" in cluster
assert ".frame(width: d * outerDiameterFactor, height: d * outerDiameterFactor)" in cluster
assert 'Image("CarbonWeave")' not in cluster
assert "endRadius: d * outerDiameterFactor / 2" in cluster
assert cluster.count(".scaleEffect(GPSDialLayout.speedScaleMagnification)") == 2
assert "showsCircularPowerGauges: Bool = true" in cluster
assert "var maximizesGPSSpeedScale: Bool = false" in cluster

shape = c.split("private struct GPSUpperLayerFootprint: Shape {", 1)[1].split(
    "private struct GPSDialExteriorMask: Shape {", 1)[0]
dial_mask = c.split("private struct GPSDialExteriorMask: Shape {", 1)[1].split(
    "private struct GPSBridgeExteriorMask: Shape {", 1)[0]
horizon = c.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "@MainActor\nprivate struct GPSHeader:", 1)[0]
assert "circleRadius = d * GPSDialLayout.outerProfileDiameterFactor / 2" in shape
assert "radius = d * GPSDialLayout.outerProfileDiameterFactor / 2 + 3" in dial_mask
assert "metalRadius = dialSize * GPSDialLayout.metalRingDiameterFactor / 2" in horizon
assert "FillStyle(eoFill: true)" in horizon

layer = c.split("private struct GPSUpperGradientLayer: View {", 1)[1].split(
    "// Build 93 — anteprima", 1)[0]
assert ".mask(GPSDialExteriorMask().fill(style: FillStyle(eoFill: true)))" in layer
assert ".mask(GPSBridgeExteriorMask().fill(style: FillStyle(eoFill: true)))" in layer

preview = c.split("struct EcoCockpitThemeMiniature: View {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1)[0]
assert "miniatureHeader(width: w, height: h * 0.10)" in preview
assert "miniatureDock(height: h * 0.082)" in preview
assert "miniatureHeader(width: w, height: h)" not in preview
assert "miniatureDock(height: h)" not in preview
assert ".frame(width: w, height: h * 0.10)" in preview
assert ".frame(width: panelWidth, height: h * 0.082)" in preview
assert "d * GPSDialLayout.outerProfileDiameterFactor" in preview
assert "d * GPSDialLayout.carbonProfileDiameterFactor" not in preview
assert 'Image("CarbonWeave")' not in preview
for comp in ('miniatureButton("map.fill"', 'miniatureButton("chart.bar.fill"',
             'miniatureButton("gearshape.fill"', 'miniatureButton("paintpalette.fill"',
             'miniatureButton("sun.max.fill"'):
    assert comp in preview
assert "Image(\"EcojumboMark\")" in preview
assert "Image(systemName: \"location.north.fill\")" in preview
theme_preview = t.split("private struct EcoThemePreview: View {", 1)[1].split(
    "private struct EcoThemeEditorView: View {", 1)[0]
assert "EcoCockpitThemeMiniature(palette: palette)" in theme_preview
assert "checkmark.circle.fill" not in theme_preview
assert "stroke(active ? Color(themeHex: palette.colors[1])" in theme_preview
assert "EcoThemePreview(palette: draft)" in t

# The enlarged GPS ticks must fit inside the shrunk metal ring,
# and both rings still fit inside the new black dial.
for diameter in (360, 390, 435, 610, 850):
    speed_radius = diameter * 0.393 * 1.08
    metal_radius = diameter * 0.965 * 0.90 / 2
    black_radius = diameter * 0.986 * 0.90 / 2
    assert speed_radius < metal_radius < black_radius
    assert math.isclose(black_radius / (diameter * 0.986 / 2), 0.90)
print("OK — build 94: miniature icon sizes contained, smaller black GPS ring, protected editable layer")
