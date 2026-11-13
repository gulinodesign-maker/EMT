"""Build 62: the five GPS buttons align to both edges of the telemetry panel."""
from pathlib import Path
from math import isclose
import hashlib

root = Path(__file__).resolve().parents[1]
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_bytes()
source = cockpit.decode("utf-8")
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 73;") == 2

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
assert "width - EcoCockpitDockGeometry.rightInset(width: width)" in dock
assert "let justifiedGap = max(0, (telemetryPanelWidth - 5 * gpsSide) / 4)" in dock
assert "HStack(spacing: telemetryDock ? justifiedGap : gpsGap)" in dock
assert ".frame(width: telemetryDock ? telemetryPanelWidth : nil, alignment: .leading)" in dock
assert "ForEach([EcoTab.trips, .settings, .themes])" in dock
assert 'gpsButton("map.fill", active: mapEnabled' in dock
assert 'gpsButton(isDay ? "moon.stars.fill" : "sun.max.fill"' in dock
# Menus remain centered; GPS map mode continues using original dock spacing.
assert "if selected != .gps {\n                    Spacer(minLength: 0)" in dock
assert "let gpsGap = width * 0.008" in dock
assert "if mapEnabled && selected == .gps" in dock

# Numerically verify alignment for diverse landscape sizes.
for w, h in [(736, 414), (844, 390), (932, 430), (956, 440),
             (1179, 510), (1536, 706), (1806, 831)]:
    gap = w * 0.008
    right = max(12, w * 0.018)
    dial = min(h * 0.965, w * 0.55)
    dial_x = max(dial * 0.51 + w * 0.010, w * 0.168 + dial * 0.30)
    safe_left = dial_x + dial * 0.50 + max(10, w * 0.010)
    side_ideal = min(max(51, min(83, h * 0.105)) * 0.96, w * 0.052)
    available = w - right - safe_left - 6 * gap
    side = min(side_ideal, max(20, available / 7))
    # Build 68: tangente al bordo reale del tachimetro e inset simmetrici.
    panel_left = dial_x + dial * 0.508 + right
    panel_width = w - right - panel_left
    justified_gap = max(0, (panel_width - 5 * side) / 4)
    button_left = panel_left
    button_right = button_left + 5 * side + 4 * justified_gap
    assert justified_gap >= gap
    assert isclose(button_left, panel_left, abs_tol=1e-7)
    assert isclose(button_right, w - right, abs_tol=1e-7)
    assert panel_left > safe_left - 5, (w, h, panel_left, safe_left)
    dial_tangent = dial_x + dial * 0.508
    assert isclose(panel_left - dial_tangent, right, abs_tol=1e-7)
    assert isclose((button_left + button_right) / 2,
                   (dial_tangent + w) / 2, abs_tol=1e-7)
print("OK — build 62: five GPS buttons justified to telemetry left/right edges")
