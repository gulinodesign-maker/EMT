"""Build 65: 2×2 icon category grid, full-size DISL with theme-matched fade."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
gps = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
pbx = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 75;") == 2

editor = tabs.split("private struct EcoThemeEditorView: View {", 1)[1].split(
    "private struct EcoThemeColorPicker: View {", 1)[0]
assert "@State private var selectedGroup: Int?" in editor
assert "LazyVGrid(columns: [GridItem(.flexible(), spacing: 12)," in editor
assert "ForEach(0..<EcoThemePalette.groups.count, id:" in editor
assert "selectedGroup = groupIndex" in editor
assert "categoryTile(groupIndex)" in editor
assert 'Label("Tutte le categorie", systemImage: "chevron.left")' in editor
assert "self.selectedGroup = nil" in editor
assert "ForEach(group.range, id:" in editor
assert "colorRoleTile(index)" in editor
assert "private func categoryTile(_ index: Int) -> some View" in editor
assert "private func colorRoleTile(_ index: Int) -> some View" in editor
for symbol in ("paintpalette", "chart.bar.fill", "speedometer",
               "arrow.triangle.turn.up.right.diamond"):
    assert '"' + symbol + '"' in editor
assert "ForEach(group.range, id:" in editor  # swatch previews & detail
assert "minimumDuration: 0.45" in editor
assert ".sheet(item: $colorID)" in editor
assert "draft.colors[selected.id] = hex" in editor
assert "onSave(slot, palette)" in editor
assert "ForEach(1...3, id:" in tabs
assert "static let colorCount = 19" in tabs
assert "decoded.colors.count == 8 || decoded.colors.count == 15 ||" in tabs
assert "decoded.colors.count == colorCount" in tabs

panel = cockpit.split("private struct GPSExpandedReadings: View {", 1)[1].split(
    "// Progressi sottili e luminosi, soltanto per SOC", 1)[0]
assert 'Text("TELEMETRIA")' in panel
assert "LazyVGrid(columns: [GridItem(.flexible(), spacing: tileGap)," in panel
assert panel.count('telemetryTile("') == 4
for label in ("SOC", "V BAT", "AUT", "TRIP"):
    assert f'telemetryTile("{label}"' in panel
assert "let cardHeight = max(1, (innerHeight - headerHeight - 3 * tileGap) / 4)" in panel
assert "let dislHeight = 2 * cardHeight" in panel
assert "dislevelCard(height: dislHeight)" in panel
assert "GPSTripAltitudeSparkline(points: gps.altitudeProfile, color: theme.accent)" in panel
assert "live = bluetooth.isConnected && snapshot.map" in panel
assert "abs(now.timeIntervalSince($0.date)) < 10" in panel
assert "EcoRangeEstimate(snapshot: live, session: bluetooth.session)" in panel
assert 'Text("DISL")' in panel
assert "gps.tripElevationMeters" in panel
assert "String(format: \"%.1f km\", gps.tripKm)" in panel

chart = cockpit.split("private struct GPSTripAltitudeSparkline: View {", 1)[1]
assert "if points.count >= 2" in chart
assert "line.stroke(color" in chart
assert "area.fill(LinearGradient(" in chart
assert "color.opacity(0.34), color.opacity(0.16), color.opacity(0.0)" in chart
assert "startPoint: .top, endPoint: .bottom" in chart
assert "path.closeSubpath()" in chart
assert "Profilo GPS in attesa" in chart
assert "points.map(\.altitudeMeters)" in chart
assert "recordTripAltitude(fix)" in gps

# Geometry, map, reset and dock safe-area unchanged.
assert "let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in cockpit
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in cockpit
assert ".position(x: panelLeft + panelWidth / 2, y: cardsCenterY)" in cockpit
assert "let telemetryDock = selected == .gps && !mapEnabled" in home
assert "let justifiedGap = max(0, (telemetryPanelWidth - 5 * gpsSide) / 4)" in home
assert "GPSCockpitMap(theme: theme)" in cockpit
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in cockpit
assert 'onLongPressGesture(minimumDuration: 0.5)' in cockpit
print("OK — build 65: categories 2×2; telemetry 2×2; DISL double with GPS color fade")
