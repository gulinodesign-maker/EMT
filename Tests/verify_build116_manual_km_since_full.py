#!/usr/bin/env python3
"""Build 116: manual distance since last fuel stop, preserved GPS accumulation and TRIP."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
read = lambda p: (root / p).read_text(encoding="utf-8")
settings = read("Ecojumbo/Views/OtherViews.swift")
gps = read("Ecojumbo/Models/GPSRideManager.swift")
project = read("Ecojumbo.xcodeproj/project.pbxproj")
assert project.count("CURRENT_PROJECT_VERSION = 133;") == 2
assert '@State private var kmSinceFullText = ""' in settings
assert '@FocusState private var distanceFieldFocused: Bool' in settings
assert 'Text("Distanza dal pieno")' in settings
assert 'TextField("Km percorsi", text: $kmSinceFullText)' in settings
assert 'Button("Salva", action: saveKmSinceFull)' in settings
assert '.onSubmit(saveKmSinceFull)' in settings
assert 'if distanceFieldFocused { saveKmSinceFull() }' in settings
assert 'func saveKmSinceFull()' in settings
assert '(0...1_000_000).contains(kilometers)' in settings
assert 'guard gps.setUniversalKmSinceFull(kilometers) else {' in settings
assert 'LabeledContent("Distanza dal pieno"' not in settings
manual = gps.split('func setUniversalKmSinceFull(_ kilometers: Double) -> Bool {', 1)[1].split('\n    }', 1)[0]
assert 'EcoVehicleMode.universal.rawValue' in manual
assert '(10...2500).contains(fullRange)' in manual
assert 'kilometers.isFinite, (0...1_000_000).contains(kilometers)' in manual
assert 'universalKmSinceFull = kilometers' in manual
assert 'universalHasFull = true' in manual
assert 'UserDefaults.standard.set(kilometers, forKey: "ecojumbo.vehicle.kmSinceFull")' in manual
assert 'UserDefaults.standard.set(true, forKey: "ecojumbo.vehicle.hasFull")' in manual
assert 'tripKm' not in manual and 'totalKm' not in manual
refuel = gps.split('func recordUniversalFull() -> Bool {',1)[1].split('\n    }',1)[0]
assert 'universalKmSinceFull = 0' in refuel
update = gps.split('func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {',1)[1].split('\n    }',1)[0]
assert 'universalKmSinceFull += increment' in update
assert 'if universalHasFull,' in update
reset = gps.split('func resetTrip() {',1)[1].split('\n    }',1)[0]
assert 'universalKmSinceFull' not in reset
assert 'return max(0, fullRange - universalKmSinceFull)' in gps
print("OK — build 116: manual calibration, fuel estimate, independent GPS/TRIP")
