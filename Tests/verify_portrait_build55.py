"""Build 55: portrait support, adaptive navigation, map and telemetry."""
from pathlib import Path
import plistlib

root = Path(__file__).resolve().parents[1]
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
cells = (root / "Ecojumbo/Views/CellsView.swift").read_text()
themes = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
bluetooth = (root / "Ecojumbo/Views/OtherViews.swift").read_text()
with (root / "Ecojumbo/Info.plist").open("rb") as f:
    plist = plistlib.load(f)

assert pbx.count("CURRENT_PROJECT_VERSION = 55;") == 2
assert set(plist["UISupportedInterfaceOrientations"]) == {
    "UIInterfaceOrientationPortrait",
    "UIInterfaceOrientationLandscapeLeft",
    "UIInterfaceOrientationLandscapeRight",
}
assert "if h > w {" in home
assert "portraitContent(width: w, height: h" in home
assert "GPSCockpitDashboard(theme: theme, now: tick, mapEnabled: mapEnabled)" in home
assert "PortraitCockpitDashboard(theme: theme, now: tick" in home
assert "PortraitTabBar(selected: $selected, theme: theme)" in home
assert "ForEach(EcoTab.allCases)" in home
assert "insets.top" in home and "insets.bottom" in home
assert "switch selected {" in home
assert "struct PortraitCockpitDashboard: View" in cockpit
assert "GPSHeader(theme: theme, now: now" in cockpit
assert "SystemClockText()" in cockpit
assert "GPSCockpitMap(theme: theme, compact: true)" in cockpit
assert "var compact: Bool = false" in cockpit
assert "if compact { Rectangle() } else { GPSMapTopContourClip() }" in cockpit
assert "mapControls.send(.toggleNavigation)" in cockpit
assert "mapControls.send(.recenter)" in cockpit
assert "mapControls.send(.toggleProjection)" in cockpit
assert "OpenSpeedCluster(speed: speed" in cockpit
assert "GPSTripResetControl(theme: theme)" in cockpit
assert "LazyVGrid(columns:" in cockpit
assert "summaryColumns = [GridItem(.adaptive(minimum: 142)" in cells
assert "LazyVGrid(columns: summaryColumns" in cells
assert "GridItem(.adaptive(minimum: 145)" in themes
assert "ViewThatFits(in: .horizontal)" in bluetooth
print("OK — build 55: portrait, MapKit, navigation, safe area and adaptive BMS")
