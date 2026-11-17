"""Build 109: cockpit navigation icon and one-tap theme kit selection."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 116;") == 2
dock = home.split("private struct CockpitCornerControls: View", 1)[1].split(
    "private func iconButton(", 1
)[0]
assert 'if selected == .gps {' in dock
assert 'gpsButton("map.fill", active: mapEnabled' in dock
assert 'gpsButton("speedometer", text: "Cockpit",' in dock
assert 'accessibility: "Torna al cockpit"' in dock
assert 'selected = .gps' in dock
# The menu-return action must not toggle the map.
return_action = dock.split('gpsButton("speedometer", text: "Cockpit",', 1)[1].split(
    '\n                        }', 1
)[0]
assert "mapEnabled.toggle()" not in return_action

editor = tabs.split("private struct EcoThemeEditorView: View {", 1)[1].split(
    "private struct EcoThemeColorPicker:", 1
)[0]
assert "@State private var selectedKit: CockpitTheme?" in editor
assert 'ForEach(CockpitTheme.allCases.filter { $0.slotIndex == nil })' in editor
assert 'Menu {' not in editor
assert 'minHeight: 48' in editor
assert '.contentShape(RoundedRectangle(cornerRadius: 10))' in editor
assert 'selectedKit = theme' in editor
assert 'draft = EcoThemePalette.template(theme)' in editor
assert 'draft = EcoThemePalette.template(theme)' in editor
assert '.accessibilityLabel("Seleziona kit " + theme.displayName)' in editor
assert "let active = selectedKit == theme" in editor
assert 'EcoThemePreview(palette: draft)' in editor
assert 'chooseSlot = true' in editor
print("OK — build 109: Cockpit return and direct one-tap kit selection")
