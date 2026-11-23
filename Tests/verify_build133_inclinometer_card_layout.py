"""Build 133: card chamfer follows top bar; two ring centres align vertically."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
code = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
dashboard = code.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1
)[0]
shape = code.split("private struct GPSInclinationCardShape: Shape {", 1)[1].split(
    "private struct GPSInclinationPanel: View {", 1
)[0]
panel = code.split("private struct GPSInclinationPanel: View {", 1)[1]

assert project.count("CURRENT_PROJECT_VERSION = 135;") == 2
assert "let topBarCorners = GPSHorizonSymmetry.corners(width: w, height: h)" in dashboard
assert "topBarCorners.rightContact.y - topBarCorners.rightKnee.y" in dashboard
assert "topBarCorners.rightKnee.x - topBarCorners.rightContact.x" in dashboard
assert "theme: theme, topLeftSlope: inclinationCardSlope" in dashboard
assert "GPSInclinationPanel(theme: theme)" not in dashboard
assert "let rise = run * slope" in shape
assert "let previousRun = min(min(42, max(16, w * 0.10))" in shape
assert "let run = previousRun * 1.50" in shape
assert "path.move(to: CGPoint(x: run, y: 0))" in shape
assert "path.addLine(to: CGPoint(x: 0, y: rise))" in shape
assert "path.closeSubpath()" in shape
assert "GPSInclinationCardShape(topLeftSlope: topLeftSlope)" in panel
assert panel.count("shape.fill(") == 3
assert "shape.stroke(theme.inclinometerRingColor.opacity(0.35)" in panel

assert "let enlargedDial = baseDial * 1.20" in panel
assert "let dialWidthLimit = (w - 2 * horizontalInset - 2 * dialGap - resetWidth) / 2" in panel
assert "let dialGroupCenterY = h / 2 + (valueGap + valueHeight) / 2" in panel
assert "HStack(alignment: .top, spacing: dialGap)" in panel
left = panel.index('dialView(label: compassGForce ? "BUSSOLA" : "ROLLIO"')
button = panel.index("motion.zeroInclination()")
right = panel.index('dialView(label: compassGForce ? "FORZA G" : "BECCHEGGIO"')
assert left < button < right
assert ".frame(width: resetWidth, height: dial, alignment: .bottom)" in panel
assert "Spacer(minLength: 0)" in panel
assert ".position(x: w / 2, y: dialGroupCenterY)" in panel
assert ".frame(height: valueHeight)" in panel
assert 'Text("AZZERA")' in panel
assert 'Image(systemName: "scope")' in panel
assert 'Azzera inclinometro: fermarsi in piano' in panel
assert 'Label("AZZERA", systemImage: "scope")' not in panel
assert 'Text("ROLLIO")' not in panel
assert 'Text("BECCHEGGIO")' not in panel
assert "motion.setInclinationActive(true)" in panel
assert "motion.setInclinationActive(false)" in panel

# The global bar vector and the card chamfer have identical slopes.
for full_width, full_height in [(736, 414), (844, 390), (932, 430),
                                (1179, 510), (1536, 706), (1806, 831)]:
    contact = (full_width * 0.45, full_height * 0.244)
    knee = (full_width * 0.54, full_height * 0.099)
    slope = (contact[1] - knee[1]) / (knee[0] - contact[0])
    # Check safe layouts independent of panel's absolute screen position.
    w, h = full_width * 0.34, full_height * 0.62
    run = min(min(42, max(16, w * 0.10)), min(w * 0.20, h * 0.20 / slope))
    rise = run * slope
    assert run > 0 and 0 < rise <= h * 0.20 + 1e-8
    assert abs(rise / run - slope) < 1e-9

    inset = max(4, w * 0.012)
    v_inset = max(4, h * 0.014)
    gap = max(4, w * 0.010)
    reset_w = max(40, min(46, w * 0.145))
    target = max(48, min((w - 42) * 0.46, h * 0.48)) * 1.2
    value_h = max(18, min(29, h * 0.095))
    limit_w = (w - 2 * inset - 2 * gap - reset_w) / 2
    limit_h = min(h * 0.70, h - 2 * v_inset - value_h
                  - max(3, target * 0.020))
    diameter = max(1, min(target, limit_w, limit_h))
    assert diameter > 0
    assert 2 * diameter + 2 * gap + reset_w + 2 * inset <= w + 1e-8
    assert diameter + value_h + max(3, diameter * 0.020) + 2 * v_inset <= h + 1e-8
    # Positioning the full dial+degree stack this far down centres the circle itself.
    value_gap = max(3, diameter * 0.020)
    group_y = h / 2 + (value_gap + value_h) / 2
    circle_y = group_y - (value_gap + value_h) / 2
    assert abs(circle_y - h / 2) < 1e-8

print("OK — build133: card/top-bar chamfer parallel; centred rings and compact reset")
