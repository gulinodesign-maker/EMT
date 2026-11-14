"""Build 79: 1:2 power sectors are physically below the kW bridge."""
from pathlib import Path
from math import radians, sin, cos, isclose

root=Path(__file__).resolve().parents[1]
source=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
project=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
status=(root/"STATO_PROGETTO.md").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 80;") == 2

power=source.split("private struct GPSPowerSemicircle: View {",1)[1].split(
    "// Calcola la posizione",1)[0]
layout=source.split("private enum GPSPowerArcLayout {",1)[1].split(
    "// Build 79: potenza",1)[0]
mask=source.split("private struct GPSPowerBelowBridgeMask: Shape {",1)[1].split(
    "// Maschera orizzontale",1)[0]
bridge=source.split("private enum GPSInnerBridgeLayout {",1)[1].split(
    "private struct GPSInnerBridgeContour: Shape {",1)[0]
speed=source.split("private struct SpeedLEDStream: View {",1)[1].split(
    "private struct SegmentedGaugeBar: View {",1)[0]
dashboard=source.split("struct GPSCockpitDashboard: View {",1)[1].split(
    "// Pulsante dedicato",1)[0]

assert "static let zeroAngle = 102.0" in layout
assert "static let regenEndAngle = 126.0" in layout
assert "static let dischargeEndAngle = 54.0" in layout
assert "static let regenMaxKilowatts = 2.5" in layout
assert "static let dischargeMaxKilowatts = 5.0" in layout
assert "let ratio = min(1, max(0, value / maximum))" in layout
assert "GPSPowerArcLayout.regenMaxKilowatts * 1_000" in power
assert "GPSPowerArcLayout.dischargeMaxKilowatts * 1_000" in power
assert "end: GPSPowerArcLayout.regenEndAngle, count: 12," in power
assert "end: GPSPowerArcLayout.dischargeEndAngle, count: 24," in power
assert power.count("GPSUnifiedScaleGeometry.powerBarRadiusFactor(for: d)") == 2
assert 'Text("READY")' not in power and 'Text("OFF")' not in power
assert "Etichette scala: READY" not in power
assert "ForEach([1.0, 2.5], id:" not in power
assert "ForEach(1...5, id:" not in power
assert 'Text("0")' not in power
assert power.count("thicknessFactor: GPSUnifiedScaleGeometry.powerTickThicknessFactor") == 2
assert "GPSPowerBelowBridgeMask()" in power
assert "var below = GPSInnerBridgeContour().path(in: rect)" in mask
assert "GPSInnerBridgeLayout.points(in: rect)" in mask
assert "below.addLine(to: CGPoint(x: rect.maxX, y: rightFoot.y))" in mask
assert "below.addLine(to: CGPoint(x: rect.minX, y: leftFoot.y))" in mask
assert "below.closeSubpath()" in mask
assert "GPSPowerSemicircle(powerWatts: live?.power, d: dialSize)" in dashboard
assert "CGPoint(x: x + d * 0.165, y: y + d * 0.825)" in bridge
assert "CGPoint(x: x + d * 0.310, y: y + d * 0.705)" in bridge
assert "CGPoint(x: x + d * 0.690, y: y + d * 0.705)" in bridge
assert "CGPoint(x: x + d * 0.835, y: y + d * 0.825)" in bridge
assert "let arcStart = 146.0" in speed
assert "let arcEnd = 394.0" in speed
assert "if let progress, progress > 0" in speed
assert "GPSUnifiedScaleGeometry.speedLEDRadius(for: d)" in speed
assert "Build 79" in status

blue_degrees=126-102
red_degrees=102-54
assert blue_degrees==24 and red_degrees==48
assert blue_degrees*2==red_degrees
assert isclose(blue_degrees/2.5, red_degrees/5)
# Geometric safety margin for every larger BMS segment:
# line is approximated by the conservative unrounded bridge polyline;
# actual clipping is guaranteed by the exact bridge-mask path above.
def bridge_y(x):
    if x<.165 or x>.835: return .825
    if x<.310: return .825-(x-.165)*(.825-.705)/(.310-.165)
    if x<=.690: return .705
    return .705+(x-.690)*(.825-.705)/(.835-.690)

for d in (300, 394, 430, 520, 710):
    metal_width=max(1.5,d*.0035)
    clearance=min(4,max(3,d*.009))
    tick_r=.890/2-metal_width/d/2-clearance/d
    bar_r=tick_r-.025/2
    for first,last in ((102,126),(54,102)):
        for i in range(41):
            deg=first+(last-first)*i/40
            x=.5+bar_r*cos(radians(deg))
            y=.5+bar_r*sin(radians(deg))
            assert y-.025/2 > bridge_y(x)+.02,(d,deg,x,y)
print("OK — build 79 1/3 cyan, 2/3 red, inside-bridge mask and speed LED at scale minimum")
