"""Regression build 48: prevent map bleed across cockpit orange contours."""
from pathlib import Path
from math import sqrt

root = Path(__file__).resolve().parents[1]
c = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
g = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
map_source = c.split("private struct GPSCockpitMap: View {", 1)[1].split(
    "// Pannello standard senza mappa", 1)[0]

assert "private struct GPSMapTopContourClip: Shape" in c
assert "private struct GPSMapLowerContourClip: Shape" in c
assert "private enum GPSMapContourSpace" in c
assert "GPSMapContourSpace.local(" in c
assert "CockpitContourGeometry.cornerRadius(in: cockpit)" in c
assert "GPSLowerLineGeometry.points(" in c
assert "path.addArc(tangent1End: elbow, tangent2End: start, radius: corner)" in c
assert "path.addArc(tangent1End: safeTopRight, tangent2End: safeTopLeft," in c
assert ".mask(GPSMapTopContourClip())" in map_source
assert ".mask(GPSMapLowerContourClip())" in map_source
assert ".mask(RadialGradient(stops: [" in map_source  # circular fade remains
assert "GPSMapTopContourClip()" not in c.split("private struct GPSCockpitMap: View {")[0]

# Exact conversion: global cockpit pixel coordinates -> local MapKit frame.
for w, h in [(736, 414), (844, 390), (932, 430), (956, 440),
             (1536, 706), (1806, 831)]:
    map_w, map_h = w * 0.64, h * 0.955
    map_x, map_y = w * 0.36, h * 0.045
    clearance = max(2, h * 0.003)
    # Upper right connector: map must be absent ABOVE its slanted edge,
    # not merely above the old horizontal 9.9% mask.
    x1, y1 = w * 0.45, h * 0.244 + clearance
    x2, y2 = w * 0.54, h * 0.099 + clearance
    x_mid = (x1 + x2) / 2
    y_edge = y1 + (y2 - y1) * ((x_mid - x1) / (x2 - x1))
    assert y_edge > h * 0.099
    assert h * 0.099 + 0.01 * h < y_edge
    assert 0 <= (x_mid - map_x) <= map_w
    assert 0 <= (y_edge - map_y) <= map_h

    # At the lower kW bridge, the route is kept to the RIGHT of the
    # actual right-hand descending segment, never in the bottom triangle.
    d = min(h * 0.965, w * 0.55)
    cx = max(d * 0.51 + w * 0.010, w * 0.168 + d * 0.30)
    top_y = min(h * 0.790, h * 0.494 + d * (0.889 - 0.50 - 0.065)
                - max(12, h * 0.014))
    foot_y = h * 0.937
    top_half = d * 0.325
    control_height = max(51, min(83, h * 0.105))
    side = min(control_height * 0.96, w * 0.059, w * 0.052)
    button_start = w - max(12, w * 0.018) - 8 * side - 7 * w * 0.008
    ideal_run = w * (0.385 - 0.323) * (
        (foot_y - top_y) / (h * (0.985 - 0.790)))
    right_top_x = min(cx + top_half,
                      button_start - max(9, w * 0.012) - ideal_run)
    run = min(ideal_run, max(0, button_start - max(9, w * 0.012)
                             - right_top_x))
    foot_x = right_top_x + run
    mid_y = (top_y + foot_y) / 2
    edge_x = right_top_x + (foot_x - right_top_x) * (
        (mid_y - top_y) / (foot_y - top_y))
    assert foot_x > right_top_x, (w, h, foot_x, right_top_x)
    assert edge_x > right_top_x
    assert 0 <= (edge_x - map_x) <= map_w
    assert 0 <= (mid_y - map_y) <= map_h
    # The lower bleed region lies to the LEFT of the descending line.
    assert right_top_x < edge_x < foot_x

# Day: near-transparent soft veil. Dark: previous shading unchanged.
light = c.split("private struct GPSLowerGlow: View {", 1)[1].split(
    "// EJ 1.22 — modalità GPS", 1)[0]
assert "colorScheme == .light ? [" in light
assert "Color(white: 0.88).opacity(0.10)" in light
assert "Color(white: 0.92).opacity(0.035)" in light
assert ".init(color: .clear, location: 0.62)" in light
assert "Color(white: 0.42).opacity(0.36)" in light

# Zero changes to speed sensing or speed-display data flow.
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in g
assert "let usableSpeed = abs(fix.timestamp.timeIntervalSinceNow) < 10" in g
assert "fix.speedAccuracy <= 5 && fix.speed <= 50" in g
assert "date.timeIntervalSince(lastValidAt) < 8" in g
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in c
print("OK — build 48: contour-safe map, subtle daylight kW fade, GPS preserved")
