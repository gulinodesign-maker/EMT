"""Build 80: no power-scale numbers, bigger BMS ticks, smaller GPS dial."""
from pathlib import Path
from math import isclose, radians, cos, sin
root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 80;") == 2
assert pbx.count("MARKETING_VERSION = 1.0;") == 2

geo = source.split("private enum GPSUnifiedScaleGeometry {",1)[1].split("// Tacche della velocità:",1)[0]
segment = source.split("private struct SegmentedGaugeBar: View {",1)[1].split("// Cifre velocità",1)[0]
power = source.split("private struct GPSPowerSemicircle: View {",1)[1].split("// Calcola la posizione",1)[0]
layout = source.split("private enum GPSDialLayout {",1)[1].split("private enum GPSMetalContourStyle {",1)[0]
dashboard = source.split("struct GPSCockpitDashboard: View {",1)[1].split("// Pulsante dedicato",1)[0]
speed = source.split("private struct OpenSpeedCluster: View {",1)[1].split("private struct CockpitPowerReadings: View {",1)[0]

# Only the live BMS single kW value remains, not number markers on either arc.
assert "Text(powerText)" in power
assert 'String(format: "%.2f kW", abs($0) / 1_000)' in power
assert "if measuredPower > 0 { return CockpitTheme.regenAccent }" in power
assert "if measuredPower < 0 { return CockpitTheme.dischargeAccent }" in power
for label in ('Text("0")', 'Text(String(value))', 'ForEach(1...5',
              'ForEach([1.0, 2.5]', 'labelPoint(kilowatts:', 'scaleTextColor'):
    assert label not in power, label
assert "GPSPowerBelowBridgeMask()" in power
assert "GPSPowerSemicircle(powerWatts: live?.power, d: dialSize)" in dashboard

# Tick stroke now 0.025d ONLY in the GPS power semicircle. Home untouched.
assert "static let powerTickThicknessFactor: CGFloat = 0.025" in geo
assert "(outerRadius(for: d) - d * powerTickThicknessFactor / 2) / d" in geo
assert "var thicknessFactor: CGFloat = 0.017" in segment
assert "let thickness: CGFloat = d * thicknessFactor" in segment
assert power.count("thicknessFactor: GPSUnifiedScaleGeometry.powerTickThicknessFactor") == 2
assert "end: GPSPowerArcLayout.regenEndAngle, count: 12," in power
assert "end: GPSPowerArcLayout.dischargeEndAngle, count: 24," in power
assert "start: 149, end: 391, count: 64, radiusFactor: 0.469" in speed
assert "start: 149, end: 391, count: 64, radiusFactor: 0.427" in speed

# GPS dial only ~4.7% smaller; relative placement and metal rim maintained.
assert "min(height * 0.920, width * 0.525)" in layout
assert "GPSDialLayout.size(width: w, height: h)" in dashboard
assert "let dialCenterX = GPSDialLayout.centerX(width: w, height: h)" in dashboard
assert dashboard.count(".frame(width: dialSize, height: dialSize)") >= 5
for w, h in ((736,414),(844,390),(932,430),(1179,510),(1536,706),(1806,831)):
    old_d = min(h*0.965, w*0.55)
    d = min(h*0.920, w*0.525)
    assert 0.94 < d/old_d < 0.97
    outer = d*0.965/2 - max(1.5, d*0.0035)/2 - min(4,max(3,d*0.009))
    bar_r = outer - d*0.025/2
    assert isclose(bar_r+d*0.025/2, outer, abs_tol=1e-9)
    assert d*0.025 > d*0.017
    for degrees in (54,102,126):
        x=0.5*d+bar_r*cos(radians(degrees))
        y=0.5*d+bar_r*sin(radians(degrees))
        assert 0<x<d and 0<y<d
assert "Build 80" in state
print("OK — build 80: power scales without numbers, +47% tick thickness, GPS dial ~5% smaller")
