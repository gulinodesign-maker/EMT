"""Regressioni Ecojumbo 1.0 (28): navigazione GPS 3D, dock e vetro, trip, temperatura e potenze cockpit."""
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
assert p.count('CURRENT_PROJECT_VERSION = 28;')==2
assert p.count('MARKETING_VERSION = 1.0;')==2
assert p.count('PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;')==2
assert set(info['UISupportedInterfaceOrientations'])=={'UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'}
assert info['NSLocationWhenInUseUsageDescription'] and info['NSBluetoothAlwaysUsageDescription']
assert 'case dashboard, trips, gps, battery, bms, settings, themes' in u
assert 'EcoTab.allCases.prefix(4)' in u and 'EcoTab.allCases.suffix(3)' in u
assert 'BluetoothGlyph()' in u and 'CockpitCornerControls' in u
# GPS è una modalità del cockpit, non una NavigationStack separata.
assert 'GPSCockpitDashboard(theme: theme, now: tick)' in u
assert 'NavigationStack { AppleMapsPanel() }' not in u
assert 'NavigationStack { RoutesPanel() }' not in u
assert 'case .gps: "GPS"' in u
assert 'case .maps' not in u and 'case .routes' not in u
assert 'GPSCockpitDashboard: View' in c
assert 'private struct GPSCockpitMap: View' in c
assert 'private struct GPSCompactReadings: View' in c
assert 'OpenSpeedCluster(speed: gps.currentSpeed(at: now)' in c
assert 'GPSCockpitMap(theme: theme)' in c
assert 'GPSCompactReadings(theme: theme)' in c
assert 'Map(position: $camera)' in c and 'UserAnnotation()' in c
assert 'MapPolyline(roadRoute.polyline)' in c
assert 'Marker(navigation.destinationName, coordinate: coordinate)' in c
assert 'navigation.plan(destination: destination, origin: gps.currentCoordinate())' in c
assert 'EcoNavigationStore.shared' in c
assert 'routeRevision' in c
assert 'MKLocalSearch(request: searchRequest)' in t
assert 'MKDirections(request: request).calculate()' in t
assert 'request.transportType = .automobile' in t
assert 'www.google.com' not in t and 'GoogleMapsPanel' not in t
assert 'struct RoutesPanel' not in t and 'struct AppleMapsPanel' not in t
assert 'EcoTab.allCases.prefix(4)' in u
assert '(tab == .gps && selected == .gps) ? .dashboard : tab' in u
assert 'lastGPSCoordinate = fix.coordinate' in g
assert 'func currentCoordinate(at date: Date = Date())' in g
assert 'GPS in pausa' in g

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
assert 'private struct GPSLowerContour: Shape' in c
assert 'private struct GPSLowerShade: Shape' in c
assert 'private struct GPSLowerGlow: View' in c
assert 'GPSLowerGlow(theme: theme)' in c
assert 'GPSLowerShade()' in c
assert 'GPSLowerContour()' in c
assert 'textTop - max(12, h * 0.014)' in c
assert 'let topHalfWidth = d * 0.325' in c
assert 'let footY = h * 0.937' in c
assert 'MapCamera(centerCoordinate: center' in c
assert '.mapStyle(.standard(elevation: mapControls.is3D ? .realistic : .flat))' in c
assert 'heading: heading, pitch: mapControls.is3D ? 55 : 0' in c
assert 'GPS e ricerca indirizzo nella STESSA barra' in c
assert 'clipShape(RoundedRectangle(cornerRadius: 16' not in c
assert 'min(37, max(12, height * 0.38))' in c
assert 'buttonStart - max(9, w * 0.012)' in c
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
# Nuovo dock GPS 7 a destra; classico 4+3 invariato.
assert 'if selected == .gps {' in u
assert 'selected == .gps' in u and 'max(4, geometry.size.height * 0.006)' in u
assert 'ForEach(EcoTab.allCases) { tab in' not in u
assert 'iconButton(.dashboard, side: gpsSide)' in u
assert 'gpsButton("play.fill"' in u
assert 'mapControls.send(.toggleNavigation)' in u
assert 'mapControls.send(.toggleProjection)' in u
assert 'mapControls.send(.noseView)' in u
assert 'mapControls.send(.focusRoute)' in u
assert 'mapControls.send(.recenter)' in u
assert 'mapControls.send(.zoomIn)' in u
assert 'mapControls.send(.zoomOut)' in u
assert 'let gpsSide = min(buttonSide, width * 0.052)' in u
assert 'let gpsGap = width * 0.008' in u
# Sfumature neutre su entrambe le modalità.
assert 'private struct CockpitTopSoftShade: View' in c
assert 'geo.size.height * 0.125' in c
assert '.init(color: Color(white: 0.30).opacity(0.38), location: 0)' in c
assert c.count('CockpitTopSoftShade()') == 2
assert 'private struct LowerPanelShade: Shape' in u
assert 'LowerPanelShade()' in u
# Tachimetro GPS più a sinistra e anello brillante senza attraversare A/kW.
assert 'private enum GPSDialLayout' in c
assert 'GPSDialLayout.centerX(width: w, height: h)' in c
assert 'GPSGaugeHalo(theme: theme)' in c
assert 'private struct GPSGaugeHalo: View' in c
assert 'location: 0.80' in c and 'location: 0.65' in c
assert '.position(x: dialCenterX, y: h * 0.494)' in c
assert 'CGRect(x: dialCenterX - dialSize * 0.508' in c
# Il bordo della mappa non deve duplicare la linea arancione superiore.
assert '.stroke(Color.white.opacity(0.16), lineWidth: 0.8)' not in c
assert '.mask(LinearGradient(stops:' in c
assert '.stroke(theme.accent.opacity(0.55), lineWidth: 1.2)' not in c
# Mappa sfumata, recenter GPS, zoom effettivo da regione visibile.
assert 'visibleCamera = context.camera' in c
assert 'recenterOnUser()' in c
assert 'zoom(inward: true)' in c and 'zoom(inward: false)' in c
assert 'camera = .camera(MapCamera(' in c
assert 'mapAction("scope"' not in c
assert 'mapAction("plus.magnifyingglass"' not in c
assert 'mapAction("minus.magnifyingglass"' not in c
assert '.onReceive(mapControls.commands)' in c
assert 'GPSMapControlStore.shared' in c
assert 'width: w * 0.64' in c
assert 'height: h * 0.89' in c
# Trip persistente: riavvio app non cancella il parziale; azzeramento solo con long press.
assert 'UserDefaults.standard.double(forKey: "ecojumbo.gps.tripKm")' in g
assert 'UserDefaults.standard.set(tripKm, forKey: "ecojumbo.gps.tripKm")' in g
assert 'func resetTrip()' in g
assert 'UserDefaults.standard.set(0, forKey: "ecojumbo.gps.tripKm")' in g
assert 'UserDefaults.standard.set(0, forKey: "ecojumbo.gps.totalKm")' not in g
assert 'onLongPressGesture(minimumDuration: 1.3)' in c
assert 'glassReading(String(format: "%.1f km", gps.tripKm)' in c
assert 'height: tileHeight, resettable: true)' in c
assert 'if reading.title == "Trip parziale"' in c
assert 'gps.resetTrip()' in c
assert 'UIApplication.shared.isIdleTimerDisabled = true' in (r/'Ecojumbo/EcojumboApp.swift').read_text()
assert 'UIApplication.shared.isIdleTimerDisabled = (phase == .active)' in (r/'Ecojumbo/EcojumboApp.swift').read_text()
assert 'UIApplication.shared.isIdleTimerDisabled = false' in (r/'Ecojumbo/EcojumboApp.swift').read_text()
# Valore meteo reale da coordinate GPS approssimate; niente termometro iPhone.
assert 'final class EcoOutsideWeather: ObservableObject' in c
assert 'private struct EcoOutsideTemperature: View' in c
assert c.count('EcoOutsideTemperature(now: now)') == 2
assert 'api.open-meteo.com/v1/forecast' in c
assert 'URLQueryItem(name: "current", value: "temperature_2m")' in c
assert 'URLQueryItem(name: "temperature_unit", value: "celsius")' in c
assert 'URLSession.shared.data(from: endpoint)' in c
assert 'gps.currentCoordinate(at: now)' in c
assert 'gps.$lastGPSCoordinate' in c
assert '(coordinate.latitude * 100).rounded() / 100' in c
assert '(coordinate.longitude * 100).rounded() / 100' in c
assert '15 * 60' in c
assert '60 * 60' in c
assert 'String(format: "%.0f°C", $0)' in c
assert '"—°C"' in c
assert 'Image(systemName: "thermometer.medium")' in c
assert 'Link("Meteo · Open-Meteo"' not in c
assert 'Temperatura meteo esterna stimata' not in c
assert 'Licenza dati (CC BY 4.0)' in o
assert 'coordinate geografiche approssimate' in info['NSLocationWhenInUseUsageDescription']
assert c.count('incomingPower: live.map { Swift.max(0, $0.power) }') == 2
assert c.count('outgoingPower: live.map { Swift.max(0, -$0.power) }') == 2
assert 'Text(incomingPower.map { String(format: "%.2f kW"' in c
assert 'Text(outgoingPower.map { String(format: "%.2f kW"' in c
assert 'private let ledOrange = Color(red: 1.00, green: 0.44, blue: 0.03)' in c
assert 'let idealRun = standardHorizontalRun * ((footY - topY) / standardVerticalRun)' in c
assert 'GPSLowerLineGeometry.points(in: rect)' in c
assert 'LabeledContent("Numero build", value: EcojumboBuildStamp.buildNumber)' in o
# Build 27: i tre comandi devono avere un'azione reale.
assert 'func startNavigation(at origin: CLLocationCoordinate2D?) -> Bool' in t
assert 'func stopNavigation()' in t
assert 'func updateProgress(at coordinate: CLLocationCoordinate2D)' in t
assert 'route.steps' in t and 'step.instructions' in t
assert 'guidanceDistanceLabel' in t and 'hasArrived' in t
assert 'navigation.startNavigation(at: gps.currentCoordinate())' in c
assert 'navigation.stopNavigation()' in c
assert 'navigation.updateProgress(at: coordinate)' in c
assert 'navigation.guidanceInstruction' in c
assert 'navigation.isNavigating' in c
assert 'Avvia navigazione GPS' in u and 'Ferma navigazione GPS' in u
assert '@Published var is3D = true' in c
assert 'private func toggleProjection()' in c
assert 'Passa alla mappa 2D' in u and 'Passa alla mappa 3D' in u
assert 'private func activateNoseView()' in c
assert 'private func followCamera(at coordinate: CLLocationCoordinate2D)' in c
assert 'Vista dal muso dello scooter, direzione di marcia' in u
assert 'let lookAhead = mapControls.headingUp' in c
assert 'private(set) var courseDegrees: CLLocationDirection?' in g
assert 'fix.speed >= 1.3, fix.course >= 0, fix.course < 360' in g
assert 'func currentCourse(at date: Date = Date()) -> CLLocationDirection?' in g
assert c.count('glassReading(') == 7
assert '.background(.ultraThinMaterial,' in c
assert '.black.opacity(0.35), .black.opacity(0.75)' not in c
assert '8 * controlSide - 7 * w * 0.008' in c
assert 'struct GPSCompactReadings: View' in c
print('OK — 28: controlli GPS inferiori, otto pulsanti, sei tessere vetro')
