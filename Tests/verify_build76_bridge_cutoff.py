"""Build 76: no GPS dial or colored rings below the actual lower kW bridge."""
from pathlib import Path
from math import isclose

root = Path(__file__).resolve().parents[1]
src = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
version = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

assert version.count("CURRENT_PROJECT_VERSION = 76;") == 2
dashboard = src.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]
mask = src.split("private struct GPSBridgeUpperMask: Shape {", 1)[1].split(
    "// Maschera orizzontale", 1)[0]
bridge = src.split("private struct GPSLowerGlow: View {", 1)[1].split(
    "// EJ 1.22", 1)[0]
power = src.split("private struct CockpitPowerReadings: View {", 1)[1].split(
    "// Calcola la posizione", 1)[0]
speed = src.split("private struct OpenSpeedCluster: View {", 1)[1].split(
    "private struct CockpitPowerReadings: View {", 1)[0]

# All GPS dial visuals are clipped as ONE composite layer, not just the rings.
a = dashboard.index("ZStack {\n                    OpenSpeedCluster(")
b = dashboard.index(".mask(GPSBridgeUpperMask())", a)
section = dashboard[a:b]
for element in ("OpenSpeedCluster(", "GPSMetalInnerRing()", "GPSGaugeHalo(theme: theme)"):
    assert element in section
assert "showsPowerReadings: false" in section
assert ".frame(width: w, height: h)" in section
assert dashboard.index("GPSLowerGlow(theme: theme)") > b
assert dashboard.index("CockpitPowerReadings(d: dialSize") > dashboard.index("GPSLowerGlow(theme: theme)")

# The same geometric curve draws the bridge and defines the cutoff; after the
# two feet it is horizontal to the screen edges, leaving no protruding arcs.
assert "let points = GPSLowerLineGeometry.points(in: rect)" in mask
assert "var upper = GPSLowerContour().path(in: rect)" in mask
assert "upper.addLine(to: CGPoint(x: rect.maxX, y: rightFoot.y))" in mask
assert "upper.addLine(to: CGPoint(x: rect.minX, y: leftFoot.y))" in mask
assert "upper.closeSubpath()" in mask
assert "GPSLowerContour()" in bridge
assert "GPSLowerShade()" not in bridge
assert ".mask(GPSLowerTerminalFade())" in bridge

# Reused kW reading view retains the original font, geometry and BMS sources.
assert "var showsPowerReadings: Bool = true" in speed
assert "if showsPowerReadings {" in speed
assert 'String(format: "%.2f kW", $0 / 1000)' in power
assert ".font(.system(size: d * 0.066, weight: .semibold))" in power
assert ".frame(width: d * 0.66, height: d * 0.13)" in power
assert ".position(x: d * 0.50, y: d * 0.889)" in power
assert "live.map { Swift.max(0, $0.power) }" in dashboard
assert "live.map { Swift.max(0, -$0.power) }" in dashboard
assert "Build 76" in state

# The bridge remains strictly above the 0.937-height feet, so the mask
# does not touch the speed digits, ODO or km/h in the centre.
for w,h in ((736,414),(844,390),(932,430),(1179,510),(1536,706),(1806,831)):
    d = min(h * 0.965, w * 0.55)
    top = min(h * 0.790, h * 0.494 + d * (0.889 - 0.50 - 0.065) - max(12, h * 0.014))
    foot = h * 0.937
    assert 0 < top < foot < h
    assert h * 0.494 + d * (0.755 - 0.5 + 0.065 / 2) < top
    assert isclose(foot/h,0.937)
print("OK — build 76: dial/metal/orange clipped on bridge; kW visible over pure backdrop")
