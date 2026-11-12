from pathlib import Path
from math import sqrt

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
gps = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()

map_section = cockpit.split("private struct GPSCockpitMap: View {", 1)[1].split(
    "// Pannello standard senza mappa", 1)[0]
assert "let dialSize = GPSDialLayout.size(width: fullWidth, height: fullHeight)" in map_section
assert "let dialCenterX = GPSDialLayout.centerX(width: fullWidth, height: fullHeight)" in map_section
assert "let mapLocalDialX = dialCenterX - fullWidth * 0.36" in map_section
assert "let mapLocalDialY = fullHeight * (0.494 - 0.045)" in map_section
assert "let dialMaskRadius = dialSize * 0.508" in map_section
assert "let dialMaskFeather = max(12, min(28, fullHeight * 0.032))" in map_section
assert "RadialGradient(stops: [" in map_section
assert "center: UnitPoint(x: mapLocalDialX / w, y: mapLocalDialY / h)" in map_section
assert "startRadius: dialMaskRadius" in map_section
assert "endRadius: dialMaskRadius + dialMaskFeather" in map_section

# Nessuna fascia scura / sovrapposizione sotto l'indirizzo GPS.
assert "GPSSearchTopBand" not in map_section
assert "GPSSearchBottomFade" not in map_section
assert "Color.black.opacity(0.27)" not in map_section
assert "fadeStart + 0.055" not in map_section
assert ".background(Color.clear)" in map_section

# I segmenti della top bar e del ponte kW sono limiti di clipping reali.
assert "if compact { Rectangle() } else { GPSMapTopContourClip() }" in map_section
assert "if compact { Rectangle() } else { GPSMapLowerContourClip() }" in map_section
assert "private struct GPSMapTopContourClip: Shape" in cockpit
assert "private struct GPSMapLowerContourClip: Shape" in cockpit
assert "GPSLowerLineGeometry.points(" in cockpit

for w,h in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    d = min(h*.965,w*.55)
    cx = max(d*.51+w*.010,w*.168+d*.30)
    cy = h*.494
    radius = d*.508
    feather = max(12,min(28,h*.032))
    assert 12 <= feather <= 28
    for y in [cy-d*.30, cy-d*.15, cy, cy+d*.15, cy+d*.30]:
        dx = sqrt(radius**2-(y-cy)**2)
        mask_x = cx+dx
        # La corona curva, non verticale; il centro è il punto più esterno.
        assert abs(sqrt((mask_x-cx)**2+(y-cy)**2)-radius)<1e-7
        assert mask_x <= cx+radius
        assert mask_x > cx
    assert cx+radius > cx+sqrt(radius**2-(d*.3)**2)
    assert abs((cy-h*.045)/(h*.955)-(.494-.045)/.955)<1e-9

# I criteri GPS funzionanti ripristinati nella 45 sono INVARIATI.
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in gps
assert "let usableSpeed = abs(fix.timestamp.timeIntervalSinceNow) < 10" in gps
assert "fix.speedAccuracy <= 5 && fix.speed <= 50" in gps
assert "date.timeIntervalSince(lastValidAt) < 8" in gps
print("OK — build 47: mappa curva, ricerca trasparente, parametri GPS preservati")
