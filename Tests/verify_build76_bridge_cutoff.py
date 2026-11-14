"""Regression for the geometry transition from external bridge (76) to inset (77)."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
src=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
project=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
state=(root/"STATO_PROGETTO.md").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 77;") == 2
dashboard=src.split("struct GPSCockpitDashboard: View {",1)[1].split("// Pulsante dedicato",1)[0]
bridge=src.split("private struct GPSLowerGlow: View {",1)[1].split("// EJ 1.22",1)[0]
speed=src.split("private struct OpenSpeedCluster: View {",1)[1].split(
    "private struct CockpitPowerReadings: View {",1)[0]
power=src.split("private struct CockpitPowerReadings: View {",1)[1].split(
    "// Build 77:",1)[0]
# The 76 clip shape stays defined for the historical/map geometry but is
# no longer applied: the new internal bridge requires a COMPLETE speed dial.
assert "private struct GPSBridgeUpperMask: Shape {" in src
assert ".mask(GPSBridgeUpperMask())" not in dashboard
assert "GPSMetalInnerRing()" in dashboard
assert "GPSGaugeHalo(theme: theme)" in dashboard
assert "GPSLowerGlow(theme: theme)" in dashboard
assert ".frame(width: dialSize, height: dialSize)" in dashboard
assert "GPSInnerBridgeContour()" in bridge
assert "GPSLowerShade()" not in bridge
assert ".mask(GPSLowerTerminalFade())" in bridge
assert "var showsPowerReadings: Bool = true" in speed
assert "showsPowerReadings: false" in dashboard
assert "showsOuterPowerRings: false" in dashboard
assert "if showsPowerReadings {" in speed
assert 'String(format: "%.2f kW", $0 / 1000)' in power
assert "GPSPowerSemicircle(powerWatts: live?.power, d: dialSize)" in dashboard
assert "Build 76" in state and "Build 77" in state
print("OK — build 76/77: legacy kW Home remains; no external GPS clip/veil")
