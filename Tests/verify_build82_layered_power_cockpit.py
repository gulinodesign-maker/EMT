"""Build 82: two underlit layers and editable real-JK lower power semicircle."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
src=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
settings=(root/"Ecojumbo/Views/OtherViews.swift").read_text()
rootview=(root/"Ecojumbo/Views/EcojumboRootView.swift").read_text()
project=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
state=(root/"STATO_PROGETTO.md").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 82;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert "Build 82" in state
dashboard=src.split("struct GPSCockpitDashboard: View {",1)[1].split("// Pulsante dedicato",1)[0]
upper=src.split("private struct GPSUpperGlassLayer: View {",1)[1].split("private enum GPSLowerGlassGeometry {",1)[0]
lower=src.split("private struct GPSLowerGlassLayer: View {",1)[1].split("private struct GPSLowerPowerScale: View {",1)[0]
geometry=src.split("private enum GPSLowerGlassGeometry {",1)[1].split("private struct GPSLowerGlassShape: Shape {",1)[0]
scale=src.split("private struct GPSLowerPowerScale: View {",1)[1].split("// EJ 1.22",1)[0]
glass=src.split("private struct GPSMetalInnerRing: View {",1)[1].split("private struct GPSGaugeHalo: View {",1)[0]
speed=src.split("private struct OpenSpeedCluster: View {",1)[1].split("private struct CockpitPowerReadings: View {",1)[0]
stream=src.split("private struct SpeedLEDStream: View {",1)[1].split("private struct SegmentedGaugeBar: View {",1)[0]
bars=src.split("private struct SegmentedGaugeBar: View {",1)[1].split("private struct OpenSpeedCluster: View {",1)[0]
assert "GPSUpperGlassLayer(theme: theme)" in dashboard
assert "GPSLowerGlassLayer(theme: theme)" in dashboard
assert "GPSLowerPowerScale(powerWatts: live?.power)" in dashboard
assert dashboard.index("GPSMetalInnerRing()") < dashboard.index("GPSLowerGlassLayer(theme: theme)") < dashboard.index("GPSLowerPowerScale(powerWatts: live?.power)")
assert "GPSHorizonLine(theme: theme)" not in dashboard
assert "GPSGaugeHalo(theme: theme)" not in dashboard
assert "GPSLowerGlow(theme: theme)" not in dashboard
assert "CockpitPowerReadings(d: dialSize" not in dashboard
assert "showsOuterPowerRings: false" in dashboard
assert "speedTrackDiameterFactor: 0.875" in dashboard
assert "var showsOuterPowerRings: Bool = true" in speed
assert "if showsOuterPowerRings {" in speed
assert "var trackDiameterFactor: CGFloat = 0.722" in stream
assert "d * trackDiameterFactor / 2" in stream
assert "AngularGradient(stops:" in glass
assert "GPSLowerGlassShape()" in lower
assert "GPSLowerGlassGeometry.edge(in: rect)" in src
assert ".mask(GPSLowerGlassShape())" in scale
assert "rise = CGPoint(x: cx - d * 0.215, y: h * 0.665)" in geometry
assert "crest = CGPoint(x: cx + d * 0.195, y: h * 0.665)" in geometry
assert "foot = CGPoint(x: min(w, cx + d * 0.51), y: h * 0.798)" in geometry
for panel in (upper,lower):
    assert "LinearGradient(colors:" in panel
    assert ".blur(radius:" in panel
    assert "theme.accent.opacity" in panel
assert "let measured = powerWatts.flatMap { $0.isFinite ? $0 : nil }" in scale
assert "let inputFill = measured.map" in scale and "let outputFill = measured.map" in scale
assert "start: 104, end: 132" in scale  # 28-degree cyan segment
assert "start: 104, end: 48" in scale   # 56-degree red segment
assert "count: max(6, min(30, regenPowerTickCount))" in scale
assert "count: max(12, min(60, dischargePowerTickCount))" in scale
assert "CockpitTheme.regenAccent" in scale and "CockpitTheme.dischargeAccent" in scale
assert "Text(measured.map { String(format:" in scale
assert scale.count('?? "— kW"') == 1
assert "($0 < 0 ? CockpitTheme.dischargeAccent : .white)" in scale
assert "var thicknessFactor: CGFloat = 0.017" in bars
assert "thicknessFactor: 0.023" in scale
for key in ("regenPowerMaxKW","dischargePowerMaxKW","regenPowerTickCount","dischargePowerTickCount"):
    assert "ecojumbo.bars."+key in scale and "ecojumbo.bars."+key in settings
assert 'Stepper("Tacche azzurre:' in settings
assert 'Stepper("Tacche rosse:' in settings
assert "EcoThemePalette.active?.colors[7]" in src
assert "EcoThemePalette.active?.colors[8]" in src
for value in ('"SOC"','"V BAT"','"AUT"','"TRIP"'):
    assert "telemetryTile("+value in src
assert "GPSTripAltitudeSparkline(points: gps.altitudeProfile" in src
assert "let resetY = min(h - resetSide * 0.58, h * 0.815)" in dashboard
assert 'gpsButton("map.fill"' in rootview and 'gpsButton(isDay ? "moon.stars.fill"' in rootview
print("OK — build 82: glass rim, concealed LEDs, dedicated configurable cyan/red BMS dome, genuine telemetry")
