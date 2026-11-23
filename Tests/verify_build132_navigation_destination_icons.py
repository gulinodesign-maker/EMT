"""Build 132: navigation controls indicate the view reached when tapped."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
dock = source.split("private struct CockpitCornerControls: View {", 1)[1].split("/// EJ 1.19", 1)[0]

assert project.count("CURRENT_PROJECT_VERSION = 132;") == 2

# The map button shows its destination: Map from telemetry, Telemetry from Map.
assert 'gpsButton(mapEnabled ? "chart.bar.xaxis" : "map.fill",' in dock
assert 'text: mapEnabled ? "Telem." : "Mappa",' in dock
assert 'accessibility: mapEnabled ? "Torna alla telemetria" : "Attiva la mappa",' in dock
assert "mapEnabled.toggle()" in dock

# The inclination button returns to telemetry rather than displaying its own icon.
assert 'gpsButton(inclinometerEnabled ? "chart.bar.xaxis" : "gyroscope",' in dock
assert 'text: inclinometerEnabled ? "Telem." : "Inclin.",' in dock
assert 'accessibility: inclinometerEnabled\n' in dock
assert '"Torna alla telemetria" : "Mostra inclinometro",' in dock
assert "inclinometerEnabled.toggle()" in dock

# No changes to the map/inclinometer exclusivity or the separate music dock.
assert "if enabled { inclinometerEnabled = false }" in source
assert "if selected == .gps && !mapEnabled {" in dock
assert 'gpsButton("chart.bar.xaxis", text: "Telemetria",' in dock
assert "if musicDock {" in dock
print("OK — build132: map/inclinometer destination icons, captions and accessible return actions")
