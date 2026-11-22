"""Build 86: one signed kW in the GPS cockpit and 40% shorter bridge top."""

from pathlib import Path
from math import isclose

root = Path(__file__).resolve().parents[1]
code = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 127;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert project.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2
assert "Build 86" in state

# The Home's original independent input/output readings stay unchanged.
home = code.split("private struct CockpitPowerReadings: View {", 1)[1].split(
    "private struct GPSCockpitPowerReading: View {", 1)[0]
assert "HStack(spacing: 0)" in home
assert 'Text(incomingPower.map { String(format: "%.2f kW"' in home
assert 'Text(outgoingPower.map { String(format: "%.2f kW"' in home

# The GPS cockpit draws ONE net signed reading, not two columns or a divider.
single = code.split("private struct GPSCockpitPowerReading: View {", 1)[1].split(
    "// Calcola la posizione", 1)[0]
assert single.count('powerKW.map { String(format: "%.2f kW"') == 1
assert 'if let inertialSymbol {' in single and 'Text(readingText)' in single
assert "HStack(" not in single
assert "Rectangle()" not in single
assert "powerWatts / 1_000.0" in single
assert "powerWatts.isFinite" in single
assert "if powerKW > 0 { return CockpitTheme.dischargeAccent }" in single
assert "if powerKW < 0 { return CockpitTheme.regenAccent }" in single
assert '.position(x: d * 0.50, y: d * 0.889)' in single

gps = code.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]
assert gps.count("GPSCockpitPowerReading(d: dialSize,") == 1
assert "powerWatts: live.map { -$0.power }" in gps
assert "CockpitPowerReadings(d: dialSize" not in gps
assert gps.index("GPSCockpitPowerReading(d: dialSize") > gps.index(
    "GPSLowerGlow(theme: theme)")
assert "showsPowerReadings: false" in gps

# Input JK charge is positive, so invert for GPS convention:
# positive = output/RED; negative = regeneration/BLUE; zero = neutral.
for jk_watts, expected_kw in [(-18_000.0, 18.0), (3_200.0, -3.2), (0.0, 0.0)]:
    assert -jk_watts / 1_000.0 == expected_kw

# The bridge and its mask share one path. The upper width goes
# from 2 * 0.325 d to 2 * 0.195 d (exactly 40% shorter).
geometry = code.split("private enum GPSLowerLineGeometry {", 1)[1].split(
    "private struct GPSLowerContour: Shape {", 1)[0]
assert "let topHalfWidth = d * 0.195" in geometry
assert "let topHalfWidth = d * 0.325" not in geometry
assert "let leftTopX = center - topHalfWidth" in geometry
assert "let rightTopX = min(center + topHalfWidth" in geometry
assert isclose((2 * 0.195) / (2 * 0.325), 0.60)
assert "GPSLowerLineGeometry.points(in: rect)" in code.split(
    "private struct GPSBridgeUpperMask: Shape {", 1)[1].split(
    "private struct GPSLowerTerminalFade: View {", 1)[0]
print("OK — build 86: single signed GPS kW, discharge red/regen blue, 40% narrower bridge, Home intact")
