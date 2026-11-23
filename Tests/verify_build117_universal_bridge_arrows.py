#!/usr/bin/env python3
"""Build 117: arrows for real inertial motion; BMS kW remains text."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text(encoding="utf-8")
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text(encoding="utf-8")
assert project.count("CURRENT_PROJECT_VERSION = 130;") == 2

bridge = cockpit.split("private struct GPSCockpitPowerReading: View {", 1)[1].split(
    "// Calcola la posizione più a sinistra possibile", 1)[0]
assert 'case .incoming: return "arrow.down"' in bridge
assert 'case .outgoing: return "arrow.up"' in bridge
assert 'case .neutral: return "minus"' in bridge
assert 'Image(systemName: inertialSymbol)' in bridge
assert 'if let inertialSymbol {' in bridge
assert 'else {\n                Text(readingText)' in bridge
assert 'powerKW.map { String(format: "%.2f kW", $0) } ?? "— kW"' in bridge
assert 'return "DECEL."' not in bridge
assert 'return "ACCEL."' not in bridge
assert 'return "INERZIA"' not in bridge
assert "movementAccessibilityValue" in bridge
assert 'case .incoming: return "Decelerazione"' in bridge
assert 'case .outgoing: return "Accelerazione"' in bridge
assert 'case .neutral: return "Inerzia"' in bridge
assert "case .incoming: return CockpitTheme.decelerationAccent" in bridge
assert "case .outgoing: return CockpitTheme.accelerationAccent" in bridge
assert 'Movimento inerziale, non potenza in kilowatt' in bridge

dashboard = cockpit.split("struct GPSCockpitDashboard: View {",1)[1].split("// Pulsante dedicato",1)[0]
assert "GPSCockpitPowerReading(d: dialSize" in dashboard
assert "powerWatts: live.map { -$0.power }" in dashboard
assert "inertialFlow: vehicleMode == EcoVehicleMode.universal.rawValue" in dashboard
assert "? flow : nil" in dashboard
print("OK — build 117: bridge icons up/down/minus in Universale; real kW text in BMS")
