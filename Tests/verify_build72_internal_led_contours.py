"""Build 72: the same narrow LED glow must face inward on all three GPS contours."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 80;") == 2

led = source.split("private enum GPSInnerLED {", 1)[1].split("private enum GPSDialLayout", 1)[0]
for name in ("haloWidth", "haloBlur", "coreWidth", "coreBlur"):
    assert name in led
top = source.split("private struct GPSHorizonLine: View {", 1)[1].split("@MainActor", 1)[0]
ring = source.split("private struct GPSGaugeHalo: View {", 1)[1].split("// EJ 1.23", 1)[0]
lower = source.split("private struct GPSLowerGlow: View {", 1)[1].split("// EJ 1.22", 1)[0]
# Preview: both contours use the same non-uniform multi-pass material.
for section in (top, ring):
    assert "EMTNeonStroke(" in section
    assert "theme.glowIntensity" in section
assert "GPSContourStroke.width(height: h)" in top
assert ".mask(visibleOutsideRing.fill(style: FillStyle(eoFill: true)))" in top
assert "GPSHorizonSymmetry.corners(width: w, height: h)" in source
assert "EMTDialSpecularReflection(diameter: d)" in ring
assert "thickness: d * 0.0095" in ring
assert ".frame(width: d * 0.992, height: d * 0.992)" in ring
assert ".mask(LinearGradient(stops:" not in ring  # 77: full 360-degree orange halo
assert "let lineWidth = GPSMetalContourStyle.strokeWidth(for: d)" in lower
assert "GPSInnerLED.haloWidth" not in lower
assert "GPSMetalContourStyle.gradient(for: colorScheme)" in lower
assert ".mask(GPSLowerTerminalFade())" in lower
assert "GPSLowerShade()" not in lower
assert "GPSLowerShade().path(in: rect)" in source
assert "GPSMetalInnerRing()" in source
assert "GPSGaugeHalo(theme: theme)" in source
assert "GPSLowerGlow(theme: theme)" in source
assert "GPSHorizonLine(theme: theme)" in source
for prohibited in ("GPSOuterProfileReinforcement", "GPSTopBandShade",
                   "GPSLowerAreaGradient", "GPSAreaGradientStyle"):
    assert prohibited not in source
assert "EMTNeonStroke(contour: line, color: theme.accent" in top
assert "style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)" in lower
print("OK — build 72: inward LED on top bar, orange ring and kW bridge with fade preserved")
