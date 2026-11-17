"""Build 107: separate opacity for four Day/Night gradients; icon-first interface."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
read = lambda p: (root / p).read_text()
tabs = read("Ecojumbo/Views/CockpitTabs.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
other = read("Ecojumbo/Views/OtherViews.swift")
cells = read("Ecojumbo/Views/CellsView.swift")
music = read("Ecojumbo/Views/EcoMusicCockpitPanel.swift")
proj = read("Ecojumbo.xcodeproj/project.pbxproj")
assert proj.count("CURRENT_PROJECT_VERSION = 113;") == 2
assert proj.count("MARKETING_VERSION = 1.0;") == 2

palette = tabs.split("struct EcoThemePalette: Codable, Equatable {", 1)[1].split(
    "extension Color {", 1)[0]
opacity_fields = (
    "lightOpacity", "shadowOpacity", "highOpacity", "lowOpacity",
    "dayLightOpacity", "dayShadowOpacity", "dayHighOpacity", "dayLowOpacity"
)
for name in opacity_fields:
    assert f"var {name}: Double" in palette, name
    assert f"try data.encode({name}, forKey: .{name})" in palette, name
    assert f"palette.{name}.isFinite" in palette, name
    assert f"palette.{name}" in palette
    assert f"{name} = try opacity(.{name})" in palette
    assert f"{name}: Double = 1" in palette, name
assert "let saved = try data.decodeIfPresent(Double.self, forKey: key) ?? 1" in palette
assert "return saved.isFinite ? min(1, max(0, saved)) : 1" in palette
# The 105-to-106 migration continues to absorb old global opacity only once;
# missing 107 fields fall back to 1, preserving existing custom themes.
assert "topFadeIntensity *= oldNight" in palette
assert "bottomFadeIntensity *= oldNight" in palette
assert "dayTopBar.highIntensity *= oldDay" in palette
assert "dayTopBar.lowIntensity *= oldDay" in palette

editor = tabs.split("private struct EcoThemeEditorView: View {", 1)[1].split(
    "private struct EcoThemeColorPicker:", 1)[0]
assert editor.index("EcoThemePreview(palette: draft)") < editor.index(
    'Picker("Modalità della sfumatura"') < editor.index("ForEach([15, 16, 19, 20]")
assert "gradientRoleTile(role)" in editor
assert 'else if selectedGroup != 4' in editor
assert "gradientIntensityBinding(for role: Int)" not in editor
assert "gradientOpacityBinding(for role: Int)" in editor
assert "Slider(value: $draft.gradientAngle" not in editor
cards = editor.split("private func gradientRoleTile(_ role: Int) -> some View {",1)[1].split(
    "private func glowBinding",1)[0]
assert cards.count("Slider(value:") == 1
assert "Slider(value: transparency, in: 0...1, step: 0.01)" in cards
assert 'accessibilityLabel("Trasparenza " + gradientDirectionName(role))' in cards
assert 'Text(EcoThemePalette.details[role])' not in cards
for role, pair in ((15, ("dayLightOpacity", "lightOpacity")),
                   (16, ("dayShadowOpacity", "shadowOpacity")),
                   (19, ("dayHighOpacity", "highOpacity")),
                   (20, ("dayLowOpacity", "lowOpacity"))):
    binding = editor.split("private func gradientOpacityBinding(for role: Int)", 1)[1].split(
        "private func gradientDirectionName", 1)[0]
    assert f"case {role}:" in binding
    for name in pair:
        assert f"draft.{name}" in binding

theme = cockpit.split("// Build 101: configurazione Day", 1)[0]
for name in ("gradientLightOpacity", "gradientShadowOpacity", "gradientHighOpacity",
             "gradientLowOpacity", "dayGradientLightOpacity", "dayGradientShadowOpacity",
             "dayGradientHighOpacity", "dayGradientLowOpacity"):
    assert f"var {name}: Double" in theme, name
upper = cockpit.split("private struct GPSUpperGradientLayer: View {", 1)[1].split(
    "struct EcoCockpitThemeMiniature:", 1)[0]
mini = cockpit.split("struct EcoCockpitThemeMiniature: View {", 1)[1].split(
    "private struct GPSHorizonLine:", 1)[0]
tele = cockpit.split("private struct GPSExpandedReadings: View {", 1)[1].split(
    "// Progressi sottili", 1)[0]
for surface in (upper, mini, tele):
    assert "lightOpacity" in surface and "shadowOpacity" in surface
assert "high.opacity(highOpacity)" in upper
assert "low.opacity(lowOpacity)" in upper
assert "high.opacity(highOpacity)" in mini
assert "low.opacity(lowOpacity)" in mini
assert "underGlow.opacity(theme.glow(for: 2)" in upper
assert "palette.dayHighOpacity : palette.highOpacity" in mini
assert "palette.dayLowOpacity : palette.lowOpacity" in mini
assert "directionalVersion = 108" in palette

# Help is discoverable by a small info control, not permanent instructional text.
assert "struct EcoInfoIcon: View" in other
assert 'Image(systemName: "info.circle")' in other
assert ".accessibilityHint(message)" in other
assert 'Text("Anteprima completa del cockpit' not in editor
assert "Colori e intensità della notte, indipendenti" not in editor
assert 'Text(EcoThemePalette.details[index])' not in editor
assert 'Text("Nessun dispositivo trovato. Accendi' not in other
assert 'Text("Valori in sola lettura, ricevuti via Bluetooth' not in cells
assert 'Text("La ricerca musicale interna è attualmente disponibile' not in music
print("OK — build 107: eight opacities, four compact single sliders, Day/Night migration and icon-first UI")
