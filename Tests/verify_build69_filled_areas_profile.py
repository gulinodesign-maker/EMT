"""Build 69: gradients fill the areas, never the border; outer double profile 3×."""
from pathlib import Path
from math import cos, sin, radians, isclose

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 69;") == 2
assert pbx.count("MARKETING_VERSION = 1.0;") == 2
assert "static let colorCount = 17" in tabs
assert "decoded.colors.count == 8 || decoded.colors.count == 15 ||" in tabs
assert "migrated.colors.append(contentsOf: [edge, edge])" in tabs
assert "draft.colors[selected.id] = hex" in tabs
assert "onSave(slot, palette)" in tabs
assert "RIEMPIMENTO" in tabs

upper_shape = cockpit.split("private struct GPSTopBandShade: Shape {", 1)[1].split(
    "private struct GPSOuterProfileReinforcement: Shape {", 1)[0]
horizon = cockpit.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "@MainActor", 1)[0]
lower_area = cockpit.split("private struct GPSLowerAreaGradient: View {", 1)[1].split(
    "private struct GPSLowerGlow: View {", 1)[0]
lower_line = cockpit.split("private struct GPSLowerGlow: View {", 1)[1].split(
    "// EJ 1.22", 1)[0]
dashboard = cockpit.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]
style = cockpit.split("private enum GPSContourStroke {", 1)[1].split(
    "private enum GPSDialLayout {", 1)[0]
outer = cockpit.split("private struct GPSOuterProfileReinforcement: Shape {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1)[0]

# Top band closes against the TOP SCREEN BORDER, follows rounded top bar
# and uses the same dial cutout as the luminous contour.
assert "GPSHorizonSymmetry.corners(width: w, height: h)" in upper_shape
assert "corners.leftKnee" in upper_shape and "corners.rightKnee" in upper_shape
assert "corners.leftContact" in upper_shape and "corners.rightContact" in upper_shape
assert "CGPoint(x: w, y: 0)" in upper_shape
assert "CGPoint(x: 0, y: 0)" in upper_shape
assert "area.closeSubpath()" in upper_shape
assert "GPSTopBandShade()" in horizon
assert ".fill(theme.contourGradient)" in horizon
assert "visibleOutsideRing.fill(style: FillStyle(eoFill: true))" in horizon
assert ".mask(RadialGradient" not in horizon

# Identical editable interpolation in BOTH areas, no colour gradient on strokes.
assert ".fill(theme.contourGradient)" in lower_area
assert "GPSLowerShade()" in lower_area
assert "GPSAreaGradientStyle.opacity" in lower_area
assert "GPSAreaGradientStyle.opacity" in horizon
assert ".stroke(theme.contourGradient" not in horizon
assert ".stroke(theme.contourGradient" not in lower_line
assert "line.stroke(theme.accent" in horizon
assert ".stroke(theme.accent" in lower_line
assert "GPSLowerTerminalFade()" in lower_line
assert "GPSLowerAreaGradient(theme: theme)" in dashboard
assert ".zIndex(7)" in dashboard
assert ".zIndex(28)" in dashboard

# Separate reinforced shape at precisely THREE TIMES the common base width.
assert "max(1.4, h * 0.003)" in style
assert "GPSContourStroke.width(height: h)" in horizon
assert "GPSContourStroke.width(height: h)" in lower_line
assert "GPSContourStroke.width(height: h) * 3" in dashboard
assert "GPSOuterProfileReinforcement()" in dashboard
assert ".stroke(theme.accent" in dashboard
assert ".zIndex(12)" in dashboard
assert "let radius = dialSize * 0.535" in outer
assert "let leftStart = point(218" in outer
assert "let rightStart = point(322" in outer
assert "for step in 1...36" in outer
assert "let angle = 218 - CGFloat(step) * (76.0 / 36.0)" in outer
assert "let angle = 322 + CGFloat(step) * (76.0 / 36.0)" in outer
assert "line.addQuadCurve(to: leftStart" in outer
assert "line.addQuadCurve(to: rightStart" in outer

for w,h in [(736,414),(844,390),(932,430),(956,440),
            (1179,510),(1536,706),(1648,928),(1806,831)]:
    d=min(h*.965,w*.55)
    cx=max(d*.51+w*.010,w*.168+d*.30)
    cy=h*.494
    radius=d*.535
    led=d*.992/2
    # Reinforcement outside the dial but still inside the telemetry clearance.
    assert radius > led
    rightmost = cx+radius
    panel_left = cx+d*.508+max(12,w*.018)
    stroke = 3*max(1.4,h*.003)
    assert rightmost+stroke/2 < panel_left, (w,h,rightmost,panel_left)
    assert cx-radius-stroke/2 > 0
    # The two flanks are mirror images around the real GPS centre.
    for left,right in [(218,322),(180,360),(142,398)]:
        xleft=cx+radius*cos(radians(left))
        xright=cx+radius*cos(radians(right))
        yleft=cy+radius*sin(radians(left))
        yright=cy+radius*sin(radians(right))
        assert isclose(xleft+xright,2*cx,abs_tol=1e-7)
        assert isclose(yleft,yright,abs_tol=1e-7)
    assert isclose(stroke/max(1.4,h*.003),3,rel_tol=1e-12)

# No accidental changes to existing GPS, MapKit, BMS or five-button alignment.
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in cockpit
assert "GPSCockpitMap(theme: theme)" in cockpit
assert "GPSTripAltitudeSparkline(points: gps.altitudeProfile" in cockpit
assert "let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in cockpit
assert "let telemetryDock = selected == .gps && !mapEnabled" in home
print("OK — build 69: editable area fills, monochrome outlines, mirrored 3× reinforcement, GPS/BMS preserved")
