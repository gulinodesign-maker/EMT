"""Build 129: true gravity tilt, no automatic zero, clockwise right-down roll."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
motion = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
math = (root / "Ecojumbo/Models/VehicleInclinationMath.swift").read_text()
panel = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text().split(
    "private struct GPSInclinationPanel: View {", 1)[1]
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
workflow = (root / ".github/workflows/ios-build.yml").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 130;") == 2
assert "VehicleInclinationMath.swift in Sources" in project
assert "let gravity = VehicleGravityVector(x: motion.gravity.x, y: motion.gravity.y, z: motion.gravity.z)" in motion
assert "VehicleInclinationMath.angles(" in motion
assert "relative.multiply(byInverseOf: reference)" not in motion
assert "inclinationReference = active" not in motion
assert "inclinationZeroGravity = gravity" in motion
assert "inclinationZeroLandscapeLeft = landscapeLeft" in motion
assert "inclinationZeroGravity = nil" in motion
assert "inclinationRollDegrees = (inclinationRollDegrees ?? roll) * 0.70 + roll * 0.30" in motion
assert "inclinationPitchDegrees = (inclinationPitchDegrees ?? pitch) * 0.70 + pitch * 0.30" in motion
assert "let roll = angles.rollDegrees" in motion
assert "let pitch = angles.pitchDegrees" in motion
assert ".rotationEffect(.degrees(roll ? (value ?? 0) : -(value ?? 0)))" in panel
assert ".disabled(!motion.available)" in panel
assert 'Image(systemName: roll ? "car.rear.fill" : "car.side.fill")' in panel
assert 'Label("AZZERA", systemImage: "scope")' in panel
assert 'ForEach(0..<72, id: \\.self) { tick in' in panel
assert "guard gravity.isValid, let zeroGravity, zeroGravity.isValid" in math
assert "let roll = atan2(lateral, vertical)" in math
assert "let pitch = atan2(longitudinal, hypot(lateral, vertical))" in math
assert "swiftc Ecojumbo/Models/VehicleInclinationMath.swift Tests/VehicleInclinationMathTests.swift" in workflow
print("OK — build129: calibrated real degrees, right-down roll, no automatic arbitrary zero")
