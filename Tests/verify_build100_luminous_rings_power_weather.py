"""Build 100/101 — preserved LED glow and bridge-safe double power bar; obsolete extra ring removed."""
from pathlib import Path
from math import isclose
import re

r = Path(__file__).resolve().parents[1]
cockpit = (r / "Ecojumbo/Views/CockpitComponents.swift").read_text()
tabs = (r / "Ecojumbo/Views/CockpitTabs.swift").read_text()
project = (r / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (r / "STATO_PROGETTO.md").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 111;") == 2
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
assert "glowIntensity: theme.glow(for: 21)" in dashboard
assert ".zIndex(27)" in dashboard
assert "GPSConcentricAccentRing(color: tone(21)," in preview
assert "GPSSecondOuterRing" not in preview
assert "glowIntensity: palette.glow(for: 21)" in preview

# Build 100 palette compatibility: first 22 colors survive, last orphaned
# extra-ring color of 23-value themes is removed.
assert "static let colorCount = 23" in tabs
assert "decoded.colors.count == 22 || decoded.colors.count == 23" in tabs
assert "if migrated.colors.count == 23 && decoded.lightingVersion < 109 {" in tabs
assert "migrated.colors.removeLast()" in tabs
assert "var secondRingColor: Color" not in cockpit
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
assert 'Image("EcojumboMark")' in header
assert "EcoOutsideTemperature(now: now, plain: true)" not in header
assert "EcoOutsideTemperature(now: now, plain: true)" in dashboard
assert ".position(x: temperatureX, y: temperatureY)" in dashboard
assert cockpit.count("EcoOutsideTemperature(now: now)") == 1
assert "GPSSiriControl" not in cockpit

# Build 108 retires only the separate kW tick bar. The net kW text,
# the original bridge contours and the Home gauges remain intact.
bridge = cockpit.split("private enum GPSLowerLineGeometry {",1)[1].split(
    "private struct GPSLowerContour: Shape {",1)[0]
assert "static func powerBarMaxWidth(in size: CGSize)" in bridge  # legacy geometry API
assert "GPSPowerHorizontalGauge" not in cockpit
assert "miniaturePowerBar" not in cockpit
assert "GPSCockpitPowerReading(d: dialSize" in dashboard
assert "powerWatts: live.map { -$0.power }" in dashboard
assert "SegmentedGaugeBar(d: d, fraction: outputFill" in cockpit
print("OK — retained build 100 primary glow, plain logo weather and text-only kW bridge; extra ring removed")
