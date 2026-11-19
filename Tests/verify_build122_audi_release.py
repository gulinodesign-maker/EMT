#!/usr/bin/env python3
"""Audi preset release: build 122, original logo and historical GPS remain intact."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text(encoding="utf-8")
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text(encoding="utf-8")
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text(encoding="utf-8")
gps = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text(encoding="utf-8")
assert project.count("CURRENT_PROJECT_VERSION = 122;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert 'case audi = "Audi"' in cockpit
assert 'case .audi: return "Audi"' in cockpit
assert 'case "Audi": return "AutoAudi"' in tabs
assert 'static let colorCount = 23' in tabs
assert 'if preset == .glacier { return ferrariFactory }' in tabs
assert 'if preset == .racing { return cupraFactory }' in tabs
assert 'manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation' in gps
assert 'let kmh = fix.speed * 3.6' in gps
assert (root / "Ecojumbo/Assets.xcassets/AutoAudi.imageset/logo.svg").exists()
print("OK — build 122, Audi factory kit, preserved GPS and other kits")
