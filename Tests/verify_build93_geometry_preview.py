"""Build 93 — entire theme cockpit preview and GPS geometry refinements."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
c = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
t = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
p = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()
assert p.count("CURRENT_PROJECT_VERSION = 111;") == 2
assert p.count("MARKETING_VERSION = 1.0;") == 2
assert "Build 93" in state

# Left layer follows the SAME bridge slope to the display bottom.
footprint = c.split("private struct GPSUpperLayerFootprint: Shape {", 1)[1].split(
    "private struct GPSDialExteriorMask: Shape {", 1)[0]
assert "let bridgeRise = max(1, leftFoot.y - leftShoulder.y)" in footprint
assert "let continuation = (h - leftFoot.y) / bridgeRise" in footprint
assert "leftFoot.x + (leftFoot.x - leftShoulder.x) * continuation - 3" in footprint
assert "left.addLine(to: CGPoint(x: leftBottomX, y: h))" in footprint
assert "left.addLine(to: CGPoint(x: leftFoot.x - 3, y: h))" not in footprint

# Only metal circle shrinks by 10%, speed scale expands by 8%, HOME untouched.
assert "static let metalRingDiameterFactor: CGFloat = 0.965 * 0.90" in c
assert "static let speedScaleMagnification: CGFloat = 1.08" in c
ring = c.split("private struct GPSMetalInnerRing: View {", 1)[1].split(
    "// Build 87: corona", 1)[0]
assert ".frame(width: d * GPSDialLayout.metalRingDiameterFactor," in ring
cluster = c.split("private struct OpenSpeedCluster: View {", 1)[1].split(
    "private struct CockpitPowerReadings: View {", 1)[0]
assert "var maximizesGPSSpeedScale: Bool = false" in cluster
assert "if maximizesGPSSpeedScale {" in cluster
assert cluster.count(".scaleEffect(GPSDialLayout.speedScaleMagnification)") == 2
assert "SpeedLEDStream(d: d, speed: speed, powerFlow: powerFlow," in cluster
assert "SpeedScaleTicks(d: d)" in cluster
gps = c.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]
assert "maximizesGPSSpeedScale: true" in gps
assert "showsCircularPowerGauges: false" in gps
assert "GPSPowerHorizontalGauge(d: dialSize," not in gps
# Ring / speed graduation have a positive separation, for every phone.
for h in (390, 414, 510, 706, 831):
    d = h * 0.965
    ring_radius = d * 0.965 * 0.90 / 2
    ticks_radius = d * 0.393 * 1.08
    assert ring_radius > ticks_radius > d * 0.393

# Glow is shifted toward the right/center, but clipped by BOTH exclusions.
layer = c.split("private struct GPSUpperGradientLayer: View {", 1)[1].split(
    "// Build 93 — anteprima", 1)[0]
assert ".offset(x: d * 0.023, y: d * 0.012)" in layer
assert "underGlow.opacity(" in layer
assert ".mask(GPSDialExteriorMask().fill(style: FillStyle(eoFill: true)))" in layer
assert ".mask(GPSBridgeExteriorMask().fill(style: FillStyle(eoFill: true)))" in layer

# Full SwiftUI cockpit preview built from the actual GPS shapes.
preview = c.split("struct EcoCockpitThemeMiniature: View {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1)[0]
for component in (
    "GPSUpperLayerFootprint()", "GPSDialExteriorMask()",
    "GPSBridgeExteriorMask()", "SpeedScaleTicks(d: d)",
    "GPSMetalInnerRing()", "GPSLowerGlow(theme: .copper)",
    'Text("ODO — km")', 'Text("km/h")', 'Text("— kW")',
    'miniatureTile("SOC"', 'miniatureTile("V BAT"', 'miniatureTile("AUT"', 'miniatureTile("TRIP"',
    'Text("DISL")', '"Mappa"', '"Viaggi"', '"Setup"', '"Temi"', '"Tema"',
):
    assert component in preview, component
assert "let palette: EcoThemePalette" in preview
assert "Color(themeHex: palette.colors[index])" in preview
assert "palette.highOpacity" in preview
assert "palette.lowOpacity" in preview
assert "palette.glow(for: 21)" in preview
assert 'Text("88")' not in preview
assert 'Text("35%")' not in preview
assert 'Text("60 km/h")' not in preview

themePreview = t.split("private struct EcoThemePreview: View {", 1)[1].split(
    "private struct EcoThemeEditorView: View {", 1)[0]
assert "EcoCockpitThemeMiniature(palette: palette)" in themePreview
for forbidden in ("Circle()", "swatch(", "ForEach(0..<EcoThemePalette.colorCount",
                  "Color(themeHex: palette.colors[8]).opacity(0.88)"):
    assert forbidden not in themePreview, forbidden
assert "EcoThemePreview(palette: palette, active: active)" in t
assert "EcoThemePreview(palette: draft)" in t
assert "draft.colors[selected.id] = hex" in t
assert "minimumDuration: 0.45" not in t
assert "static let colorCount = 23" in t
print("OK — build 93: diagonal exterior layer, -10% ring, larger GPS scale, complete live draft cockpit miniature")
