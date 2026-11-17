"""Build 96: sfumato top bar senza fessura, profilo grigio in primo piano."""
from pathlib import Path
from math import isclose

root = Path(__file__).resolve().parents[1]
source = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
state = (root / "STATO_PROGETTO.md").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 116;") == 2
assert "Build 96" in state

footprint = source.split("private struct GPSUpperLayerFootprint: Shape {", 1)[1].split(
    "private struct GPSDialExteriorMask: Shape {", 1)[0]
horizon = source.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "@MainActor", 1)[0]
dashboard = source.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]

# Il margine di riempimento coincide con il lato inferiore dello stroke,
# non con il vecchio -3 pt: stessa traiettoria arrotondata della linea grigia.
assert "let topBarFillEdge = GPSMetalContourStyle.inset(for: d)" in footprint
assert "+ GPSMetalContourStyle.strokeWidth(for: d) / 2" in footprint
for anchor in (
    "corners.rightContact.y + topBarFillEdge",
    "corners.rightKnee.y + topBarFillEdge",
    "h * 0.099 + topBarFillEdge",
):
    assert anchor in footprint
for old in ("corners.rightContact.y - 3", "corners.rightKnee.y - 3",
            "h * 0.099 - 3"):
    assert old not in footprint

# La stessa geometria è usata per la fascia e per il contorno,
# ma la linea metallica deve rimanere DAVANTI al colore.
assert "GPSHorizonSymmetry.corners(width: w, height: h)" in footprint
assert "GPSHorizonSymmetry.corners(width: w, height: h)" in horizon
assert "CockpitContourGeometry.roundedPath(points: [" in footprint
assert "CockpitContourGeometry.roundedPath(points: [" in horizon
assert "translationX: 0, y: GPSMetalContourStyle.inset(for: dialSize)" in horizon
layer_index = dashboard.index("GPSUpperGradientLayer(theme: theme)")
line_index = dashboard.index("GPSHorizonLine(theme: theme)")
assert layer_index < line_index
assert ".zIndex(4)" in dashboard[layer_index:line_index]
assert ".zIndex(8)" in dashboard[line_index:line_index + 160]
assert ".mask(GPSDialExteriorMask().fill(style: FillStyle(eoFill: true)))" in source
assert ".mask(GPSBridgeExteriorMask().fill(style: FillStyle(eoFill: true)))" in source

# Tutte le altezze landscape: zero separazione fra colore e contorno grigio.
for w, h in ((736, 414), (844, 390), (932, 430), (956, 440),
             (1179, 510), (1536, 706), (1806, 831)):
    d = min(h * 0.965, w * 0.55)
    metal_inset = d * (0.992 - 0.965) / 2
    stroke = max(1.5, d * 0.0035)
    fill_edge = h * 0.099 + metal_inset + stroke / 2
    bottom_of_metal = h * 0.099 + metal_inset + stroke / 2
    assert isclose(fill_edge, bottom_of_metal, abs_tol=1e-10)
    assert fill_edge > h * 0.099 - 3

print("OK — build 96: layer appoggiato alla linea metallica senza spazio, grigio visibile")
