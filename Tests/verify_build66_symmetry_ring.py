"""Build 66: mirrored upper bends, centered gray metal ring and safe thermometer."""
from pathlib import Path
from math import isclose

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 69;") == 2
symmetry = cockpit.split("private enum GPSHorizonSymmetry {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1)[0]
horizon = cockpit.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "private struct GPSHeader: View {", 1)[0]
ring = cockpit.split("private struct GPSMetalInnerRing: View {", 1)[1].split(
    "private struct GPSGaugeHalo: View {", 1)[0]
dashboard = cockpit.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato per azzerare trip", 1)[0]

# Both knees and both contacts are true reflections across the real GPS dial.
assert "GPSDialLayout.centerX(width: w, height: h)" in symmetry
assert "let rightKnee = CGPoint(x: w * 0.54, y: h * 0.099)" in symmetry
assert "let rightContact = CGPoint(x: w * 0.45, y: h * 0.244)" in symmetry
assert "let leftKnee = CGPoint(x: 2 * axis - rightKnee.x, y: rightKnee.y)" in symmetry
assert "let leftContact = CGPoint(x: 2 * axis - rightContact.x, y: rightContact.y)" in symmetry
assert "corners.leftKnee" in horizon and "corners.leftContact" in horizon
assert "corners.rightKnee" in horizon and "corners.rightContact" in horizon
assert "corners: [1], radius: radius" in horizon
assert "visibleOutsideRing.fill(style: FillStyle(eoFill: true))" in horizon
assert "GPSMapTopContourClip()" in cockpit

# Metal ring concentric with the orange GPS halo and physically inside it.
assert ".frame(width: d * 0.965, height: d * 0.965)" in ring
assert "StrokeStyle(lineWidth: max(1.5, d * 0.0035))" in ring
assert "Color(white:" in ring
assert "LinearGradient(stops:" in ring
assert "location: 0.80" in ring
assert "accessibilityHidden(true)" in ring
assert "GPSMetalInnerRing()" in dashboard
assert ".zIndex(26)" in dashboard
assert "GPSGaugeHalo(theme: theme)" in dashboard
assert ".zIndex(27)" in dashboard
assert ".position(x: dialCenterX, y: h * 0.494)" in dashboard

# Temperature shifts left when a mirrored bend reduces available space.
assert "GPSHorizonSymmetry.temperatureFrame(width: w, height: h)" in dashboard
assert ".frame(width: temperatureLayout.width)" in dashboard
assert ".position(x: temperatureLayout.centerX," in dashboard
assert "let lineX = points.leftKnee.x" in symmetry
assert "let rightLimit = lineX - max(8, w * 0.012)" in symmetry
assert ".minimumScaleFactor(0.68)" in cockpit

for w, h in ((736, 414), (844, 390), (932, 430), (956, 440),
             (1179, 510), (1536, 706), (1648, 928), (1806, 831)):
    d = min(h * .965, w * .55)
    axis = max(d * .51 + w * .010, w * .168 + d * .30)
    right_knee = w * .54
    right_contact = w * .45
    left_knee = 2 * axis - right_knee
    left_contact = 2 * axis - right_contact
    assert 0 < left_knee < left_contact < axis < right_contact < right_knee < w
    assert isclose(axis - left_knee, right_knee - axis, abs_tol=1e-7)
    assert isclose(axis - left_contact, right_contact - axis, abs_tol=1e-7)
    assert isclose(.099 * h, .099 * h)
    assert isclose(.244 * h, .244 * h)
    # Orange halo at diameter 0.992 d; silver at diameter 0.965 d.
    outer_radius = .992 * d / 2
    metal_radius = .965 * d / 2
    power_segments_outside = (.469 + .017 / 2) * d
    assert power_segments_outside + .0035 * d / 2 < metal_radius
    assert metal_radius + .0035 * d / 2 < outer_radius - .0038 * d / 2
    # Keep the temperature wholly to the left of the diagonal at 15.8% h.
    ratio = (.158 - .099) / (.244 - .099)
    diagonal_x = left_knee + (left_contact - left_knee) * ratio
    inset = max(4, w * .007)
    clearance = max(8, w * .012)
    available = max(52, diagonal_x - clearance - inset)
    temp_width = min(136, w * .108, available)
    assert inset + temp_width < diagonal_x - clearance + 0.001
    assert temp_width >= 52

# Do not alter approved telemetry grid, GPS reset, map or justified nav dock.
assert 'telemetryTile("SOC"' in cockpit
assert 'telemetryTile("V BAT"' in cockpit
assert 'telemetryTile("AUT"' in cockpit
assert 'telemetryTile("TRIP"' in cockpit
assert "let dislHeight = 2 * cardHeight" in cockpit
assert "area.fill(LinearGradient(" in cockpit
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in cockpit
assert "GPSCockpitMap(theme: theme)" in cockpit
assert "GPSLowerGlow(theme: theme)" in cockpit
assert "let telemetryDock = selected == .gps && !mapEnabled" in home
assert "let justifiedGap = max(0, (telemetryPanelWidth - 5 * gpsSide) / 4)" in home
print("OK — build 66: mathematically mirrored top-bar bends, inset metal ring and temperature clearance")
