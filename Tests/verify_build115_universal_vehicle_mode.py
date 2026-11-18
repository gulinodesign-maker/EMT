#!/usr/bin/env python3
"""Build 115: user-selectable BMS/universal automotive cockpit, no synthetic fuel/BMS data."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
read = lambda p: (root / p).read_text(encoding="utf-8")
gps = read("Ecojumbo/Models/GPSRideManager.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
setup = read("Ecojumbo/Views/OtherViews.swift")
root_view = read("Ecojumbo/Views/EcojumboRootView.swift")
project = read("Ecojumbo.xcodeproj/project.pbxproj")
assert project.count("CURRENT_PROJECT_VERSION = 117;") == 2

# Modalità predefinita BMS conserva i vecchi dispositivi e gli slot personalizzati.
assert 'enum EcoVehicleMode: String, CaseIterable, Identifiable' in gps
assert 'case bms = "BMS"' in gps and 'case universal = "Universale"' in gps
assert '@AppStorage("ecojumbo.vehicle.mode") private var vehicleMode = EcoVehicleMode.bms.rawValue' in setup
assert 'case .vehicle: "Veicolo"' in setup
assert 'case .vehicle: "car.side.fill"' in setup
assert 'Picker("Modalità veicolo", selection: $vehicleMode)' in setup
assert 'ForEach(visibleSections)' in setup
assert '![.battery, .bms, .scooter, .bluetooth, .charging].contains($0)' in setup
assert 'powerSource = mode == EcoVehicleMode.universal.rawValue' in setup
assert 'Picker("Controllo", selection: $powerSource)' not in setup
assert 'Section("Carburante stimato")' in setup
assert 'Section("Velocità media")' in setup
assert 'value: $averageSpeedScaleKmh, in: 30...240, step: 10' in setup
assert 'value: $averagePowerMaxKW, in: 1...20, step: 1' in setup  # BMS kept
assert 'func saveFullRange()' in setup
assert '(10...2500).contains(kilometers)' in setup
assert '@AppStorage("ecojumbo.vehicle.fullRangeKm") private var fullRangeKm = 0.0' in setup
assert '"Stima, non sensore carburante"' in setup

# Nessun 500 km predefinito o pieno automatico: solo conferma dell'utente.
assert '@Published private(set) var universalKmSinceFull: Double' in gps
assert '@Published private(set) var universalHasFull: Bool' in gps
assert 'ecojumbo.vehicle.kmSinceFull' in gps
assert 'ecojumbo.vehicle.hasFull' in gps
assert 'func recordUniversalFull() -> Bool' in gps
refuel = gps.split("func recordUniversalFull() -> Bool {",1)[1].split("\n    }",1)[0]
assert 'UserDefaults.standard.string(forKey: "ecojumbo.vehicle.mode") == EcoVehicleMode.universal.rawValue' in refuel
assert '(10...2500).contains(fullRange)' in refuel
assert 'universalKmSinceFull = 0' in refuel and 'universalHasFull = true' in refuel
assert 'UserDefaults.standard.set(0.0, forKey: "ecojumbo.vehicle.kmSinceFull")' in refuel
assert 'func universalEstimatedRemainingKm(fullRange: Double) -> Double?' in gps
assert 'return max(0, fullRange - universalKmSinceFull)' in gps
assert 'func universalEstimatedFuelFraction(fullRange: Double) -> Double?' in gps
assert 'return min(1, max(0, remaining / fullRange))' in gps
reset = gps.split("func resetTrip() {",1)[1].split("\n    }",1)[0]
assert 'universalKmSinceFull' not in reset and 'universalHasFull' not in reset
updates = gps.split('func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {',1)[1].split('\n    }',1)[0]
assert 'universalKmSinceFull += increment' in updates
assert 'if universalHasFull,' in updates
assert '== EcoVehicleMode.universal.rawValue' in updates
assert 'fix.speed <= maxTrustedSpeed' in updates
assert '? 80 : 50' in updates
assert 'meters <= dt * maxTrustedSpeed + 4' in updates
assert 'movingSeconds.isFinite, movingSeconds >= 60' in gps
assert 'tripKm / (movingSeconds / 3600)' in gps

# Il cockpit non deve usare misure JK in Universale, neppure se connesso.
dashboard = cockpit.split("struct GPSCockpitDashboard: View {",1)[1].split("// Pulsante dedicato",1)[0]
assert 'guard vehicleMode == EcoVehicleMode.bms.rawValue,' in dashboard
assert 'if vehicleMode == EcoVehicleMode.bms.rawValue, let snapshot' in dashboard
assert 'return powerMotion.currentFlow(at: now)' in dashboard
assert 'if vehicleMode == EcoVehicleMode.bms.rawValue {' in dashboard  # rail MapKit
assert 'GPSMapBatteryRail(theme: theme, now: now)' in dashboard
assert 'inertialFlow: vehicleMode == EcoVehicleMode.universal.rawValue' in dashboard
assert 'powerWatts: live.map { -$0.power }' in dashboard
assert 'Button("Conferma pieno") { gps.recordUniversalFull() }' in dashboard
assert '.disabled(!(10...2500).contains(fullRangeKm))' in dashboard
assert 'if vehicleMode == EcoVehicleMode.universal.rawValue {' in dashboard
assert 'showsBMS: vehicleMode == EcoVehicleMode.bms.rawValue' in dashboard
assert 'case .incoming: return "arrow.down"' in cockpit
assert 'case .outgoing: return "arrow.up"' in cockpit
assert 'case .neutral: return "minus"' in cockpit
assert 'Movimento inerziale, non potenza in kilowatt' in cockpit

tele = cockpit.split("private struct GPSExpandedReadings: View {",1)[1].split("// Progressi sottili",1)[0]
assert 'vehicleMode == EcoVehicleMode.bms.rawValue &&' in tele
assert 'if vehicleMode == EcoVehicleMode.universal.rawValue {' in tele
for label in ("CARB", "V MED", "SOC", "V BAT", "AUT", "TRIP"):
    assert f'telemetryTile("{label}"' in tele
assert 'gps.universalEstimatedFuelFraction(fullRange: fullRangeKm)' in tele
assert 'gps.universalEstimatedRemainingKm(fullRange: fullRangeKm)' in tele
assert 'gps.averageMovingSpeedKmh' in tele
assert 'CockpitBarMath.unit($0, maximum: averageSpeedScaleKmh)' in tele
assert 'scaleLabel: "Stima GPS"' in tele
assert 'String(format: "%.1f km", gps.tripKm)' in tele
assert 'gps.averageRecentTripKm(at: now)' in tele
assert 'GPSTripAltitudeSparkline(points: gps.altitudeProfile' in tele
home = cockpit.split("struct CockpitDashboard:View {",1)[1].split("private func topInfoBar",1)[0]
assert 'vehicleMode == EcoVehicleMode.universal.rawValue' in home
assert 'title: "Carburante stimato"' in home
assert 'title: "Velocità media GPS"' in home
assert 'title: "Movimento inerziale"' in home
assert "Vista in direzione di marcia del veicolo" in root_view
print("OK — build 115: BMS data gated, universal estimated fuel/average GPS speed, explicit full reset, 4 gauges")
