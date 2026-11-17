"""Build 70: requested NO colored gradients; preserve centered full-width telemetry/dock."""
from pathlib import Path
from math import isclose

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 109;") == 2
assert pbx.count("MARKETING_VERSION = 1.0;") == 2
assert pbx.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2

# The two 68/69 gradient-colored surfaces are REMOVED, not merely made transparent.
assert "GPSTopBandShade" not in cockpit
assert "GPSLowerAreaGradient" not in cockpit
assert "GPSAreaGradientStyle" not in cockpit
assert "contourGradient" not in cockpit
assert '("Sfumatura top bar e ponte kW", 15..<17)' not in tabs
assert "static let colorCount = 23" in tabs  # existing saved slots are never erased
assert "decoded.colors.count == 8 || decoded.colors.count == 15 ||" in tabs
assert "migrated.colors.append(contentsOf: [edge, edge])" in tabs

horizon = cockpit.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "@MainActor", 1)[0]
lower = cockpit.split("private struct GPSLowerGlow: View {", 1)[1].split(
    "// EJ 1.22", 1)[0]
assert "metalLine.stroke(GPSMetalContourStyle.gradient(for: colorScheme)" in horizon
assert ".stroke(GPSMetalContourStyle.gradient(for: colorScheme)" in lower
assert ".mask(visibleOutsideMetalRing.fill(style: FillStyle(eoFill: true)))" in horizon
assert ".mask(GPSLowerTerminalFade())" in lower
assert "GPSLowerShade()" not in lower   # build 76: no under-bridge veil
assert "GPSOuterProfileReinforcement" not in cockpit
assert "GPSContourStroke.width(height: h) * 3" not in cockpit

# Same geometry functions for telemetry cards and five no-map controls.
geometry = home.split("enum EcoCockpitDockGeometry {", 1)[1].split(
    "struct EcojumboRootView: View {", 1)[0]
assert "return dialX + radius + neonStroke / 2" in geometry
assert "visibleDialRightTangent(width: width, height: height) + rightInset(width: width)" in geometry
assert "let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in cockpit
assert "let panelWidth = max(1, w - EcoCockpitDockGeometry.rightInset(width: w) - panelLeft)" in cockpit
assert ".position(x: panelLeft + panelWidth / 2, y: cardsCenterY)" in cockpit
assert "let telemetryDock = selected == .gps && !mapEnabled" in home
assert "let telemetryPanelLeft = EcoCockpitDockGeometry.standardLeft(width: width, height: screenHeight)" in home
assert "let justifiedGap = max(0, (telemetryPanelWidth - 6 * gpsSide) / 5)" in home
assert ".frame(width: fillsTelemetryWidth ? telemetryPanelWidth : nil, alignment: .center)" in home

for w, h in ((736, 414), (844, 390), (932, 430), (956, 440),
             (1179, 510), (1536, 706), (1648, 928), (1806, 831)):
    d = min(h * 0.965, w * 0.55)
    cx = max(d * 0.51 + w * 0.010, w * 0.168 + d * 0.30)
    tangent = cx + d * (.986 * .90) / 2 + 1.5 + max(2.4, min(4.2, d * .0051)) / 2
    margin = max(12, w * 0.018)
    left, right = tangent + margin, w - margin
    width = right - left
    assert width > 0
    assert isclose((left + right) / 2, (tangent + w) / 2, abs_tol=1e-8)
    controls_h = max(51, min(83, h * 0.105))
    ideal_side = min(controls_h * 0.96, w * 0.052)
    safe_left = cx + d * 0.50 + max(10, w * 0.010)
    gap = w * 0.008
    side = min(ideal_side, max(20, (w - margin - safe_left - 6 * gap) / 7))
    assert width >= 6 * side, (w, h, width, side)
    justified_gap = (width - 6 * side) / 5
    standard_gap = min(justified_gap, max(8, w * 0.013))
    group_width = 6 * side + 5 * standard_gap
    button_left = (left + right) / 2 - group_width / 2
    button_right = button_left + group_width
    assert isclose((button_left + button_right) / 2, (left + right) / 2, abs_tol=1e-8)
    assert left <= button_left <= button_right <= right
    # The original dial remains outside the aligned telemetry panel.
    assert tangent < left

assert "Build 70" in state
assert "senza applicare le sfumature" in state
assert "GPSCockpitMap(theme: theme)" in cockpit
assert "GPSTripAltitudeSparkline(points: gps.altitudeProfile" in cockpit
assert "let live: JKSnapshot? = {" in cockpit
print("OK — build 70/71: no colored gradients, 18 palette colors, originals kept, centered telemetry and five dock controls")
