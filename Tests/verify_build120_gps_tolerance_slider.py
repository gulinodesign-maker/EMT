#!/usr/bin/env python3
"""Build 120: user-adjustable 2-10s hold of real GPS speed without fake readings."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
read = lambda path: (root / path).read_text(encoding="utf-8")
gps = read("Ecojumbo/Models/GPSRideManager.swift")
ui = read("Ecojumbo/Views/OtherViews.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
project = read("Ecojumbo.xcodeproj/project.pbxproj")
assert project.count("CURRENT_PROJECT_VERSION = 120;") == 2
assert '@AppStorage("ecojumbo.gps.speedDisplayToleranceSeconds") private var gpsSpeedDisplayToleranceSeconds = 8.0' in ui
assert 'Section("Tachimetro GPS")' in ui
assert 'Slider(value: $gpsSpeedDisplayToleranceSeconds, in: 2...10, step: 1)' in ui
assert 'cursore non accelera la ricezione' in ui
assert 'private var lastSpeedReceivedAt: Date?' in gps
assert 'lastSpeedReceivedAt = Date()' in gps
assert gps.index('lastSpeedReceivedAt = Date()') < gps.index('speedKmh = kmh < 1.5 ? 0 : kmh')
assert gps.count('lastSpeedReceivedAt = nil') >= 3
assert 'as? Double) ?? 8.0' in gps
assert 'return min(10.0, max(2.0, saved))' in gps
accessor = gps.split("func currentSpeed(at date: Date = Date()) -> Double? {",1)[1].split("\n    }",1)[0]
assert 'guard let speedKmh, let lastSpeedReceivedAt else { return nil }' in accessor
assert 'let receivedAge = date.timeIntervalSince(lastSpeedReceivedAt)' in accessor
assert 'receivedAge >= -1.6' in accessor
assert 'receivedAge < speedDisplayToleranceSeconds' in accessor
assert 'return speedKmh' in accessor
assert 'let age = date.timeIntervalSince(lastValidAt)' not in accessor
assert 'func isSpeedHeld(at date: Date = Date()) -> Bool' in gps
assert 'date.timeIntervalSince(lastValidAt) > 2.0' in gps
assert 'func displayedSpeedSampleAge(at date: Date = Date()) -> TimeInterval?' in gps
assert cockpit.count('speedHeld: gps.isSpeedHeld(at: now)') == 2
assert 'if speedHeld && speed != nil {' in cockpit
assert 'Text("ULTIMO GPS")' in cockpit
assert 'LabeledContent("Tolleranza visualizzazione"' in cockpit
assert 'LabeledContent("Età velocità mostrata"' in cockpit
assert 'let kmh = fix.speed * 3.6' in gps
assert 'let freshSpeedFix = fixAge >= -1.5 && fixAge < 8.0' in gps
assert 'let newerSpeedFix = lastValidAt.map { fix.timestamp > $0 } ?? true' in gps
native = gps.split('let usableSpeed =',1)[1].split('if usableSpeed {',1)[0]
assert 'fix.horizontalAccuracy <= 70' in native
assert 'fix.speedAccuracy <= 5' in native
assert 'fix.speed <= maxTrustedSpeed' in native
trip = gps.split('// Trip/odometro: filtri severi invariati',1)[1].split(
    '// Primo campione attendibile del viaggio',1)[0]
assert 'fix.horizontalAccuracy <= 35' in trip
assert 'fix.speedAccuracy <= 5' in trip
assert 'universalKmSinceFull += increment' in gps
assert 'manager.requestLocation()' not in gps
print("OK — 120: adjustable native GPS display hold, stale label, trip/odo safe")
