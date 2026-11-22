"""Build 101: independent Day/Night gradient, cleanup of unused ring, tap swatches."""
from pathlib import Path
import re

root=Path(__file__).resolve().parents[1]
tabs=(root/"Ecojumbo/Views/CockpitTabs.swift").read_text()
c=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
project=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 126;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2

# Deliberately remove ONLY the extra second ring. The original luminous
# concentric ring and its editable color and glow remain.
layout=c.split("private enum GPSDialLayout {",1)[1].split("private enum GPSMetalContourStyle {",1)[0]
assert "GPSSecondOuterRing" not in c
assert "secondRingRadius" not in c
assert "secondRingStroke" not in c
assert "secondRingColor" not in c
assert "savedPalette.colors[22]" in c
assert "static func mapExclusionRadius(for d: CGFloat)" in layout
assert "concentricRingRadius(for: d) + concentricRingStroke(for: d) / 2" in layout
assert "static let mapToDialClearance: CGFloat = 2" in layout
assert "GPSConcentricAccentRing(color: theme.concentricRingColor," in c
assert "GPSConcentricAccentRing(color: tone(21)," in c
assert "GPSLuminousCircleStroke(" in c
assert "glowIntensity: theme.glow(for: 21)" in c

# Unique, complete menu categories: 0..21 exactly once; 8 & 9 are the
# actual red/blue power bar colours, never telemetric rows.
assert "static let colorCount = 23" in tabs
assert '"Secondo cerchio esterno · spessore doppio"' not in tabs
assert '"Barre telemetria e potenza"' not in tabs
groups=tabs.split("static let groups:",1)[1].split("static let colorCount",1)[0]
for text in ('("Aspetto generale", [0])',
             '("Cockpit", [1, 3, 21, 22, 2, 11, 10, 14, 18, 17, 8, 9])',
             '("Barre telemetria", [4, 5, 6])',
             '("Navigatore", [12, 13])',
             '("Sfumature", [15, 16, 19, 20])'):
    assert text in groups
indices=[int(v) for v in re.findall(r"\d+", groups)]
assert sorted(indices)==[i for i in range(23) if i != 7],indices
assert '"Cursore potenza · uscita"' in tabs
assert '"Cursore potenza · ingresso"' in tabs
assert 'glowRoleSection("LED potenza · BMS", roles: [8, 9])' in tabs
assert 'glowRoleSection("Anelli", roles: [1, 21, 22, 2])' in tabs
assert 'glowRoleSection("LED velocità · inerzia", roles: [10, 14, 18, 17])' in tabs
assert 'colorRoleSection("Metallo e numeri", roles: [3, 11])' in tabs
labels=tabs.split("static let labels = [",1)[1].split("]",1)[0]
details=tabs.split("static let details = [",1)[1].split("]",1)[0]
assert len(re.findall(r'^\s*"[^"]+"',labels,re.M))==23
assert len(re.findall(r'^\s*"[^"]+"',details,re.M))==23

# 23-colour saved build 100 palettes lose only the removed colour index22.
assert "decoded.colors.count == 22 || decoded.colors.count == 23" in tabs
assert "if migrated.colors.count == 23 && decoded.lightingVersion < 109 {" in tabs
assert "migrated.colors.removeLast()" in tabs
assert "if migrated.colors.count == 21 {" in tabs
assert "migrated.colors.append(migrated.colors[1])" in tabs
assert "dayTopBar = try data.decodeIfPresent(EcoDayTopBarPalette.self," in tabs
assert "EcoDayTopBarPalette.derived(from: colors)" in tabs
assert "case name, colors, glowIntensity, topFadeIntensity, bottomFadeIntensity, dayTopBar" in tabs
assert "try data.encode(dayTopBar, forKey: .dayTopBar)" in tabs
assert "palette.dayTopBar.isValid" in tabs
day=tabs.split("struct EcoDayTopBarPalette: Codable, Equatable {",1)[1].split("struct EcoThemePalette:",1)[0]
for member in ("left: String","right: String","high: String","low: String",
               "underGlow: String","highIntensity: Double","lowIntensity: Double",
               "func hex(for role: Int)","mutating func set(_ hex: String, for role: Int)",
               "var isValid: Bool", "colors.indices.contains(15)"):
    assert member in day,member

# Actual layer switches on iOS color scheme, including underglow and
# vertical overlay intensities, and keeps independent dial/bridge masks.
layer=c.split("private struct GPSUpperGradientLayer: View {",1)[1].split(
    "struct EcoCockpitThemeMiniature: View {",1)[0]
for needle in ("@Environment(\\.colorScheme) private var colorScheme",
               "let daylight = colorScheme == .light",
               "let day = theme.dayTopBar",
               "theme.dayGradientHighOpacity", "theme.dayGradientLowOpacity",
               "day.left", "day.right", "day.high", "day.low", "day.underGlow",
               ".mask(GPSDialExteriorMask()", ".mask(GPSBridgeExteriorMask()"):
    assert needle in layer,needle
mini=c.split("struct EcoCockpitThemeMiniature: View {",1)[1].split(
    "private struct GPSHorizonLine:",1)[0]
assert "let day = palette.dayTopBar" in mini
assert "let daylight = colorScheme == .light" in mini

# One-tap accessible colour buttons, not gesture recognisers.
editor=tabs.split("private struct EcoThemeEditorView: View {",1)[1].split(
    "private struct EcoThemeColorPicker: View {",1)[0]
role=editor.split("private func colorRoleTile(_ index: Int) -> some View {",1)[1].split(
    "private func save(slot: Int) {",1)[0]
assert "Button {" in role
assert "colorID = EcoThemeColorID(" in role
assert ".buttonStyle(.plain)" in role
assert ".onLongPressGesture" not in role
assert ".accessibilityHint(EcoThemePalette.details[index])" in role
assert 'Text("☀️ Day Mode").tag(true)' in editor
assert 'Text("🌙 Night Mode").tag(false)' in editor
assert "initialHex: selected.isDay" in editor
assert "draft.dayTopBar.set(hex, for: selected.id)" in editor
assert "gradientOpacityBinding(for role: Int)" in editor
assert ".preferredColorScheme(selectedGroup == 4" in editor

# User's original 20-swatch colour picker and brightness slider still exist.
picker=tabs.split("private struct EcoThemeColorPicker: View {",1)[1]
colors=picker.split("private static let baseColors: [String] = [",1)[1].split("]",1)[0]
assert len(re.findall(r'#[0-9A-F]{6}',colors))==20
assert "Slider(value: $shadeLevel" in picker
assert "onConfirm(selectedHex)" in picker
print("OK — build 101 Day/Night themes, menu taxonomy, palette migration, ring removal and single-tap picker")
