"""Build 61: all 12 Setup destinations use a flat 3x4 grid and modal sheets."""
from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
settings = (root / "Ecojumbo/Views/OtherViews.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 64;") == 2
en = settings.split("private enum EcoSetupSection:", 1)[1].split("struct EcoSettingsView:", 1)[0]
assert "case battery, bms, appearance, scooter, bluetooth, charging" in en
assert "case odometer, bars, gps, weather, privacy, version" in en
assert "LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 0), spacing: 10), count: 3)" in settings
assert "ForEach(EcoSetupSection.allCases)" in settings
assert "Image(systemName: section.symbol)" in settings
assert "Text(section.title)" in settings
assert ".frame(height: tileHeight)" in settings
assert ".buttonStyle(.plain)" in settings
assert ".accessibilityLabel(" in settings
assert ".sheet(item: $activeSection)" in settings
assert "Button(\"Chiudi\") { activeSection = nil }" in settings
assert "CellsView(portrait: space.size.height > space.size.width)" in settings
assert "BluetoothView()" in settings
for label in ["Aspetto dell'app", "Il mio Ecojumbo", "Bluetooth JK", "Ricarica",
              "Chilometri totali dello scooter", "Scale delle barre luminose",
              "GPS e viaggi", "Temperatura esterna", "Sicurezza e privacy", "Versione"]:
    assert f'Section("{label}")' in settings
assert "gps.setOdometer(number)" in settings
assert "bluetooth.applyFormat(" in settings
assert 'Picker("Modalità schermo", selection: $appearanceMode)' in settings
print("OK — build 61: 12 icon-label buttons in 3x4 with modal configuration sections")
