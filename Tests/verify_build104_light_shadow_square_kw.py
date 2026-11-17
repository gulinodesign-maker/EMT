"""Build 104 — shared Day/Night light-shadow direction, hidden redundant kW swatch and contiguous square power cells."""
from pathlib import Path
import math
import re

root = Path(__file__).resolve().parents[1]
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
status = (root / "STATO_PROGETTO.md").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 112;") == 2
assert "## Build 104" in status

# A single angle, never a second setting for the cards or for Day Mode.
assert "enum EcoGradientDirection {" in tabs
direction = tabs.split("enum EcoGradientDirection {", 1)[1].split("// Build 74:", 1)[0]
for code in (
    "static func points(angle: Double)",
    "let radians = angle * .pi / 180",
    "let dx = cos(radians) * 0.5",
    "let dy = sin(radians) * 0.5",
    "UnitPoint(x: CGFloat(0.5 - dx), y: CGFloat(0.5 - dy))",
    "UnitPoint(x: CGFloat(0.5 + dx), y: CGFloat(0.5 + dy))",
):
    assert code in direction, code
for angle, start, end in (
    (0,(0,.5),(1,.5)),
    (90,(.5,0),(.5,1)),
    (180,(1,.5),(0,.5)),
    (270,(.5,1),(.5,0)),
    (360,(0,.5),(1,.5)),
):
    r=math.radians(angle)
    source=(.5-math.cos(r)/2,.5-math.sin(r)/2)
    target=(.5+math.cos(r)/2,.5+math.sin(r)/2)
    assert all(math.isclose(source[i],start[i],abs_tol=1e-9) for i in (0,1))
    assert all(math.isclose(target[i],end[i],abs_tol=1e-9) for i in (0,1))

palette=tabs.split("struct EcoThemePalette: Codable, Equatable {",1)[1].split("extension Color",1)[0]
assert "var gradientAngle: Double" in palette
assert "dayTopBar: EcoDayTopBarPalette? = nil, gradientAngle: Double = 0" in palette
assert "decodeIfPresent(Double.self, forKey: .gradientAngle) ?? 0" in palette
assert "try data.encode(gradientAngle, forKey: .gradientAngle)" in palette
assert "palette.gradientAngle.isFinite, (0...360).contains(palette.gradientAngle)" in palette
assert "static let colorCount = 23" in palette # all 22 old saved slot values survive
assert "if migrated.colors.count == 23 && decoded.lightingVersion < 109 {" in palette
assert '("Sfumature", [15, 16, 19, 20])' in palette
assert '"Sfumatura sinistra"' in palette
assert '"Sfumatura destra"' in palette
assert '("Cockpit", [1, 3, 21, 22, 2, 11, 10, 14, 18, 17, 8, 9])' in palette
labels=palette.split("static let labels = [",1)[1].split("]",1)[0]
details=palette.split("static let details = [",1)[1].split("]",1)[0]
assert len(re.findall(r'^\s*"[^"]+"', labels, re.M)) == 23
assert len(re.findall(r'^\s*"[^"]+"', details, re.M)) == 23
groups=palette.split("static let groups:",1)[1].split("static let colorCount",1)[0]
listed = list(map(int,re.findall(r'\d+',groups)))
assert sorted(listed)==[i for i in range(23) if i!=7], listed
assert '"Numeri kW · energia in ingresso (ruolo storico nascosto)"' in labels
assert "[8, 9, 7]" not in tabs
assert 'glowRoleSection("LED potenza · BMS", roles: [8, 9])' in tabs
assert "EcoThemePalette.active?.colors[9]" in cockpit
assert "EcoThemePalette.active?.colors[7]" not in cockpit
assert ".foregroundStyle(tone(9))" in cockpit

editor=tabs.split("private struct EcoThemeEditorView: View {",1)[1].split(
    "private struct EcoThemeColorPicker:",1)[0]
assert 'Picker("Modalità della sfumatura"' in editor
assert 'Slider(value: $draft.gradientAngle, in: 0...360, step: 5)' not in editor
assert '"Orientamento globale · luce → ombra"' not in editor
assert '"0° →"' not in editor and '"90° ↓"' not in editor
assert '"180° ←"' not in editor and '"270° ↑"' not in editor
assert 'EcoGradientDirection.points(angle: draft.gradientAngle)' not in editor
assert '.preferredColorScheme(selectedGroup == 4' in editor
assert 'colorID = EcoThemeColorID(' in editor
assert ".onLongPressGesture" not in editor
assert "gradientOpacityBinding(for role: Int)" in editor

upper=cockpit.split("private struct GPSUpperGradientLayer: View {",1)[1].split(
    "struct EcoCockpitThemeMiniature:",1)[0]
telemetry=cockpit.split("private struct GPSExpandedReadings: View {",1)[1].split(
    "// Progressi sottili",1)[0]
preview=cockpit.split("struct EcoCockpitThemeMiniature: View {",1)[1].split(
    "private struct GPSHorizonLine",1)[0]
# Four directional fades instead of a single rotatable light-shadow wash.
for surface in (upper, preview):
    assert "startPoint: .leading, endPoint: .trailing" in surface
    assert "from.opacity(lightOpacity)" in surface
    assert "to.opacity(shadowOpacity)" in surface
    assert "high.opacity(highOpacity)" in surface
    assert "low.opacity(lowOpacity)" in surface
assert "theme.dayTopBar.left" in telemetry and "theme.dayTopBar.right" in telemetry
assert telemetry.count(".background(telemetryCardBackground)") == 2
assert "theme.topBarGradientStart" in telemetry and "theme.topBarGradientEnd" in telemetry
assert "GPSPowerHorizontalGauge" not in cockpit
assert "miniaturePowerBar" not in cockpit

print("OK — build 104: legacy theme migration and four directional gradients with kW text, old themes preserved")
