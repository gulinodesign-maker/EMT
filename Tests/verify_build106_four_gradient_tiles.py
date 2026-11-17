"""Build 106: exactly four independent Day/Night gradient color+intensity cards."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
proj = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert proj.count("CURRENT_PROJECT_VERSION = 115;") == 2

editor = tabs.split("private struct EcoThemeEditorView: View {", 1)[1].split(
    "private struct EcoThemeColorPicker:", 1)[0]
preview = editor.index("EcoThemePreview(palette: draft)")
mode = editor.index('Picker("Modalità della sfumatura"')
roles = editor.index("ForEach([15, 16, 19, 20]")
category = editor.index('Label(group.title, systemImage: categorySymbol(selectedGroup))')
assert preview < mode < roles < category, "Place exactly four color+slider cards under preview"
assert "gradientRoleTile(role)" in editor
assert 'else if selectedGroup != 4' in editor, "Do not render duplicate color-only tiles"
assert "Slider(value: $draft.gradientAngle" not in editor
assert "Slider(value: gradientOpacityBinding" not in editor
assert "topFadeBinding" not in editor and "bottomFadeBinding" not in editor
cards = editor.split("private func gradientRoleTile(_ role: Int) -> some View {", 1)[1].split(
    "private func glowBinding", 1)[0]
assert "colorID = EcoThemeColorID(id: role, isDay: editingDayTopBar)" in cards
assert "Slider(value: transparency, in: 0...1, step: 0.01)" in cards
assert cards.count("Slider(value:") == 1
assert "gradientArrow(role)" in cards
assert "Color(themeHex: roleHex(role))" in cards

palette = tabs.split("struct EcoThemePalette: Codable, Equatable {", 1)[1].split("extension Color {", 1)[0]
assert '("Sfumature", [15, 16, 19, 20])' in palette
assert '("Cockpit", [1, 3, 21, 22, 2, 11, 10, 14, 18, 17, 8, 9])' in palette
groups = palette.split("static let groups:", 1)[1].split("static let colorCount", 1)[0]
assert sorted(map(int, re.findall(r"\d+", groups))) == [i for i in range(23) if i != 7]
for name in ("lightIntensity", "shadowIntensity", "dayLightIntensity", "dayShadowIntensity"):
    assert f"var {name}: Double" in palette
    assert f"try data.encode({name}, forKey: .{name})" in palette
    assert f"palette.{name}.isFinite" in palette
for expression in ("topFadeIntensity *= oldNight", "bottomFadeIntensity *= oldNight",
                   "dayTopBar.highIntensity *= oldDay", "dayTopBar.lowIntensity *= oldDay"):
    assert expression in palette, expression
assert "gradientOpacity = 1" in palette and "dayGradientOpacity = 1" in palette

# The historic intensity values are decoded and migrated once, not lost.
for term in ("normalizeLegacyFadeIntensities()", "highOpacity *= topFadeIntensity",
             "lowOpacity *= bottomFadeIntensity", "directionalVersion = 108"):
    assert term in palette
bindings = editor.split("private func gradientOpacityBinding(for role: Int)",1)[1].split(
    "private func gradientDirectionName",1)[0]
for role, fields in ((15, ("dayLightOpacity", "lightOpacity")),
                     (16, ("dayShadowOpacity", "shadowOpacity")),
                     (19, ("dayHighOpacity", "highOpacity")),
                     (20, ("dayLowOpacity", "lowOpacity"))):
    assert f"case {role}:" in bindings
    for field in fields:
        assert f"draft.{field}" in bindings

upper = cockpit.split("private struct GPSUpperGradientLayer: View {",1)[1].split(
    "struct EcoCockpitThemeMiniature:",1)[0]
mini = cockpit.split("struct EcoCockpitThemeMiniature: View {",1)[1].split(
    "private struct GPSHorizonLine:",1)[0]
for layer in (upper,mini):
    assert "from.opacity(lightOpacity)" in layer
    assert "to.opacity(shadowOpacity)" in layer
    assert "high.opacity(highOpacity)" in layer
    assert "low.opacity(lowOpacity)" in layer
assert "Color(red: 0.94, green: 0.96, blue: 0.985) : tone(0)" in mini
print("OK — build 106: four colors migrated to directional opacity Day/Night")
