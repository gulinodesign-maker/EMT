import SwiftUI
import MapKit

struct TripsPanel: View {
    @EnvironmentObject private var gps: GPSRideManager
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    @State private var confirmReset = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    dataTile("Trip GPS", value: (gps.isReceiving || gps.tripKm > 0) ? String(format: "%.2f km", gps.tripKm) : "— km",
                             symbol: "location")
                    dataTile("Contachilometri", value: gps.hasOdometer ? String(format: "%.0f km", gps.totalKm) : "— km",
                             symbol: "number.square")
                }
                HStack(spacing: 12) {
                    dataTile("Energia uscita", value: bluetooth.session.points.isEmpty ? "— kWh" : String(format: "%.3f kWh", bluetooth.session.dischargedKWh), symbol: "bolt.fill")
                    dataTile("Energia ingresso", value: bluetooth.session.points.isEmpty ? "— kWh" : String(format: "%.3f kWh", bluetooth.session.chargedKWh), symbol: "arrow.down.circle")
                }
                HStack(spacing: 12) {
                    dataTile("Potenza media", value: bluetooth.session.averageDischargeKW.map { String(format: "%.2f kW", $0) } ?? "— kW", symbol: "chart.bar")
                    dataTile("Corrente scaricata", value: bluetooth.session.points.isEmpty ? "— Ah" : String(format: "%.1f Ah", bluetooth.session.dischargedAh), symbol: "battery.50percent")
                }
                EcoCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Registrazione viaggio").font(.headline)
                        Text("Le misure vengono raccolte soltanto quando arrivano dati reali e l'app è attiva. La carica in ingresso comprende sia ricarica sia rigenerazione.")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Text(gps.state).font(.subheadline).foregroundStyle(.secondary)
                        Button(role: .destructive) { confirmReset = true } label: {
                            Label("Azzera trip e sessione BMS", systemImage: "arrow.counterclockwise")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }.padding(16)
        }
        .scrollContentBackground(.hidden)
        .background(Color.ecoBackground)
        .navigationTitle("Viaggi")
        .confirmationDialog("Azzerare il viaggio parziale e i consumi della sessione?", isPresented: $confirmReset,
                            titleVisibility: .visible) {
            Button("Azzera viaggio", role: .destructive) {
                gps.resetTrip()
                bluetooth.session.reset()
            }
        }
    }

    private func dataTile(_ title: String, value: String, symbol: String) -> some View {
        EcoCard {
            VStack(alignment: .leading, spacing: 9) {
                Label(title, systemImage: symbol).font(.subheadline).foregroundStyle(.secondary)
                Text(value).font(.system(size: 24, weight: .bold, design: .rounded))
                    .monospacedDigit().lineLimit(1).minimumScaleFactor(0.65)
            }
        }
    }
}

// EJ 1.20: piano stradale condiviso fra Navigazione e Percorsi.
// MKDirections restituisce la geometria delle strade, non semplici segmenti GPS.
@MainActor
final class EcoNavigationStore: ObservableObject {
    static let shared = EcoNavigationStore()

    @Published private(set) var route: MKRoute?
    @Published private(set) var destinationCoordinate: CLLocationCoordinate2D?
    @Published private(set) var destinationName: String = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var routeRevision = 0
    @Published private(set) var isNavigating = false
    @Published private(set) var hasArrived = false
    @Published private(set) var guidanceInstruction = ""
    @Published private(set) var guidanceDistanceMeters: CLLocationDistance?
    @Published private(set) var isWaitingForGPS = false
    private var pendingDestination: MKMapItem?
    private var nextStepIndex = 0

    private init() {}

    func plan(destination rawQuery: String, origin: CLLocationCoordinate2D?) async {
        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            errorMessage = "Inserisci un indirizzo o il nome di una destinazione."
            return
        }
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Cerca la destinazione ANCHE se il GPS non ha ancora una partenza.
            // Nessuna coordinata viene simulata per costruire la rotta.
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = query
            if let origin, CLLocationCoordinate2DIsValid(origin) {
                searchRequest.region = MKCoordinateRegion(
                    center: origin, latitudinalMeters: 80_000, longitudinalMeters: 80_000)
            }
            let searchResponse = try await MKLocalSearch(request: searchRequest).start()
            guard let destination = searchResponse.mapItems.first else {
                errorMessage = "Destinazione non trovata. Specifica indirizzo e città."
                return
            }
            stopNavigation()
            route = nil
            destinationName = destination.name ?? query
            destinationCoordinate = destination.placemark.coordinate
            routeRevision += 1

            guard let origin, CLLocationCoordinate2DIsValid(origin) else {
                pendingDestination = destination
                isWaitingForGPS = true
                errorMessage = "Destinazione trovata. In attesa di un GPS preciso per il percorso."
                return
            }
            await calculateRoadRoute(from: origin, to: destination)
        } catch {
            errorMessage = "Ricerca indirizzo non riuscita: \(error.localizedDescription)"
        }
    }

    /// Appena Core Location restituisce una posizione reale, completa
    /// automaticamente il percorso richiesto mentre il GPS era assente.
    func resumePendingRoute(origin: CLLocationCoordinate2D?) async {
        guard !isLoading, isWaitingForGPS, let pendingDestination,
              let origin, CLLocationCoordinate2DIsValid(origin) else { return }
        isLoading = true
        isWaitingForGPS = false
        defer { isLoading = false }
        await calculateRoadRoute(from: origin, to: pendingDestination)
    }

    private func calculateRoadRoute(from origin: CLLocationCoordinate2D,
                                    to destination: MKMapItem) async {
        do {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
            request.destination = destination
            request.transportType = .automobile
            request.requestsAlternateRoutes = false
            let response = try await MKDirections(request: request).calculate()
            guard let roadRoute = response.routes.first else {
                errorMessage = "MapKit non trova una strada percorribile per la destinazione."
                return
            }
            route = roadRoute
            pendingDestination = nil
            isWaitingForGPS = false
            errorMessage = nil
            routeRevision += 1
        } catch {
            errorMessage = "Percorso non disponibile: \(error.localizedDescription)"
        }
    }

    func clear() {
        stopNavigation()
        route = nil
        pendingDestination = nil
        isWaitingForGPS = false
        destinationName = ""
        destinationCoordinate = nil
        errorMessage = nil
        routeRevision += 1
    }

    // La pianificazione non equivale all'avvio: si entra in navigazione
    // soltanto premendo esplicitamente il pulsante Avvia e con GPS valido.
    @discardableResult
    func startNavigation(at origin: CLLocationCoordinate2D?) -> Bool {
        guard let route else {
            errorMessage = "Calcola prima un percorso stradale."
            return false
        }
        guard let origin, CLLocationCoordinate2DIsValid(origin) else {
            errorMessage = "Attendi una posizione GPS valida prima di avviare la navigazione."
            return false
        }
        errorMessage = nil
        hasArrived = false
        isNavigating = true
        nextStepIndex = route.steps.firstIndex {
            !$0.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } ?? 0
        updateProgress(at: origin)
        return true
    }

    func stopNavigation() {
        isNavigating = false
        hasArrived = false
        nextStepIndex = 0
        guidanceInstruction = ""
        guidanceDistanceMeters = nil
    }

    // Avanzamento indicativo delle manovre secondo il percorso MapKit.
    // Non simula una posizione né sostituisce la guida e la segnaletica.
    func updateProgress(at coordinate: CLLocationCoordinate2D) {
        guard isNavigating, let route,
              CLLocationCoordinate2DIsValid(coordinate) else { return }
        let here = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if let destinationCoordinate {
            let finish = CLLocation(latitude: destinationCoordinate.latitude,
                                    longitude: destinationCoordinate.longitude)
            if here.distance(from: finish) < 35 {
                isNavigating = false
                hasArrived = true
                guidanceInstruction = "Destinazione raggiunta"
                guidanceDistanceMeters = 0
                return
            }
        }
        let steps = route.steps
        guard !steps.isEmpty else {
            guidanceInstruction = "Segui il percorso evidenziato"
            guidanceDistanceMeters = nil
            return
        }
        // L'ultimo punto della polilinea di ciascuna tappa rappresenta
        // la manovra seguente. Passa alla prossima solo quando è vicina.
        while nextStepIndex < steps.count - 1 {
            let segment = steps[nextStepIndex].polyline
            if segment.pointCount == 0 {
                nextStepIndex += 1
                continue
            }
            let lastPoint = segment.points()[segment.pointCount - 1].coordinate
            let target = CLLocation(latitude: lastPoint.latitude,
                                    longitude: lastPoint.longitude)
            if here.distance(from: target) > 25 { break }
            nextStepIndex += 1
        }
        let step = steps[min(nextStepIndex, steps.count - 1)]
        let instruction = step.instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        guidanceInstruction = instruction.isEmpty ? "Segui il percorso evidenziato" : instruction
        if step.polyline.pointCount > 0 {
            let point = step.polyline.points()[step.polyline.pointCount - 1].coordinate
            guidanceDistanceMeters = here.distance(from: CLLocation(
                latitude: point.latitude, longitude: point.longitude))
        } else {
            guidanceDistanceMeters = nil
        }
    }

    var guidanceDistanceLabel: String {
        guard let distance = guidanceDistanceMeters, distance.isFinite else { return "—" }
        return distance >= 1000
            ? String(format: "%.1f km", distance / 1000)
            : "\(Int((distance / 10).rounded() * 10)) m"
    }

    var distanceLabel: String {
        guard let route else { return "— km" }
        return String(format: "%.1f km", route.distance / 1000)
    }

    var travelTimeLabel: String {
        guard let route else { return "— min" }
        let minutes = max(1, Int((route.expectedTravelTime / 60).rounded()))
        return minutes < 60 ? "\(minutes) min" : "\(minutes / 60) h \(minutes % 60) min"
    }
}

// EJ 1.21 — un solo cockpit GPS. Nessuna schermata Percorsi/Mappe separata.
// EcoNavigationStore resta condiviso e mantiene la rotta quando si cambia modalità.

struct ThemePickerView: View {
    @AppStorage("ecojumbo.theme") private var selection = CockpitTheme.copper.rawValue
    // Sempre tre a tre: sei temi disposti in due righe da tre.
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 13), count: 3)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Ogni anteprima mostra i colori reali del tema: fondo, luce, ombra, acciaio, tre colori della barra e rigenerazione.")
                    .font(.subheadline).foregroundStyle(.secondary)
                LazyVGrid(columns: columns, spacing: 13) {
                    ForEach(CockpitTheme.allCases) { theme in
                        Button { selection = theme.rawValue } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 13)
                                        .fill(theme.previewPalette[0])
                                    Circle()
                                        .stroke(theme.secondary, lineWidth: 3)
                                        .frame(width: 51, height: 51)
                                    Circle()
                                        .trim(from: 0.10, to: 0.84)
                                        .stroke(theme.accent,
                                                style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                        .rotationEffect(.degrees(85))
                                        .frame(width: 43, height: 43)
                                        .shadow(color: theme.accent.opacity(0.7), radius: 7)
                                    Text("—")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(theme.steel)
                                    Capsule()
                                        .fill(LinearGradient(colors: [CockpitTheme.barDark,
                                                                      CockpitTheme.barMid,
                                                                      CockpitTheme.barBright],
                                                             startPoint: .leading, endPoint: .trailing))
                                        .frame(width: 61, height: 4)
                                        .offset(x: 56, y: 19)
                                    if selection == theme.rawValue {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(theme.accent)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity,
                                                   alignment: .topTrailing)
                                            .padding(6)
                                    }
                                }
                                .frame(height: 72)
                                // Tutte le otto tonalita principali realmente presenti nel cockpit.
                                HStack(spacing: 4) {
                                    ForEach(theme.previewPalette.indices, id: \.self) { i in
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(theme.previewPalette[i])
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 12)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .stroke(.white.opacity(0.28), lineWidth: 0.5)
                                            }
                                    }
                                }
                                Text(theme.rawValue)
                                    .font(.system(size: 15, weight: .semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.70)
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.ecoCard, in:
                                RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .stroke(selection == theme.rawValue ? theme.accent : .white.opacity(0.16),
                                            lineWidth: selection == theme.rawValue ? 2 : 1)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Tema \(theme.rawValue), otto colori in anteprima")
                        .accessibilityAddTraits(selection == theme.rawValue ? .isSelected : [])
                    }
                }
            }
            .padding(15)
        }
        .background(Color.ecoBackground)
        .navigationTitle("Kit colori")
    }
}
