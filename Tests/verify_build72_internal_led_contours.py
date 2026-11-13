"""Build 72: the same narrow LED glow must face inward on all three GPS contours."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 75;") == 2

led = source.split("private enum GPSInnerLED {", 1)[1].split("private enum GPSDialLayout", 1)[0]
for name in ("haloWidth", "haloBlur", "coreWidth", "coreBlur"):
    assert name in led
top = source.split("private struct GPSHorizonLine: View {", 1)[1].split("@MainActor", 1)[0]
ring = source.split("private struct GPSGaugeHalo: View {", 1)[1].split("// EJ 1.23", 1)[0]
lower = source.split("private struct GPSLowerGlow: View {", 1)[1].split("// EJ 1.22", 1)[0]
for section in (top, ring, lower):
    for method in ("haloWidth", "haloBlur", "coreWidth", "coreBlur"):
        assert "GPSInnerLED." + method + "(" in section
assert "GPSInnerLED.haloWidth(h)" in top
assert "GPSInnerLED.highlightWidth(h)" in top
assert "GPSInnerLED.outerOpacity(theme.glowIntensity)" in top
assert ".mask(visibleOutsideRing.fill(style: FillStyle(eoFill: true)))" in top
assert "GPSHorizonSymmetry.corners(width: w, height: h)" in source
assert ring.count("GPSInnerLED.haloWidth(d)") == 1
assert "GPSInnerLED.highlightWidth(d)" in ring
assert ".shadow(color: theme.accent.opacity(GPSInnerLED.outerOpacity(theme.glowIntensity))" in ring
assert ".frame(width: d * 0.992, height: d * 0.992)" in ring
for fade in ("location: 0.65", "location: 0.72", "location: 0.80"):
    assert fade in ring
assert "GPSInnerLED.haloWidth(h)" in lower
assert "GPSInnerLED.highlightWidth(h)" in lower
assert ".mask(GPSLowerTerminalFade())" in lower
assert "GPSLowerShade()" in lower
assert "GPSLowerShade().path(in: rect)" in source
assert "GPSMetalInnerRing()" in source
assert "GPSGaugeHalo(theme: theme)" in source
assert "GPSLowerGlow(theme: theme)" in source
assert "GPSHorizonLine(theme: theme)" in source
for prohibited in ("GPSOuterProfileReinforcement", "GPSTopBandShade",
                   "GPSLowerAreaGradient", "GPSAreaGradientStyle"):
    assert prohibited not in source
assert "line.stroke(theme.accent, lineWidth: GPSContourStroke.width(height: h))" in top
assert "StrokeStyle(lineWidth: GPSContourStroke.width(height: h)," in lower
print("OK — build 72: inward LED on top bar, orange ring and kW bridge with fade preserved")
