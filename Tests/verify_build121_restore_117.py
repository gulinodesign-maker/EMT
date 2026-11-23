#!/usr/bin/env python3
"""Restore 117: exact native GPS logic and Universal UI, release as build 121."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
read = lambda p: (root / p).read_text(encoding="utf-8")
gps = read("Ecojumbo/Models/GPSRideManager.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
setup = read("Ecojumbo/Views/OtherViews.swift")
project = read("Ecojumbo.xcodeproj/project.pbxproj")
assert project.count("CURRENT_PROJECT_VERSION = 131;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
# Check the original, unmodified 117 location and speed acceptance path.
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in gps
assert "manager.activityType = .automotiveNavigation" in gps
assert "manager.distanceFilter = kCLDistanceFilterNone" in gps
assert "let usableSpeed = abs(fix.timestamp.timeIntervalSinceNow) < 10" in gps
assert "fix.horizontalAccuracy <= 35" in gps
assert "fix.speedAccuracy <= 5 && fix.speed <= maxTrustedSpeed" in gps
assert "let kmh = fix.speed * 3.6" in gps
assert "guard let lastValidAt, date.timeIntervalSince(lastValidAt) < 8 else { return nil }" in gps
assert "freshSpeedFix" not in gps
assert "lastSpeedReceivedAt" not in gps
assert "speedDisplayToleranceSeconds" not in gps
assert "isSpeedHeld(" not in gps
# Preserved 116 fuel range and manual kilometers since full.
assert 'Text("Distanza dal pieno")' in setup
assert 'TextField("Km percorsi", text: $kmSinceFullText)' in setup
assert 'setUniversalKmSinceFull' in gps
# Preserved 117 inertial bridge icons and authentic kW in BMS.
assert 'case .incoming: return "arrow.down"' in cockpit
assert 'case .outgoing: return "arrow.up"' in cockpit
assert 'case .neutral: return "minus"' in cockpit
assert 'Text("ULTIMO GPS")' not in cockpit
assert 'speedHeld: gps.isSpeedHeld' not in cockpit
assert 'Section("Tachimetro GPS")' not in setup
assert '@AppStorage("ecojumbo.gps.speedDisplayToleranceSeconds")' not in setup
assert 'OpenSpeedCluster(speed: gps.currentSpeed(at: now)' in cockpit
assert 'manager.requestLocation()' not in gps
print("OK — build 121 restores original build-117 GPS, BMS and Universal UI")
