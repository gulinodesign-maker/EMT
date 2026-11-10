from pathlib import Path
import json, plistlib
root = Path(__file__).resolve().parents[1]
project = (root/'Ecojumbo.xcodeproj/project.pbxproj').read_text()
with (root/'Ecojumbo/Info.plist').open('rb') as f:
    plist = plistlib.load(f)
for name in ('CockpitComponents.swift', 'CockpitTabs.swift', 'EcojumboRootView.swift'):
    assert project.count(name) >= 2, f'Missing build references: {name}'
assert 'it.ecojumbo.battery' in project
assert 'CURRENT_PROJECT_VERSION = 14' in project
assert 'MARKETING_VERSION = 1.0' in project
assert set(plist['UISupportedInterfaceOrientations']) == {
    'UIInterfaceOrientationLandscapeLeft', 'UIInterfaceOrientationLandscapeRight'
}
assert plist['NSLocationWhenInUseUsageDescription']
assert plist['NSBluetoothAlwaysUsageDescription']
ui = (root/'Ecojumbo/Views/EcojumboRootView.swift').read_text()
comp = (root/'Ecojumbo/Views/CockpitComponents.swift').read_text()
tabs = (root/'Ecojumbo/Views/CockpitTabs.swift').read_text()
gps = (root/'Ecojumbo/Models/GPSRideManager.swift').read_text()
assert 'case dashboard, trips, routes, battery, bms, maps, settings, themes' in ui
assert 'Image("EcojumboMark")' in comp
assert 'SegmentedGaugeBar(d:' in comp
assert 'gps.currentSpeed(at:now)' in comp
assert 'bluetooth.snapshot' in comp
assert 'averageDischargeKW' in comp
assert 'GoogleMapsPanel' in tabs and 'www.google.com' in tabs
assert 'func setOdometer(_ kilometers: Double)' in gps
assert 'track: [RouteCoordinate]' in gps
assert 'Rame' in comp and 'Ghiaccio' in comp
settings = (root/'Ecojumbo/Views/OtherViews.swift').read_text()
assert 'Chilometri totali dello scooter' in settings
for image in ('AppIcon.appiconset/AppIcon.png','EcojumboMark.imageset/EcojumboMark.png'):
    assert (root/'Ecojumbo/Assets.xcassets'/image).stat().st_size > 10000
assert (root/'RiferimentoGrafico/Cockpit_approvato.jpg').is_file()
assert 'PremiumWing' in comp and 'ContinuousHorizonLine' in comp
assert 'cornerRadius: h * 0.16' in comp  # angoli delle ali
assert '.blur(radius:' in comp and '.shadow(color:' in comp  # vera luce per SwiftUI
assert 'min(h * 0.93, w * 0.57)' in comp  # quadrante entro i bordi
assert 'CockpitCornerControls' in ui and 'EcoTab.allCases.prefix(4)' in ui and 'EcoTab.allCases.suffix(4)' in ui
assert '48 A' not in comp and '62 km/h' not in comp  # nessuna lettura hardcoded
assert 'HollowSpeedNumber' in comp and 'NSAttributedString' in comp
assert 'SegmentedGaugeBar' in comp and 'SpeedScaleTicks' in comp
assert 'CarbonWeave' in comp and (root/'Ecojumbo/Assets.xcassets/CarbonWeave.imageset/CarbonWeave.png').exists()
assert (root/'RiferimentoGrafico/Cockpit_1_07_utente.jpg').stat().st_size > 100_000
assert 'PremiumWing(readings: leftRows' in comp and 'PremiumWing(readings: rightRows' in comp
print('OK — EJ 1.09: carbonio, ali unite, anelli segmentati, speed stream rossa e 8 pulsanti separati')

# Regression: every view referenced by the root navigation must be defined and compiled.
assert (root/'Ecojumbo/Views/CellsView.swift').exists()
assert 'struct CellsView: View' in (root/'Ecojumbo/Views/CellsView.swift').read_text()
assert 'CellsView.swift in Sources' in project

# Regressioni della nuova grafica: nessun simbolo nelle tre righe laterali.
assert 'Image(systemName:item.symbol)' not in comp
assert 'let symbol: String' not in comp
assert 'BluetoothGlyph().frame(width:' in comp
assert 'BluetoothGlyph()' in ui
assert 'Text(now.formatted(date: .omitted, time: .shortened))' in comp
assert 'Image("CarbonWeave")' in comp
assert '.clipShape(Circle())' in comp
assert '.zIndex(30)' in comp and '.zIndex(2)' in comp
assert 'ContinuousHorizonLine(theme: theme)' in comp
assert 'p.addLine(to: CGPoint(x: w, y: y))' in comp
assert '— V' in comp and '— kW' in comp
print('OK — gerarchia primo piano, linea superiore dissolvente, Bluetooth vettoriale, numeri senza icone')

# EJ 1.08: nessuna barra inferiore continua; i pulsanti sono flottanti in due gruppi.
assert 'BottomRailShape' not in ui
assert 'CockpitCornerControls(selected: $selected' in ui
assert '.frame(width: geometry.size.width, height: geometry.size.height)' in ui
assert 'frame(width: side, height: side)' in ui
# La top bar e le 6 letture laterali non devono sovrapporsi al disco centrale.
assert comp.index('PremiumWing(readings: leftRows') < comp.index('OpenSpeedCluster(speed: liveSpeed')
assert '.zIndex(30)' in comp
assert '.opacity(0.74)' in comp
assert 'let innerColor' in comp and 'let outerColor' in comp
assert 'current.map { String(format:' in comp
assert '62 km/h' not in comp and '78%' not in comp
print('OK — root a pieno schermo, tasti 4+4, pannelli dietro a disco opaco, misure reali')

# EJ 1.08: barre reali per tutti i sei pannelli, nessuna simulazione.
assert 'MetricGlowBar(fraction: reading.fraction' in comp
assert comp.count('CockpitBarMath.unit(') == 5
assert 'CockpitBarMath.odometerCycle(' in comp
assert '.animation(.easeInOut(duration: 0.35), value: fraction)' in comp
assert 'ecojumbo.bars.rangeMaxKm' in settings
assert 'Scale delle barre luminose' in settings
assert (root/'Ecojumbo/Models/CockpitBarMath.swift').exists()
assert 'CockpitBarMath.swift in Sources' in project
print('OK — 6 barre con riempimento reale, scale modificabili e valori non disponibili vuoti')

assert 'ContinuousLowerLine: Shape' in ui
assert 'ContinuousLowerGlow(theme: theme)' in ui
assert 'CornerDockGlow' not in ui
assert 'FooterLightContour' not in comp
assert ui.count('p.move(to: pt(0.012, 0.872))') == 1
assert ui.count('p.addLine(to: pt(0.988, 0.872))') == 1
# EJ 1.10: piattaforma leggermente ribassata, due raccordi cubici C1.
assert 'p.addLine(to: pt(0.635, 0.735))' in ui
assert 'control1: pt(0.294, 0.872), control2: pt(0.305, 0.735)' in ui
assert 'control1: pt(0.695, 0.735), control2: pt(0.706, 0.872)' in ui
assert 'let wingInset = max(5, w * 0.006)' in comp
assert '.position(x: wingInset + wingWidth / 2' in comp
assert '.position(x: w - wingInset - wingWidth / 2' in comp
assert 'SpeedLEDStream(d: d, speed: speed)' in comp
assert 'SpeedScaleTicks(d: d)' in comp
assert 'GaugeTicks' not in comp
assert 'for index in 0...6' not in comp
assert 'let label=Text(' not in comp
assert 'guard let speed, speed.isFinite' in comp
assert 'min(1, max(0, speed / 120))' in comp
assert '.animation(.easeInOut(duration: 0.38), value: progress)' in comp
assert 'var animatableData: Double' in comp
assert 'y: d * 0.825' in comp
assert (root/'RiferimentoGrafico/Cockpit_1_09_utente.jpg').stat().st_size > 100_000
print('OK — linea inferiore UNICA a tutto schermo, LED rosso GPS, senza numeri statici')
