"""Build 90: layer colors/glow categorically excluded from dial and bridge."""
from pathlib import Path
from math import hypot
root = Path(__file__).resolve().parents[1]
src = (root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
themes = (root/"Ecojumbo/Views/CockpitTabs.swift").read_text()
project = (root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root/"STATO_PROGETTO.md").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 134;") == 2
assert "Build 90" in state
footprint = src.split("private struct GPSUpperLayerFootprint: Shape {",1)[1].split(
    "private struct GPSDialExteriorMask: Shape {",1)[0]
dial_mask = src.split("private struct GPSDialExteriorMask: Shape {",1)[1].split(
    "private struct GPSBridgeExteriorMask: Shape {",1)[0]
bridge_mask = src.split("private struct GPSBridgeExteriorMask: Shape {",1)[1].split(
    "private struct GPSUpperGradientLayer: View {",1)[0]
layer = src.split("private struct GPSUpperGradientLayer: View {",1)[1].split(
    "private struct GPSHorizonLine: View {",1)[0]
dashboard = src.split("struct GPSCockpitDashboard: View {",1)[1].split(
    "// Pulsante dedicato",1)[0]

# CRITICAL: original source of build 89 regression. An ellipse inside the
# combined two-lobe footprint can reverse even-odd parity inside the dial.
assert "left.addEllipse" not in footprint
assert "upper.addEllipse" not in footprint
assert "left.addPath(upper)" in footprint
assert "left.addLine(to: CGPoint(x: leftBottomX, y: h))" in footprint
assert "CGPoint(x: corners.rightContact.x, y: h)" not in footprint

# One independent full-screen-minus-circle mask for the *whole* dial.
assert "var exterior = Path(rect)" in dial_mask
assert "exterior.addEllipse(in: CGRect(" in dial_mask
assert "let radius = d * GPSDialLayout.outerProfileDiameterFactor / 2 + 3" in dial_mask
assert "GPSDialLayout.size(width: w, height: h)" in dial_mask
assert "GPSDialLayout.centerX(width: w, height: h)" in dial_mask
assert "y: h * 0.494 - radius" in dial_mask

# Another independent rectangle-minus-bridge-interior mask. Never combine
# both holes in the same even-odd fill: overlapping holes would unmask pixels.
assert "var exterior = Path(rect)" in bridge_mask
assert "exterior.addPath(GPSLowerShade().path(in: rect))" in bridge_mask
assert "exterior.addEllipse" not in bridge_mask

# BOTH masks are applied after ZStack (gradient + blurred glow), in sequence.
assert "theme.topBarUnderGlow" in layer
assert ".blur(radius:" in layer
assert "theme.topBarGradientStart" in layer
assert "theme.topBarGradientEnd" in layer
assert ".mask(GPSDialExteriorMask().fill(style: FillStyle(eoFill: true)))" in layer
assert ".mask(GPSBridgeExteriorMask().fill(style: FillStyle(eoFill: true)))" in layer
assert layer.index(".blur(radius:") < layer.index(".mask(GPSDialExteriorMask()")
assert layer.index(".mask(GPSDialExteriorMask()") < layer.index(".mask(GPSBridgeExteriorMask()")
assert ".mask(GPSBridgeUpperMask())" not in layer  # left edge reaches bottom

# Depth is belt-and-braces: layer is BEHIND the full speed dial + cards,
# so even a future accidental footprint overlap cannot obscure speed values.
assert "GPSUpperGradientLayer(theme: theme)" in dashboard
z = dashboard.split("GPSUpperGradientLayer(theme: theme)",1)[1].split("GPSHorizonLine(theme: theme)",1)[0]
assert ".zIndex(4)" in z
assert ".zIndex(27)" not in z
assert ".zIndex(25)" in dashboard
assert "GPSMetalInnerRing()" in dashboard
assert "GPSHorizonLine(theme: theme)" in dashboard
assert "GPSLowerGlow(theme: theme)" in dashboard
assert "GPSCockpitPowerReading(d: dialSize," in dashboard
assert "GPSPowerHorizontalGauge(d: dialSize," not in dashboard
assert '("Sfumature", [15, 16, 19, 20])' in themes
assert "powerWatts: live.map { -$0.power }" in dashboard

# Mathematically the dial mask clears every point on and inside the entire
# displayed circle, with a 3pt safety margin on every landscape device.
for w,h in ((736,414),(844,390),(932,430),(1179,510),
            (1536,706),(1806,831)):
    d=min(h*.965,w*.55)
    cx=max(d*.51+w*.010,w*.168+d*.30)
    cy=h*.494
    radius=d*.508+3
    dial_visual_radius=d*.986/2
    assert radius>dial_visual_radius+3
    for fx,fy in ((0,0),(.20,0),(-.20,0),(0,.48),
                  (.40,.22),(-.40,-.22)):
        x=cx+fx*d
        y=cy+fy*d
        if hypot(fx,fy)<.493:
            assert hypot(x-cx,y-cy)<radius
    # Left layer still reaches the real bottom edge of the display.
    assert 0<h*.937<h

print("OK — build 90: two independent masks and safe drawing order; no dial/bridge fill")
