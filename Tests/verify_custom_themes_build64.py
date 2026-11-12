"""Build 64 — 15 clearly named colors, backward-compatible slots and real cockpit wiring."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
settings = (root / "Ecojumbo/Views/OtherViews.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 65;") == 2
assert "static let colorCount = 15" in tabs
labels = tabs.split("static let labels = [", 1)[1].split("]", 1)[0]
details = tabs.split("static let details = [", 1)[1].split("]", 1)[0]
assert len(re.findall(r'^\s*"[^"]+"', labels, flags=re.M)) == 15
assert len(re.findall(r'^\s*"[^"]+"', details, flags=re.M)) == 15
for label in (
    "Sfondo del cockpit", "Colore principale · top bar e icone Setup",
    "Barre telemetria · colore scuro", "Numeri kW · energia in ingresso",
    "Anello esterno · potenza erogata", "Anello interno · recupero energia",
    "Arco LED · velocità GPS", "Numeri del tachimetro · km/h",
    "Navigatore · svolta a destra", "Navigatore · svolta a sinistra",
    "Decelerazione GPS · non sensore freno",
):
    assert f'"{label}"' in labels, label

# Four named groups and long-press on each color; color picker keeps cancel/confirm.
for group in ("Aspetto generale", "Barre telemetria e potenza",
              "Anelli e numeri del tachimetro", "Navigatore e decelerazione"):
    assert f'"{group}"' in tabs
assert "ForEach(group.range, id:" in tabs
assert "EcoThemePalette.labels[index]" in tabs
assert "EcoThemePalette.details[index]" in tabs
assert "minimumDuration: 0.45" in tabs
assert ".sheet(item: $colorID)" in tabs
assert "onConfirm(selectedHex)" in tabs
assert 'Button("Annulla", role: .cancel)' in tabs
assert "EcoThemePalette.colorCount" in tabs

# Do not wipe existing custom palettes: old 8-color slots become 15 colors.
assert "(decoded.colors.count == 8 || decoded.colors.count == colorCount)" in tabs
assert "migrated.colors.append(contentsOf: extraDefaults)" in tabs
assert "migrated.colors[9] = decoded.colors[7]" in tabs
assert "guard (1...3).contains(slot)" in tabs
assert "palette.colors.count == colorCount" in tabs
assert 'UserDefaults.standard.set(data, forKey: storagePrefix + String(slot))' in tabs
assert "ForEach(1...3, id:" in tabs
assert 'Label("Crea un nuovo tema", systemImage: "paintbrush.pointed")' in tabs

# Principal accent reaches top-bar strokes AND all twelve icon buttons in Setup.
assert "theme.accent" in home
assert 'private var setupIconColor: Color' in settings
assert "CockpitTheme(rawValue: themeName) ?? .copper" in settings
assert ".foregroundStyle(setupIconColor)" in settings
assert '@AppStorage("ecojumbo.themeRevision") private var themeRevision = 0' in settings

# Every newly added swatch maps to a distinct rendered element.
for i in range(8, 15):
    assert f"EcoThemePalette.active?.colors[{i}]" in cockpit, i
assert "activeColor: CockpitTheme.dischargeAccent" in cockpit
assert "activeColor: CockpitTheme.recoveryRingAccent" in cockpit
assert "CockpitTheme.speedLEDAccent" in cockpit
assert "CockpitTheme.decelerationAccent" in cockpit
assert ".foregroundStyle(CockpitTheme.speedDigitsAccent)" in cockpit
assert "navigationArrow.contains(\"right\")" in cockpit
assert "navigationArrow.contains(\"left\")" in cockpit
assert "CockpitTheme.turnRightAccent" in cockpit
assert "CockpitTheme.turnLeftAccent" in cockpit
assert "navigationDistance: navigation.isNavigating &&" in cockpit
assert 'Text(navigationDistance)' in cockpit
assert "navigation.guidanceDistanceLabel" in cockpit

# A reduction of actual GPS speed is not the brake signal; never claim it is.
assert ".onChange(of: speed)" in cockpit
assert "previousSpeed.map" in cockpit
assert "($0 - current) >= 2.5" in cockpit
assert "non da un sensore sul freno meccanico" in cockpit
assert "isDecelerating = false" in cockpit
assert "now.timeIntervalSince(previousUpdateAt) > 2" in cockpit
assert "Decelerazione GPS · non sensore freno" in tabs

# Critical GPS and telemetry measurements and geometry remain unchanged.
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in cockpit
assert "let railCenterY = (railTopBound + railBottomBound) / 2" in cockpit
assert "let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in cockpit
assert ".position(x: panelLeft + panelWidth / 2, y: cardsCenterY)" in cockpit
assert "let telemetryDock = selected == .gps && !mapEnabled" in home
assert "let justifiedGap = max(0, (telemetryPanelWidth - 5 * gpsSide) / 4)" in home
assert "UIDevice.current.orientation == .portrait" in home
print("OK — build 64: 15 named colors, 8→15 migration, Setup accent and GPS layout intact")
