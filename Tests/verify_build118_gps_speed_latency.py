#!/usr/bin/env python3
"""Build 118: fast native GPS speed without using stale or inaccurate samples."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
read = lambda p: (root / p).read_text(encoding="utf-8")
gps = read("Ecojumbo/Models/GPSRideManager.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
project = read("Ecojumbo.xcodeproj/project.pbxproj")
assert project.count("CURRENT_PROJECT_VERSION = 118;") == 2
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in gps
assert "manager.activityType = .automotiveNavigation" in gps
assert "manager.distanceFilter = kCLDistanceFilterNone" in gps
assert "manager.pausesLocationUpdatesAutomatically = false" in gps
assert "manager.startUpdatingLocation()" in gps
assert "for fix in locations.sorted(by: { $0.timestamp < $1.timestamp })" in gps
assert "let fixAge = Date().timeIntervalSince(fix.timestamp)" in gps
assert "lastGPSFixTime.map({ fix.timestamp > $0 }) ?? true" in gps
assert "let freshSpeedFix = fixAge >= -1.5 && fixAge < 8.0" in gps
assert "let newerSpeedFix = lastValidAt.map { fix.timestamp > $0 } ?? true" in gps
speed = gps.split("let usableSpeed = freshSpeedFix",1)[1].split("if usableSpeed {",1)[0]
assert "&& newerSpeedFix" in speed
assert "manager.accuracyAuthorization == .fullAccuracy" not in speed
assert "fix.horizontalAccuracy <= 70" in speed
assert "fix.speedAccuracy <= 5" in speed
assert "fix.speed <= maxTrustedSpeed" in speed
assert "let kmh = fix.speed * 3.6" in gps
assert "speedKmh = kmh < 1.5 ? 0 : kmh" in gps
speed_accessor = gps.split("func currentSpeed(at date: Date = Date()) -> Double? {",1)[1].split("\n    }",1)[0]
assert "let age = date.timeIntervalSince(lastValidAt)" in speed_accessor
assert "guard age >= -1.6 && age < 6.0" in speed_accessor
assert "return speedKmh" in speed_accessor
assert "guard age >= -1.6 && age < 6.0" in gps
# Independent trip, odometer and fuel tracking keep strict GPS controls.
trip = gps.split("// Trip/odometro: filtri severi invariati",1)[1].split(
    "// Primo campione attendibile del viaggio",1)[0]
assert "fix.horizontalAccuracy <= 35" in trip
assert "fix.speedAccuracy <= 5" in trip
assert "fix.speed <= maxTrustedSpeed" in trip
assert "universalKmSinceFull += increment" in gps
assert "UserDefaults.standard.set(tripKm" in gps
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in cockpit
assert "manager.requestLocation()" not in gps
assert "estimatedSpeed" not in gps
print("OK — build 119 keeps 118 native-speed protections and restores GPS availability")
