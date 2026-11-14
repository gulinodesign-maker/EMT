"""Build 78: shared GPS velocity/power circle, 3–4pt gap, metallic bridge."""
from pathlib import Path
from math import isclose, cos, sin, radians

root=Path(__file__).resolve().parents[1]
s=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
p=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
state=(root/"STATO_PROGETTO.md").read_text()
assert p.count("CURRENT_PROJECT_VERSION = 78;") == 2
geo=s.split("private enum GPSUnifiedScaleGeometry {",1)[1].split("// Tacche della velocità:",1)[0]
ticks=s.split("private struct SpeedScaleTicks: View {",1)[1].split("/// Stream LED ARANCIONE",1)[0]
led=s.split("private struct SpeedLEDStream: View {",1)[1].split("private struct SegmentedGaugeBar: View {",1)[0]
seg=s.split("private struct SegmentedGaugeBar: View {",1)[1].split("// Cifre velocità",1)[0]
speed=s.split("private struct OpenSpeedCluster: View {",1)[1].split("private struct CockpitPowerReadings: View {",1)[0]
power=s.split("private struct GPSPowerSemicircle: View {",1)[1].split("// Calcola la posizione",1)[0]
bridge=s.split("private struct GPSLowerGlow: View {",1)[1].split("// EJ 1.22",1)[0]
ring=s.split("private struct GPSMetalInnerRing: View {",1)[1].split("private struct GPSGaugeHalo: View {",1)[0]
orange=s.split("private struct GPSGaugeHalo: View {",1)[1].split("// EJ 1.23",1)[0]

assert "min(4, max(3, d * 0.009))" in geo
assert "d * 0.965 / 2" in geo
assert "GPSMetalContourStyle.strokeWidth(for: d) / 2" in geo
assert "outerRadius(for: d) - d * 0.017 / 2" in geo
assert "GPSUnifiedScaleGeometry.outerRadius(for: d)" in ticks
assert "d * 0.393" in ticks  # Home untouched
assert "146.0 + Double(index) * (248.0 / 48.0)" in ticks
assert "start: 90, end: 146, count: 24," in power
assert "start: 90, end: 34, count: 24," in power
assert power.count("GPSUnifiedScaleGeometry.powerBarRadiusFactor(for: d)") == 2
assert "let degrees = 90.0 + (input ? 56.0 : -56.0)" in power
assert "let radius = d * 0.408" in power
assert "let edgeInset: Double = stepAngle >= 0 ? 0.40 : -0.40" in seg
assert "SpeedLEDStream(d: d, speed: speed)" in speed
assert "SpeedScaleTicks(d: d)" in speed
assert "SpeedLEDStream(d: d, speed: speed, usesGPSRing: true)" in speed
assert "SpeedScaleTicks(d: d, usesGPSRing: true)" in speed
assert "let arcStart = usesGPSRing ? 190.0 : 146.0" in led
assert "let arcEnd = 394.0" in led
assert "GPSUnifiedScaleGeometry.speedLEDRadius(for: d)" in led
assert "let radius = ledRadius" in led
assert "speed / max(30, vehicleSpeedMaxKmh)" in led
assert "GPSMetalContourStyle.strokeWidth(for: d)" in ring
assert "let lineWidth = GPSMetalContourStyle.strokeWidth(for: d)" in bridge
assert "style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)" in bridge
assert "GPSMetalContourStyle.gradient(for: colorScheme)" in bridge
assert "GPSInnerLED.haloWidth" not in bridge
assert ".mask(GPSLowerTerminalFade())" in bridge
assert "max(3.8, d * 0.017)" in orange  # orange halo unchanged
assert "Build 78" in state

for d in (260,320,394,430,520,710):
    metal_width=max(1.5,d*0.0035)
    clearance=min(4,max(3,d*0.009))
    outer=d*0.965/2-metal_width/2-clearance
    bar_center=outer-d*0.017/2
    led_center=outer-d*0.034/2
    assert 3<=clearance<=4
    assert isclose(d*0.965/2-metal_width/2-outer,clearance,abs_tol=1e-8)
    assert isclose(bar_center+d*0.017/2,outer,abs_tol=1e-8)
    assert 0<led_center and led_center+d*0.034/2<=outer+1e-8
    for v in range(1,6):
        for side in (-1,1):
            rad=radians(90+side*56*v/5)
            x=d*0.5+d*0.408*cos(rad)
            y=d*0.5+d*0.408*sin(rad)
            assert 0<x<d and d*0.65<y<d*0.91
print("OK — build 78 unified circular speed/power scale and gray-ring-width bridge")
