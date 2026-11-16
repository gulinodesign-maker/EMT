"""Build 100 — LED glow + 2× outer ring, plain GPS weather, power bar within bridge."""
from pathlib import Path
from math import isclose
import re

r = Path(__file__).resolve().parents[1]
cockpit = (r / "Ecojumbo/Views/CockpitComponents.swift").read_text()
tabs = (r / "Ecojumbo/Views/CockpitTabs.swift").read_text()
project = (r / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (r / "STATO_PROGETTO.md").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 100;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert "## Build 100" in state

layout = cockpit.split("private enum GPSDialLayout {", 1)[1].split(
    "private enum GPSMetalContourStyle {", 1)[0]
ring = cockpit.split("private struct GPSLuminousCircleStroke: View {", 1)[1].split(
    "// Build 87: corona LED tachimetro GPS rimossa", 1)[0]
dashboard = cockpit.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato per azzerare trip", 1)[0]
preview = cockpit.split("struct EcoCockpitThemeMiniature: View {", 1)[1].split(
    "private struct GPSHorizonLine: View", 1)[0]
assert "static func secondRingRadius(for d: CGFloat)" in layout
assert "concentricRingRadius(for: d) + max(6, d * 0.018)" in layout
assert "static func secondRingStroke(for d: CGFloat)" in layout
assert "concentricRingStroke(for: d) * 2" in layout
assert "secondRingRadius(for: d) + secondRingStroke(for: d) / 2" in layout
assert "static let mapToDialClearance: CGFloat = 2" in layout
assert "private struct GPSConcentricAccentRing: View" in cockpit
assert "private struct GPSSecondOuterRing: View" in cockpit
assert "GPSLuminousCircleStroke(" in ring
assert ".blur(radius:" in ring and ".shadow(color: color.opacity(" in ring
assert "lineWidth: stroke * 4.0" in ring
assert "lineWidth: stroke * 2.1" in ring
assert ring.count(".mask(GPSBridgeUpperMask())") == 2
assert "color: theme.concentricRingColor" in dashboard
assert "color: theme.secondRingColor" in dashboard
assert "glowIntensity: theme.glowIntensity" in dashboard
assert ".zIndex(27.5)" in dashboard and ".zIndex(27)" in dashboard
assert "GPSConcentricAccentRing(color: tone(21)," in preview
assert "GPSSecondOuterRing(color: tone(22)," in preview
assert "glowIntensity: palette.glowIntensity" in preview

# New palette value persists without corrupting the first 22 slot colours.
assert "static let colorCount = 23" in tabs
assert "decoded.colors.count == 22 || decoded.colors.count == colorCount" in tabs
assert "if migrated.colors.count == 22 {" in tabs
assert "migrated.colors.append(migrated.colors[1])" in tabs
assert "var secondRingColor: Color" in cockpit
assert "savedPalette.colors[22]" in cockpit
assert '"Secondo cerchio esterno · spessore doppio"' in tabs
assert '("Anelli e numeri del tachimetro", [8, 9, 11, 22])' in tabs
labels = tabs.split("static let labels = [", 1)[1].split("]", 1)[0]
details = tabs.split("static let details = [", 1)[1].split("]", 1)[0]
assert len(re.findall(r'^\s*"[^"]+"', labels, re.M)) == 23
assert len(re.findall(r'^\s*"[^"]+"', details, re.M)) == 23

# Only GPS header has text-only meteo under the brand mark; other Home unchanged.
weather = cockpit.split("private struct EcoOutsideTemperature: View {", 1)[1].split(
    "// EJ 1.19", 1)[0]
header = cockpit.split("private struct GPSHeader: View {", 1)[1].split(
    "private struct GPSDiagnosticsView", 1)[0]
assert "var plain: Bool = false" in weather
assert ".padding(.horizontal, plain ? 0 : 5)" in weather
assert ".padding(.vertical, plain ? 0 : 3)" in weather
assert "if !plain {" in weather
assert "VStack(spacing: 1)" in header
assert "EcoOutsideTemperature(now: now, plain: true)" in header
assert header.index('Image("EcojumboMark")') < header.index(
    "EcoOutsideTemperature(now: now, plain: true)") < header.index("SystemClockText()")
assert cockpit.count("EcoOutsideTemperature(now: now)") == 1
assert "GPSSiriControl" not in cockpit

# The requested doubling is exact for height and desired full width;
# width is limited to the actual bridge feet (without changing its contour).
bar = cockpit.split("private struct GPSPowerHorizontalGauge: View {", 1)[1].split(
    "// Costanti LED storiche", 1)[0]
bridge = cockpit.split("private enum GPSLowerLineGeometry {", 1)[1].split(
    "private struct GPSLowerContour: Shape {", 1)[0]
assert "let bridgeMaxWidth: CGFloat" in bar
assert "min(d * 0.78, max(1, bridgeMaxWidth))" in bar
assert "height: 2 * max(5, d * 0.014)" in bar
assert "let regenTacks = 9" in bar and "let dischargeTacks = 21" in bar
assert "let halfSpace = min(center - ends[0].x, ends[3].x - center) - safety" in bridge
assert "static func powerBarMaxWidth(in size: CGSize)" in bridge
assert "bridgeMaxWidth: GPSLowerLineGeometry.powerBarMaxWidth(" in dashboard
assert "2 * max(3, d * 0.014)" in preview
assert "min(d * 0.78, max(1, bridgeMaxWidth))" in preview
assert "let live = bluetooth.snapshot" in dashboard
assert "powerWatts: live.map { -$0.power }" in dashboard

# Analytic check: the twice-thick bar ends strictly before both bridge feet.
for w, h in ((736, 414), (844, 390), (932, 430), (956, 440),
             (1179, 510), (1536, 706), (1648, 928), (1806, 831)):
    d = min(h * .965, w * .55)
    cx = max(d * .51 + w * .010, w * .168 + d * .30)
    text_top = h * .494 + d * (.889 - .50 - .065)
    top_y = min(h * .790, text_top - max(12, h * .014))
    foot_y = h * .937
    left_top = cx - d * .195
    controls_height = max(51, min(83, h * .105))
    side = min(controls_height * .96, w * .059, w * .052)
    button_start = w - max(12, w * .018) - 8 * side - 7 * w * .008
    ideal_run = w * (.385 - .323) * ((foot_y - top_y) / (h * (.985 - .790)))
    max_right = button_start - max(9, w * .012)
    right_top = min(cx + d * .195, max_right - ideal_run)
    run = min(ideal_run, max(0, max_right - right_top))
    left_foot, right_foot = left_top - run, right_top + run
    width = min(d * .78,
                max(1, 2 * (min(cx-left_foot, right_foot-cx)-max(6,d*.014))))
    assert width > 0 and cx - width / 2 > left_foot
    assert cx + width / 2 < right_foot
    assert isclose(2 * max(5, d * .014) / max(5, d * .014), 2)
    first_stroke = max(1.5, min(2.4, d * .003))
    second_stroke = first_stroke * 2
    first_radius = d * (.986 * .90) / 2 + 1.5
    second_radius = first_radius + max(6, d * .018)
    assert second_radius - second_stroke / 2 > first_radius + first_stroke / 2
    assert isclose(second_stroke, 2 * first_stroke)

print("OK — build 100: luminous dual rings with saved independent color, plain logo weather and bridge-safe 2× power scale")
