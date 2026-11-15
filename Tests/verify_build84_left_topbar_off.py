"""Build 84: remove only the left GPS top-bar orange neon, starting from build 83."""
from pathlib import Path
from hashlib import sha1

root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_bytes()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

# Guard the full Swift file against accidental changes to GPS/BMS/MapKit or cockpit.
blob = b"blob " + str(len(source)).encode() + b"\x00" + source
assert sha1(blob).hexdigest() == "b19ca124bd4bb54df11cad6b0c504d5847a99642"
assert project.count("CURRENT_PROJECT_VERSION = 84;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert project.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2
assert "Build 84" in state and "Build 83" in state

code = source.decode()
top = code.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "private struct GPSHeader: View {", 1)[0]
# Keep the two original gray metallic segments.
metal = top.split("let metalBaseLine = Path { path in", 1)[1].split(
    "let line = right", 1)[0]
assert "path.addPath(left)" in metal and "path.addPath(right)" in metal
assert "let metalLine = metalBaseLine.applying(CGAffineTransform(" in top
assert "metalLine.stroke(GPSMetalContourStyle.gradient(for: colorScheme)" in top
# Only the right-side shape feeds all four orange/white LED strokes.
assert "let line = right" in top
assert "let line = Path { path in" not in top
assert top.count("line.stroke(") == 4
assert "line.stroke(theme.accent, lineWidth: GPSContourStroke.width(height: h))" in top
assert ".mask(visibleOutsideRing.fill(style: FillStyle(eoFill: true)))" in top
assert "GPSGaugeHalo(theme: theme)" in code
assert "GPSLowerGlow(theme: theme)" in code
assert "GPSHorizonSymmetry.temperatureFrame(width: w, height: h)" in code
assert "private struct GPSBridgeUpperMask: Shape {" in code
print("OK — build 84: left top-bar neon removed; right neon, gray guide and cockpit preserved")
