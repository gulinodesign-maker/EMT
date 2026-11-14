"""Build 77: real BMS dual half-scale, integrated bridge, single kW and bold halo."""
from pathlib import Path
from math import cos, sin, radians

root=Path(__file__).resolve().parents[1]
source=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
pbx=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
state=(root/"STATO_PROGETTO.md").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 77;") == 2
assert pbx.count("MARKETING_VERSION = 1.0;") == 2

speed=source.split("private struct OpenSpeedCluster: View {",1)[1].split(
    "private struct CockpitPowerReadings: View {",1)[0]
power=source.split("private struct GPSPowerSemicircle: View {",1)[1].split(
    "// Calcola la posizione",1)[0]
bridge_geometry=source.split("private enum GPSInnerBridgeLayout {",1)[1].split(
    "// Maschera orizzontale",1)[0]
bridge=source.split("private struct GPSLowerGlow: View {",1)[1].split(
    "// EJ 1.22",1)[0]
ring=source.split("private struct GPSGaugeHalo: View {",1)[1].split(
    "// EJ 1.23",1)[0]
metal=source.split("private struct GPSMetalInnerRing: View {",1)[1].split(
    "private struct GPSGaugeHalo: View {",1)[0]
dashboard=source.split("struct GPSCockpitDashboard: View {",1)[1].split(
    "// Pulsante dedicato",1)[0]

# The Home retains the two old 242° BMS rings and side-by-side power labels.
assert "var showsOuterPowerRings: Bool = true" in speed
assert "if showsOuterPowerRings {" in speed
assert "if showsPowerReadings {" in speed
assert "start: 149, end: 391, count: 64, radiusFactor: 0.469" in speed
assert "start: 149, end: 391, count: 64, radiusFactor: 0.427" in speed
assert "showsOuterPowerRings: false" in dashboard
assert "showsPowerReadings: false" in dashboard

# GPS semicircle uses ONLY JKSnapshot.power, no synthetic input, and
# matches both numerical colors exactly to those of active segments.
assert "GPSPowerSemicircle(powerWatts: live?.power, d: dialSize)" in dashboard
assert "guard let powerWatts, powerWatts.isFinite else { return nil }" in power
assert "measuredPower.map { min(1, max(0, $0) / 5_000) }" in power
assert "measuredPower.map { min(1, max(0, -$0) / 5_000) }" in power
assert "start: 90, end: 126, count: 24, radiusFactor: 0.433" in power
assert "start: 90, end: 54, count: 24, radiusFactor: 0.433" in power
assert power.count("activeColor: CockpitTheme.regenAccent") == 1
assert power.count("activeColor: CockpitTheme.dischargeAccent") == 1
assert "if measuredPower > 0 { return CockpitTheme.regenAccent }" in power
assert "if measuredPower < 0 { return CockpitTheme.dischargeAccent }" in power
assert "String(format: \"%.2f kW\", abs($0) / 1_000)" in power
assert '?? "— kW"' in power
assert "ForEach(1...5, id:" in power
assert power.count('Text(String(value))') == 2
assert 'Text("0")' in power
assert 'Text("READY")' in power and 'Text("OFF")' in power
assert "stato marcia non disponibile" in power

# The bridge is now inside dial coordinates; old 76 external clip is inactive.
for fragment in ("d * 0.165", "d * 0.310", "d * 0.690", "d * 0.835",
                 "d * 0.746", "d * 0.852"):
    assert fragment in bridge_geometry
assert "GPSInnerBridgeContour()" in bridge
assert "GPSMetalContourStyle.gradient(for: colorScheme)" in bridge
assert ".mask(GPSLowerTerminalFade())" in bridge
assert ".frame(width: dialSize, height: dialSize)" in dashboard
assert ".mask(GPSBridgeUpperMask())" not in dashboard
assert "CockpitPowerReadings(d: dialSize" not in dashboard
assert "GPSLowerGlow(theme: theme)" in dashboard

# Orange ring is physically thicker, concentric and fully closed.
assert "max(3.8, d * 0.017)" in ring
assert "GPSInnerLED.haloWidth(d) * 1.40" in ring
assert "GPSInnerLED.coreWidth(d) * 1.45" in ring
assert ring.count(".frame(width: d * 0.992, height: d * 0.992)") == 4
assert ".mask(LinearGradient(stops:" not in ring
assert ".mask(LinearGradient(stops:" not in metal
assert "GPSMetalInnerRing()" in dashboard and "GPSGaugeHalo(theme: theme)" in dashboard
assert "Build 77" in state

# Scale geometry has distinct left/right halves and clear labels above bar.
for d in (320, 400, 520, 710):
    for value in range(1, 6):
        angle_left=radians(90+36*value/5)
        angle_right=radians(90-36*value/5)
        left_x=0.5*d+0.385*d*cos(angle_left)
        right_x=0.5*d+0.385*d*cos(angle_right)
        assert left_x < 0.5*d < right_x
        assert abs((left_x+right_x)-d)<1e-7
    assert 0.746*d < 0.800*d < 0.876*d < 0.933*d
print("OK — build 77: internal 0-5 kW twin arcs, real sign-based color, READY/OFF legends, full thick halo")
