"""Build 91: editable and persistent high/low vertical fades outside GPS dial and bridge."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 124;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert project.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2
assert "Build 91" in state

layer = source.split("private struct GPSUpperGradientLayer: View {", 1)[1].split(
    "// Build 93 — anteprima", 1)[0]
accessors = source.split("var topBarGradientStart: Color {", 1)[1].split(
    "// Le barre mantengono", 1)[0]
dashboard = source.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]

# The horizontal gradient and underglow are preserved; high and low are
# independently editable, never shortcuts to the same color or slider.
assert "colors[19]" in accessors and "colors[20]" in accessors
assert "savedPalette?.topFadeIntensity ?? 0.35" in accessors
assert "savedPalette?.bottomFadeIntensity ?? 0.35" in accessors
for prop in ("topBarGradientStart", "topBarGradientEnd", "topBarUnderGlow",
             "topBarHighFade", "topBarLowFade"):
    assert "theme." + prop in layer, prop
assert layer.count("GPSUpperLayerFootprint()") >= 7
assert "from.opacity(lightOpacity)" in layer
assert "to.opacity(shadowOpacity)" in layer
assert "high.opacity(highOpacity)" in layer
assert "low.opacity(lowOpacity)" in layer
assert layer.count("], startPoint: .top, endPoint: .bottom)") == 2

# Both masks are OUTSIDE the ZStack and AFTER all four fills.
assert layer.index("low.opacity(lowOpacity)") < layer.index(
    ".mask(GPSDialExteriorMask().fill(style: FillStyle(eoFill: true)))")
assert layer.index(".mask(GPSDialExteriorMask()") < layer.index(
    ".mask(GPSBridgeExteriorMask()")
assert "GPSUpperGradientLayer(theme: theme)" in dashboard
assert ".zIndex(4)" in dashboard
assert "GPSMetalInnerRing()" in dashboard
assert "GPSLowerGlow(theme: theme)" in dashboard
assert "GPSPowerHorizontalGauge" not in dashboard

# Two new palette roles, each with color and independent adjustable intensity.
assert "static let colorCount = 23" in tabs
labels = tabs.split("static let labels = [", 1)[1].split("]", 1)[0]
details = tabs.split("static let details = [", 1)[1].split("]", 1)[0]
assert len(re.findall(r'^\s*"[^"]+"', labels, re.M)) == 23
assert len(re.findall(r'^\s*"[^"]+"', details, re.M)) == 23
assert '"Sfumatura alto"' in tabs
assert '"Sfumatura basso"' in tabs
assert '("Sfumature", [15, 16, 19, 20])' in tabs
assert "gradientOpacityBinding(for role: Int)" in tabs
assert "Slider(value: transparency, in: 0...1, step: 0.01)" in tabs
assert "Color(themeHex: roleHex(role))" in tabs and "ForEach([15, 16, 19, 20]" in tabs
assert "case 19:" in tabs and "case 20:" in tabs
assert "draft.colors[selected.id] = hex" in tabs
assert "if selectedGroup == 4 {" in tabs

# Old custom slots of every previously supported size upgrade to 21 colors
# without overwriting original indexes 0..18.
assert "decoded.colors.count == 19 || decoded.colors.count == 21 ||" in tabs
assert "if migrated.colors.count == 19 {" in tabs
assert "migrated.colors[15], migrated.colors[16]" in tabs
assert "topFadeIntensity, bottomFadeIntensity" in tabs
for prop in ("topFadeIntensity", "bottomFadeIntensity"):
    assert f"decodeIfPresent(Double.self, forKey: .{prop})" in tabs
    assert f"data.encode({prop}, forKey: .{prop})" in tabs
    assert f"palette.{prop}.isFinite" in tabs
# Build 112 changes only preset colors; the 23 historical roles and old-slot migration stay intact.
assert "static let colorCount = 23" in tabs
assert "shade, main, \"#FF3B30\", signal," in tabs
assert "main, shade, bright, main" in tabs
assert "brandID: preset.automotiveBrand" in tabs
assert "EcoThemePalette.save(palette, slot: slot)" in tabs

print("OK — build 91: independent high/low color and opacity, migrated slots, dial/bridge masks")
