"""Build 111: cockpit ring 3-pt gap, specific symbols and altitude graph theme."""
from pathlib import Path

r = Path(__file__).resolve().parents[1]
tabs = (r / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit = (r / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (r / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 116;") == 2
layout = cockpit.split("private enum GPSDialLayout {", 1)[1].split("// Anello esterno luminoso", 1)[0]
assert "static func innerRingDiameter(for d: CGFloat)" in layout
assert "GPSInnerLED.coreWidth(d) * speedScaleMagnification" in layout
assert "ledInnerRadius - 3 - innerRingStroke(for: d) / 2" in layout
assert cockpit.count("diameter: GPSDialLayout.innerRingDiameter(for: d)") == 2
assert cockpit.count("stroke: GPSDialLayout.innerRingStroke(for: d)") == 2
assert "diameter: d * 0.630" not in cockpit

palette = tabs.split("struct EcoThemePalette: Codable, Equatable {", 1)[1].split("extension Color {", 1)[0]
assert '("Cockpit", [1, 3, 21, 22, 2, 11, 10, 14, 18, 17, 8, 9])' in palette
assert '("Anelli e numeri del tachimetro",' not in palette
assert "static let colorCount = 23" in palette
for line in [
    "var altitudeGraphColor: String", "var altitudeGraphGlow: Double",
    "decodeIfPresent(String.self, forKey: .altitudeGraphColor)",
    "decodeIfPresent(Double.self, forKey: .altitudeGraphGlow)",
    "data.encode(altitudeGraphColor, forKey: .altitudeGraphColor)",
    "data.encode(altitudeGraphGlow, forKey: .altitudeGraphGlow)",
    "validHex(palette.altitudeGraphColor)",
    "(0...1).contains(palette.altitudeGraphGlow)",
]:
    assert line in palette, line
assert "storedGraphColor.flatMap" in palette and "legacyGraphColor" in palette

editor = tabs.split("private struct EcoThemeEditorView: View {", 1)[1].split("private struct EcoThemeColorPicker:", 1)[0]
assert "altitudeGraphTile()" in editor
assert 'Label("Grafico altimetrico · Telemetria", systemImage: "mountain.2.fill")' in editor
assert "Slider(value: $draft.altitudeGraphGlow, in: 0...1, step: 0.01)" in editor
assert "choosingAltitudeColor = true" in editor
assert 'initialHex: draft.altitudeGraphColor' in editor
assert "draft.altitudeGraphColor = hex" in editor
assert 'accessibilityLabel("Colore grafico altimetrico")' in editor
assert 'accessibilityLabel("Illuminazione grafico altimetrico")' in editor
assert "private func roleSymbol(_ role: Int)" in editor
assert "Label(roleShortName(role), systemImage: roleSymbol(role))" in editor
for role in (1, 2, 3, 8, 9, 10, 11, 14, 17, 18, 21, 22):
    assert f"case {role}: return" in editor

assert "var altitudeGraphColor: Color" in cockpit
assert "var altitudeGraphGlow: Double" in cockpit
assert "color: theme.altitudeGraphColor, glowIntensity: theme.altitudeGraphGlow" in cockpit
graph = cockpit.split("private struct GPSTripAltitudeSparkline: View {", 1)[1]
assert "let glowIntensity: Double" in graph
assert "if points.count >= 2" in graph
assert "line.stroke(color.opacity(" in graph and ".blur(radius: 3.5)" in graph
assert "line.stroke(color, style: StrokeStyle(lineWidth: 2," in graph
print("OK — build 111 cockpit ring / icons / altitude graph persistent color and glow")
