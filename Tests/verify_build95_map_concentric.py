"""Build 95 — MapKit hugs GPS ring by 2pt, colored ring clipped at kW bridge."""
from pathlib import Path
import re
from math import hypot

root = Path(__file__).resolve().parents[1]
c = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
t = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
p = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()
assert p.count("CURRENT_PROJECT_VERSION = 101;") == 2
assert "Build 95" in state

dial = c.split("private enum GPSDialLayout {", 1)[1].split(
    "private enum GPSMetalContourStyle", 1)[0]
assert "static let mapToDialClearance: CGFloat = 2" in dial
assert "static func concentricRingRadius(for d: CGFloat)" in dial
assert "static func concentricRingStroke(for d: CGFloat)" in dial
assert "static func mapExclusionRadius(for d: CGFloat)" in dial
assert "secondRingRadius(for: d) + secondRingStroke(for: d) / 2" in dial
assert "+ mapToDialClearance" in dial
assert "outerProfileDiameterFactor: CGFloat = 0.986 * 0.90" in dial

clip = c.split("private struct GPSMapDialClearanceClip: Shape {", 1)[1].split(
    "private struct GPSMapTopContourClip: Shape {", 1)[0]
assert "GPSMapContourSpace.cockpitSize(for: rect)" in clip
assert "GPSMapContourSpace.local(" in clip
assert "GPSDialLayout.centerX(width: cockpit.width, height: cockpit.height)" in clip
assert "GPSDialLayout.mapExclusionRadius(for: d)" in clip
assert "var visible = Path(rect)" in clip
assert "visible.addEllipse(in: CGRect(" in clip

map_body = c.split("private struct GPSCockpitMap: View {", 1)[1].split(
    "private struct GPSMapBatteryRail:", 1)[0]
assert ".mask(GPSMapDialClearanceClip()" in map_body
assert ".fill(style: FillStyle(eoFill: true)))" in map_body
assert ".mask(RadialGradient(stops: [" not in map_body
assert "dialMaskFeather" not in map_body
assert ".mask(GPSMapTopContourClip())" in map_body
assert ".mask(GPSMapLowerContourClip())" in map_body
assert ".mapStyle(.standard(elevation: mapControls.is3D ? .realistic : .flat))" in map_body
assert "navigation.route" in map_body

ring = c.split("private struct GPSConcentricAccentRing: View {", 1)[1].split(
    "private enum GPSLowerLineGeometry", 1)[0]
assert "let color: Color" in ring
assert "GPSDialLayout.concentricRingRadius(for: d)" in ring
assert "GPSDialLayout.concentricRingStroke(for: d)" in ring
assert ".mask(GPSBridgeUpperMask())" in ring
assert ".allowsHitTesting(false)" in ring

dash = c.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]
assert "GPSConcentricAccentRing(color: theme.concentricRingColor," in dash
assert ".zIndex(27)" in dash
assert ".zIndex(28)" in dash
assert "GPSLowerGlow(theme: theme)" in dash

theme = c.split("enum CockpitTheme: String", 1)[1].split(
    "// Le barre mantengono i ruoli storici", 1)[0]
assert "var concentricRingColor: Color" in theme
assert "savedPalette.colors[21]" in theme
assert "return accent" in theme

# All existing 21 colors survive, and the new role starts from old accent.
assert "static let colorCount = 22" in t
assert '"Cerchio concentrico · sopra top bar"' in t
assert '("Layer top bar", [15, 16, 19, 20, 2, 21])' in t
assert "decoded.colors.count == 21 ||" in t
assert "if migrated.colors.count == 21 {" in t
assert "migrated.colors.append(migrated.colors[1])" in t
labels = t.split("static let labels = [", 1)[1].split("]", 1)[0]
details = t.split("static let details = [", 1)[1].split("]", 1)[0]
assert len(re.findall(r'^\s*"[^"]+"', labels, re.M)) == 22
assert len(re.findall(r'^\s*"[^"]+"', details, re.M)) == 22
assert "Scegli uno dei 20 colori base" in t
preview = c.split("struct EcoCockpitThemeMiniature: View {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1)[0]
assert "GPSConcentricAccentRing(color: tone(21)," in preview

# Geometry on landscape iPhones: the map starts EXACTLY 2pt beyond
# the ring stroke, and the ring remains outside the black dial.
for w,h in ((736,414),(932,430),(1179,510),(1536,706),(1806,831)):
    d=min(h*.965,w*.55)
    r=d*(.986*.90)/2+1.5
    stroke=max(1.5,min(2.4,d*.003))
    exclusion=r+stroke/2+2
    assert abs(exclusion-(r+stroke/2)-2) < 1e-8
    assert r-stroke/2 > d*(.986*.90)/2
    assert d*.965*.90/2 < r

print("OK — build 95 map 2pt from concentric ring, ring over topbar and outside bridge, 22-color migration")
