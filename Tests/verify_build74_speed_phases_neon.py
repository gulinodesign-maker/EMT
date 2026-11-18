"""Build 74 — speed-state tolerance, optional warning color and GPS-speed neon parity."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
settings = (root / "Ecojumbo/Views/OtherViews.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

assert pbx.count("CURRENT_PROJECT_VERSION = 119;") == 2
assert pbx.count("MARKETING_VERSION = 1.0;") == 2
assert pbx.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2

# Four independently selectable swatches, with the old 10/14/17 preserved.
assert "static let colorCount = 23" in tabs
assert 'glowRoleSection("LED velocità · inerzia", roles: [10, 14, 18, 17])' in tabs
for name in ("LED velocità · neutro", "Inerzia · decelerazione",
             "Inerzia · accelerazione", "Velocità GPS · limite superato"):
    assert f'"{name}"' in tabs
for i in (10, 14, 17, 18):
    assert i in [14, 10, 18, 17]
assert "ForEach(group.range, id:" in tabs
assert "EcoThemePalette.labels[index]" in tabs
assert "EcoThemePalette.details[index]" in tabs
assert "colorID = EcoThemeColorID(" in tabs
assert "draft.colors[selected.id] = hex" in tabs
labels = tabs.split("static let labels = [", 1)[1].split("]", 1)[0]
details = tabs.split("static let details = [", 1)[1].split("]", 1)[0]
assert len(re.findall(r'^\s*"[^"]+"', labels, flags=re.M)) == 23
assert len(re.findall(r'^\s*"[^"]+"', details, flags=re.M)) == 23

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
assert "case 9: return CockpitTheme.recoveryRingAccent" in speed
assert "case 8: return CockpitTheme.dischargeAccent" in speed
assert "case .neutral:" in speed
assert "case 14: return CockpitTheme.decelerationAccent" in speed
assert "case 18: return CockpitTheme.accelerationAccent" in speed
assert "speed / max(30, vehicleSpeedMaxKmh)" in speed
assert "guard let speed, speed.isFinite, speed >= 0 else { return nil }" in speed
assert "GPSSpeedMovement" not in cockpit
assert "speedHistory" not in cockpit
motion=(root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
assert "let accel = motion.userAcceleration" in motion
assert "sensor.startDeviceMotionUpdates(to: .main)" in motion

# The actual speed LED remains active; decorative GPS outlines are removed.
neon = cockpit.split("private enum GPSInnerLED {", 1)[1].split(
    "private enum GPSDialLayout {", 1)[0]
for suffix in ("size * 0.042", "size * 0.027", "size * 0.0195",
               "size * 0.012", "size * 0.004"):
    assert suffix in neon
for key in ("haloWidth", "haloBlur", "coreWidth", "outerBlur", "highlightWidth"):
    assert "GPSInnerLED." + key + "(d)" in speed, key
assert "GPSGaugeHalo(theme: theme)" not in cockpit
top = cockpit.split("private struct GPSHorizonLine: View {",1)[1].split("@MainActor",1)[0]
lower = cockpit.split("private struct GPSLowerGlow: View {",1)[1].split("// EJ 1.22",1)[0]
assert "theme.accent" not in top and "theme.accent" not in lower
assert "GPSMetalContourStyle.gradient(for: colorScheme)" in top
assert "GPSMetalContourStyle.gradient(for: colorScheme)" in lower
assert "GPSOuterProfileReinforcement" not in cockpit
assert "GPSTopBandShade" not in cockpit
assert "GPSLowerAreaGradient" not in cockpit
assert ".mask(visibleOutsideMetalRing.fill(style: FillStyle(eoFill: true)))" in cockpit
assert ".mask(GPSLowerTerminalFade())" in cockpit
assert "GPSMetalInnerRing()" in cockpit
assert "Build 74" in state
print("OK — build 74: colors and neon preserved; power flow now Core Motion/BMS")
