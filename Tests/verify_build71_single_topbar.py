"""Build 71: remove the second orange profile added in 69, keep original GPS top bar."""
from pathlib import Path
from math import isclose

root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 74;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert project.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2

# Crucial: delete the entire secondary 3x shape and its drawing layer.
# A hidden/transparent stroke is NOT enough and could reappear with theme changes.
assert "private struct GPSOuterProfileReinforcement: Shape" not in source
assert "GPSOuterProfileReinforcement()" not in source
assert "let topY = h * 0.144" not in source
assert "GPSContourStroke.width(height: h) * 3" not in source

dashboard = source.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]
assert dashboard.count("GPSHorizonLine(theme: theme)") == 1
assert ".zIndex(8)" in dashboard
assert ".zIndex(12)" not in dashboard
assert "GPSMetalInnerRing()" in dashboard
assert "GPSGaugeHalo(theme: theme)" in dashboard
assert "GPSLowerGlow(theme: theme)" in dashboard
assert "GPSExpandedReadings(theme: theme, now: now)" in dashboard

# Preserve the authentic mirrored contour, ring exclusion and sharp connections.
horizon = source.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "@MainActor", 1)[0]
assert "corners.leftKnee" in horizon and "corners.rightKnee" in horizon
assert "corners.leftContact" in horizon and "corners.rightContact" in horizon
assert "line.stroke(theme.accent, lineWidth: GPSContourStroke.width(height: h))" in horizon
assert ".mask(visibleOutsideRing.fill(style: FillStyle(eoFill: true)))" in horizon
assert ".mask(RadialGradient" not in horizon
assert "GPSHorizonSymmetry.corners(width: w, height: h)" in horizon

# No new gradients, no alteration to the original kW bridge shading.
lower = source.split("private struct GPSLowerGlow: View {", 1)[1].split(
    "// EJ 1.22", 1)[0]
assert "GPSLowerContour()" in lower and "GPSLowerShade()" in lower
assert ".mask(GPSLowerTerminalFade())" in lower
assert "GPSTopBandShade" not in source and "GPSLowerAreaGradient" not in source

# Keep GPS geometry and telemetry controls aligned over different iPhone widths.
for w, h in ((736, 414), (844, 390), (932, 430), (956, 440),
             (1179, 510), (1536, 706), (1806, 831)):
    d = min(h * 0.965, w * 0.55)
    cx = max(d * 0.51 + w * 0.010, w * 0.168 + d * 0.30)
    left = cx + d * 0.508 + max(12, w * 0.018)
    right = w - max(12, w * 0.018)
    assert left < right
    assert isclose((left + right) / 2, (cx + d * 0.508 + w) / 2)
assert "let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in dashboard
assert "let telemetryDock = selected == .gps && !mapEnabled" in home
assert "let justifiedGap = max(0, (telemetryPanelWidth - 5 * gpsSide) / 4)" in home
assert "GPSCockpitMap(theme: theme)" in source
assert "GPSOuterProfileReinforcement" in state  # decision logged, not drawn
print("OK — build 71: single original top bar, no double 3x contour, GPS and telemetry preserved")
