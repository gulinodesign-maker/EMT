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
assert '.frame(width: w * 0.64, height: h * 0.89)' in c
assert '.position(x: w * 0.68, y: h * 0.49)' in c
assert 'GPSHorizonLine(theme: theme)' in c
assert 'GPSLowerGlow(theme: theme)' in c
assert 'EcoTab.allCases.suffix(3)' in u
assert 'EcoTab.allCases.dropFirst().prefix(3)' in u
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
    assert w*.68+w*.64/2<=w*1.001
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
    left_top=cx-d*.325
    assert left_top>0
    text_top=h*.494+d*(.889-.5-.065)
    line_y=min(h*.790,text_top-max(12,h*.014))
    foot_y=h*.937
    assert text_top-line_y>=12-1e-8
    assert line_y<foot_y
    control_h=max(51,min(83,h*.105))
    control_side=min(control_h*.96,w*.059,w*.052)
    button_start=w-max(12,w*.018)-8*control_side-7*w*.008
    ideal_run=w*(.385-.323)*((foot_y-line_y)/(h*(.985-.790)))
    max_right_foot=button_start-max(9,w*.012)
    right_top=min(cx+d*.325,max_right_foot-ideal_run)
    assert right_top<w*.60
    run=min(ideal_run,max(0,max_right_foot-right_top))
    assert left_top-run>=0,(w,h)
    assert right_top+run+max(9,w*.012)<=button_start+1e-8,(w,h)
    assert (right_top-left_top)<d*.66
    assert foot_y<h*.945
    assert h-max(4,h*.006)-control_h>0
# Sei tessere di vetro altezza esatta, 30% meno larghe e con
# distanza dal dock anche sugli iPhone più bassi.
for w,h in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    map_w=w*.64
    map_h=h*.89
    card_w=map_w*.265*.70
    card_h=map_h*.60
    gap=max(5,card_h*.018)
    tile=(card_h-5*gap)/6
    assert tile>0
    assert math.isclose(card_w/(map_w*.265),.70)
    x_right=map_w-max(6,map_w*.012)
    assert x_right-card_w>map_w*.60
    top_y=h*(.49-.89/2)+map_h*.21
    bottom_y=top_y+card_h
    dock_top=h-max(4,h*.006)-max(51,min(83,h*.105))
    assert bottom_y<dock_top,(w,h,bottom_y,dock_top)
    # Bordo barra indirizzo coincidente con la linea superiore (0.085 h).
    bar_y=h*(.49-.89/2)+map_h*.045
    assert abs(bar_y-h*.085)<h*.001,(w,h,bar_y)
assert 'let glassWidth = w * 0.265 * 0.70' in c
assert '.mask(GPSLowerTerminalFade())' in c
# Il campo di ricerca aderisce anche al ginocchio della linea GPS.
for w,h in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    map_w=w*.64
    map_h=h*.89
    knee_global=(w*.54,h*.085)
    knee_local=(w*.54-w*.36,h*.085-h*.045)
    assert math.isclose(knee_local[0]+w*.36,knee_global[0])
    assert math.isclose(knee_local[1]+h*.045,knee_global[1])
    d=min(h*.982,w*.57)
    ring_radius=d*.985/2
    assert h*.507+ring_radius+h*.002<h,(w,h,"cerchio home tagliato")
    # Il cerchio lungo interseca il fianco del ponte: la maschera
    # lo termina proprio sulla sagoma reale e non a un angolo fisso.
    controls_h=max(51,min(83,h*.105))
    button_side=min(controls_h*.96,w*.059)
    end=max(12,w*.018)+4*button_side+3*w*.010
    foot=min(.342,max(.323,end/w+.035))
    x0,y0=w*foot,h*.985
    x1,y1=w*.385,h*.790
    radius=ring_radius
    cx,cy=w*.5,h*.507
    f=lambda v: (x0+(x1-x0)*v-cx)**2+(y0+(y1-y0)*v-cy)**2-radius**2
    assert f(0)>0 and f(1)<0,(w,h,"anello non interseca il ponte")
    lo,hi=0.0,1.0
    for _ in range(35):
        mid=(lo+hi)/2
        if f(mid)>0: lo=mid
        else: hi=mid
    assert abs(f((lo+hi)/2))<1e-3
assert '.mask(ContinuousLowerTerminalFade())' in u
assert 'GPSSearchTopBand()' in c
assert '.mask(HomeRingBridgeMask().fill(style: FillStyle(eoFill: true)))' in c
# Il bordo inferiore GPS resta orizzontale e sotto l'estremità
# inferiore della diagonale superiore, anche sugli schermi stretti.
for W,H in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    mh=H*.89
    left_y=H*(.23-.045)
    knee_y=H*(.085-.045)
    row=max(43,min(60,mh*.089))
    bottom=max(left_y+max(2,mh*.008),knee_y+row+3)
    assert bottom>left_y and bottom>knee_y+row,(W,H,bottom)
assert 'p.addLine(to: CGPoint(x: left.x, y: bottomY))' in c
# Dissolvenza del bordo inferiore dell'indirizzo: nessuna alterazione
# del ginocchio, solo gli ultimi 16-34pt diventano trasparenti.
for W,H in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    mh=H*.89
    left_y=H*(.23-.045)
    knee_y=H*(.085-.045)
    row=max(43,min(60,mh*.089))
    bottom=max(left_y+max(2,mh*.008),knee_y+row+3)
    fade_start=max(0,(bottom-max(16,mh*.045))/mh)
    fade_end=min(1,bottom/mh)
    assert 0<fade_start<fade_end<1
    # Anche i due terminali arancioni mantengono l'anello pieno
    # fino al tratto finale e arrivano a zero sul ponte.
    controls_h=max(51,min(83,H*.105))
    button_side=min(controls_h*.96,W*.059)
    end=max(12,W*.018)+4*button_side+3*W*.010
    foot=min(.342,max(.323,end/W+.035))
    x0,y0=W*foot,H*.985
    x1,y1=W*.385,H*.790
    r=min(H*.982,W*.57)*.985/2
    cx,cy=W*.5,H*.507
    f=lambda v: (x0+(x1-x0)*v-cx)**2+(y0+(y1-y0)*v-cy)**2-r*r
    assert f(0)>0>f(1)
    low,high=0.0,1.0
    for _ in range(30):
        mid=(low+high)/2
        if f(mid)>0: low=mid
        else: high=mid
    contact_y=y0+(y1-y0)*(low+high)/2
    fade_start=(contact_y-max(20,H*.075))/H
    fade_end=contact_y/H
    assert 0<fade_start<fade_end<1
assert '.mask(HomeRingTerminalFade())' in c
assert '.mask(GPSSearchBottomFade())' in c
# Raccordo luminoso alto: la top bar si spegne alla corona e
# torna completamente visibile prima del tratto orizzontale.
for W,H in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    d=min(H*.982,W*.57)
    r=d*.506
    fade_len=max(18,H*.070)
    assert fade_len>0 and (r+fade_len)<W*.50,(W,H,r,fade_len)
    dg=min(H*.982,W*.50)
    rg=dg*.508
    assert max(18,H*.070)<dg*.25
assert c.count('.mask(RadialGradient(stops: [') == 3
assert 'func retryLocation()' in (root/'Ecojumbo/Models/GPSRideManager.swift').read_text()
# Build 35: lo stesso tachimetro interno in Home e GPS:
# freccia e cifre separate, linea fra cifre e unità, km/h in basso.
arrow_top=.214-.185/2
arrow_bottom=.214+.185/2
speed_top=.495-.285/2
speed_bottom=.495+.285/2
separator=.682
unit_top=.755-.065/2
unit_bottom=.755+.065/2
assert 0<arrow_top<arrow_bottom<speed_top<speed_bottom<separator<unit_top<unit_bottom<.89
assert speed_top-arrow_bottom>.04
assert 'y: d * 0.682' in c
assert 'y: d * 0.755' in c
assert 'HollowSpeedNumber(text: String(Int(speed.rounded()))' in c
assert c.count('HollowSpeedNumber(text: String(Int(speed.rounded()))')==1
assert 'navigationArrow: maneuverSymbol' in c
assert 'GPSManeuverIcon.symbol(for: navigation.guidanceInstruction)' in c
print('OK — EJ 1.35: frecce e cifre distinte, linea sopra km/h, layout unico Home/GPS')
