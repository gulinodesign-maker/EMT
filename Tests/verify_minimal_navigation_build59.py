"""Build 59: same flat controls in both orientations, centered menus and physical rotation to Settings."""
from pathlib import Path
import hashlib

root = Path(__file__).resolve().parents[1]
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
app = (root / "Ecojumbo/EcojumboApp.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_bytes()

assert pbx.count("CURRENT_PROJECT_VERSION = 69;") == 2

# Same shared flat treatment drives portrait tabs and landscape menu/GPS controls.
assert "private struct EcoMinimalNavigationLabel: View" in home
assert home.count("EcoMinimalNavigationLabel(") == 3
assert "foregroundStyle(active ? theme.accent : Color.secondary)" in home
assert 'PortraitServiceTabBar(selected: $selected, theme: theme)' in home
controls = home.split("    private func iconButton(_ tab: EcoTab, side: CGFloat)", 1)[1].split("/// EJ 1.19:", 1)[0]
for forbidden in ("LinearGradient(", ".shadow(", ".stroke(", "BluetoothGlyph()"):
    assert forbidden not in controls, forbidden
assert "gpsButton(\"map.fill\", active: mapEnabled" in home
assert "ForEach([EcoTab.trips, .settings, .themes])" in home
assert "mapControls.send(.toggleNavigation)" in home
assert "mapControls.send(.recenter)" in home

# GPS always stays right; the extra trailing spacer exists only in service menus.
dock = home.split("private struct CockpitCornerControls: View", 1)[1].split("private func iconButton(", 1)[0]
assert "Spacer(minLength: 0)" in dock
assert "if selected != .gps {\n                    Spacer(minLength: 0)" in dock
assert "let gpsGap = width * 0.008" in dock

# Physical device orientation is observed despite the GPS UIKit landscape-only mask.
assert "UIDevice.current.beginGeneratingDeviceOrientationNotifications()" in home
assert "NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)" in home
assert "if selected == .gps && UIDevice.current.orientation == .portrait {" in home
assert "selected = .settings" in home
assert "UIDevice.current.endGeneratingDeviceOrientationNotifications()" in home
assert "let newCockpitOnly = tab == .gps" in app
assert "requestGeometryUpdate(.iOS(interfaceOrientations: mask))" in app
assert "if selected != .gps && w < h {" in home

# Never modify established GPS dial/map geometry or hardware integration.
blob = b"blob " + str(len(cockpit)).encode() + b"\0" + cockpit
# Build 63 adds palette support but preserves the GPS panel bounds.
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in cockpit.decode('utf-8')
print("OK — build 59: flat navigation, centered landscape menus, portrait goes to Settings")
