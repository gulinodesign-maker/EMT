"""Build 63: three persistent palettes, long-press and live cockpit colors."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 70;") == 2
assert "struct EcoThemePalette: Codable, Equatable" in tabs
assert 'static let storagePrefix = "ecojumbo.customTheme."' in tabs
assert "let data = try? JSONEncoder().encode(palette)" in tabs
assert "JSONDecoder().decode(EcoThemePalette.self, from: data)" in tabs
assert "decoded.colors.count == 8" in tabs  # Legacy build 63 slots migrate forward
assert "migrated.colors.append(contentsOf: extraDefaults)" in tabs
assert "palette.colors.count == colorCount" in tabs
assert "decoded.colors.allSatisfy({ validHex($0) })" in tabs
assert 'UserDefaults.standard.set(data, forKey: storagePrefix + String(slot))' in tabs
assert "guard (1...3).contains(slot)" in tabs
assert "static func remove(slot: Int)" in tabs
assert "static var active: EcoThemePalette?" in tabs
assert "ForEach(1...3, id:" in tabs
assert "ForEach(CockpitTheme.allCases.filter { $0.slotIndex == nil })" in tabs
assert 'Label("Crea un nuovo tema", systemImage: "paintbrush.pointed")' in tabs
assert "private struct EcoThemeEditorView: View" in tabs
assert "private struct EcoThemeColorPicker: View" in tabs
assert "EcoThemePreview(palette: draft, editColor:" in tabs
assert "minimumDuration: 0.45" in tabs
assert ".sheet(item: $colorID)" in tabs
assert ".sheet(item: $editor)" in tabs
assert "onConfirm(selectedHex)" in tabs
assert "confirmationDialog(" in tabs
assert "In quale slot vuoi salvare il tema?" in tabs
assert "Sostituire il tema nello slot" in tabs
assert "onSave(slot, palette)" in tabs
assert "ColorPicker(" in tabs
assert "count: 6" in tabs
for declaration in [
    'case slot1 = "Slot 1"', 'case slot2 = "Slot 2"', 'case slot3 = "Slot 3"',
    "var accent: Color", "var secondary: Color", "var backdrop: Color",
    "var steel: Color", "static var barDark: Color", "static var barMid: Color",
    "static var barBright: Color", "static var regenAccent: Color",
    "var previewPalette: [Color]",
]:
    assert declaration in cockpit
assert "EcoThemePalette.load(slot: $0)" in cockpit
for index in range(4, 8):
    assert f"EcoThemePalette.active?.colors[{index}]" in cockpit
assert ": theme.backdrop" in cockpit
assert ".fill(theme.backdrop)" in cockpit
for symbol in ("barDark", "barMid", "barBright", "regenAccent"):
    assert "CockpitTheme." + symbol in cockpit
assert '@AppStorage("ecojumbo.themeRevision") private var themeRevision = 0' in home
assert "CockpitTheme(rawValue: themeName) ?? .copper" in home
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in cockpit
assert "let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in cockpit
assert ".position(x: panelLeft + panelWidth / 2, y: cardsCenterY)" in cockpit
assert "let telemetryDock = selected == .gps && !mapEnabled" in home
assert "let justifiedGap = max(0, (telemetryPanelWidth - 5 * gpsSide) / 4)" in home
assert "UIDevice.current.orientation == .portrait" in home
print("OK — build 63 compatibility: 3 saved slots migrate 8 -> 15 colors")
