"""Build 105 compatibility: saved legacy fields, Day preview, power ticks and music remain."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
read = lambda name: (root / name).read_text()
tabs = read("Ecojumbo/Views/CockpitTabs.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
panel = read("Ecojumbo/Views/EcoMusicCockpitPanel.swift")
manager = read("Ecojumbo/Models/EcoMusicManager.swift")
dock = read("Ecojumbo/Views/EcojumboRootView.swift")
project = read("Ecojumbo.xcodeproj/project.pbxproj")
assert project.count("CURRENT_PROJECT_VERSION = 128;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2

editor = tabs.split("private struct EcoThemeEditorView: View {", 1)[1].split(
    "private struct EcoThemeColorPicker:", 1)[0]
assert editor.index("EcoThemePreview(palette: draft)") < editor.index(
    'Picker("Modalità della sfumatura"') < editor.index("ForEach([15, 16, 19, 20]")
assert ".preferredColorScheme(selectedGroup == 4" in editor

palette = tabs.split("struct EcoThemePalette: Codable, Equatable {", 1)[1].split(
    "extension Color {", 1)[0]
# The old gradient-opacity settings remain recognized at decode time, so all
# build 105 personal themes migrate to four separate controls without data loss.
for term in ("var gradientOpacity: Double", "var dayGradientOpacity: Double",
             "decodeIfPresent(Double.self, forKey: .gradientOpacity) ?? 1",
             "decodeIfPresent(Double.self, forKey: .dayGradientOpacity) ?? 1",
             "try data.encode(gradientOpacity, forKey: .gradientOpacity)",
             "try data.encode(dayGradientOpacity, forKey: .dayGradientOpacity)"):
    assert term in palette, term

upper = cockpit.split("private struct GPSUpperGradientLayer: View {", 1)[1].split(
    "struct EcoCockpitThemeMiniature:", 1)[0]
mini = cockpit.split("struct EcoCockpitThemeMiniature: View {", 1)[1].split(
    "private struct GPSHorizonLine:", 1)[0]
telemetry = cockpit.split("private struct GPSExpandedReadings: View {", 1)[1].split(
    "// Progressi sottili", 1)[0]
# Build 108 replaces the obsolete tick scale with a single kW text.
for part in (upper, mini, telemetry):
    assert "lightOpacity" in part and "shadowOpacity" in part
assert "Color(red: 0.94, green: 0.96, blue: 0.985) : tone(0)" in mini
assert "GPSPowerHorizontalGauge" not in cockpit
assert "miniaturePowerBar" not in cockpit
assert 'Text("— kW")' in mini
assert "GPSCockpitPowerReading(d: dialSize" in cockpit

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

print("OK — build 105: retained Day preview, text-only kW and live music after build 106 UI refresh")
