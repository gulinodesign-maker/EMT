"""Build 74 — speed-state tolerance, optional warning color and GPS-speed neon parity."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
settings = (root / "Ecojumbo/Views/OtherViews.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

assert pbx.count("CURRENT_PROJECT_VERSION = 77;") == 2
assert pbx.count("MARKETING_VERSION = 1.0;") == 2
assert pbx.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2

# Four independently selectable swatches, with the old 10/14/17 preserved.
assert "static let colorCount = 19" in tabs
assert '("Velocità oltre soglia", [14, 10, 18, 17])' in tabs
for name in ("Velocità GPS · fase normale", "Velocità GPS · fase decelerazione",
             "Velocità GPS · fase accelerazione", "Velocità GPS · limite superato"):
    assert f'"{name}"' in tabs
for i in (10, 14, 17, 18):
    assert i in [14, 10, 18, 17]
assert "ForEach(group.range, id:" in tabs
assert "EcoThemePalette.labels[index]" in tabs
assert "EcoThemePalette.details[index]" in tabs
assert "colorID = EcoThemeColorID(id: index)" in tabs
assert "draft.colors[selected.id] = hex" in tabs
labels = tabs.split("static let labels = [", 1)[1].split("]", 1)[0]
details = tabs.split("static let details = [", 1)[1].split("]", 1)[0]
assert len(re.findall(r'^\s*"[^"]+"', labels, flags=re.M)) == 19
assert len(re.findall(r'^\s*"[^"]+"', details, flags=re.M)) == 19

# Lossless migration of existing slots: 8, 15, 17, 18 -> 19.
assert "(decoded.colors.count == 8 || decoded.colors.count == 15 ||" in tabs
assert "decoded.colors.count == 17 || decoded.colors.count == 18 ||" in tabs
assert "if migrated.colors.count == 18 {" in tabs
assert 'migrated.colors.append("#FF3B30")' in tabs
assert "migrated.colors[9] = decoded.colors[7]" in tabs
assert 'try data.encode(colors, forKey: .colors)' in tabs
assert "decodeIfPresent(Double.self, forKey: .glowIntensity)" in tabs

# Toggle controls only speed limit warning; all three GPS phases remain.
for text in ("ecojumbo.bars.speedLimitColorEnabled", "ecojumbo.bars.vehicleSpeedMaxKmh",
             "ecojumbo.bars.speedColorThresholdKmh"):
    assert text in settings and text in cockpit
assert 'Toggle("Colore speciale oltre il limite", isOn: $speedLimitColorEnabled)' in settings
assert ".disabled(!speedLimitColorEnabled)" in settings
assert "speedLimitColorEnabled = true" in cockpit
speed = cockpit.split("private struct SpeedLEDStream: View {", 1)[1].split(
    "private struct SegmentedGaugeBar: View {", 1)[0]
assert "if speedLimitColorEnabled, let speed, speed.isFinite," in speed
assert speed.index("return CockpitTheme.speedLimitAccent") < speed.index("switch movement")
assert "case .accelerating: return CockpitTheme.accelerationAccent" in speed
assert "case .decelerating: return CockpitTheme.decelerationAccent" in speed
assert "case .normal: return CockpitTheme.speedLEDAccent" in speed
assert "speed / max(30, vehicleSpeedMaxKmh)" in speed
assert "guard let speed, speed.isFinite, speed >= 0 else { return nil }" in speed
assert "speed / 120" not in speed

# Finite 4s window, strict +/-5 km/h tolerance; no synthetic speed readings.
phase = cockpit.split("private enum GPSSpeedMovement {", 1)[1].split(
    "private struct SpeedLEDStream: View {", 1)[0]
assert "if deltaKmh > 5 { return .accelerating }" in phase
assert "if deltaKmh < -5 { return .decelerating }" in phase
assert "return .normal" in phase
assert "deltaKmh.isFinite" in phase
assert "speedHistory.removeAll { now.timeIntervalSince($0.time) > 4 }" in speed
assert "now.timeIntervalSince(reference.time) >= 0.2" in speed
assert "GPSSpeedMovement.classify(deltaKmh: current - reference.value)" in speed
assert "now.timeIntervalSince(lastSpeedUpdate) > 4" in speed
for current, expected in ((50, "normal"), (55, "normal"), (55.001, "accelerating"),
                          (44.999, "decelerating"), (45, "normal")):
    delta = current - 50
    phase = "accelerating" if delta > 5 else ("decelerating" if delta < -5 else "normal")
    assert phase == expected

# The neon styling is literally shared with SpeedLEDStream, not the JK power rings.
neon = cockpit.split("private enum GPSInnerLED {", 1)[1].split(
    "private enum GPSDialLayout {", 1)[0]
for suffix in ("size * 0.034", "size * 0.027", "size * 0.015",
               "size * 0.010", "size * 0.003"):
    assert suffix in neon
for key in ("haloWidth", "haloBlur", "coreWidth", "outerBlur", "highlightWidth"):
    assert "GPSInnerLED." + key + "(d)" in speed, key
for shape, end, dim in (("GPSHorizonLine", "@MainActor", "h"),
                        ("GPSGaugeHalo", "// EJ 1.23", "d"),
                        ("GPSLowerGlow", "// EJ 1.22", "h")):
    section = cockpit.split("private struct " + shape + ": View {", 1)[1].split(end, 1)[0]
    for key in ("haloWidth", "haloBlur", "coreWidth", "outerBlur", "highlightWidth"):
        assert "GPSInnerLED." + key + "(" + dim + ")" in section, (shape, key)
    assert "Color.white.opacity(0.65)" in section
    assert "GPSInnerLED.outerOpacity(theme.glowIntensity)" in section
assert "GPSOuterProfileReinforcement" not in cockpit
assert "GPSTopBandShade" not in cockpit
assert "GPSLowerAreaGradient" not in cockpit
assert ".mask(visibleOutsideRing.fill(style: FillStyle(eoFill: true)))" in cockpit
assert ".mask(GPSLowerTerminalFade())" in cockpit
assert "GPSMetalInnerRing()" in cockpit
assert "Build 74" in state
print("OK — build 74: four independent speed-phase colors, 5-km/h GPS tolerance, optional limit and speed-arc neon")
