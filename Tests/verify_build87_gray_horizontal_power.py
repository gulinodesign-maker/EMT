"""Build 87 — gray GPS contours and signed 30/70 horizontal power meter."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
c = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
p = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()
assert p.count("CURRENT_PROJECT_VERSION = 111;") == 2
assert "Build 87" in state
gps = c.split("struct GPSCockpitDashboard: View {",1)[1].split("// Pulsante dedicato",1)[0]
cluster = c.split("private struct OpenSpeedCluster: View {",1)[1].split("private struct CockpitPowerReadings: View {",1)[0]
top = c.split("private struct GPSHorizonLine: View {",1)[1].split("@MainActor",1)[0]
bridge = c.split("private struct GPSLowerGlow: View {",1)[1].split("// EJ 1.22",1)[0]
assert "GPSPowerHorizontalGauge" not in c
assert "GPSGaugeHalo(theme: theme)" not in c
assert "GPSMetalInnerRing()" in gps
assert "metalLine.stroke(GPSMetalContourStyle.gradient(for: colorScheme)" in top
assert "line.stroke(theme.accent" not in top
assert "GPSLowerContour()" in bridge
assert "GPSMetalContourStyle.gradient(for: colorScheme)" in bridge
assert "theme.accent" not in bridge
assert "showsCircularPowerGauges: false" in gps
assert "var showsCircularPowerGauges: Bool = true" in cluster
assert "if showsCircularPowerGauges {" in cluster
assert "SegmentedGaugeBar(d: d, fraction: outputFill" in cluster
assert "SegmentedGaugeBar(d: d, fraction: inputFill" in cluster
assert "SpeedLEDStream(d: d, speed: speed, powerFlow: powerFlow," in cluster
assert "GPSCockpitPowerReading(d: dialSize" in gps
assert "powerWatts: live.map { -$0.power }" in gps
assert "powerFlow: flow" in gps
assert ".position(x: dialCenterX, y: h * 0.963)" not in gps
assert "let topHalfWidth = d * 0.195" in c
assert "GPSBridgeUpperMask()" in c
print("OK — build 87: gray GPS contours and real 30/70 power meter; Home unchanged")
