"""Build 108: directional opacity UI, motion-or-BMS speed LED, kW-only bridge."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
read = lambda p: (root / p).read_text()
tabs = read("Ecojumbo/Views/CockpitTabs.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
motion = read("Ecojumbo/Models/GPSRideManager.swift")
settings = read("Ecojumbo/Views/OtherViews.swift")
app = read("Ecojumbo/EcojumboApp.swift")
plist = read("Ecojumbo/Info.plist")
project = read("Ecojumbo.xcodeproj/project.pbxproj")
assert project.count("CURRENT_PROJECT_VERSION = 132;") == 2
assert 'NSMotionUsageDescription' in plist
palette = tabs.split("struct EcoThemePalette: Codable, Equatable {", 1)[1].split("extension Color", 1)[0]
assert '("Sfumature", [15, 16, 19, 20])' in palette
for name in ("Sfumatura sinistra", "Sfumatura destra", "Sfumatura alto", "Sfumatura basso"):
    assert name in palette
for name in ("lightOpacity", "shadowOpacity", "highOpacity", "lowOpacity",
             "dayLightOpacity", "dayShadowOpacity", "dayHighOpacity", "dayLowOpacity"):
    assert "var " + name + ": Double" in palette
    assert "try data.encode(" + name + ", forKey: ." + name + ")" in palette
assert "let legacyLayout = (try data.decodeIfPresent(Int.self, forKey: .directionalVersion) ?? 0) < 108" in palette
assert "normalizeLegacyFadeIntensities()" in palette
assert "directionalVersion = 108" in palette
assert "lightOpacity *= lightIntensity" in palette
assert "highOpacity *= topFadeIntensity" in palette
assert "dayHighOpacity *= dayTopBar.highIntensity" in palette

editor = tabs.split("private struct EcoThemeEditorView: View {", 1)[1].split(
    "private struct EcoThemeColorPicker:", 1)[0]
assert editor.index("EcoThemePreview(palette: draft)") < editor.index(
    "ForEach([15, 16, 19, 20]") < editor.index('Label(group.title, systemImage: categorySymbol(selectedGroup))')
assert "private func gradientIntensityBinding" not in editor
assert "private func gradientOpacityBinding(for role: Int)" in editor
for r, direction in ((15,"arrow.left"),(16,"arrow.right"),(19,"arrow.up"),(20,"arrow.down")):
    assert 'case ' + str(r) + ': return "' + direction + '"' in editor
tile = editor.split("private func gradientRoleTile(_ role: Int) -> some View {",1)[1].split(
    "private func glowBinding",1)[0]
assert "return HStack(spacing: 9)" in tile
assert tile.index('RoundedRectangle(cornerRadius: 7)') < tile.index('Image(systemName: gradientArrow(role))') < tile.index('Slider(value: transparency, in: 0...1, step: 0.01)') < tile.index('Text("\\(Int((transparency.wrappedValue * 100).rounded()))%")')
assert tile.count("Slider(value:") == 1
assert 'Text(gradientDirectionName(role))' not in tile
assert 'accessibilityLabel("Trasparenza " + gradientDirectionName(role))' in tile
assert "dayLightOpacity : draft.lightOpacity" in editor
assert "dayHighOpacity : draft.highOpacity" in editor

upper = cockpit.split("private struct GPSUpperGradientLayer: View {",1)[1].split(
    "struct EcoCockpitThemeMiniature:",1)[0]
mini = cockpit.split("struct EcoCockpitThemeMiniature: View {",1)[1].split(
    "private struct GPSHorizonLine:",1)[0]
tele = cockpit.split("private struct GPSExpandedReadings: View {",1)[1].split(
    "// Progressi sottili",1)[0]
for layer in (upper,mini):
    assert "startPoint: .leading, endPoint: .trailing" in layer
    assert "from.opacity(lightOpacity)" in layer
    assert "to.opacity(shadowOpacity)" in layer
    assert "high.opacity(highOpacity)" in layer
    assert "low.opacity(lowOpacity)" in layer
    assert ".mask(GPSDialExteriorMask()" in layer
    assert ".mask(GPSBridgeExteriorMask()" in layer
assert "high.opacity(highOpacity * 0.32)" in tele
assert "low.opacity(lowOpacity * 0.32)" in tele
assert "from.opacity((day ? 0.38 : 0.32) * lightOpacity)" in tele
assert "to.opacity((day ? 0.38 : 0.32) * shadowOpacity)" in tele

assert "GPSPowerHorizontalGauge" not in cockpit
assert "miniaturePowerBar" not in cockpit
dashboard = cockpit.split("struct GPSCockpitDashboard: View {",1)[1].split(
    "// Pulsante dedicato",1)[0]
assert "GPSCockpitPowerReading(d: dialSize" in dashboard
assert "powerWatts: live.map { -$0.power }" in dashboard
assert "speed: gps.currentSpeed(at: now)" in dashboard
assert "powerFlow: flow" in dashboard
assert "abs(now.timeIntervalSince(sample.date)) < 10" in dashboard
assert "if vehicleMode == EcoVehicleMode.bms.rawValue, let snapshot" in dashboard
assert "if watts > 30 { return .incoming }" in dashboard
assert "if watts < -30 { return .outgoing }" in dashboard
assert "return powerMotion.currentFlow(at: now)" in dashboard
stream = cockpit.split("private struct SpeedLEDStream: View {",1)[1].split(
    "private struct SegmentedGaugeBar:",1)[0]
assert "case .incoming: return usesBMS ? 9 : 14" in stream
assert "case .outgoing: return usesBMS ? 8 : 18" in stream
assert "GPSSpeedMovement" not in cockpit
assert "speedHistory" not in cockpit
assert "speed / max(30, vehicleSpeedMaxKmh)" in stream

assert "import CoreMotion" in motion
assert "final class EcoPowerMotionManager: ObservableObject" in motion
assert "sensor.startDeviceMotionUpdates(to: .main)" in motion
assert "let accel = motion.userAcceleration" in motion
assert "let rotation = motion.rotationRate" in motion
assert "filteredAcceleration" in motion
assert "let enterThreshold = 0.21 - sensitivity * 0.16" in motion
assert "time.timeIntervalSince(lastUpdate) < 1" in motion
assert 'private var powerSource = EcoPowerSource.inertia.rawValue' in settings
assert 'case .power: "Scala potenza"' in settings
assert 'LabeledContent("Controllo",' in settings
assert 'Slider(value: $motionSensitivity, in: 0...1, step: 0.01)' in settings
assert 'Picker("Asse iPhone", selection: $motionAxis)' in settings
assert 'Toggle("Inverti direzione", isOn: $reverseMotion)' in settings
assert '.environmentObject(powerMotion)' in app
assert "powerMotion.stop()" in app and "powerMotion.start()" in app
print("OK — build 108: directional four fades and real power-source speed LED")
