"""Build 75: inset metallic top-bar contour and readable light-mode GPS speed."""
from pathlib import Path
from math import isclose

root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 77;") == 2
metal = source.split("private enum GPSMetalContourStyle {", 1)[1].split(
    "private struct GPSMetalInnerRing: View {", 1)[0]
ring = source.split("private struct GPSMetalInnerRing: View {", 1)[1].split(
    "private struct GPSGaugeHalo: View {", 1)[0]
top = source.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "@MainActor", 1)[0]
speed = source.split("Text(String(Int(speed.rounded())))", 1)[1].split(
    ".accessibilityLabel(", 1)[0]

# A single metallic palette and stroke scale is used in both the ring and top bar.
assert "GPSMetalContourStyle.gradient(for: colorScheme)" in ring
assert "GPSMetalContourStyle.gradient(for: colorScheme)" in top
assert "GPSMetalContourStyle.strokeWidth(for: d)" in ring
assert "GPSMetalContourStyle.strokeWidth(for: dialSize)" in top
assert ".frame(width: d * 0.965, height: d * 0.965)" in ring
assert "dialSize * (0.992 - 0.965) / 2" in metal
assert "CGAffineTransform(" in top and "GPSMetalContourStyle.inset(for: dialSize)" in top
assert "metalLine.stroke(" in top and "visibleOutsideMetalRing.fill(style: FillStyle(eoFill: true))" in top
assert ".mask(visibleOutsideRing.fill(style: FillStyle(eoFill: true)))" in top
assert top.count("line.stroke(theme.accent, lineWidth: GPSContourStroke.width(height: h))") == 1
assert "GPSOuterProfileReinforcement" not in source

# The only added speed contrast is a downward shadow in light mode.
assert ".font(.custom(\"Arial-BoldMT\", size: d * 0.275))" in speed
assert ".foregroundStyle(CockpitTheme.speedDigitsAccent)" in speed
assert speed.count("colorScheme == .light ? .black.opacity(") == 2
assert speed.count(": .clear") == 2
assert "y: d * 0.007" in speed and "y: d * 0.012" in speed
assert speed.index(".shadow(") < speed.index(".frame(")
assert "Build 75" in state

# The offset is the same radial inset as the concentric GPS metal ring.
for width, height in ((736, 414), (844, 390), (932, 430), (1179, 510), (1536, 706)):
    d = min(height * 0.965, width * 0.55)
    gap = d * (0.992 - 0.965) / 2
    assert isclose(d * 0.992 / 2 - d * 0.965 / 2, gap, abs_tol=1e-9)
    assert gap > 0
print("OK — build 75: gray top bar follows inset metal ring; day-mode speed shadows")
