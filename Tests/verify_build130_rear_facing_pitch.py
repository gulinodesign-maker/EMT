"""Build 130: rear-facing phone, longitudinal tilt sign corrected without touching roll."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
math = (root / "Ecojumbo/Models/VehicleInclinationMath.swift").read_text()
swift_tests = (root / "Tests/VehicleInclinationMathTests.swift").read_text()
motion = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
view = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 132;") == 2
assert "let pitch = atan2(longitudinal, hypot(lateral, vertical))" in math
assert "let roll = atan2(lateral, vertical)" in math
assert "let pitch = atan2(-longitudinal" not in math
assert "z: -sin(p)" in swift_tests
assert "near(noseUp.pitchDegrees, 15)" in swift_tests
assert "near(noseDown.pitchDegrees, -12)" in swift_tests
assert "near(noseUp.rollDegrees, 0)" in swift_tests
assert "near(noseDown.rollDegrees, 0)" in swift_tests
assert "for left in [false, true]" in swift_tests
assert "z: -sin(p)" in swift_tests
assert "let pitch = angles.pitchDegrees" in motion
assert "let roll = angles.rollDegrees" in motion
assert ".rotationEffect(.degrees(roll ? (value ?? 0) : -(value ?? 0)))" in view
assert "inclinationZeroGravity = gravity" in motion
print("OK — rear-facing device pitch sign, calibrated degree values, roll animation unchanged")
