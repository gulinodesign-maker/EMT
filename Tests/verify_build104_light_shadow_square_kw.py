"""Build 104 — shared Day/Night light-shadow direction, hidden redundant kW swatch and contiguous square power cells."""
from pathlib import Path
import math
import re

root = Path(__file__).resolve().parents[1]
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
status = (root / "STATO_PROGETTO.md").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 106;") == 2
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
assert "static let colorCount = 22" in palette # all 22 old saved slot values survive
assert "if migrated.colors.count == 23 {" in palette
assert '("Sfumature · luce e ombra", [15, 16, 19, 20])' in palette
assert '"Sfumature · colore luce"' in palette
assert '"Sfumature · colore ombra"' in palette
assert '("Anelli e numeri del tachimetro", [1, 3, 21, 2, 11, 10, 14, 18, 17, 8, 9])' in palette
labels=palette.split("static let labels = [",1)[1].split("]",1)[0]
details=palette.split("static let details = [",1)[1].split("]",1)[0]
assert len(re.findall(r'^\s*"[^"]+"', labels, re.M)) == 22
assert len(re.findall(r'^\s*"[^"]+"', details, re.M)) == 22
groups=palette.split("static let groups:",1)[1].split("static let colorCount",1)[0]
listed = list(map(int,re.findall(r'\d+',groups)))
assert sorted(listed)==[i for i in range(22) if i!=7], listed
assert '"Numeri kW · energia in ingresso (ruolo storico nascosto)"' in labels
assert "[8, 9, 7]" not in tabs
assert 'colorRoleSection("Barre di potenza", roles: [8, 9])' in tabs
assert "EcoThemePalette.active?.colors[9]" in cockpit
assert "EcoThemePalette.active?.colors[7]" not in cockpit
assert ".foregroundStyle(tone(9))" in cockpit

editor=tabs.split("private struct EcoThemeEditorView: View {",1)[1].split(
    "private struct EcoThemeColorPicker:",1)[0]
assert 'Picker("Modalità della sfumatura"' in editor
assert 'Slider(value: $draft.gradientAngle, in: 0...360, step: 5)' not in editor
assert '"Orientamento globale · luce → ombra"' in editor
assert '"0° →"' in editor and '"90° ↓"' in editor
assert '"180° ←"' in editor and '"270° ↑"' in editor
assert 'EcoGradientDirection.points(angle: draft.gradientAngle)' not in editor
assert '.preferredColorScheme(selectedGroup == 4' in editor
assert 'colorID = EcoThemeColorID(' in editor
assert ".onLongPressGesture" not in editor
assert "gradientIntensityBinding(for role: Int)" in editor

upper=cockpit.split("private struct GPSUpperGradientLayer: View {",1)[1].split(
    "struct EcoCockpitThemeMiniature:",1)[0]
telemetry=cockpit.split("private struct GPSExpandedReadings: View {",1)[1].split(
    "// Progressi sottili",1)[0]
preview=cockpit.split("struct EcoCockpitThemeMiniature: View {",1)[1].split(
    "private struct GPSHorizonLine",1)[0]
assert "EcoGradientDirection.points(angle: 0)" in upper
assert "startPoint: direction.start, endPoint: direction.end" in upper
assert "EcoGradientDirection.points(angle: 0)" in telemetry
assert "startPoint: direction.start, endPoint: direction.end" in telemetry
assert telemetry.count(".background(telemetryCardBackground)") == 2
assert "theme.dayTopBar.left" in telemetry and "theme.dayTopBar.right" in telemetry
assert "theme.topBarGradientStart" in telemetry and "theme.topBarGradientEnd" in telemetry
assert preview.count("EcoGradientDirection.points(angle: 0)") == 2
assert preview.count("startPoint: direction.start, endPoint: direction.end") == 2

bar=cockpit.split("private struct GPSPowerHorizontalGauge: View {",1)[1].split(
    "// Costanti LED storiche",1)[0]
mini=preview.split("private func miniaturePowerBar(d: CGFloat, bridgeMaxWidth: CGFloat)",1)[1].split(
    "private func miniatureTelemetry",1)[0]
assert "private let regenTacks = 3" in bar and "private let dischargeTacks = 7" in bar
assert "let tickSide = min(geo.size.width / CGFloat(count), geo.size.height)" in bar
assert "HStack(spacing: 0)" in bar and "Rectangle()" in bar
assert ".frame(width: tickSide, height: tickSide)" in bar
assert "RoundedRectangle(cornerRadius:" not in bar
assert "let tickSide = min(width / 10, height)" in mini
assert "HStack(spacing: 0)" in mini and "Rectangle()" in mini
assert ".frame(width: tickSide, height: tickSide)" in mini
assert "ForEach(0..<10" in mini and "i < 3 ? tone(9) : tone(8)" in mini
for width,height in [(190,18),(240,22),(300,29),(400,36)]:
    side=min(width/10,height)
    assert side>0 and side*10<=width
    assert math.isclose(side,side) and 10*side<=width

print("OK — build 104: shared 360° day/night angle and ten contiguous square kW cells, old themes preserved")
