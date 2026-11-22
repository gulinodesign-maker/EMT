"""Build 112: six branded themes and safe import/export of complete theme JSON."""
from pathlib import Path
import json

root = Path(__file__).resolve().parents[1]
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
status = (root / "STATO_PROGETTO.md").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 125;") == 2
assert "## Build 112" in status
brand_assets = {
    "BMW": "AutoBMW", "Ferrari": "AutoFerrari", "Mercedes": "AutoMercedes",
    "Alfa Romeo": "AutoAlfaRomeo", "Lamborghini": "AutoLamborghini", "Cupra": "AutoCupra",
}
for brand, asset in brand_assets.items():
    p = root / "Ecojumbo/Assets.xcassets" / (asset + ".imageset")
    svg = (p / "logo.svg").read_text()
    info = json.loads((p / "Contents.json").read_text())
    assert "<svg" in svg and "</svg>" in svg and "<path" in svg
    assert info["images"][0]["filename"] == "logo.svg"
    assert info["properties"]["preserves-vector-representation"] is True
    assert '"'+brand+'"' in cockpit
    assert '"'+brand+'"' in tabs
    assert '"'+asset+'"' in tabs

theme_enum = cockpit.split("enum CockpitTheme: String, CaseIterable, Identifiable {",1)[1].split("// Le due barre arancioni",1)[0]
for old in ['case copper = "Rame"', 'case glacier = "Ghiaccio"', 'case green = "Verde"',
            'case aquamarine = "Acquamarina"', 'case brown = "Marrone"', 'case racing = "Racing"']:
    assert old in theme_enum, old
assert "var automotiveBrand: String?" in theme_enum
assert "var displayName: String" in theme_enum

palette = tabs.split("struct EcoThemePalette: Codable, Equatable {",1)[1].split("extension Color {",1)[0]
assert "var brandID: String?" in palette
assert "data.encodeIfPresent(brandID, forKey: .brandID)" in palette
assert "decodeIfPresent(String.self, forKey: .brandID)" in palette
assert "static let colorCount = 23" in palette
assert "static func isValidImported(_ p: EcoThemePalette) -> Bool" in palette
assert "p.colors.count == colorCount" in palette
assert "p.glowLevels.count == colorCount" in palette
assert "p.dayTopBar.isValid" in palette
assert 'return template(.copper)' in palette
assert "return template(theme)" in palette
assert "brandID: preset.automotiveBrand" in palette
assert "#FF3B30" in palette
assert "migrated.colors.append(contentsOf: extraDefaults)" in palette
picker = tabs.split("struct ThemePickerView: View {",1)[1].split("private struct EcoThemePreview:",1)[0]
assert 'Label("Temi automobilistici", systemImage: "car.side.fill")' in picker
assert 'selection = theme.rawValue' in picker
assert 'EcoAutomotiveBrandLogo(brand: theme.displayName, size: 50)' in picker
editor = tabs.split("private struct EcoThemeEditorView: View {",1)[1].split("private struct EcoThemeColorPicker:",1)[0]
assert 'EcoAutomotiveBrandLogo(brand: theme.displayName, size: 36)' in editor
assert 'Label("Importa tema", systemImage: "square.and.arrow.down")' in editor
assert 'Label("Esporta tema", systemImage: "square.and.arrow.up")' in editor
assert ".fileImporter(isPresented: $importingTheme" in editor
assert ".fileExporter(isPresented: $exportingTheme" in editor
assert "url.startAccessingSecurityScopedResource()" in editor
assert "128_000" in editor
assert "envelope.isSupported" in editor
assert "pendingImportedTheme = envelope.theme" in editor
assert 'Button("Carica nell’editor")' in editor
assert "draft = imported" in editor
assert 'Button("Sostituisci", role: .destructive)' in editor
assert 'Button("Salva"' not in editor or 'chooseSlot = true' in editor
assert 'let format: String' in tabs and 'let version: Int' in tabs
assert 'format == "ecojumbo.theme" && version == 1' in tabs
assert "let encoder = JSONEncoder()" in tabs
assert "FileWrapper(regularFileWithContents:" in tabs
assert "try data.encode(altitudeGraphGlow, forKey: .altitudeGraphGlow)" in tabs
print("OK — six automotive presets + SVG logos + validated, confirmed JSON theme transfer")
