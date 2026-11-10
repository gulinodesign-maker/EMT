"""Geometria Ecojumbo 1.0 (21) — angoli uguali e valori speculari."""
from pathlib import Path
import math
root=Path(__file__).resolve().parents[1]
c=(root/'Ecojumbo/Views/CockpitComponents.swift').read_text()
u=(root/'Ecojumbo/Views/EcojumboRootView.swift').read_text()
t=(root/'Ecojumbo/Views/CockpitTabs.swift').read_text()
assert 'enum CockpitContourGeometry' in c
assert 'path.addArc(tangent1End: points[i], tangent2End: points[i + 1], radius: radius)' in c
assert 'static func cornerRadius(in size: CGSize) -> CGFloat' in c
assert 'size.height * 0.075' in c
assert 'size.width * 0.032' in c
assert 'corners: [1, 4], radius: CockpitContourGeometry.cornerRadius(in: geometry.size)' in c
assert 'corners: [1, 2], radius: CockpitContourGeometry.cornerRadius(in: rect.size)' in u
assert 'if left { Spacer(minLength: 0) }' in c
assert 'if left { icon }' in c
assert 'if !left { icon }' in c
assert '.padding(.trailing, left ? inset : width * 0.035)' in c
assert '.padding(.leading, left ? width * 0.035 : inset)' in c
assert 'var previewPalette: [Color]' in c
assert 'ForEach(theme.previewPalette.indices' in t
assert 'LazyVGrid(columns: columns, spacing: 13)' in t
assert 'count: 3' in t
assert 'let dialSize = min(h * 0.982, w * 0.57)' in c
assert 'ringRadius = min(h * 0.982, w * 0.57) * 0.506' in c
assert 'FillStyle(eoFill: true)' in c
assert u.count('struct ContinuousLowerLine: Shape')==1
assert 'p.addLine(to: pt(' not in u
for w,h in [(844,390),(852,393),(932,430),(956,440),(736,414),(1536,707),(1536,864),(1806,831)]:
    dial=min(h*.982,w*.57)
    assert h*.507-dial/2>=h*.016-1e-9
    assert h*.507+dial/2 <= h*.999
    controls_h=max(51,min(83,h*.105))
    button_side=min(controls_h*.96,w*.059)
    group_end=max(12,w*.018)+4*button_side+3*w*.010
    foot=min(.342,max(.323,group_end/w+.035))
    assert foot>group_end/w
    assert foot<.385
    # Pendenza destra e sinistra speculari, più vicina alla verticale della build 18.
    dx=(.385-foot)*w;dy=(.985-.790)*h
    old_dx=(.353-min(.320,max(.272,group_end/w+.013)))*w
    old_dy=(.987-.850)*h
    assert dx/dy < old_dx/old_dy, (w,h,dx/dy,old_dx/old_dy)
    assert math.isclose(min(h*.075,w*.032),min(h*.075,w*.032))
# Cockpit GPS: quadrante sinistro entro bordo, mappa a destra, sette pulsanti.
assert 'let dialSize = GPSDialLayout.size(width: w, height: h)' in c
assert 'return max(d * 0.51 + width * 0.010, width * 0.168 + d * 0.30)' in c
assert 'private struct GPSGaugeHalo: View' in c
assert 'LowerPanelShade()' in u
assert c.count('CockpitTopSoftShade()') == 2
assert '.position(x: dialCenterX, y: h * 0.494)' in c
assert '.frame(width: w * 0.475, height: h * 0.725)' in c
assert '.position(x: w * 0.7625, y: h * 0.455)' in c
assert 'GPSHorizonLine(theme: theme)' in c
assert 'GPSLowerGlow(theme: theme)' in c
assert 'EcoTab.allCases.suffix(3)' in u
assert 'max(4, geometry.size.height * 0.006)' in u
assert 'textTop - max(12, h * 0.014)' in c
assert 'buttonStart - max(9, w * 0.012)' in c
for w,h in [(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    d=min(h*.965,w*.55)
    cx=max(d*.51+w*.010,w*.168+d*.30)
    cy=h*.494
    assert cx-d/2>0,(w,h)
    assert cx+d/2 < w*.65,(w,h)
    assert cy-d/2>0 and cy+d/2<h
    assert w*.7625+w*.475/2<=w*1.001
    # Il bordo superiore del quadrante resta fuori dalla zona riservata all'orario.
    assert cx-d*.30 > w*.155 - 3,(w,h)
    controls_h=max(51,min(83,h*.105))
    side=min(controls_h*.96,w*.059,w*.052)
    gps_width=7*side+6*w*.008
    assert gps_width+max(12,w*.018)<w*.50,(w,h,gps_width)
# Allargamento profilo GPS, nessun testo o pulsante attraversato.
for w,h in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    d=min(h*.965,w*.55)
    cx=max(d*.51+w*.010,w*.168+d*.30)
    text_left=cx-d*.33
    text_right=cx+d*.33
    left_top=cx-d*.405
    right_top=min(cx+d*.405,w*.525-max(9,w*.012))
    assert left_top<text_left
    assert right_top>text_right,(w,h,right_top,text_right)
    text_top=h*.494+d*(.889-.5-.065)
    line_y=min(h*.790,text_top-max(12,h*.014))
    assert text_top-line_y>=12-1e-8
    control_h=max(51,min(83,h*.105))
    control_side=min(control_h*.96,w*.059,w*.052)
    button_start=w-max(12,w*.018)-7*control_side-6*w*.008
    foot_right=min(cx+d*.455,button_start-max(9,w*.012))
    assert foot_right+max(9,w*.012)<=button_start+1e-8
    assert h-max(4,h*.006)-control_h>0
print('OK — EJ 1.23: tachimetro GPS, curva A/kW allargata e dock a 4–6 punti dal bordo')
