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

    private init() {}

    func plan(destination rawQuery: String, origin: CLLocationCoordinate2D?) async {
        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            errorMessage = "Inserisci un indirizzo o il nome di una destinazione."
            return
        }
        guard let origin, CLLocationCoordinate2DIsValid(origin) else {
            errorMessage = "Attendi una posizione GPS valida e autorizza la localizzazione."
            return
        }
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = query
            let search = MKLocalSearch(request: searchRequest)
            let searchResponse = try await search.start()
            guard let destination = searchResponse.mapItems.first else {
                errorMessage = "Destinazione non trovata. Prova a specificare anche la città."
                return
            }
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
            request.destination = destination
            request.transportType = .automobile
            request.requestsAlternateRoutes = false
            let response = try await MKDirections(request: request).calculate()
            guard let roadRoute = response.routes.first else {
                errorMessage = "Non è disponibile un percorso stradale per questa destinazione."
                return
            }
            route = roadRoute
            destinationName = destination.name ?? query
            destinationCoordinate = destination.placemark.coordinate
            routeRevision += 1
        } catch {
            errorMessage = "Impossibile calcolare il percorso: \(error.localizedDescription)"
        }
    }

    func clear() {
        route = nil
        destinationName = ""
        destinationCoordinate = nil
        errorMessage = nil
        routeRevision += 1
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
