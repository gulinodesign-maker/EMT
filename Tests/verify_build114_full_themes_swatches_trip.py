#!/usr/bin/env python3
"""Build 114: full JSON palette application, inline swatches and genuine 7-day TRIP."""
from pathlib import Path
import json, hashlib, re

root = Path(__file__).resolve().parents[1]
read = lambda p: (root / p).read_text(encoding="utf-8")
tabs = read("Ecojumbo/Views/CockpitTabs.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
gps = read("Ecojumbo/Models/GPSRideManager.swift")
project = read("Ecojumbo.xcodeproj/project.pbxproj")
assert project.count("CURRENT_PROJECT_VERSION = 114;") == 2

expected = {
    "ferrariFactory": ("Ferrari", "0dec80e42a369102cbe716535a280d4405654dde73f2448b2cf9a15ae4febe94", "#6C6C6C"),
    "cupraFactory": ("Cupra", "d09b287a7270a4b8ea6223238ccd862906e3533953c5ef56bab54e80099b6b37", "#AAAAAA")
}
for name, (brand, digest, inner) in expected.items():
    match = re.search(r"private static let " + name + r': EcoThemePalette = \{\s*let json = ##"(.*?)"##', tabs)
    assert match, name
    theme = json.loads(match.group(1))
    canonical = json.dumps(theme, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    assert hashlib.sha256(canonical.encode()).hexdigest() == digest
    assert theme["name"] == theme["brandID"] == brand and theme["colors"][22] == inner
    assert len(theme["colors"]) == len(theme["glowLevels"]) == 23
assert "if preset == .glacier { return ferrariFactory }" in tabs
assert "if preset == .racing { return cupraFactory }" in tabs
theme_model = cockpit.split("enum CockpitTheme: String, CaseIterable, Identifiable {",1)[1].split("// Le due barre arancioni",1)[0]
resolved = theme_model.split("private var savedPalette: EcoThemePalette? {",1)[1].split("\n    }",1)[0]
assert "if let slot = slotIndex" in resolved
assert "EcoThemePalette.load(slot: slot)" in resolved
assert "return EcoThemePalette.template(self)" in resolved
for field in ("savedPalette.colors[22]", "savedPalette?.dayTopBar", "savedPalette?.lightOpacity",
              "savedPalette?.shadowOpacity", "savedPalette?.highOpacity", "savedPalette?.lowOpacity",
              "savedPalette?.dayHighOpacity", "savedPalette?.dayLowOpacity",
              "savedPalette?.altitudeGraphColor", "savedPalette?.altitudeGraphGlow",
              "savedPalette?.glow(for: role)"):
    assert field in theme_model, field

picker = tabs.split("private struct EcoThemeColorPicker: View {",1)[1]
base = picker.split("private static let baseColors: [String] = [",1)[1].split("]",1)[0]
assert len(re.findall(r"#[0-9A-F]{6}", base)) == 20
for token in ('@AppStorage("ecojumbo.theme.savedSwatches.v1")',
              'private var paletteColors: [String]',
              "return Self.baseColors + extra", "private func saveCurrentColor()",
              "selectedHex.uppercased()", "seen.insert($0).inserted",
              'Button(action: saveCurrentColor)', 'Label("Salva colore"',
              r"ForEach(paletteColors.indices, id: \.self)",
              'savedSwatchesJSON = json'):
    assert token in picker, token
assert "I miei colori" not in picker
assert 'onConfirm(selectedHex)' in picker and 'dismiss()' in picker

assert "struct EcoCompletedTrip: Codable, Equatable" in gps
assert "let completedAt: Date" in gps and "let distanceKm: Double" in gps
assert '@Published private(set) var completedTrips: [EcoCompletedTrip]' in gps
assert 'ecojumbo.gps.completedTrips.v1' in gps
avg = gps.split("func averageRecentTripKm(at date: Date = Date()) -> Double? {",1)[1].split("\n    }",1)[0]
assert "-7 * 24 * 60 * 60" in avg and "completedTrips.filter" in avg
assert "guard !recent.isEmpty else { return nil }" in avg
assert "recent.reduce(0) { $0 + $1.distanceKm } / Double(recent.count)" in avg
reset = gps.split("func resetTrip() {",1)[1].split("\n    }",1)[0]
assert "if tripKm.isFinite && (0.05...10_000).contains(tripKm)" in reset
assert "EcoCompletedTrip(completedAt: now, distanceKm: tripKm)" in reset
assert reset.index("EcoCompletedTrip") < reset.index("tripKm = 0")
assert "ecojumbo.gps.totalKm" not in reset
telemetry = cockpit.split("private struct GPSExpandedReadings: View {",1)[1]
assert "let tripAverage = gps.averageRecentTripKm(at: now)" in telemetry
assert 'telemetryTile("TRIP"' in telemetry and 'showsBar: true' in telemetry
assert "CockpitBarMath.unit(gps.tripKm, maximum: $0)" in telemetry
assert 'scaleLabel: tripAverage.map' in telemetry
assert '?? "Media 7 gg: —"' in telemetry
assert "TelemetrySlimBar(fraction: fraction, theme: theme)" in telemetry
assert 'value: String(format: "%.1f km", gps.tripKm)' in telemetry
print("OK — build 114: full themes, single expandable swatch grid, factual trip average")
