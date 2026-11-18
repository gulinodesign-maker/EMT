#!/usr/bin/env python3
"""Hotfix 119: GPS/native speed must remain available with realistic location delays."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
gps = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text(encoding="utf-8")
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text(encoding="utf-8")
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text(encoding="utf-8")
assert project.count("CURRENT_PROJECT_VERSION = 120;") == 2
# No new unreliable, synthetic speed.
assert "let kmh = fix.speed * 3.6" in gps
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in gps
assert "manager.activityType = .automotiveNavigation" in gps
assert "manager.distanceFilter = kCLDistanceFilterNone" in gps
assert "manager.pausesLocationUpdatesAutomatically = false" in gps
assert "manager.startUpdatingLocation()" in gps
assert "let freshSpeedFix = fixAge >= -1.5 && fixAge < 8.0" in gps
assert "let newerSpeedFix = lastValidAt.map { fix.timestamp > $0 } ?? true" in gps
native = gps.split("let usableSpeed =",1)[1].split("if usableSpeed {",1)[0]
assert "freshSpeedFix && newerSpeedFix" in native
assert "fix.horizontalAccuracy <= 70" in native
assert "fix.speedAccuracy <= 5" in native
assert "manager.accuracyAuthorization == .fullAccuracy" not in native
assert "fix.speed <= maxTrustedSpeed" in native
assert "fix.speedAccuracy <= 2.5" not in native
assert "speedKmh = kmh < 1.5 ? 0 : kmh" in gps
# Guard against display clock lagging behind recently published speed fix.
accessor = gps.split("func currentSpeed(at date: Date = Date()) -> Double? {",1)[1].split("\n    }",1)[0]
assert "let receivedAge = date.timeIntervalSince(lastSpeedReceivedAt)" in accessor
assert "receivedAge < speedDisplayToleranceSeconds" in accessor
assert "return speedKmh" in accessor
# Trip/odo remain stricter and independent of tachometer quality.
trip = gps.split("// Trip/odometro: filtri severi invariati",1)[1].split(
    "// Primo campione attendibile del viaggio",1)[0]
assert "fix.horizontalAccuracy <= 35" in trip
assert "fix.speedAccuracy <= 5" in trip
assert "fix.speed <= maxTrustedSpeed" in trip
assert "universalKmSinceFull += increment" in gps
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in cockpit
assert "manager.requestLocation()" not in gps
print("OK — build 119: GPS speed recovery, no stale/fictional speed, trip protected")
