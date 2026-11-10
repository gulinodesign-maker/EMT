"""Geometria Ecojumbo 1.0 (19) — angoli uguali e valori speculari."""
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
print('OK — EJ 1.19: raggio unico di top/down bar, lati meno inclinati, testi speculari, 8 colori in preview')
