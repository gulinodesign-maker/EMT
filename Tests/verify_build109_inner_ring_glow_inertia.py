"""Build 109: inner GPS neon ring, independent illumination, stabilized inertial LED."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
read = lambda path: (root / path).read_text()
tabs = read("Ecojumbo/Views/CockpitTabs.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
motion = read("Ecojumbo/Models/GPSRideManager.swift")
project = read("Ecojumbo.xcodeproj/project.pbxproj")
assert project.count("CURRENT_PROJECT_VERSION = 115;") == 2
palette = tabs.split("struct EcoThemePalette: Codable, Equatable {", 1)[1].split("extension Color {", 1)[0]
assert "static let colorCount = 23" in palette
assert '"Anello interno · tachimetro"' in palette
assert '("Cockpit", [1, 3, 21, 22, 2, 11, 10, 14, 18, 17, 8, 9])' in palette
assert "var glowLevels: [Double]" in palette
assert "var lightingVersion: Int" in palette
assert "func glow(for role: Int) -> Double" in palette
assert "decodeIfPresent([Double].self, forKey: .glowLevels)" in palette
assert "Self.defaultGlowLevels(legacyGlow: glowIntensity)" in palette
assert "try data.encode(glowLevels, forKey: .glowLevels)" in palette
assert "glowLevels.allSatisfy({ $0.isFinite && (0...1).contains($0) })" in palette
assert "if migrated.colors.count == 22" in palette
assert "migrated.colors.append(migrated.colors[21])" in palette
assert "decoded.lightingVersion < 109" in palette
assert "migrated.lightingVersion = 109" in palette
assert "lightingVersion = 109" in palette
assert '"#FF9A1F"' in palette and '"#38BDF8"' in palette

editor = tabs.split("private struct EcoThemeEditorView: View {", 1)[1].split(
    "private struct EcoThemeColorPicker:", 1)[0]
assert 'Label("Luce tachimetro", systemImage: "sun.max")' not in editor
assert "Slider(value: $draft.glowIntensity" not in editor
assert "private func glowRoleTile(_ role: Int)" in editor
assert "private func glowRoleSection(_ title: String, roles: [Int])" in editor
assert "glowRoleSection(\"Anelli\", roles: [1, 21, 22, 2])" in editor
assert 'glowRoleSection("LED velocità · inerzia", roles: [10, 14, 18, 17])' in editor
assert 'glowRoleSection("LED potenza · BMS", roles: [8, 9])' in editor
assert 'glowRoleSection("Barre telemetria", roles: [4, 5, 6])' in editor
glow_tile = editor.split("private func glowRoleTile(_ role: Int) -> some View {",1)[1].split(
    "private func altitudeGraphTile",1)[0]
assert glow_tile.index("RoundedRectangle(cornerRadius: 7)") < glow_tile.index(
    "Image(systemName:") < glow_tile.index("Slider(value: illumination") < glow_tile.index(
    'Text("\\(Int((illumination.wrappedValue * 100).rounded()))%")')
assert glow_tile.count("Slider(value:") == 1
assert 'accessibilityLabel("Illuminazione " + EcoThemePalette.labels[role])' in glow_tile
assert 'Slider(value: transparency, in: 0...1, step: 0.01)' in editor

cluster = cockpit.split("private struct OpenSpeedCluster: View {",1)[1].split(
    "private struct GPSMetalInnerRing:",1)[0] if "private struct GPSMetalInnerRing:" in cockpit else cockpit
assert "GPSLuminousCircleStroke(color: theme.innerRingColor" in cockpit
assert "diameter: GPSDialLayout.innerRingDiameter(for: d)" in cockpit
assert "glowIntensity: theme.glow(for: 22)" in cockpit
assert "GPSLuminousCircleStroke(color: tone(22)" in cockpit
assert "glowIntensity: palette.glow(for: 22)" in cockpit
assert "glowIntensity: theme.glow(for: 21)" in cockpit
assert "glowIntensity: palette.glow(for: 21)" in cockpit
assert "theme.glow(for: 2)" in cockpit
assert "theme.glow(for: 1)" in cockpit
for role in (4, 5, 6, 8, 9):
    assert f"CockpitTheme.glowForRole({role})" in cockpit
speed = cockpit.split("private struct SpeedLEDStream: View {",1)[1].split(
    "private struct SegmentedGaugeBar: View {",1)[0]
assert "let usesBMS: Bool" in speed
assert "case .incoming: return usesBMS ? 9 : 14" in speed
assert "case .outgoing: return usesBMS ? 8 : 18" in speed
assert "case 14: return CockpitTheme.decelerationAccent" in speed
assert "case 18: return CockpitTheme.accelerationAccent" in speed
assert "CockpitTheme.glowForRole(colorRole)" in speed
assert "ledColor.opacity(0.80 * illumination)" in speed
assert "ledColor.opacity(0.94 * illumination)" in speed
assert "let usesBMS = vehicleMode == EcoVehicleMode.bms.rawValue" in cockpit
assert "powerFlowUsesBMS: usesBMS" in cockpit
assert "GPSSpeedMovement" not in cockpit
assert "speedHistory" not in cockpit

assert "import CoreMotion" in motion
assert "let longitudinal = switch axis" in motion
assert "default: z" in motion
assert "filteredAcceleration = 0.86 * filteredAcceleration + 0.14 * longitudinal * sign" in motion
assert "let enterThreshold = 0.21 - sensitivity * 0.16" in motion
assert "let leaveThreshold = enterThreshold * 0.48" in motion
assert "let requiredDwell = candidate == .neutral ? 0.60 : 0.70" in motion
assert "date.timeIntervalSince(lastTransition) >= 1.10" in motion
assert "rotationRate < 1.15" in motion
assert "candidate = .outgoing" in motion and "candidate = .incoming" in motion
assert "time.timeIntervalSince(lastUpdate) < 1" in motion
print("OK — build 109: independent illumination, nested neon ring and stable inertial acceleration")
