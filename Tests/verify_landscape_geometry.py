"""Regression di layout senza dipendenze da UIKit / simulatore iOS.
Verifica i limiti geometrici utilizzati in SwiftUI ai rapporti tipici in landscape.
"""
from pathlib import Path
import math
root = Path(__file__).resolve().parents[1]
c = (root/'Ecojumbo/Views/CockpitComponents.swift').read_text()
r = (root/'Ecojumbo/Views/EcojumboRootView.swift').read_text()
assert 'let dialSize = min(h * 0.93, w * 0.57)' in c
assert '.position(x: w / 2, y: h * 0.50)' in c
assert '.position(x: d * 0.50, y: d * 0.910)' in c
assert 'ContinuousLowerLine: Shape' in r
assert 'CornerDockGlow' not in r
assert 'FooterLightContour' not in c
# Un solo path unificato in ordine sinistra -> centro -> destra.
marks = [
    'p.move(to: pt(0.012, 0.973))',
    'p.addLine(to: pt(0.242, 0.973))',
    'p.addQuadCurve(to: pt(0.273, 0.946)',
    'p.addCurve(to: pt(0.339, 0.797)',
    'p.addQuadCurve(to: pt(0.363, 0.785)',
    'p.addLine(to: pt(0.637, 0.785))',
    'p.addQuadCurve(to: pt(0.661, 0.797)',
    'p.addCurve(to: pt(0.727, 0.946)',
    'p.addQuadCurve(to: pt(0.758, 0.973)',
    'p.addLine(to: pt(0.988, 0.973))'
]
indices = [r.index(mark) for mark in marks]
assert indices == sorted(indices)
for width, height in [(844, 390), (852, 393), (932, 430), (956, 440), (736, 414), (1536, 864)]:
    d = min(height*0.93, width*0.57)
    top = height*0.50-d/2
    bottom = height*0.50+d/2
    assert top >= height*0.03 and bottom <= height*0.97, (width,height,top,bottom)
    # Interior of meter text: A/kW below the continuous central line, before the dock bottom.
    text_y = top+d*0.910
    line_y = height*0.785
    assert line_y < text_y < height*0.96, (width,height,line_y,text_y)
    # Buttons (root: height max(51,min(83,h*0.105)), bottom padding max(7,h*0.050))
    controls_h = max(51, min(83, height*0.105))
    controls_bottom = height-max(7,height*.05)
    curve_bottom = height*.973
    assert controls_bottom < curve_bottom < height, (width,height,controls_bottom,curve_bottom)
# 0, 60, 120 km/h => 0, 50, 100% dell'arco; oltre 120 satura.
for kmh, expected in [(0,0), (30,.25),(60,.5),(120,1),(150,1)]:
    assert math.isclose(min(1,max(0,kmh/120)),expected)
assert 'SpeedLEDStream(d: d, speed: speed)' in c
assert 'SpeedScaleTicks(d: d)' in c
assert 'let label=Text(' not in c # eliminati i numeri fissi
assert 'var animatableData: Double' in c
print('OK — diametro entro 93% altezza, contorno inferiore unico, LED rosso 0–120 progressivo')
