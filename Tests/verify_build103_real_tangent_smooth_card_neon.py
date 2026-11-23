"""Build 103 — visible dial tangent centering, carbon-free cockpit, telemetry gradients, thicker speed neon."""
from pathlib import Path
from math import isclose

root=Path(__file__).resolve().parents[1]
cockpit=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
home=(root/"Ecojumbo/Views/EcojumboRootView.swift").read_text()
proj=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
status=(root/"STATO_PROGETTO.md").read_text()

assert proj.count("CURRENT_PROJECT_VERSION = 129;")==2
assert "## Build 103" in status
assert 'Image("CarbonWeave")' not in cockpit
assert "private struct CarbonBackdrop: View" in cockpit # smooth backdrop still shared
assert "Image(\"EcojumboMark\")" in cockpit

geo=home.split("enum EcoCockpitDockGeometry {",1)[1].split("struct EcojumboRootView",1)[0]
assert "static func visibleDialRightTangent(width: CGFloat, height: CGFloat)" in geo
assert "let radius = dial * (0.986 * 0.90) / 2 + 1.5" in geo
assert "let neonStroke = max(2.4, min(4.2, dial * 0.0051))" in geo
assert "return dialX + radius + neonStroke / 2" in geo
assert "visibleDialRightTangent(width: width, height: height) + rightInset(width: width)" in geo
assert "return dialX + dial * 0.508" not in geo

dashboard=cockpit.split("struct GPSCockpitDashboard: View {",1)[1].split(
    "// Pulsante dedicato per azzerare trip",1)[0]
dock=home.split("private struct CockpitCornerControls: View {",1)[1].split(
    "private func iconButton(",1)[0]
assert "EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in dashboard
assert "EcoCockpitDockGeometry.standardLeft(width: width, height: screenHeight)" in dock
assert ".position(x: panelLeft + panelWidth / 2, y: cardsCenterY)" in dashboard
assert ".frame(width: fillsTelemetryWidth ? telemetryPanelWidth : nil, alignment: .center)" in dock
assert "let temperatureX = max(43, w * 0.060)" in dashboard
assert "let temperatureY = h * 0.235" in dashboard
assert "EcoOutsideTemperature(now: now, plain: true)" in dashboard
assert ".position(x: temperatureX, y: temperatureY)" in dashboard
header=cockpit.split("private struct GPSHeader: View {",1)[1].split(
    "private struct GPSDiagnosticsView",1)[0]
assert 'Image("EcojumboMark")' in header
assert "EcoOutsideTemperature(now: now, plain: true)" not in header
assert "size: plain ? 30 : 15" in cockpit
assert ".onLongPressGesture(minimumDuration: 0.5)" in cockpit

layout=cockpit.split("private enum GPSDialLayout {",1)[1].split(
    "private enum GPSMetalContourStyle",1)[0]
assert "max(2.4, min(4.2, d * 0.0051))" in layout
assert "concentricRingRadius(for: d) + concentricRingStroke(for: d) / 2" in layout
led=cockpit.split("private enum GPSInnerLED {",1)[1].split("private enum GPSDialLayout",1)[0]
assert "size * 0.042" in led
assert "size * 0.0195" in led
assert "size * 0.004" in led
speed=cockpit.split("private struct SpeedLEDStream: View {",1)[1].split(
    "private struct OpenSpeedCluster",1)[0] if "private struct OpenSpeedCluster" in cockpit else cockpit
assert "if let progress, progress > 0" in speed # no fake speed LED while GPS unavailable
assert "GPSInnerLED.coreWidth(d)" in speed

telemetry=cockpit.split("private struct GPSExpandedReadings: View {",1)[1].split(
    "// Progressi sottili",1)[0]
assert "private var telemetryCardGradient: LinearGradient" in telemetry
assert "theme.dayTopBar.left" in telemetry and "theme.dayTopBar.right" in telemetry
assert "theme.topBarGradientStart" in telemetry and "theme.topBarGradientEnd" in telemetry
assert "startPoint: direction.start, endPoint: direction.end" not in telemetry
assert "startPoint: .leading, endPoint: .trailing" in telemetry
assert "from.opacity((day ? 0.38 : 0.32) * lightOpacity)" in telemetry
assert telemetry.count(".background(telemetryCardBackground)")==2
assert "telemetryTile(\"SOC\"" in telemetry
assert "dislevelCard(height: dislHeight)" in telemetry
assert "let snapshot = bluetooth.snapshot" in telemetry
assert "gps.altitudeProfile" in telemetry

preview=cockpit.split("struct EcoCockpitThemeMiniature: View {",1)[1].split(
    "private struct GPSHorizonLine",1)[0]
assert "palette.dayTopBar.left" in preview
assert "palette.dayTopBar.right" in preview
assert "tone(15)" in preview and "tone(16)" in preview
assert "LinearGradient(" in preview
assert 'Image("CarbonWeave")' not in preview

for w,h in ((736,414),(844,390),(932,430),(956,440),(1179,510),
            (1536,706),(1648,928),(1806,831)):
    dial=min(h*.965,w*.55)
    cx=max(dial*.51+w*.010,w*.168+dial*.30)
    radius=dial*(.986*.90)/2+1.5
    stroke=max(2.4,min(4.2,dial*.0051))
    tangent=cx+radius+stroke/2
    margin=max(12,w*.018)
    left=tangent+margin
    right=w-margin
    panel_center=(left+right)/2
    assert 0<tangent<left<right<w
    assert isclose(panel_center,(tangent+w)/2,abs_tol=1e-8)
    # Centered card/dock is pulled left relative to the obsolete 0.508 radius.
    old_center=(cx+dial*.508+w)/2
    assert panel_center<old_center-4
    # The lower temperature occupies the left-side region referenced by screenshot.
    temp_x=max(43,w*.060)
    temp_y=h*.235
    assert temp_x<cx and temp_y<h*.30 and temp_y>h*.14

print("OK — build 103: tangent-correct telemetry, lower temp, no carbon, thick neon, day/night card gradients")
