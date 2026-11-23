"""Build 72 regression carried into 87: speed LED preserved, GPS contours now gray."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 129;") == 2
speed = source.split("private struct SpeedLEDStream: View {",1)[1].split("private struct SegmentedGaugeBar",1)[0]
top = source.split("private struct GPSHorizonLine: View {",1)[1].split("@MainActor",1)[0]
lower = source.split("private struct GPSLowerGlow: View {",1)[1].split("// EJ 1.22",1)[0]
for key in ("haloWidth", "haloBlur", "coreWidth", "outerBlur"):
    assert "GPSInnerLED."+key+"(d)" in speed
assert "GPSGaugeHalo(theme: theme)" not in source
assert "GPSMetalInnerRing()" in source
assert "metalLine.stroke(GPSMetalContourStyle.gradient(for: colorScheme)" in top
assert "line.stroke(theme.accent" not in top
assert ".mask(visibleOutsideMetalRing.fill(style: FillStyle(eoFill: true)))" in top
assert "GPSLowerContour()" in lower
assert "GPSMetalContourStyle.gradient(for: colorScheme)" in lower
assert "theme.accent" not in lower
assert ".mask(GPSLowerTerminalFade())" in lower
assert "GPSLowerShade()" not in lower
assert "GPSHorizonLine(theme: theme)" in source
assert "GPSLowerGlow(theme: theme)" in source
print("OK — retained speed LED and gray metal GPS contours (87)")
