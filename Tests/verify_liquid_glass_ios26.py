#!/usr/bin/env python3
"""Regression: native iOS 26 Liquid Glass with safe iOS 17-25 fallbacks."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
read = lambda path: (root / path).read_text(encoding="utf-8")
ui = read("Ecojumbo/Views/EcojumboRootView.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
themes = read("Ecojumbo/Views/CockpitTabs.swift")
setup = read("Ecojumbo/Views/OtherViews.swift")
cells = read("Ecojumbo/Views/CellsView.swift")
music = read("Ecojumbo/Views/EcoMusicCockpitPanel.swift")
project = read("Ecojumbo.xcodeproj/project.pbxproj")
ci = read(".github/workflows/ios-build.yml")
testflight = read(".github/workflows/testflight.yml")

# New SDK is required to compile, but the app still supports existing iPhones.
assert "runs-on: macos-26" in ci and "runs-on: macos-26" in testflight
assert project.count("CURRENT_PROJECT_VERSION = 123;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert project.count("IPHONEOS_DEPLOYMENT_TARGET = 17.0;") == 4
assert "glassEffect(.regular.tint(tint).interactive()" in ui
assert "GlassEffectContainer(spacing: spacing)" in ui
assert ui.count("#available(iOS 26.0, *)") >= 6
assert "legacyBackground" in ui and "legacyOpacity" in ui
assert "self.background(Color.ecoCard" in ui

# Glass is in the interaction layer: not overlaid on GPS speed or BMS values.
assert ".ecoLiquidGlassContainer(spacing:" in ui
assert "ecoLiquidGlassNavigationBar(accent: theme.accent)" in ui
assert "ecoLiquidGlassCircularControl" in cockpit
assert "ecoLiquidGlassFloatingField(cornerRadius: 15)" in cockpit
assert "adaptiveTelemetryBackground" in cockpit
assert ".fill(.regularMaterial)" in cockpit
assert "ecoLiquidGlassControl" in themes
assert "ecoLiquidGlassContainer" in themes
assert "I sette kit sono punti di partenza" in themes
assert "ecoLiquidGlassControl" in setup
assert "ecoLiquidGlassPanel" in cells
assert "ecoLiquidGlassFloatingField" in music
assert "legacyBackground: .black.opacity(0.76)" in music

# All original vehicle / theme entry points and honest telemetry remain.
assert 'case audi = "Audi"' in cockpit
assert "case .gps:" in ui and "case .themes:" in ui
assert "CLLocation.speed" not in ui  # GPS source lives in its original manager
gps = read("Ecojumbo/Models/GPSRideManager.swift")
assert "let kmh = fix.speed * 3.6" in gps
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in gps
assert "bluetooth.isConnected" in cells
assert "verifiedSnapshot(at:" in cells
print("OK — Liquid Glass iOS 26, legacy iOS 17-25 and original GPS/BMS paths")
