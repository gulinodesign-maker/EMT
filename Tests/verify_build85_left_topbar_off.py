"""Build 85: remove the residual left GPS top-bar metallic guide from build 84."""
from pathlib import Path
from hashlib import sha1

root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_bytes()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

# Guard the full Swift file against accidental changes to GPS/BMS/MapKit or cockpit.
blob = b"blob " + str(len(source)).encode() + b"\x00" + source
assert sha1(blob).hexdigest() == "ea8d9610e634cb2163df80283c46b614eb4afe9c"
assert project.count("CURRENT_PROJECT_VERSION = 85;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert project.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2
assert "Build 85" in state and "Build 84" in state and "Build 83" in state

code = source.decode()
top = code.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "private struct GPSHeader: View {", 1)[0]
# Both orange LED and silver metal must be drawn only on the right path.
assert "let line = right" in top
assert "let metalLine = line.applying(CGAffineTransform(" in top
assert "metalBaseLine" not in top
assert "path.addPath(left)" not in top
assert "let left = CockpitContourGeometry.roundedPath" not in top
assert "metalLine.stroke(GPSMetalContourStyle.gradient(for: colorScheme)" in top
# Only the right-side shape feeds all four orange/white LED strokes.
assert "let line = Path { path in" not in top
assert top.count("line.stroke(") == 4
assert "line.stroke(theme.accent, lineWidth: GPSContourStroke.width(height: h))" in top
assert ".mask(visibleOutsideRing.fill(style: FillStyle(eoFill: true)))" in top
assert "GPSGaugeHalo(theme: theme)" in code
assert "GPSLowerGlow(theme: theme)" in code
assert "GPSHorizonSymmetry.temperatureFrame(width: w, height: h)" in code
assert "private struct GPSBridgeUpperMask: Shape {" in code
print("OK — build 85: left gray and neon top-bar traces removed; right contour and cockpit preserved")
