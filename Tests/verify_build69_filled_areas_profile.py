"""Historical build 69/70 regression with the duplicate upper profile retired in 71."""
from pathlib import Path
from math import cos, sin, radians, isclose

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 77;") == 2
assert pbx.count("MARKETING_VERSION = 1.0;") == 2
assert "static let colorCount = 19" in tabs
assert "decoded.colors.count == 8 || decoded.colors.count == 15 ||" in tabs
assert "migrated.colors.append(contentsOf: [edge, edge])" in tabs
assert "draft.colors[selected.id] = hex" in tabs
assert "onSave(slot, palette)" in tabs
assert "RIEMPIMENTO" in tabs

# 70 removes only the colored fill layers; the historical 3x profile remains.
assert "GPSTopBandShade" not in cockpit
assert "GPSLowerAreaGradient" not in cockpit
assert "GPSAreaGradientStyle" not in cockpit
assert "contourGradient" not in cockpit
horizon = cockpit.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "@MainActor", 1)[0]
lower_line = cockpit.split("private struct GPSLowerGlow: View {", 1)[1].split(
    "// EJ 1.22", 1)[0]
dashboard = cockpit.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]
style = cockpit.split("private enum GPSContourStroke {", 1)[1].split(
    "private enum GPSDialLayout {", 1)[0]
# Build 71 removes the whole secondary 3x topbar-and-side profile.
# Keep the original top bar and lower kW bridge unchanged.
assert "GPSOuterProfileReinforcement" not in cockpit
assert "GPSContourStroke.width(height: h) * 3" not in cockpit
assert "line.stroke(theme.accent" in horizon
assert "GPSMetalContourStyle.gradient(for: colorScheme)" in lower_line
assert "visibleOutsideRing.fill(style: FillStyle(eoFill: true))" in horizon
assert ".mask(RadialGradient" not in horizon
assert "GPSLowerShade()" not in lower_line
assert "GPSLowerTerminalFade()" in lower_line
assert ".zIndex(28)" in dashboard
assert "max(1.4, h * 0.003)" in style
assert "GPSContourStroke.width(height: h)" in horizon
assert "GPSContourStroke.width(height: h)" in lower_line

# No accidental changes to existing GPS, MapKit, BMS or five-button alignment.
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in cockpit
assert "GPSCockpitMap(theme: theme)" in cockpit
assert "GPSTripAltitudeSparkline(points: gps.altitudeProfile" in cockpit
assert "let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in cockpit
assert "let telemetryDock = selected == .gps && !mapEnabled" in home
print("OK — build 69/70/71: single top bar, no colored fills, original kW bridge and GPS/BMS")
