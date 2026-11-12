"""Regressioni Ecojumbo 1.0 (40): navigazione GPS 3D, dock e vetro, trip, temperatura e potenze cockpit."""
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
assert p.count('CURRENT_PROJECT_VERSION = 55;')==2
assert p.count('MARKETING_VERSION = 1.0;')==2
assert p.count('PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;')==2
assert set(info['UISupportedInterfaceOrientations'])=={'UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'}
assert info['NSLocationWhenInUseUsageDescription'] and info['NSBluetoothAlwaysUsageDescription']
assert 'case gps, trips, battery, bms, settings, themes' in u
assert '@AppStorage("ecojumbo.mapEnabled") private var mapEnabled = true' in u
assert '@State private var selected: EcoTab = .gps' in u
assert 'case .dashboard:' not in u
assert 'ForEach([EcoTab.trips, .battery, .bms, .settings, .themes])' in u
assert 'if mapEnabled && selected == .gps {' in u
assert 'BluetoothGlyph()' in u and 'CockpitCornerControls' in u
# GPS è una modalità del cockpit, non una NavigationStack separata.
assert 'GPSCockpitDashboard(theme: theme, now: tick, mapEnabled: mapEnabled)' in u
assert 'NavigationStack { AppleMapsPanel() }' not in u
assert 'NavigationStack { RoutesPanel() }' not in u
assert 'case .gps: "GPS"' in u
assert 'case .maps' not in u and 'case .routes' not in u
assert 'GPSCockpitDashboard: View' in c
assert 'private struct GPSCockpitMap: View' in c
assert 'OpenSpeedCluster(speed: gps.currentSpeed(at: now)' in c
assert 'GPSCockpitMap(theme: theme)' in c
assert 'Map(position: $camera)' in c and 'UserAnnotation()' not in c
assert 'Annotation("", coordinate: coordinate, anchor: .center)' in c
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
assert 'selected = selected == tab ? .gps : tab' in u
assert 'mapEnabled.toggle()' in u and 'selected = .gps' in u
assert 'lastGPSCoordinate = fix.coordinate' in g
assert 'func currentCoordinate(at date: Date = Date())' in g
assert 'GPS in pausa' in g
# Build 33: distinguere ricezione posizione da velocità/trip BMS.
assert 'manager.distanceFilter = kCLDistanceFilterNone' in g
assert 'manager.pausesLocationUpdatesAutomatically = false' in g
assert 'func retryLocation()' in g
assert 'func isPermissionDenied' not in g
assert 'var isPermissionDenied: Bool' in g
assert 'fix.horizontalAccuracy <= 300' in g
assert 'Posizione troppo imprecisa: attiva Posizione precisa' in g
assert 'state = fix.horizontalAccuracy > 35' in g
assert 'date.timeIntervalSince(lastGoodCoordinateAt) < 45' in g
# Geocodifica subito; percorso solo con posizione reale.
assert 'func resumePendingRoute(origin: CLLocationCoordinate2D?) async' in t
assert 'func calculateRoadRoute(from origin: CLLocationCoordinate2D,' in t
assert 'pendingDestination = destination' in t
assert 'isWaitingForGPS = true' in t
assert 'searchResponse.mapItems.first' in t
assert t.index('searchResponse.mapItems.first') < t.index('guard let origin, CLLocationCoordinate2DIsValid(origin) else')
assert 'await navigation.resumePendingRoute(origin: gps.currentCoordinate())' in c
assert 'navigation.isWaitingForGPS' in c
assert 'Image(systemName: "location.slash")' not in c
assert 'gps.retryLocation()' in c  # solo pannello diagnostico aperto dall'utente
assert 'UIApplication.openSettingsURLString' in c  # link permessi nel pannello diagnostico
assert 'else if let destinationPoint = navigation.destinationCoordinate' in c

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
legacy = c[:c.index('private struct GPSExpandedReadings: View {')]
assert legacy.count('showsBar: true')==3 and legacy.count('showsBar: false')==3
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
assert 'Label("GPS", systemImage: "location.north.fill")' in c and 'Text("P")' not in c
assert 'SpeedLEDStream(d: d, speed: speed)' in c and 'SpeedScaleTicks(d: d)' in c
assert 'SegmentedGaugeBar(d:' in c

# Le linee usano lo stesso raggio effettivo; angoli inferiori retti.
assert 'ContinuousLowerLine: Shape' in u and 'struct ContinuousLowerGlow' in u
assert 'private struct ContinuousLowerTerminalFade: View' in u
assert '.mask(ContinuousLowerTerminalFade())' in u
assert 'ForEach([EcoTab.trips, .battery, .bms, .settings, .themes])' in u
assert 'private struct GPSLowerContour: Shape' in c
assert 'private struct GPSLowerShade: Shape' in c
assert 'private struct GPSLowerGlow: View' in c
assert 'GPSLowerGlow(theme: theme)' in c
assert 'private struct GPSLowerTerminalFade: View' in c
assert '.mask(GPSLowerTerminalFade())' in c
assert 'location: 0.17' in c and 'location: 0.83' in c
assert 'GPSLowerShade()' in c
assert 'GPSLowerContour()' in c
assert 'textTop - max(12, h * 0.014)' in c
assert 'let topHalfWidth = d * 0.325' in c
assert 'let footY = h * 0.937' in c
assert 'MapCamera(centerCoordinate: center' in c
assert '.mapStyle(.standard(elevation: mapControls.is3D ? .realistic : .flat))' in c
assert 'heading: heading, pitch: mapControls.is3D ? 55 : 0' in c
assert 'GPS e ricerca indirizzo nella STESSA barra' in c
assert 'private struct GPSSearchTopBand: Shape' not in c
assert 'GPSSearchTopBand()' not in c
assert 'private struct GPSSearchBottomFade: View' not in c
assert '.mask(GPSSearchBottomFade())' not in c
assert 'let dialMaskRadius = dialSize * 0.508' in c
assert 'let dialMaskFeather = max(12, min(28, fullHeight * 0.032))' in c
assert 'GPSSearchTopBand' not in c
assert 'GPSSearchBottomFade' not in c
assert 'let mapLocalDialY = fullHeight * (0.494 - 0.045)' in c
assert '.background(Color.clear)' in c
assert 'clipShape(RoundedRectangle(cornerRadius: 16' not in c
assert 'GPSCompactReadings' not in c  # nessun pannello sopra la mappa
assert 'buttonStart - max(9, w * 0.012)' in c
assert 'CockpitContourGeometry.roundedPath(points:' in u
assert 'CockpitContourGeometry.roundedPath(points:' in c
assert 'corners: [1, 4]' in c and 'corners: [1, 2]' in u
assert 'p.addLine(to: pt(' not in u
assert 'CornerDockGlow' not in u and 'FooterLightContour' not in c
assert 'private struct ContinuousHorizonLine: View' in c
# Top bar sfumata alle intersezioni con il cerchio in Home e GPS.
assert c.count('.mask(RadialGradient(stops: [') == 4
assert 'startRadius: ringRadius, endRadius: ringRadius + max(18, h * 0.070)' in c
assert 'startRadius: dialSize * 0.508,' in c
assert 'endRadius: dialSize * 0.508 + max(18, h * 0.070)' in c
assert c.count('Circle()\n                        .stroke(theme.accent.opacity(') == 2
assert c.count('.frame(width: dialSize * 0.985, height: dialSize * 0.985)') == 2
assert 'private struct HomeRingBridgeMask: Shape' in c
assert 'var beneathBridge = ContinuousLowerLine().path(in: rect)' in c
assert 'visible.addPath(beneathBridge)' in c
assert '.mask(HomeRingBridgeMask().fill(style: FillStyle(eoFill: true)))' in c
assert 'private struct HomeRingTerminalFade: View' in c
assert '.mask(HomeRingTerminalFade())' in c
assert 'let contactY = Self.ringBridgeContactY(in: geometry.size)' in c
assert 'let fadeStart = max(0, (contactY - max(20, h * 0.075)) / h)' in c
assert 'distanceSquaredMinusRadius(middle) > 0' in c
assert 'GaugeArc(start: 208, end: 332)' not in c
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
assert 'if mapEnabled && selected == .gps {' in u
assert 'selected == .gps' in u and '? max(4, h * 0.006)' in u
assert 'ForEach(EcoTab.allCases) { tab in' not in u
assert 'gpsButton("map.fill", active: mapEnabled' in u
assert 'gpsButton(isDay ? "moon.stars.fill" : "sun.max.fill"' in u
assert 'gpsButton("play.fill"' in u
assert 'mapControls.send(.toggleNavigation)' in u
assert 'mapControls.send(.toggleProjection)' in u
assert 'mapControls.send(.noseView)' in u
assert 'mapControls.send(.focusRoute)' not in u
assert 'accessibility: "Mostra intero percorso"' not in u
assert 'mapControls.send(.recenter)' in u
assert 'mapControls.send(.zoomIn)' in u
assert 'mapControls.send(.zoomOut)' in u
assert 'EcoCockpitDockGeometry.standardSide(width: width, height: screenHeight)' in u
assert 'screenHeight: h' in u
assert 'max(28, geometry.safeAreaInsets.bottom + 14, h * 0.055)' in u
assert '.position(x: w / 2, y: h - dockBottom - dockHeight / 2)' in u
assert 'let contentHeight = selected == .gps' in u
assert '.frame(width: w, height: contentHeight)' in u
assert '.position(x: w / 2, y: contentHeight / 2)' in u
assert '.padding(.bottom, selected == .gps ?' not in u
assert 'Color(white: 0.96) : Color(white: 0.19)' in u
assert '.shadow(color: .black.opacity(colorScheme == .light ? 0.10 : 0.90)' not in u
assert 'let gpsGap = width * 0.008' in u
# Sfumature neutre su entrambe le modalità.
assert 'private struct CockpitTopSoftShade: View' in c
assert 'geo.size.height * 0.125' in c
assert 'colorScheme == .light ? Color.white.opacity(0.83) : Color(white: 0.30).opacity(0.38)' in c
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
assert 'height: h * 0.955' in c
assert '.position(x: w * 0.68, y: h * 0.5225)' in c
# Trip persistente: riavvio app non cancella il parziale; azzeramento solo con long press.
assert 'UserDefaults.standard.double(forKey: "ecojumbo.gps.tripKm")' in g
assert 'UserDefaults.standard.set(tripKm, forKey: "ecojumbo.gps.tripKm")' in g
assert 'func resetTrip()' in g
assert 'UserDefaults.standard.set(0, forKey: "ecojumbo.gps.tripKm")' in g
assert 'UserDefaults.standard.set(0, forKey: "ecojumbo.gps.totalKm")' not in g
assert 'onLongPressGesture(minimumDuration: 1.3)' in c
assert 'GPSCompactReadings' not in c
assert 'GPSCompactReadings(theme: theme)' not in c
assert 'glassReading(' not in c
assert '.padding(.top, h * 0.0565)' in c
assert '.padding(.leading, w * 0.285)' in c
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
assert 'private struct GPSTripResetControl: View' in c
assert 'showsOdometer: true' in c
assert 'odometerKm: gps.hasOdometer ? gps.totalKm : nil' in c
assert 'RoundedRectangle(cornerRadius: max(14, min(29, height * 0.055))' not in c
assert '.black.opacity(0.35), .black.opacity(0.75)' not in c
assert '8 * controlSide - 7 * w * 0.008' in c
# Build 34: guida solo come freccia nel quadrante, neon velocità,
# mappa diurna e modalità chiaro/scuro/automatico con comando rapido.
assert 'private var maneuverSymbol: String?' in c
assert 'navigationArrow: maneuverSymbol' in c
assert 'navigationInstruction: navigation.guidanceInstruction' in c
assert 'showsGPSBadge' not in c
assert 'Text("GPS")' not in c[c.index('private struct OpenSpeedCluster: View {'):c.index('// Calcola la posizione più a sinistra possibile')]
assert 'if let navigationArrow {' in c
assert 'Image(systemName: navigationArrow)' in c
assert '.symbolRenderingMode(.monochrome)' in c
assert 'GPSAngularManeuverArrow' not in c
assert 'size: d * 0.124, weight: .semibold' in c
assert 'y: d * 0.241' in c
assert 'arrow.turn.up.left' in c and 'arrow.turn.up.right' in c
assert 'if navigation.isNavigating {\n                        HStack(spacing: 7) {' not in c
# Build 39: velocità leggibile in SwiftUI e senza disegno vettoriale.
assert 'Text(String(Int(speed.rounded())))' in c
assert '.font(.custom("Arial-BoldMT", size: d * 0.275))' in c
assert '.foregroundStyle(CockpitTheme.dischargeAccent)' in c
assert '.monospacedDigit()' in c
assert 'SpeedGlyphOutlineView' not in c
assert 'HollowSpeedNumber' not in c
assert 'import CoreText' not in c
assert 'Text("km/h")' in c
assert 'y: d * 0.755' in c
assert 'if let navigationArrow {' in c
assert 'Image(systemName: navigationArrow)' in c
assert '.symbolRenderingMode(.monochrome)' in c
assert 'GPSAngularManeuverArrow' not in c
assert 'size: d * 0.124, weight: .semibold' in c
assert 'y: d * 0.241' in c
assert 'arrow.turn.up.left' in c and 'arrow.turn.up.right' in c
assert 'enum EcoAppearanceMode: String, CaseIterable, Identifiable' in u
assert 'case dark = "Scuro", light = "Chiaro", automatic = "Automatico"' in u
assert '@AppStorage("ecojumbo.appearanceMode")' in u
assert '.preferredColorScheme(selectedAppearance.preferredScheme)' in u
assert 'appearanceMode = isDay' in u
assert 'sun.max.fill' in u and 'moon.stars.fill' in u
assert 'mapEnabled.toggle()' in u
assert 'appearanceMode = isDay' in u
assert 'GPSExpandedReadings(theme: theme, now: now)' in c
assert 'positionAvailable: gps.currentCoordinate(at: now) != nil' in c
assert 'Color.yellow : Color.gray' in c
assert 'let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)' in c
assert 'let panelWidth = max(1, w - EcoCockpitDockGeometry.rightInset(width: w) - panelLeft)' in c
assert 'GPSDiagnosticsView()' in c
assert 'GPSHeader: View' in c and 'showGPSDiagnostics = true' in c
assert 'lastNativeSpeed' in g and 'lastNativeSpeedAccuracy' in g
assert 'lastGPSFixTime = fix.timestamp' in g
assert 'hasPreciseLocation' in g  # resta disponibile nella diagnostica
assert 'nativeAccuracyGood' not in g  # non fa parte dei parametri 33
assert 'Color.black.opacity(0.27)' not in c[c.index('private struct GPSCockpitMap: View'):c.index('// Pannello standard senza mappa')]
assert 'Color.black.opacity(0.80)' not in c[c.index('private struct GPSCockpitMap: View'):c.index('// Pannello standard senza mappa')]
assert 'EcoCockpitDockGeometry.standardLeft(width: w, height: h)' in c
assert '.position(x: panelLeft + panelWidth / 2, y: cardsCenterY)' in c
assert '.frame(width: panelWidth, height: cardsHeight)' in c
assert 'let cardsTop = h * 0.099 + outerMargin' in c
assert 'let cardsBottom = h - dockBottom - dockHeight - outerMargin' in c
assert 'let mapLocalDialX = dialCenterX - fullWidth * 0.36' in c
assert 'let mapLocalDialY = fullHeight * (0.494 - 0.045)' in c
assert '.mask(RadialGradient(stops: [' in c
assert 'center: UnitPoint(x: mapLocalDialX / w, y: mapLocalDialY / h)' in c
assert 'startRadius: dialMaskRadius' in c
assert 'endRadius: dialMaskRadius + dialMaskFeather' in c
assert 'private struct GPSMapTopContourClip: Shape' in c
assert 'private struct GPSMapLowerContourClip: Shape' in c
assert '.mask(GPSMapTopContourClip())' in c
assert '.mask(GPSMapLowerContourClip())' in c
assert 'GPSLowerLineGeometry.points(' in c
assert 'GPSMapContourSpace.local(points[3], cockpit: cockpit)' in c
assert 'Color(white: 0.88).opacity(0.10)' in c
assert 'Color(white: 0.92).opacity(0.035)' in c
assert '.init(color: .clear, location: 0.62)' in c
expanded = c[c.index('private struct GPSExpandedReadings: View {'):]
assert expanded.count('showsBar: true') == 3
assert 'telemetryRow("Corrente batteria"' not in expanded
assert 'telemetryRow("Potenza istantanea"' not in expanded
assert expanded.count('telemetryRow("') == 5
assert 'let rowHeight = max(1, (innerHeight - headerHeight - 4 * dividerHeight) / 5)' in expanded
assert 'Text("TELEMETRIA")' in expanded
assert 'telemetryRow("DISL"' in expanded
assert 'GPSTripAltitudeSparkline(points: gps.altitudeProfile' in expanded
assert 'onLongPressGesture(minimumDuration: resettable ? 0.5 : 1.3)' not in expanded
assert 'onLongPressGesture(minimumDuration: 0.5)' in c
assert 'GPSTripResetControl(theme: theme)' in c
assert 'altitudeProfile.removeAll()' in g
assert 'recordTripAltitude(fix)' in g
assert 'tripElevationMeters' in g
assert 'if showsBar {' in expanded
assert 'TelemetrySlimBar(fraction: fraction, theme: theme)' in expanded
assert 'if let progress, progress > 0 {' in expanded
assert 'speedDiagnostic' in g and 'estimatedSpeed' not in g
assert 'manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation' in g
assert 'manager.requestLocation()' not in g
assert '.position(x: geometry.size.width * 0.165, y: geometry.size.height * 0.159)' not in u
assert 'Picker("Modalità schermo", selection: $appearanceMode)' in o
assert 'ForEach(EcoAppearanceMode.allCases)' in o
assert '.preferredColorScheme(.dark)' not in (r/'Ecojumbo/EcojumboApp.swift').read_text()
assert 'UIColor { traits in' in u
assert '.environment(\.colorScheme, colorScheme)' in c
assert 'Color.white.opacity(0.96)' not in c[c.index('private struct GPSCockpitMap: View'):c.index('// Pannello standard senza mappa')]
assert 'Color(red: 0.94, green: 0.96, blue: 0.985)' in c
assert 'Color(white: 0.32) : Color(white: 0.68)' in c
assert '@Environment(\.colorScheme) private var colorScheme' in t
assert 'private enum GPSManeuverIcon' in c
assert c.count('OpenSpeedCluster(speed: ') == 2
assert 'GPSManeuverIcon.symbol(for: navigation.guidanceInstruction)' in c
assert '@StateObject private var navigation = EcoNavigationStore.shared' in c
assert 'navigationArrow: maneuverSymbol' in c
assert 'GPSSearchTopBand()' not in c
assert 'VStack(alignment: .leading, spacing: 7)' in c
assert '.mask(RadialGradient(stops: [' in c
assert '.init(color: .white.opacity(0.58), location: 0.91)' in c
assert '.shadow(color: .black.opacity(0.88), radius: d * 0.025)' in c
assert 'if colorScheme == .light {' in c
# Build 36: pannelli Home ritagliati alla circonferenza in modalità
# diurna; nessun valore o bordo card può risultare sotto il tachimetro.
assert 'private struct DayWingOutsideDial: Shape' in c
assert 'path.addRect(rect)' in c
assert 'path.addEllipse(in: CGRect(x: center.x - radius,' in c
assert 'radius: dialSize * 0.495' in c
assert 'DayWingOutsideDial(center: CGPoint(x: w * 0.50, y: h * 0.507),' in c
assert '.fill(style: FillStyle(eoFill: true))' in c
assert 'if colorScheme == .light {' in c
assert 'PremiumWing(readings: leftRows' in c and 'PremiumWing(readings: rightRows' in c
# Build 38: Core Location riparte in foreground, fix mappa e speed disaccoppiati.
assert 'func speedStatus(at date: Date = Date()) -> String' in g
assert 'lastHorizontalAccuracy = fix.horizontalAccuracy' in g
assert 'fix.horizontalAccuracy <= 35' in g  # soglia tachimetro build 33
assert 'let usableSpeed = abs(fix.timestamp.timeIntervalSinceNow) < 10' in g
assert 'fix.speedAccuracy >= 0' in g and 'fix.speedAccuracy <= 5' in g
assert 'date.timeIntervalSince(lastValidAt) < 8' in g
assert 'if usableSpeed {' in g
assert 'date.timeIntervalSince(lastValidAt) < 8' in g
assert 'if speedKmh < 1.5 {' not in g
assert 'fix.horizontalAccuracy <= 35' in g and 'fix.speedAccuracy <= 5' in g
assert 'if phase == .active { gps.retryLocation() }' in (r/'Ecojumbo/EcojumboApp.swift').read_text()
assert 'Text(gps.speedStatus(at: now))' not in c
assert 'gps.speedStatus()' in c  # diagnostica solo su richiesta
assert 'if liveSpeed == nil {' not in c
assert 'if gps.currentCoordinate() == nil || gps.currentSpeed() == nil {' not in c
assert 'func speedStatus(at date: Date = Date()) -> String' in g
assert 'CGPoint(x: 0, y: h * 0.099)' in c
assert 'CGPoint(x: w, y: h * 0.099)' in c
assert 'CGPoint(x: w * 0.54, y: h * 0.099)' in c
assert 'CGPoint(x: w * 0.745, y: h * 0.099)' in c
assert 'CGPoint(x: w * 0.355, y: h * 0.252)' in c
assert 'CGPoint(x: w * 0.25, y: h * 0.244)' in c
assert 'let mapLocalDialY = fullHeight * (0.494 - 0.045)' in c
assert 'let mapLocalDialY = fullHeight * (0.494 - 0.045)' in c
assert '.padding(.top, h * 0.0565)' in c
# Build 40: estensione della mappa, freccia GPS, contrasto daylight,
# controlli minimal e avvio Core Location più rapido.
assert '.frame(width: w * 0.64, height: h * 0.955)' in c
assert '.position(x: w * 0.68, y: h * 0.5225)' in c
assert 'let fullWidth = w / 0.64' in c
assert 'let fullHeight = h / 0.955' in c
assert '.init(color: .white.opacity(0.70), location: 0.91)' in c
assert 'UserAnnotation()' not in c
assert 'Annotation("", coordinate: coordinate, anchor: .center)' in c
assert '(gps.currentHeading() ?? 0) - (visibleCamera?.heading ?? 0)' in c
assert 'struct BluetoothGlyph:View {' in c
assert '.stroke(colorScheme == .light ? Color(white: 0.16) : .white,' in c
assert 'Color.black.opacity(0.33)' in c
assert 'Text(text)' in u and 'foregroundStyle(colorScheme == .light ? Color(white: 0.16) : .white)' in u
assert 'Color(white: 0.96) : Color(white: 0.19)' in u
assert 'Color(white: 0.92) : Color(white: 0.08)' in u
assert 'if selected == .gps { mapEnabled.toggle() }' in u
assert 'manager.desiredAccuracy = kCLLocationAccuracyBest\n' not in g
assert 'manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation' in g
assert 'manager.requestLocation()' not in g
assert 'manager.startUpdatingHeading()' in g
assert 'func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading)' in g
assert 'func currentHeading(at date: Date = Date())' in g
assert 'func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager)' in g
assert 'heading.headingAccuracy <= 45' in g
print('OK — 51: mappa e layout invariati, GPS nativo ripristinato dalla build 33')
