"""Build 82 migration: historic build 76 bridge mask still protects the speed dial,
while the new glass layer owns the lower power semicircle."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
src = (root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root/"STATO_PROGETTO.md").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 82;") == 2
dashboard = src.split("struct GPSCockpitDashboard: View {",1)[1].split("// Pulsante dedicato",1)[0]
mask = src.split("private struct GPSBridgeUpperMask: Shape {",1)[1].split("// Maschera orizzontale",1)[0]
speed = src.split("private struct OpenSpeedCluster: View {",1)[1].split("private struct CockpitPowerReadings: View {",1)[0]
glass = src.split("private struct GPSLowerGlassLayer: View {",1)[1].split("private struct GPSLowerPowerScale: View {",1)[0]
assert ".mask(GPSBridgeUpperMask())" in dashboard
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in dashboard
assert "GPSMetalInnerRing()" in dashboard
assert "showsPowerReadings: false" in dashboard
assert "showsOuterPowerRings: false" in dashboard
assert "var showsOuterPowerRings: Bool = true" in speed
assert "if showsOuterPowerRings {" in speed
assert "let points = GPSLowerLineGeometry.points(in: rect)" in mask
assert "var upper = GPSLowerContour().path(in: rect)" in mask
assert "upper.closeSubpath()" in mask
assert "GPSLowerGlassShape()" in glass
assert "GPSLowerGlassLayer(theme: theme)" in dashboard
assert "GPSLowerPowerScale(powerWatts: live?.power)" in dashboard
assert "GPSLowerGlow(theme: theme)" not in dashboard
assert "CockpitPowerReadings(d: dialSize" not in dashboard
assert "Build 76" in state and "Build 82" in state
print("OK — build 82 replaces lower bridge lighting with tinted glass and live BMS")
