"""Build 92: exactly 20 base colors, one shade slider, no other picker."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 132;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert project.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2
assert "Build 92" in state

picker = tabs.split("private struct EcoThemeColorPicker: View {", 1)[1]
base = picker.split("private static let baseColors: [String] = [", 1)[1].split("]", 1)[0]
colors = re.findall(r'"(#[A-Fa-f0-9]{6})"', base)
assert len(colors) == 20, f"Expected 20 presets, found {len(colors)}"
assert len(set(colors)) == 20
assert "count: 5" in picker
assert "ForEach(paletteColors.indices, id: \\.self)" in picker

# The entire replacement popup has a single light/dark slider and no
# spectrum/filter controls or secondary system picker.
assert picker.count("Slider(value: $shadeLevel") == 1
assert 'Text("Scuro")' in picker
assert 'Text("Chiaro")' in picker
assert 'Label("Colori", systemImage: "paintpalette")' in picker
for retired in ("private static let spectrum:", "private static let neutrals:",
                "displayedColors", "filterButton(", "@State private var filter",
                'ColorPicker("Altro colore"', "pickerColor"):
    assert retired not in picker, retired

# Selecting a base changes ONLY the working color; moving the slider
# shades the chosen base, without mutating other theme roles.
assert "selectedBaseIndex = index" in picker
assert "referenceHex = hex" in picker
assert "shadeLevel = 0.50" in picker
assert "selectedHex = hex" in picker
assert "selectedHex = Self.shade(baseHex: referenceHex, level: level)" in picker
assert "if progress <= 0.5" in picker
assert "return channel * (progress * 2)" in picker
assert "return channel + (1 - channel) * ((progress - 0.5) * 2)" in picker
assert "EcoThemePalette.colorHex(UIColor(" in picker
assert "_selectedHex = State(initialValue: initialHex)" in picker
assert "_referenceHex = State(initialValue: initialHex)" in picker
assert "onConfirm(selectedHex)" in picker
assert 'accessibilityLabel("Annulla modifica")' in picker
assert "onConfirm(" not in picker.split('accessibilityLabel("Annulla modifica")',1)[1]

# The established theme editor still commits ONLY the tapped role on
# explicit confirmation, with existing 21-color palettes untouched.
assert "static let colorCount = 23" in tabs
assert "draft.colors[selected.id] = hex" in tabs
assert "selected.isDay" in tabs
assert "draft.dayTopBar.hex(for: selected.id)" in tabs
assert "draft.inclinometerColors[selected.id - EcoThemePalette.colorCount]" in tabs
assert '("Sfumature", [15, 16, 19, 20])' in tabs
assert "gradientOpacityBinding(for role: Int)" in tabs
assert "Slider(value: transparency, in: 0...1, step: 0.01)" in tabs
assert "try data.encode(colors, forKey: .colors)" in tabs

print("OK — build 92: 20 base swatches, one individual light/dark slider; no legacy filters")
