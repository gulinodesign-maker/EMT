"""Build 134: +50% card chamfer; AZZERA lowered to bottom between dials."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
code = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
shape = code.split("private struct GPSInclinationCardShape: Shape {", 1)[1].split(
    "private struct GPSInclinationPanel: View {", 1)[0]
panel = code.split("private struct GPSInclinationPanel: View {", 1)[1]
dash = code.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1)[0]

assert project.count("CURRENT_PROJECT_VERSION = 134;") == 2
assert "let previousRun = min(min(42, max(16, w * 0.10))" in shape
assert "min(w * 0.20, h * 0.20 / slope)" in shape
assert "let run = previousRun * 1.50" in shape
assert "let rise = run * slope" in shape
assert "path.move(to: CGPoint(x: run, y: 0))" in shape
assert "path.addLine(to: CGPoint(x: 0, y: rise))" in shape
assert "topBarCorners.rightContact.y - topBarCorners.rightKnee.y" in dash
assert "topBarCorners.rightKnee.x - topBarCorners.rightContact.x" in dash
assert "theme: theme, topLeftSlope: inclinationCardSlope" in dash
assert "GPSInclinationCardShape(topLeftSlope: topLeftSlope)" in panel
assert "let enlargedDial = baseDial * 1.20" in panel
assert "HStack(alignment: .top, spacing: dialGap)" in panel
assert '.frame(width: resetWidth, height: dial, alignment: .bottom)' in panel
assert '.frame(width: resetWidth, height: dial, alignment: .center)' not in panel
assert "Spacer(minLength: 0)" in panel
assert panel.index('dialView(label: "ROLLIO"') < panel.index("motion.zeroInclination()")
assert panel.index("motion.zeroInclination()") < panel.index('dialView(label: "BECCHEGGIO"')
assert '.accessibilityLabel("Azzera inclinometro: fermarsi in piano")' in panel
assert ".position(x: w / 2, y: dialGroupCenterY)" in panel
assert "let dialGroupCenterY = h / 2 + (valueGap + valueHeight) / 2" in panel
assert 'Text("ROLLIO")' not in panel and 'Text("BECCHEGGIO")' not in panel

# Exactly +50% on every supported landscape layout; slope is unchanged.
for screen_w, screen_h in [(736, 414), (844, 390), (932, 430),
                            (1179, 510), (1536, 706), (1806, 831)]:
    slope = (screen_h * (0.244 - 0.099)) / (screen_w * (0.54 - 0.45))
    w, h = screen_w * .34, screen_h * .62
    previous = min(min(42, max(16, w * .10)), min(w * .20, h * .20 / slope))
    run = previous * 1.5
    rise = run * slope
    assert previous > 0 and run > previous
    assert abs(run / previous - 1.5) < 1e-9
    assert abs(rise / run - slope) < 1e-9
    assert run <= w * .30 + 1e-8 and rise <= h * .30 + 1e-8

    inset = max(4, w * .012)
    gap = max(4, w * .010)
    reset_w = max(40, min(46, w * .145))
    reset_h = max(34, min(40, h * .15))
    base = max(48, min((w - 42) * .46, h * .48))
    target = base * 1.2
    value_h = max(18, min(29, h * .095))
    diameter = max(1, min(target,
        (w - 2 * inset - 2 * gap - reset_w) / 2,
        min(h * .70, h - 2 * max(4, h * .014)
            - value_h - max(3, target * .020))))
    assert 2 * diameter + 2 * gap + reset_w + 2 * inset <= w + 1e-8
    assert diameter >= reset_h, (screen_w, screen_h)
    # Button's vertical centre is LOWER than the circles' centre.
    assert (diameter - reset_h) / 2 > 0

print("OK — build134: +50% same slope; AZZERA bottom-centred without dial overlap")
