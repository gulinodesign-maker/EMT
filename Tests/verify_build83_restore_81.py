"""Build 83 restores the exact build 81 cockpit (itself byte-identical to build 76).

Original historical merge commit: 42e72614211580dc771e06f9dc764f33a88fc194.
This fingerprint checks the complete restored Swift source, not just selected strings.
"""
from pathlib import Path
from hashlib import sha1

root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_bytes()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

blob = b"blob " + str(len(source)).encode() + b"\x00" + source
assert sha1(blob).hexdigest() == "55f939bc8c981efda5090eb48e417f3fce986d74"
assert project.count("CURRENT_PROJECT_VERSION = 83;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert "Build 83" in state and "Build 81" in state and "Build 76" in state
code = source.decode()
assert "private struct GPSBridgeUpperMask: Shape {" in code
assert ".mask(GPSBridgeUpperMask())" in code
assert "CockpitPowerReadings(d: dialSize" in code
assert "private struct GPSPowerSemicircle: View {" not in code
assert "private enum GPSPowerArcLayout {" not in code
print("OK — build 83 restores the byte-identical cockpit from build 81 / 76")
