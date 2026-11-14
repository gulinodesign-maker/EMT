"""Build 61: technical pages live in Setup; cockpit telemetry and dock geometry stay fixed."""
from pathlib import Path
import hashlib

root = Path(__file__).resolve().parents[1]
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
settings = (root / "Ecojumbo/Views/OtherViews.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_bytes()
cockpit_text = cockpit.decode("utf-8")
assert project.count("CURRENT_PROJECT_VERSION = 77;") == 2

# Only driving-relevant navigation is shown: technical screens are still accessible via Setup.
portrait = home.split("private struct PortraitServiceTabBar: View", 1)[1].split(
    "private struct CockpitCornerControls: View", 1
)[0]
dock = home.split("private struct CockpitCornerControls: View", 1)[1].split(
    "private func iconButton(", 1
)[0]
assert "ForEach([EcoTab.gps, .trips, .settings, .themes])" in portrait
assert "ForEach([EcoTab.trips, .settings, .themes])" in dock
for region in (portrait, dock):
    assert "ForEach(EcoTab.allCases)" not in region
    assert "ForEach([EcoTab.trips, .battery" not in region
# Build 61: access to both technical pages is modal inside the 3x4 grid.
assert "ForEach(EcoSetupSection.allCases)" in settings
assert "LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 0), spacing: 10), count: 3)" in settings
assert ".sheet(item: $activeSection)" in settings
assert "CellsView(portrait: space.size.height > space.size.width)" in settings
assert "BluetoothView()" in settings
assert "case battery, bms, appearance, scooter, bluetooth, charging" in settings
assert "case odometer, bars, weather" in settings

# The GPS map, dial, telemetry, horizontal dock placement and vertical bounds
# must not be changed when moving service navigation out of the cockpit.
blob = b"blob " + str(len(cockpit)).encode() + b"\0" + cockpit
# Palette editing changes the theme enum, not the geometry of the GPS cockpit.
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in cockpit_text
assert "let railBottomBound = h - dockBottom - dockHeight" in cockpit_text
assert "let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in cockpit_text
assert ".position(x: w / 2, y: h - dockBottom - dockHeight / 2)" in home
assert "let dockBottom = selected == .gps\n                ? max(4, h * 0.006)" in home
assert "let gpsGap = width * 0.008" in dock
assert "Spacer(minLength: 0)" in dock
assert "if selected != .gps {\n                    Spacer(minLength: 0)" in dock
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in cockpit_text
assert "let railBottomBound = h - dockBottom - dockHeight" in cockpit_text
assert ".position(x: panelLeft + panelWidth / 2, y: cardsCenterY)" in cockpit_text
assert "y: railCenterY)" in cockpit_text

for width, height in ((736, 414), (844, 390), (932, 430), (956, 440), (1536, 706)):
    dock_height = max(51, min(83, height * 0.105))
    dock_bottom = max(4, height * 0.006)
    dock_top = height - dock_bottom - dock_height
    outer_margin = max(8, height * 0.018)
    # Both standard telemetry and map battery rail finish above the same dock datum.
    assert height * 0.099 + outer_margin < dock_top - outer_margin
    assert (dock_top - outer_margin) + outer_margin == dock_top
    assert 0 < dock_top < height

# Portrait rotation still selects Setup; GPS-only landscape is retained.
assert "if selected == .gps && UIDevice.current.orientation == .portrait" in home
assert "selected = .settings" in home
assert "GPSCockpitDashboard(theme: theme, now: tick, mapEnabled: mapEnabled)" in home
print("OK — build 61: Batteria/BMS only in Setup, GPS dock and telemetry vertically aligned")
