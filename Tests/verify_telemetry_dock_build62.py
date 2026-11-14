"""Build 62: the five GPS buttons align to both edges of the telemetry panel."""
from pathlib import Path
from math import isclose
import hashlib

root = Path(__file__).resolve().parents[1]
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_bytes()
source = cockpit.decode("utf-8")
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 80;") == 2

# Preserve telemetry, dial and map source from the approved landscape cockpit.
blob = b"blob " + str(len(cockpit)).encode() + b"\0" + cockpit
# Build 63 adds palette support but preserves the GPS panel bounds.
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in source
assert "let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in source
assert "let panelWidth = max(1, w - EcoCockpitDockGeometry.rightInset(width: w) - panelLeft)" in source
assert ".position(x: panelLeft + panelWidth / 2, y: cardsCenterY)" in source
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in source

# Only when the GPS map is hidden: distribute the five buttons under telemetry.
dock = home.split("private struct CockpitCornerControls: View", 1)[1].split("/// EJ 1.19:", 1)[0]
assert "let telemetryDock = selected == .gps && !mapEnabled" in dock
assert "let telemetryPanelLeft = EcoCockpitDockGeometry.standardLeft(width: width, height: screenHeight)" in dock
assert "- EcoCockpitDockGeometry.rightInset(width: width)" in dock
assert "let justifiedGap = max(0, (telemetryDockWidth - dockContentInset - 5 * gpsSide) / 4)" in dock
assert "HStack(spacing: telemetryDock ? justifiedGap : gpsGap)" in dock
assert ".frame(width: telemetryDock ? telemetryDockWidth : nil, alignment: .leading)" in dock
assert "ForEach([EcoTab.trips, .settings, .themes])" in dock
assert 'gpsButton("map.fill", active: selected == .gps' in dock
assert 'gpsButton(isDay ? "moon.stars.fill" : "sun.max.fill"' in dock
# Menus remain centered; GPS map mode continues using original dock spacing.
assert "if selected != .gps {\n                    Spacer(minLength: 0)" in dock
assert "let gpsGap = width * 0.008" in dock
assert "if mapEnabled && selected == .gps" in dock

# The dock is one beveled glass unit, wider than the four telemetry cards.
for w, h in [(736, 414), (844, 390), (932, 430), (956, 440),
             (1179, 510), (1536, 706), (1806, 831)]:
    dial = min(h * .920, w * .525)
    dial_x = max(dial * .51 + w * .010, w * .154 + dial * .280)
    right = max(12, w * .018)
    panel_left = dial_x + dial * .508 + right
    dock_left = max(0, panel_left - w * .080)
    dock_width = w - right - dock_left
    inset = w * .045
    gap = w * .008
    safe_left = dial_x + dial * .50 + max(10, w * .010)
    side_ideal = min(max(51, min(83, h * .105)) * .96, w * .052)
    side = min(side_ideal, max(20, (w - right - safe_left - 6 * gap) / 7))
    justified_gap = max(0, (dock_width - inset - 5 * side) / 4)
    assert dock_left < panel_left
    assert dock_width > 5 * side
    assert justified_gap > 0
    assert isclose(dock_left + inset + 5 * side + 4 * justified_gap,
                   w - right, abs_tol=1e-7)
print("OK — build 62: five GPS buttons justified to telemetry left/right edges")
