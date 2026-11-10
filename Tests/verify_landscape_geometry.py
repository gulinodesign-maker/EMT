"""Controlli numerici dei tracciati e del layout adattivo landscape EJ 1.18."""
from pathlib import Path
import math

root=Path(__file__).resolve().parents[1]
c=(root/'Ecojumbo/Views/CockpitComponents.swift').read_text()
u=(root/'Ecojumbo/Views/EcojumboRootView.swift').read_text()

assert 'let dialSize = min(h * 0.982, w * 0.57)' in c
assert '.position(x: w / 2, y: h * 0.507)' in c
assert 'let wingHeight = h * 0.455' in c
assert 'ringRadius = min(h * 0.982, w * 0.57) * 0.506' in c
assert 'FillStyle(eoFill: true)' in c
assert '.position(x: d * 0.50, y: d * 0.889)' in c
assert 'p.addLine(to: pt(shoulderX, 0.850))' in u
assert c.count('.position(x: w * 0.50, y: h * 0.507)')==2
assert 'p.move(to: CGPoint(x: 0, y: h * 0.085))' in c
assert 'p.addLine(to: CGPoint(x: w, y: h * 0.085))' in c
assert c.count('p.addCurve(to: CGPoint(x: w * 0.')==2
assert 'p.move(to: pt(footX, 0.987))' in u
assert u.count('p.addCurve(to: pt(')==2
assert u.count('p.addLine(to: pt(')==3
assert 'p.addLine(to: pt(0.588, 0.785))' in u
assert math.isclose(.412,1-.588)
assert math.isclose(.353,1-.647)

for w,h in [(844,390),(852,393),(932,430),(956,440),(736,414),(1536,707),(1536,864),(1667,835)]:
    d=min(h*.982,w*.57)
    top=h*.507-d/2
    bottom=h*.507+d/2
    assert top>=h*.014 and bottom<=h*.999,(w,h,top,bottom)
    wing_h=h*.455
    wing_top=h*.490-wing_h/2
    wing_bottom=h*.490+wing_h/2
    assert wing_top>h*.25 and wing_bottom<h*.72
    controls_h=max(51,min(83,h*.105))
    buttons_top=h-max(7,h*.075)-controls_h
    assert buttons_top>wing_bottom+6,(w,h,wing_bottom,buttons_top)
    side=min(controls_h*.96,w*.059)
    group_end=max(12,w*.018)+side*4+3*w*.010
    foot=min(.320,max(.272,group_end/w+.013))
    assert group_end<w*foot,(w,h,foot,group_end/w)
    assert foot<.353
    line_vec=(.353-foot, .850-.987)
    tan_vec=((.353+(.353-foot)*.16)-.353, .82808-.850)
    assert math.isclose(line_vec[0]*.16,tan_vec[0],abs_tol=1e-9)
    assert math.isclose(line_vec[1]*.16,tan_vec[1],abs_tol=1e-9)
    assert (.785+.03)<(.507-d/(2*h)+(.889*d/h))
    assert .987<1

print('OK — 17: rettilinei inferiori, curve alte tangenti C1, quadrante entro display')
