"""Build 128 regression: keep independent vehicle indications and a rear/side view.
Build 129 replaces Euler source with calibrated gravity to fix physical accuracy.
"""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
motion = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
panel = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text().split(
    "private struct GPSInclinationPanel: View {", 1
)[1]
assert 'dialView(label: "ROLLIO", value: motion.inclinationRollDegrees,' in panel
assert 'dialView(label: "BECCHEGGIO", value: motion.inclinationPitchDegrees,' in panel
assert 'Image(systemName: roll ? "car.rear.fill" : "car.side.fill")' in panel
assert 'ForEach(0..<72, id: \\.self) { tick in' in panel
assert "VehicleInclinationMath.angles(" in motion
assert "let roll = angles.rollDegrees" in motion
assert "let pitch = angles.pitchDegrees" in motion
assert "relative.multiply(byInverseOf: reference)" not in motion
assert "inclinationRollDegrees = (inclinationRollDegrees ?? roll)" in motion
assert "inclinationPitchDegrees = (inclinationPitchDegrees ?? pitch)" in motion
assert "func zeroInclination()" in motion
print("OK — dual inclinometer dial mapping preserved using calibrated gravity")
