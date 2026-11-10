"""Regressioni EJ 1.15 del cockpit in landscape, senza dipendenze iOS."""
from pathlib import Path
import math
root = Path(__file__).resolve().parents[1]
c = (root/'Ecojumbo/Views/CockpitComponents.swift').read_text()
r = (root/'Ecojumbo/Views/EcojumboRootView.swift').read_text()
assert 'let dialSize = min(h * 0.952, w * 0.57)' in c
assert '.position(x: w / 2, y: h * 0.50)' in c
assert '.position(x: d * 0.50, y: d * 0.900)' in c
assert 'ContinuousHorizonLine: View' in c
assert 'ContinuousHorizonLine(theme: theme)' in c
assert 'SplitHorizonLine' not in c
assert 'p.move(to: CGPoint(x: 0, y: y))' in c
assert 'p.addLine(to: CGPoint(x: w, y: y))' in c
assert 'ContinuousHorizonLine(theme: theme)\n                    .frame(width: w, height: headerHeight)\n                    .zIndex(2)' in c
assert 'ContinuousLowerLine: Shape' in r
assert 'CornerDockGlow' not in r
assert 'FooterLightContour' not in c
assert r.count('p.move(to: pt(') == 1
assert r.count('p.addCurve(to: pt(') == 2
marks = [
    'p.move(to: pt(0.012, 0.942))',
    'p.addLine(to: pt(0.234, 0.942))',
    'p.addCurve(to: pt(0.365, 0.805)',
    'control1: pt(0.294, 0.942), control2: pt(0.305, 0.805)',
    'p.addLine(to: pt(0.635, 0.805))',
    'p.addCurve(to: pt(0.766, 0.942)',
    'control1: pt(0.695, 0.805), control2: pt(0.706, 0.942)',
    'p.addLine(to: pt(0.988, 0.942))'
]
indices = [r.index(mark) for mark in marks]
assert indices == sorted(indices)
assert '.padding(.bottom, max(7, geometry.size.height * 0.075))' in r
# Tangenti orizzontali e simmetria: nessun micro-gradino nei raccordi.
assert math.isclose(.365-.305, .294-.234)
assert math.isclose(.766-.706, .695-.635)
assert math.isclose(.365, 1-.635)
assert math.isclose(.234, 1-.766)
for width, height in [(844,390),(852,393),(932,430),(956,440),(736,414),(1536,707),(1536,864)]:
    wing_inset = max(5, width*.006)
    assert wing_inset >= 5 and width*.390 + wing_inset < width/2
    d = min(height*.952, width*.57)
    top = height*.50-d/2
    bottom = height*.50+d/2
    assert top >= height*.02 and bottom <= height*.98
    footer_y = top+d*.900
    line_y = height*.805
    assert line_y < footer_y < height*.91
    controls_bottom = height-max(7,height*.075)
    outer_line_y = height*.942
    assert controls_bottom + 3 < outer_line_y < height
    assert height-max(7,height*.075)-max(51,min(83,height*.105)) > height*(.475+.560/2)+8
    assert (footer_y-d*.065) > line_y+3
    assert (footer_y+d*.065) < height*.95
    assert math.isclose(height*.125*.67, height*.08375)
for kmh, expected in [(0,0),(30,.25),(60,.5),(120,1),(150,1)]:
    assert math.isclose(min(1,max(0,kmh/120)),expected)
assert 'SpeedLEDStream(d: d, speed: speed)' in c
assert 'SpeedScaleTicks(d: d)' in c
assert 'var animatableData: Double' in c
print('OK — EJ 1.15: top bar ininterrotta, raccordi cubici C1 senza gradini, layout landscape')
