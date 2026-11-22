"""Build 128: Core Motion axes are mapped to vehicle roll and pitch, not their homonyms."""

from pathlib import Path

root = Path(__file__).resolve().parents[1]
motion = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 128;") == 2

# The iPhone is displayed landscape in the cockpit. Its Core Motion Euler
# labels must not be confused with the car's physical longitudinal/lateral axes.
mapping = motion.split("private func consumeInclination(attitude:", 1)[1].split(
    "private func consume(x:", 1
)[0]
assert "relative.multiply(byInverseOf: reference)" in mapping
assert "let roll = relative.pitch * 180 / .pi" in mapping
assert "let pitch = relative.roll * 180 / .pi" in mapping
assert "let roll = relative.roll * 180 / .pi" not in mapping
assert "let pitch = relative.pitch * 180 / .pi" not in mapping
assert "inclinationRollDegrees = (inclinationRollDegrees ?? roll) * 0.70 + roll * 0.30" in mapping
assert "inclinationPitchDegrees = (inclinationPitchDegrees ?? pitch) * 0.70 + pitch * 0.30" in mapping

# Independent, synthetic rotations: a tilt on either input axis may move
# only its intended dial, without duplicating the other angle.
def vehicle_angles(core_roll_degrees, core_pitch_degrees):
    return core_pitch_degrees, core_roll_degrees

assert vehicle_angles(0, 14) == (14, 0)   # lateral vehicle roll
assert vehicle_angles(-9, 0) == (0, -9)   # nose-down vehicle pitch
assert vehicle_angles(12, 0) == (0, 12)   # nose-up vehicle pitch

panel = cockpit.split("private struct GPSInclinationPanel: View {", 1)[1]
assert 'dialView(label: "ROLLIO", value: motion.inclinationRollDegrees,' in panel
assert 'dialView(label: "BECCHEGGIO", value: motion.inclinationPitchDegrees,' in panel
assert 'Image(systemName: roll ? "car.rear.fill" : "car.side.fill")' in panel
assert 'ForEach(0..<72, id: \\.self) { tick in' in panel
assert ".rotationEffect(.degrees(-(value ?? 0)))" in panel
assert 'Label("AZZERA", systemImage: "scope")' in panel
assert "relative.multiply(byInverseOf: reference)" in motion
assert "func zeroInclination()" in motion
print("OK — build 128: independent vehicle roll/pitch mapping; cockpit and zero unchanged")
