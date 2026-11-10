"""EJ 1.16: regressione top bar, profilo aperto, cornice del quadrante."""
from pathlib import Path
import math
root=Path(__file__).resolve().parents[1]
c=(root/'Ecojumbo/Views/CockpitComponents.swift').read_text()
r=(root/'Ecojumbo/Views/EcojumboRootView.swift').read_text()
assert 'let dialSize = min(h * 0.970, w * 0.57)' in c
assert '.position(x: w / 2, y: h * 0.505)' in c
assert c.count('.position(x: w * 0.50, y: h * 0.505)') == 2
assert 'let y = h * 0.73' in c
assert 'ContinuousHorizonLine: View' in c
assert 'ContinuousHorizonLine(theme: theme)' in c
assert 'SplitHorizonLine' not in c
assert 'p.move(to: CGPoint(x: 0, y: y))' in c
assert 'p.addLine(to: CGPoint(x: w, y: y))' in c
assert 'ContinuousLowerLine: Shape' in r
assert 'CornerDockGlow' not in r
assert 'FooterLightContour' not in c
assert r.count('p.move(to: pt(')==1
assert r.count('p.addLine(to: pt(')==1
assert r.count('p.addCurve(to: pt(')==2
points=[
 'p.move(to: pt(footX, 0.987))',
 'p.addCurve(to: pt(0.365, 0.805)',
 'control1: pt(footX + 0.012, 0.957), control2: pt(0.342, 0.805)',
 'p.addLine(to: pt(0.635, 0.805))',
 'p.addCurve(to: pt(1 - footX, 0.987)',
 'control1: pt(0.658, 0.805), control2: pt(1 - footX - 0.012, 0.957)'
]
assert [r.index(x) for x in points]==sorted(r.index(x) for x in points)
assert 'p.addLine(to: pt(0.988' not in r
assert 'p.addLine(to: pt(0.234' not in r
assert 'p.move(to: pt(0.012' not in r
assert '.padding(.bottom, max(7, geometry.size.height * 0.075))' in r
assert 'let footX = min(CGFloat(0.343), max(CGFloat(0.266), groupEnd / w + 0.014))' in r
for w,h in [(844,390),(852,393),(932,430),(956,440),(736,414),(1536,707),(1536,864),(1667,835)]:
 d=min(h*.970,w*.57)
 top=h*.505-d/2
 bottom=h*.505+d/2
 assert top>=h*.019 and bottom<=h*.991,(w,h,top,bottom)
 controls_height=max(51,min(83,h*.105))
 button_side=min(controls_height*.96,w*.059)
 button_gap=w*.010
 button_margin=max(12,w*.018)
 group_end=button_margin+4*button_side+3*button_gap
 foot_x=min(.343,max(.266,group_end/w+.014))
 assert group_end < w*foot_x,(w,h,group_end,foot_x)
 assert w*(1-foot_x) < w-group_end
 assert foot_x < .365
 footer_y=top+d*.900
 footer_top=footer_y-d*.065
 assert footer_top>h*.805+5
 assert h*.987<h
 assert math.isclose((.73-.67)*h*.125,h*.0075)
assert 'SpeedLEDStream(d: d, speed: speed)' in c
assert 'SpeedScaleTicks(d: d)' in c
print('OK — EJ 1.16: tachimetro entro display, top bar ribassata, profilo centrale aperto senza binari sotto i tasti')
