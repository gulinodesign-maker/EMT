"""Build 53: Arial Bold applies only to real GPS speed digits."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
c=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
g=(root/"Ecojumbo/Models/GPSRideManager.swift").read_text()
p=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert p.count("CURRENT_PROJECT_VERSION = 65;") == 2
speed=c.split("private struct OpenSpeedCluster: View {",1)[1].split(
    "// Calcola la posizione più a sinistra possibile",1)[0]
speed_number=speed.split("Text(String(Int(speed.rounded())))",1)[1].split(
    ".accessibilityLabel(",1)[0]
assert '.font(.custom("Arial-BoldMT", size: d * 0.275))' in speed_number
assert ".foregroundStyle(CockpitTheme.speedDigitsAccent)" in speed_number
assert ".monospacedDigit()" in speed_number
assert ".frame(width: d * 0.60, height: d * 0.285)" in speed_number
assert ".font(.system(size: d * 0.275, weight: .bold, design: .rounded))" not in speed
assert speed.count("Arial-BoldMT") == 1
assert "Text(\"km/h\")" in speed
assert "String(format: \"ODO %.0f km\", $0)" in speed
assert "SpeedLEDStream(d: d, speed: speed)" in speed
# Models/GPSRideManager is intentionally unchanged from the working GPS build.
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in g
assert "fix.speedAccuracy <= 5 && fix.speed <= 50" in g
assert "date.timeIntervalSince(lastValidAt) < 8" in g
assert "func currentSpeed(at date: Date = Date()) -> Double?" in g
print("OK — build 53: Arial Bold rosso sul solo valore velocità; GPS invariato")
