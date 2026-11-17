"""Build 100/101 — preserved LED glow and bridge-safe double power bar; obsolete extra ring removed."""
from pathlib import Path
from math import isclose
import re

r = Path(__file__).resolve().parents[1]
cockpit = (r / "Ecojumbo/Views/CockpitComponents.swift").read_text()
tabs = (r / "Ecojumbo/Views/CockpitTabs.swift").read_text()
project = (r / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (r / "STATO_PROGETTO.md").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 107;") == 2
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
# The primary luminous ring of build 100 is retained; the later extra
# second ring is deliberately removed in 101.
assert "static let mapToDialClearance: CGFloat = 2" in layout
assert "private struct GPSConcentricAccentRing: View" in cockpit
assert "private struct GPSSecondOuterRing: View" not in cockpit
assert "secondRingRadius" not in layout
assert "GPSLuminousCircleStroke(" in ring
assert ".blur(radius:" in ring and ".shadow(color: color.opacity(" in ring
assert "lineWidth: stroke * 4.0" in ring
assert "lineWidth: stroke * 2.1" in ring
assert ring.count(".mask(GPSBridgeUpperMask())") == 1
assert "color: theme.concentricRingColor" in dashboard
assert "glowIntensity: theme.glowIntensity" in dashboard
assert ".zIndex(27)" in dashboard
assert "GPSConcentricAccentRing(color: tone(21)," in preview
assert "GPSSecondOuterRing" not in preview
assert "glowIntensity: palette.glowIntensity" in preview

# Build 100 palette compatibility: first 22 colors survive, last orphaned
# extra-ring color of 23-value themes is removed.
assert "static let colorCount = 22" in tabs
assert "decoded.colors.count == 22 || decoded.colors.count == 23" in tabs
assert "if migrated.colors.count == 23 {" in tabs
assert "migrated.colors.removeLast()" in tabs
assert "var secondRingColor: Color" not in cockpit
labels = tabs.split("static let labels = [", 1)[1].split("]", 1)[0]
details = tabs.split("static let details = [", 1)[1].split("]", 1)[0]
assert len(re.findall(r'^\s*"[^"]+"', labels, re.M)) == 22
assert len(re.findall(r'^\s*"[^"]+"', details, re.M)) == 22

# Only GPS header has text-only meteo under the brand mark; other Home unchanged.
weather = cockpit.split("private struct EcoOutsideTemperature: View {", 1)[1].split(
    "// EJ 1.19", 1)[0]
header = cockpit.split("private struct GPSHeader: View {", 1)[1].split(
    "private struct GPSDiagnosticsView", 1)[0]
assert "var plain: Bool = false" in weather
assert ".padding(.horizontal, plain ? 0 : 5)" in weather
assert ".padding(.vertical, plain ? 0 : 3)" in weather
assert "if !plain {" in weather
assert 'Image("EcojumboMark")' in header
assert "EcoOutsideTemperature(now: now, plain: true)" not in header
assert "EcoOutsideTemperature(now: now, plain: true)" in dashboard
assert ".position(x: temperatureX, y: temperatureY)" in dashboard
assert cockpit.count("EcoOutsideTemperature(now: now)") == 1
assert "GPSSiriControl" not in cockpit

# The requested doubling is exact for height and desired full width;
# width is limited to the actual bridge feet (without changing its contour).
bar = cockpit.split("private struct GPSPowerHorizontalGauge: View {", 1)[1].split(
    "// Costanti LED storiche", 1)[0]
bridge = cockpit.split("private enum GPSLowerLineGeometry {", 1)[1].split(
    "private struct GPSLowerContour: Shape {", 1)[0]
assert "let bridgeMaxWidth: CGFloat" in bar
assert "min(d * 0.54, max(1, bridgeMaxWidth))" in bar
assert "height: max(16, d * 0.045)" in bar
assert "let regenTacks = 3" in bar and "let dischargeTacks = 7" in bar
assert "let halfSpace = min(center - ends[0].x, ends[3].x - center) - safety" in bridge
assert "static func powerBarMaxWidth(in size: CGSize)" in bridge
assert "bridgeMaxWidth: GPSLowerLineGeometry.powerBarMaxWidth(" in dashboard
assert "max(16, d * 0.045)" in preview
assert "min(d * 0.54, max(1, bridgeMaxWidth))" in preview
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
    width = min(d * .54,
                max(1, 2 * (min(cx-left_foot, right_foot-cx)-max(6,d*.014))))
    assert width > 0 and cx - width / 2 > left_foot
    assert cx + width / 2 < right_foot
    assert max(16, d * .045) > 2 * max(5, d * .014)

print("OK — retained build 100 primary glow, plain logo weather and safe 2× power scale; extra ring removed")
