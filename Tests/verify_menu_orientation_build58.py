"""Build 58: portrait only in service menus, never in GPS cockpit."""
from pathlib import Path
import hashlib
import plistlib

root = Path(__file__).resolve().parents[1]
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
plist = plistlib.loads((root / "Ecojumbo/Info.plist").read_bytes())
app = (root / "Ecojumbo/EcojumboApp.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
cells = (root / "Ecojumbo/Views/CellsView.swift").read_text()
themes = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit_file = (root / "Ecojumbo/Views/CockpitComponents.swift").read_bytes()

assert pbx.count("CURRENT_PROJECT_VERSION = 63;") == 2
assert set(plist["UISupportedInterfaceOrientations"]) == {
    "UIInterfaceOrientationPortrait",
    "UIInterfaceOrientationLandscapeLeft",
    "UIInterfaceOrientationLandscapeRight",
}
# Tachimetro, mappa e quadranti devono essere identici a build 57.
blob = b"blob " + str(len(cockpit_file)).encode() + b"\0" + cockpit_file
# Build 63 adds palette support but preserves the GPS panel bounds.
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in cockpit_file.decode('utf-8')

assert "@UIApplicationDelegateAdaptor(EcojumboOrientationAppDelegate.self)" in app
assert "supportedInterfaceOrientationsFor window:" in app
assert "let newCockpitOnly = tab == .gps" in app
assert "cockpitOnly ? .landscape : .allButUpsideDown" in app
assert "requestGeometryUpdate(.iOS(interfaceOrientations: mask))" in app
assert "setNeedsUpdateOfSupportedInterfaceOrientations()" in app
assert "private(set) static var cockpitOnly = true" in app

assert "@State private var selected: EcoTab = .gps" in home
assert "EcojumboOrientationPolicy.update(for: selected, force: true)" in home
assert "EcojumboOrientationPolicy.update(for: newTab)" in home
assert "if selected != .gps && w < h {" in home
assert "} else if selected == .gps && w < h {" in home
assert "landscapeDashboardGuard(width: w, height: h)" in home
assert 'GPSCockpitDashboard(theme: theme, now: tick, mapEnabled: mapEnabled)' in home
assert home.count("GPSCockpitDashboard(theme: theme, now: tick, mapEnabled: mapEnabled)") == 1
assert "PortraitCockpitDashboard" not in home
assert "PortraitServiceTabBar(selected: $selected, theme: theme)" in home
assert "ForEach([EcoTab.gps, .trips, .settings, .themes])" in home
for view in [
    "NavigationStack { TripsPanel() }",
    "NavigationStack { CellsView(portrait: true) }",
    "NavigationStack { BluetoothView() }",
    "NavigationStack { EcoSettingsView() }",
    "NavigationStack { ThemePickerView(portrait: true) }",
]:
    assert view in home
assert 'Label("Torna ai menù", systemImage: "arrow.left")' in home
assert "lastMenu = newTab" in home

assert "if portrait {" in cells
assert "LazyVGrid(columns: portraitSummaryColumns" in cells
assert "HStack(spacing: 12)" in cells
assert "summaryTiles(snapshot)" in cells
assert "portrait ? portraitColumns : landscapeColumns" in themes
assert "count: 3" in themes and "let portraitColumns = [GridItem(.flexible(), spacing: 13)]" in themes
print("OK — build 58: portrait solo menu, cockpit GPS landscape originale invariato")
