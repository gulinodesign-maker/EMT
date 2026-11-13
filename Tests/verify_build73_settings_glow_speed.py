"""Build 73 — themes, restrained external LED halo, 3x3 Setup and speed limits."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
settings = (root / "Ecojumbo/Views/OtherViews.swift").read_text()
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 75;") == 2
assert pbx.count("MARKETING_VERSION = 1.0;") == 2

# Setup exactly 3x3; the footer stays outside the scrolling cell grid.
cases = settings.split("private enum EcoSetupSection:", 1)[1].split("var id: Self", 1)[0]
assert "case battery, bms, appearance, scooter, bluetooth, charging" in cases
assert "case odometer, bars, weather" in cases
assert "gps, weather, privacy, version" not in cases
assert "LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 0), spacing: 10), count: 3)" in settings
assert "ForEach(EcoSetupSection.allCases)" in settings
assert 'Text("Ecojumbo \\(EcojumboBuildStamp.display) · build \\(EcojumboBuildStamp.buildNumber)")' in settings
for obsolete in ('case .gps:', 'case .privacy:', 'case .version:',
                 'Section("GPS e viaggi")', 'Section("Sicurezza e privacy")',
                 'Section("Versione")'):
    assert obsolete not in settings
assert "gps.setOdometer(number)" in settings
assert "bluetooth.applyFormat(" in settings
assert "CellsView(portrait: space.size.height > space.size.width)" in settings

# One speed scale, one warning threshold, reactive and persistent on both sides.
for key in ("ecojumbo.bars.vehicleSpeedMaxKmh",
            "ecojumbo.bars.speedColorThresholdKmh"):
    assert key in settings and key in cockpit
assert "value: $vehicleSpeedMaxKmh, in: 30...240, step: 5" in settings
assert "in: 10...vehicleSpeedMaxKmh, step: 5" in settings
assert "speedColorThresholdKmh = min(speedColorThresholdKmh, newMax)" in settings
speed = cockpit.split("private struct SpeedLEDStream: View {", 1)[1].split(
    "private struct SegmentedGaugeBar: View {", 1)[0]
assert "speed / max(30, vehicleSpeedMaxKmh)" in speed
assert "return CockpitTheme.speedLimitAccent" in speed
assert "case .decelerating: return CockpitTheme.decelerationAccent" in speed
assert "case .accelerating: return CockpitTheme.accelerationAccent" in speed
assert "case .normal: return CockpitTheme.speedLEDAccent" in speed
assert "if speedLimitColorEnabled, let speed" in speed
assert speed.index("return CockpitTheme.speedLimitAccent") < speed.index("switch movement")
assert "guard let speed, speed.isFinite, speed >= 0 else { return nil }" in speed
assert "speed / 120" not in speed

# Current palette persistence (8/15/17 -> 18) and defaulted Codable intensity.
assert "static let colorCount = 19" in tabs
assert "decoded.colors.count == 17 || decoded.colors.count == 18 ||" in tabs
assert "decoded.colors.count == colorCount" in tabs
assert "migrated.colors.append(contentsOf: extraDefaults)" in tabs
assert "migrated.colors.append(contentsOf: [edge, edge])" in tabs
assert 'migrated.colors.append("#FF3B30")' in tabs
assert "decodeIfPresent(Double.self, forKey: .glowIntensity)" in tabs
assert "try data.encode(glowIntensity, forKey: .glowIntensity)" in tabs
assert "Slider(value: $draft.glowIntensity, in: 0...1, step: 0.05)" in tabs
assert '("Velocità oltre soglia", [14, 10, 18, 17])' in tabs
assert '"Velocità GPS · limite superato"' in tabs
assert '"Velocità GPS · fase accelerazione"' in tabs
assert "EcoThemePalette.active?.colors[17]" in cockpit
assert "savedPalette?.glowIntensity ?? 0.60" in cockpit

# The outward glow affects precisely the same top bar, orange ring and kW bridge.
led = cockpit.split("private enum GPSInnerLED {", 1)[1].split(
    "private enum GPSDialLayout", 1)[0]
assert "outerOpacity(_ intensity: Double)" in led
assert "outerBlur(_ size: CGFloat)" in led
for shape, closing in (("GPSHorizonLine", "@MainActor"),
                       ("GPSGaugeHalo", "// EJ 1.23"),
                       ("GPSLowerGlow", "// EJ 1.22")):
    section = cockpit.split("private struct " + shape + ": View {", 1)[1].split(closing, 1)[0]
    assert "GPSInnerLED.outerOpacity(theme.glowIntensity)" in section
    assert "GPSInnerLED.outerBlur(" in section
    assert "theme.accent" in section
assert "GPSOuterProfileReinforcement" not in cockpit
assert "GPSTopBandShade" not in cockpit
assert "GPSLowerAreaGradient" not in cockpit
assert ".mask(GPSLowerTerminalFade())" in cockpit
assert "GPSMetalInnerRing()" in cockpit
assert "Build 73" in state
print("OK — build 73: external theme glow, palette migration, Setup 3x3, real GPS speed scale/threshold")
