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

struct RoutesPanel: View {
    @EnvironmentObject private var gps: GPSRideManager
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        VStack(spacing: 0) {
            if gps.track.count >= 2 {
                Map(position: $position) {
                    MapPolyline(coordinates: gps.track.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
                        .stroke(Color.ecoGreen, lineWidth: 5)
                }
                .mapStyle(.standard(elevation: .flat))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack {
                    Label(String(format: "%.2f km", gps.tripKm), systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    Spacer()
                    Text("Solo traccia GPS registrata nell'app").font(.caption).foregroundStyle(.secondary)
                }.padding(12)
            } else {
                ContentUnavailableView("Nessun percorso ancora registrato", systemImage: "map",
                    description: Text("Autorizza la posizione e percorri un tragitto con Ecojumbo aperta. Non vengono inventate posizioni GPS."))
            }
        }
        .background(Color.ecoBackground)
        .navigationTitle("Percorsi")
        .toolbar {
            if gps.track.count > 1 {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Mostra percorso", systemImage: "scope") { position = .automatic }
                }
            }
        }
    }
}

struct GoogleMapsPanel: View {
    @Environment(\.openURL) private var openURL
    @AppStorage("ecojumbo.mapsDestination") private var destination = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                EcoCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Google Maps", systemImage: "location.north.fill").font(.title2.bold())
                        Text("Apri la navigazione in Google Maps. Il percorso attivo resta nell'app Google Maps, non sopra il tachimetro Ecojumbo.")
                            .font(.subheadline).foregroundStyle(.secondary)
                        TextField("Destinazione (facoltativa)", text: $destination)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                        HStack {
                            Button { launchMap() } label: {
                                Label(destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Apri Google Maps" : "Ottieni indicazioni", systemImage: "arrow.up.right")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.ecoGreen)
                        }
                    }
                }
                Text("Nessuna API a pagamento: il pulsante utilizza i link universali ufficiali di Google Maps. Per seguire la navigazione, Google Maps passa in primo piano; iOS può sospendere le misure raccolte da Ecojumbo.")
                    .font(.footnote).foregroundStyle(.secondary)
            }.padding(16)
        }
        .background(Color.ecoBackground)
        .navigationTitle("Navigazione")
    }

    private func launchMap() {
        let trimmed = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.google.com"
        components.path = trimmed.isEmpty ? "/maps/@" : "/maps/dir/"
        components.queryItems = trimmed.isEmpty
            ? [URLQueryItem(name: "api", value: "1"), URLQueryItem(name: "map_action", value: "map")]
            : [URLQueryItem(name: "api", value: "1"), URLQueryItem(name: "destination", value: trimmed),
               URLQueryItem(name: "travelmode", value: "driving")]
        if let url = components.url { openURL(url) }
    }
}

struct ThemePickerView: View {
    @AppStorage("ecojumbo.theme") private var selection = CockpitTheme.copper.rawValue
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 13), count: 3)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Seleziona uno dei sei kit colori: le curve, gli anelli e le icone luminose cambiano insieme. Le misurazioni restano reali e leggibili.")
                    .font(.subheadline).foregroundStyle(.secondary)
                LazyVGrid(columns: columns, spacing: 13) {
                    ForEach(CockpitTheme.allCases) { theme in
                        Button { selection = theme.rawValue } label: {
                            VStack(spacing: 7) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.black.opacity(0.72))
                                    Capsule()
                                        .stroke(theme.accent, lineWidth: 3)
                                        .shadow(color: theme.accent.opacity(0.62), radius: 8)
                                        .frame(width: 96, height: 37)
                                    Circle().fill(theme.accent)
                                        .frame(width: 16, height: 16)
                                    if selection == theme.rawValue {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(theme.accent)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                            .padding(5)
                                    }
                                }
                                .frame(height: 61)
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
                        .accessibilityLabel("Tema \(theme.rawValue)")
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
