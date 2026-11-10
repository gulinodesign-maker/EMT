"""Regressione funzionale e grafica Ecojumbo 1.0 (17), senza dati simulati."""
from pathlib import Path
import plistlib

r=Path(__file__).resolve().parents[1]
p=(r/'Ecojumbo.xcodeproj/project.pbxproj').read_text()
u=(r/'Ecojumbo/Views/EcojumboRootView.swift').read_text()
c=(r/'Ecojumbo/Views/CockpitComponents.swift').read_text()
t=(r/'Ecojumbo/Views/CockpitTabs.swift').read_text()
o=(r/'Ecojumbo/Views/OtherViews.swift').read_text()
g=(r/'Ecojumbo/Models/GPSRideManager.swift').read_text()
with (r/'Ecojumbo/Info.plist').open('rb') as f: info=plistlib.load(f)

for item in ('CockpitComponents.swift','CockpitTabs.swift','EcojumboRootView.swift','CellsView.swift','CockpitBarMath.swift'):
    assert p.count(item)>=2,(item,p.count(item))
assert p.count('CURRENT_PROJECT_VERSION = 19;')==2
assert p.count('MARKETING_VERSION = 1.0;')==2
assert p.count('PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;')==2
assert set(info['UISupportedInterfaceOrientations'])=={'UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'}
assert info['NSLocationWhenInUseUsageDescription'] and info['NSBluetoothAlwaysUsageDescription']
assert 'case dashboard, trips, routes, battery, bms, maps, settings, themes' in u
assert 'EcoTab.allCases.prefix(4)' in u and 'EcoTab.allCases.suffix(4)' in u
assert 'BluetoothGlyph()' in u and 'CockpitCornerControls' in u
assert 'GoogleMapsPanel' in t and 'www.google.com' in t
assert 'struct CellsView: View' in (r/'Ecojumbo/Views/CellsView.swift').read_text()
assert 'func setOdometer(_ kilometers: Double)' in g and 'track: [RouteCoordinate]' in g
for a in ('AppIcon.appiconset/AppIcon.png','EcojumboMark.imageset/EcojumboMark.png'):
    assert (r/'Ecojumbo/Assets.xcassets'/a).stat().st_size>10000
assert (r/'Ecojumbo/Assets.xcassets/CarbonWeave.imageset/CarbonWeave.png').exists()
assert 'Image("CarbonWeave")' in c and 'Image("EcojumboMark")' in c
assert (r/'RiferimentoGrafico/Cockpit_1_09_utente.jpg').stat().st_size>100000

# Sei schede indipendenti, con sei icone e soltanto tre barre reali.
assert 'private struct PremiumWing: View' in c and 'metricTile(reading, width: w, height: tileHeight)' in c
assert 'ForEach(readings.indices' in c
assert c.count('WingReading(value:')==6
assert c.count('showsBar: true')==3 and c.count('showsBar: false')==3
for sym in ('bolt.fill','voltage','road.lanes','chart.bar.fill','mappin','speedometer'):
    assert f'icon: "{sym}"' in c
assert 'if reading.showsBar {' in c and 'MetricGlowBar(fraction: reading.fraction' in c
assert c.count('CockpitBarMath.unit(')==3
assert 'CockpitBarMath.odometerCycle(' not in c
assert 'rangeKm.map' in c and 'gps.tripKm' in c and 'gps.totalKm' in c
assert 'let instantKW = live.map { -($0.power) / 1000.0 }' in c
assert 'bluetooth.snapshot' in c and 'gps.currentSpeed(at:now)' in c
assert '48 A' not in c and '62 km/h' not in c and '400 V' not in c
assert '— V' in c and '— kW' in c and '— km' in c
assert 'Text(String(Int(speed.rounded())))' in c and 'Text("km/h")' in c
assert 'Text("GPS")' in c and 'Text("P")' not in c
assert 'SpeedLEDStream(d: d, speed: speed)' in c and 'SpeedScaleTicks(d: d)' in c
assert 'SegmentedGaugeBar(d:' in c

# Le linee usano lo stesso raggio effettivo; angoli inferiori retti.
assert 'ContinuousLowerLine: Shape' in u and 'ContinuousLowerGlow(theme: theme)' in u
assert 'CockpitContourGeometry.roundedPath(points:' in u
assert 'CockpitContourGeometry.roundedPath(points:' in c
assert 'corners: [1, 4]' in c and 'corners: [1, 2]' in u
assert 'p.addLine(to: pt(' not in u
assert 'CornerDockGlow' not in u and 'FooterLightContour' not in c
assert 'private struct ContinuousHorizonLine: View' in c
assert 'min(h * 0.982, w * 0.57)' in c
assert 'ringRadius = min(h * 0.982, w * 0.57) * 0.506' in c
assert 'FillStyle(eoFill: true)' in c
assert 'wingHeight = h * 0.455' in c
assert '.position(x: wingInset + wingWidth / 2, y: h * 0.490)' in c
assert '.position(x: d * 0.50, y: d * 0.889)' in c
assert 'if left { icon }' in c and 'if !left { icon }' in c
assert 'if left { Spacer(minLength: 0) }' in c
assert 'var previewPalette: [Color]' in c
assert 'Self.barDark, Self.barMid, Self.barBright, Self.regenAccent]' in c
assert 'ForEach(theme.previewPalette.indices' in t

# Sei temi, griglia visibile con 3 colonne e 2 righe in landscape.
for tag in ['case copper = "Rame"','case glacier = "Ghiaccio"','case green = "Verde"','case aquamarine = "Acquamarina"','case brown = "Marrone"','case racing = "Racing"']:
    assert tag in c
assert 'LazyVGrid(columns: columns, spacing: 13)' in t
assert 'Array(repeating: GridItem(.flexible(), spacing: 13), count: 3)' in t
assert 'ForEach(CockpitTheme.allCases)' in t
assert 'Scale delle barre luminose' in o and 'Nessuna barra nelle tre schede chilometriche' in o
assert 'Potenza istantanea:' in o and 'Ciclo km totali:' not in o
print('OK — 19: 6 card con icone, 3 barre reali, raccordi C1, 6 temi a griglia 2x3')
