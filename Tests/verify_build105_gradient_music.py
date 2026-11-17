"""Build 105: visible preview while editing, transparent gradients, day background and live music."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
read = lambda name: (root / name).read_text()
tabs = read("Ecojumbo/Views/CockpitTabs.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
panel = read("Ecojumbo/Views/EcoMusicCockpitPanel.swift")
manager = read("Ecojumbo/Models/EcoMusicManager.swift")
dock = read("Ecojumbo/Views/EcojumboRootView.swift")
project = read("Ecojumbo.xcodeproj/project.pbxproj")

assert project.count("CURRENT_PROJECT_VERSION = 105;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2

# All gradient sliders are immediately after the cockpit preview,
# BEFORE the category header/colour swatches rather than beyond them.
editor = tabs.split("private struct EcoThemeEditorView: View {", 1)[1].split(
    "private struct EcoThemeColorPicker:", 1)[0]
preview = editor.index("EcoThemePreview(palette: draft)")
category = editor.index("Label(group.title, systemImage: categorySymbol(selectedGroup))")
for slider in ("Slider(value: gradientOpacityBinding, in: 0...1, step: 0.01)",
               "Slider(value: $draft.gradientAngle, in: 0...360, step: 5)",
               "Slider(value: topFadeBinding, in: 0...1, step: 0.05)",
               "Slider(value: bottomFadeBinding, in: 0...1, step: 0.05)"):
    assert preview < editor.index(slider) < category, slider
assert editor.index('Picker("Modalità della sfumatura"') < category
assert "editingDayTopBar ? draft.dayGradientOpacity : draft.gradientOpacity" in editor
assert "0% rende trasparenti luce, ombra" in editor

# JSON migration preserves previously saved slots, and Day/Night retain
# independent opacity settings while sharing orientation.
palette = tabs.split("struct EcoThemePalette: Codable, Equatable {", 1)[1].split(
    "extension Color {", 1)[0]
for term in ("var gradientOpacity: Double", "var dayGradientOpacity: Double",
             "decodeIfPresent(Double.self, forKey: .gradientOpacity) ?? 1",
             "decodeIfPresent(Double.self, forKey: .dayGradientOpacity) ?? 1",
             "try data.encode(gradientOpacity, forKey: .gradientOpacity)",
             "try data.encode(dayGradientOpacity, forKey: .dayGradientOpacity)",
             "palette.gradientOpacity.isFinite", "palette.dayGradientOpacity.isFinite"):
    assert term in palette, term

upper = cockpit.split("private struct GPSUpperGradientLayer: View {", 1)[1].split(
    "struct EcoCockpitThemeMiniature:", 1)[0]
mini = cockpit.split("struct EcoCockpitThemeMiniature: View {", 1)[1].split(
    "private struct GPSHorizonLine:", 1)[0]
telemetry = cockpit.split("private struct GPSExpandedReadings: View {", 1)[1].split(
    "// Progressi sottili", 1)[0]
bar = cockpit.split("private struct GPSPowerHorizontalGauge: View {", 1)[1].split(
    "// Costanti LED storiche", 1)[0]
for part in (upper, mini, telemetry):
    assert "fadeOpacity" in part
    assert "dayGradientOpacity" in part
    assert "gradientOpacity" in part
assert "highStrength * fadeOpacity" in upper
assert "lowStrength * fadeOpacity" in upper
assert "theme.glowIntensity * (daylight ? 0.36 : 0.72) * fadeOpacity" in upper
assert "Color(red: 0.94, green: 0.96, blue: 0.985) : tone(0)" in mini
assert bar.count("strokeBorder") >= 1
miniPower = mini.split("private func miniaturePowerBar", 1)[1].split(
    "private func miniatureTelemetry", 1)[0]
assert "strokeBorder" in miniPower
assert "HStack(spacing: 0)" in miniPower and "HStack(spacing: 0)" in bar

# Cover and Play/Pause follow the real player and current item.
assert "Notification.Name.MPMusicPlayerControllerNowPlayingItemDidChange" in manager
assert "Notification.Name.MPMusicPlayerControllerPlaybackStateDidChange" in manager
assert "self.refreshApple()" in manager
assert "artworkURL = current.artwork?.url(width: 1100, height: 1100)" in panel
assert "?? artworkURL" not in panel
assert "if player.state.playbackStatus == .playing" in panel
assert "Timer.publish(every: 1" in panel
assert "if usesInAppPlayer {" in panel and ".id(url)" in panel
assert '? apple.isPlaying : music.isPlaying) ? "pause.fill" : "play.fill"' in dock

print("OK — build 105 gradient placement/opacity, Day preview, segmented power and live music")
