"""Build 106: exactly four independent Day/Night gradient color+intensity cards."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
proj = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert proj.count("CURRENT_PROJECT_VERSION = 106;") == 2

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
    "private func colorRoleSection", 1)[0]
assert "colorID = EcoThemeColorID(id: role, isDay: editingDayTopBar)" in cards
assert "Slider(value: binding, in: 0...1, step: 0.01)" in cards
assert '"sun.max"' in cards and "binding.wrappedValue * 100" in cards
assert 'Color(themeHex: roleHex(role))' in cards

palette = tabs.split("struct EcoThemePalette: Codable, Equatable {", 1)[1].split("extension Color {", 1)[0]
assert '("Sfumature · luce e ombra", [15, 16, 19, 20])' in palette
assert '("Anelli e numeri del tachimetro", [1, 3, 21, 2, 11, 10, 14, 18, 17, 8, 9])' in palette
groups = palette.split("static let groups:", 1)[1].split("static let colorCount", 1)[0]
assert sorted(map(int, re.findall(r"\d+", groups))) == [i for i in range(22) if i != 7]
for name in ("lightIntensity", "shadowIntensity", "dayLightIntensity", "dayShadowIntensity"):
    assert f"var {name}: Double" in palette
    assert f"try data.encode({name}, forKey: .{name})" in palette
    assert f"palette.{name}.isFinite" in palette
for expression in ("topFadeIntensity *= oldNight", "bottomFadeIntensity *= oldNight",
                   "dayTopBar.highIntensity *= oldDay", "dayTopBar.lowIntensity *= oldDay"):
    assert expression in palette, expression
assert "gradientOpacity = 1" in palette and "dayGradientOpacity = 1" in palette

bindings = editor.split("private func gradientIntensityBinding(for role: Int)", 1)[1].split(
    "private func gradientRoleTile", 1)[0]
for role, fields in ((15,("dayLightIntensity", "lightIntensity")),
                     (16,("dayShadowIntensity", "shadowIntensity")),
                     (19,("dayTopBar.highIntensity", "topFadeIntensity")),
                     (20,("dayTopBar.lowIntensity", "bottomFadeIntensity"))):
    assert f"case {role}:" in bindings
    for field in fields:
        assert f"draft.{field}" in bindings, (role, field)

upper = cockpit.split("private struct GPSUpperGradientLayer: View {", 1)[1].split(
    "struct EcoCockpitThemeMiniature:", 1)[0]
mini = cockpit.split("struct EcoCockpitThemeMiniature: View {", 1)[1].split(
    "private struct GPSHorizonLine:", 1)[0]
tele = cockpit.split("private struct GPSExpandedReadings: View {", 1)[1].split(
    "// Progressi sottili", 1)[0]
for surface in (upper, mini, tele):
    assert "EcoGradientDirection.points(angle: 0)" in surface
    assert "lightStrength" in surface and "shadowStrength" in surface
    assert "fadeOpacity" not in surface
assert "colors: [from.opacity(lightStrength * lightOpacity), to.opacity(shadowStrength * shadowOpacity)]" in upper
assert "high.opacity(highStrength * highOpacity)" in upper and "low.opacity(lowStrength * lowOpacity)" in upper
assert "theme.glowIntensity * (daylight ? 0.36 : 0.72) * lightStrength * lightOpacity" in upper
assert "colors: [from.opacity(lightStrength * lightOpacity), to.opacity(shadowStrength * shadowOpacity)]" in mini
assert "palette.glowIntensity * (daylight ? 0.36 : 0.72) * lightStrength * lightOpacity" in mini
assert "from.opacity((day ? 0.38 : 0.32) * lightStrength * lightOpacity)" in tele
assert "to.opacity((day ? 0.38 : 0.32) * shadowStrength * shadowOpacity)" in tele
assert "Color(red: 0.94, green: 0.96, blue: 0.985) : tone(0)" in mini
print("OK — build 106: four color+intensity cards, separate Day/Night values, fixed orientation, migration")
