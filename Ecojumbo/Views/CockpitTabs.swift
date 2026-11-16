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


// Build 74: ruoli esistenti 10 (normale), 14 (decelerazione), 17 (limite); 18 (accelerazione).
// I valori 15 e 16 rimangono riservati e salvati per compatibilità.
struct EcoThemePalette: Codable, Equatable {
    var name: String
    var colors: [String]
    var glowIntensity: Double
    var topFadeIntensity: Double
    var bottomFadeIntensity: Double

    init(name: String, colors: [String], glowIntensity: Double = 0.60,
         topFadeIntensity: Double = 0.35, bottomFadeIntensity: Double = 0.35) {
        self.name = name
        self.colors = colors
        self.glowIntensity = glowIntensity.isFinite ? min(1, max(0, glowIntensity)) : 0.60
        self.topFadeIntensity = topFadeIntensity.isFinite ? min(1, max(0, topFadeIntensity)) : 0.35
        self.bottomFadeIntensity = bottomFadeIntensity.isFinite ? min(1, max(0, bottomFadeIntensity)) : 0.35
    }

    // Le palette 63–72 non contenevano intensità: default retrocompatibile.
    private enum CodingKeys: String, CodingKey {
        case name, colors, glowIntensity, topFadeIntensity, bottomFadeIntensity
    }

    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)
        name = try data.decode(String.self, forKey: .name)
        colors = try data.decode([String].self, forKey: .colors)
        let saved = try data.decodeIfPresent(Double.self, forKey: .glowIntensity) ?? 0.60
        glowIntensity = saved.isFinite ? min(1, max(0, saved)) : 0.60
        // Migrazione automatica e non distruttiva degli slot fino alla 90:
        // gli antichi JSON non contengono queste proprietà.
        let high = try data.decodeIfPresent(Double.self, forKey: .topFadeIntensity) ?? 0.35
        let low = try data.decodeIfPresent(Double.self, forKey: .bottomFadeIntensity) ?? 0.35
        topFadeIntensity = high.isFinite ? min(1, max(0, high)) : 0.35
        bottomFadeIntensity = low.isFinite ? min(1, max(0, low)) : 0.35
    }

    func encode(to encoder: Encoder) throws {
        var data = encoder.container(keyedBy: CodingKeys.self)
        try data.encode(name, forKey: .name)
        try data.encode(colors, forKey: .colors)
        try data.encode(glowIntensity, forKey: .glowIntensity)
        try data.encode(topFadeIntensity, forKey: .topFadeIntensity)
        try data.encode(bottomFadeIntensity, forKey: .bottomFadeIntensity)
    }

    // L'ordine 0...7 resta invariato per migrare gli slot personalizzati della build 63.
    static let labels = [
        "Sfondo del cockpit",
        "Colore principale · top bar e icone Setup",
        "Luce sfumata sotto il layer della top bar",
        "Dettagli metallici del quadrante",
        "Barre telemetria · colore scuro",
        "Barre telemetria · colore intermedio",
        "Barre telemetria · colore luminoso",
        "Numeri kW · energia in ingresso",
        "Anello esterno · potenza erogata",
        "Anello interno · recupero energia",
        "Velocità GPS · fase normale",
        "Numeri del tachimetro · km/h",
        "Navigatore · svolta a destra",
        "Navigatore · svolta a sinistra",
        "Velocità GPS · fase decelerazione",
        "Layer top bar · sfumatura sinistra",
        "Layer top bar · sfumatura destra",
        "Velocità GPS · limite superato",
        "Velocità GPS · fase accelerazione",
        "Layer top bar · sfumatura alta",
        "Layer top bar · sfumatura bassa"
    ]
    static let details = [
        "Fondo scuro dietro gli strumenti.",
        "Stesso colore per linee della top bar, contorni e tutte le icone della griglia 3×4 in Impostazioni.",
        "Colore modificabile della luce diffusa che traspare sotto il layer GPS.",
        "Colore dei dettagli effetto acciaio.",
        "Prima tonalità delle barre di telemetria.",
        "Tonalità centrale delle barre di telemetria.",
        "Tonalità brillante delle barre di telemetria.",
        "Numero della potenza che entra nella batteria (kW); non dimostra da sola che si sta frenando.",
        "Corona segmentata esterna: potenza in uscita dal BMS.",
        "Corona segmentata interna: energia in ingresso alla batteria, da carica o recupero.",
        "Colore normale dell’arco GPS quando la variazione resta entro ±5 km/h.",
        "Cifre grandi della velocità GPS al centro.",
        "Freccia e distanza della prossima svolta verso destra.",
        "Freccia e distanza della prossima svolta verso sinistra.",
        "Colore dell’arco GPS quando la velocità cala di oltre 5 km/h nella finestra di osservazione; non indica il freno fisico.",
        "Primo colore della superficie sfumata del nuovo layer superiore GPS.",
        "Secondo colore della superficie sfumata del nuovo layer superiore GPS.",
        "Colore della barra LED quando la velocità GPS raggiunge il limite attivato in Barre luminose.",
        "Colore dell’arco GPS quando la velocità aumenta di oltre 5 km/h nella finestra di osservazione.",
        "Sfumatura verticale dal bordo alto verso il centro del layer esterno; colore e intensità indipendenti.",
        "Sfumatura verticale dal bordo basso verso il centro del layer esterno; colore e intensità indipendenti."
    ]
    // L'ordine visibile colloca le quattro fasi GPS in un'unica categoria,
    // senza duplicare il colore normale (indice 10) né il colore di decelerazione (14).
    static let groups: [(title: String, range: [Int])] = [
        ("Aspetto generale", Array(0..<4)),
        ("Barre telemetria e potenza", Array(4..<8)),
        ("Anelli e numeri del tachimetro", [8, 9, 11]),
        ("Navigatore", [12, 13]),
        ("Velocità oltre soglia", [14, 10, 18, 17]),
        ("Layer top bar", [15, 16, 19, 20, 2])
    ]
    static let colorCount = 21
    static let extraDefaults = [
        "#FA2B2E", "#2BBAFF", "#FF7008", "#FA2B2E",
        "#FFFFFF", "#FFFFFF", "#FFB224"
    ]
    static let standardBarColors = ["#8C0521", "#E90F3B", "#FC3352", "#2BBAFF"]
    static let storagePrefix = "ecojumbo.customTheme."

    static func validHex(_ code: String) -> Bool {
        let hex = code.hasPrefix("#") ? String(code.dropFirst()) : code
        return hex.count == 6 && hex.allSatisfy { $0.isHexDigit }
    }

    static func template(_ preset: CockpitTheme) -> EcoThemePalette {
        let foreground: (String, String)
        switch preset {
        case .glacier: foreground = ("#B0E0FA", "#3082BA")
        case .green: foreground = ("#42DB68", "#1A7A42")
        case .aquamarine: foreground = ("#47E0CE", "#1A787D")
        case .brown: foreground = ("#BA6E38", "#5E301F")
        case .racing: foreground = ("#F73B38", "#A11726")
        default: foreground = ("#FF7008", "#BF3D17")
        }
        return EcoThemePalette(
            name: "Il mio tema",
            colors: ["#040405", foreground.0, foreground.1, "#D9DEE3"]
                + standardBarColors + extraDefaults
                + [foreground.1, foreground.1, "#FF3B30", "#FF3B30",
                   foreground.1, foreground.0]
        )
    }

    static func load(slot: Int) -> EcoThemePalette? {
        guard (1...3).contains(slot),
              let data = UserDefaults.standard.data(forKey: storagePrefix + String(slot)),
              let decoded = try? JSONDecoder().decode(EcoThemePalette.self, from: data),
              (decoded.colors.count == 8 || decoded.colors.count == 15 ||
               decoded.colors.count == 17 || decoded.colors.count == 18 ||
               decoded.colors.count == 19 || decoded.colors.count == colorCount),
              decoded.colors.allSatisfy({ validHex($0) }) else { return nil }
        // Migrazione non distruttiva: gli 8 colori delle build 63 restano identici.
        var migrated = decoded
        if migrated.colors.count == 8 {
            migrated.colors.append(contentsOf: extraDefaults)
            // La corona in ingresso eredita il colore già scelto per il recupero.
            migrated.colors[9] = decoded.colors[7]
        }
        // Migrazione 8→15→17 e 15→17 senza modificare i colori già salvati.
        if migrated.colors.count == 15 {
            let edge = migrated.colors[2]
            migrated.colors.append(contentsOf: [edge, edge])
        }
        // 8→15→17→18 oppure 15→17→18 o 17→18 senza perdere i vecchi colori.
        if migrated.colors.count == 17 {
            migrated.colors.append("#FF3B30")
        }
        // Build 73: il colore oltre soglia 17 resta invariato, si aggiunge
        // soltanto la fase di accelerazione per arrivare a 19 ruoli.
        if migrated.colors.count == 18 {
            migrated.colors.append("#FF3B30")
        }
        // Build 91: 19 → 21 (e anche le palette 8/15/17/18): aggiungere
        // due nuovi colori senza modificare nessuno dei 19 precedenti.
        if migrated.colors.count == 19 {
            migrated.colors.append(contentsOf: [
                migrated.colors[15], migrated.colors[16]
            ])
        }
        return migrated
    }

    @discardableResult
    static func save(_ palette: EcoThemePalette, slot: Int) -> Bool {
        guard (1...3).contains(slot), palette.colors.count == colorCount,
              palette.glowIntensity.isFinite, (0...1).contains(palette.glowIntensity),
              palette.topFadeIntensity.isFinite, (0...1).contains(palette.topFadeIntensity),
              palette.bottomFadeIntensity.isFinite, (0...1).contains(palette.bottomFadeIntensity),
              palette.colors.allSatisfy({ validHex($0) }),
              let data = try? JSONEncoder().encode(palette) else { return false }
        UserDefaults.standard.set(data, forKey: storagePrefix + String(slot))
        return true
    }

    static func remove(slot: Int) {
        guard (1...3).contains(slot) else { return }
        UserDefaults.standard.removeObject(forKey: storagePrefix + String(slot))
    }

    static var active: EcoThemePalette? {
        guard let key = UserDefaults.standard.string(forKey: "ecojumbo.theme"),
              let slot = CockpitTheme(rawValue: key)?.slotIndex else { return nil }
        return load(slot: slot)
    }

    static func colorHex(_ color: UIColor) -> String {
        let value = color.resolvedColor(with: .init(userInterfaceStyle: .light))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard value.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return "#000000"
        }
        let r = Int((max(0, min(1, red)) * 255).rounded())
        let g = Int((max(0, min(1, green)) * 255).rounded())
        let b = Int((max(0, min(1, blue)) * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension Color {
    init(themeHex code: String) {
        let hex = code.hasPrefix("#") ? String(code.dropFirst()) : code
        guard hex.count == 6, let rgb = UInt64(hex, radix: 16) else {
            self = Color(red: 0, green: 0, blue: 0)
            return
        }
        self = Color(.sRGB,
                     red: Double((rgb >> 16) & 0xFF) / 255.0,
                     green: Double((rgb >> 8) & 0xFF) / 255.0,
                     blue: Double(rgb & 0xFF) / 255.0,
                     opacity: 1)
    }
}

private struct EcoThemeEditorSession: Identifiable {
    let id = UUID()
    let palette: EcoThemePalette
    let slot: Int?
}

private struct EcoThemeColorID: Identifiable {
    let id: Int
}

struct ThemePickerView: View {
    var portrait: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("ecojumbo.theme") private var selection = CockpitTheme.copper.rawValue
    @AppStorage("ecojumbo.themeRevision") private var revision = 0
    @State private var editor: EcoThemeEditorSession?
    @State private var deletingSlot: Int?

    private let landscapeColumns = Array(repeating: GridItem(.flexible(), spacing: 13), count: 3)
    private let portraitColumns = [GridItem(.flexible(), spacing: 13)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Tre temi personali. Tieni premuto ogni quadratino nel configuratore per scegliere il suo colore. Salva il risultato in uno degli slot.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: portrait ? portraitColumns : landscapeColumns, spacing: 13) {
                    ForEach(1...3, id: \.self) { slot in
                        slotCard(slot)
                    }
                }
                Button {
                    openEditor(slot: nil)
                } label: {
                    Label("Crea un nuovo tema", systemImage: "paintbrush.pointed")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(CockpitTheme(rawValue: selection)?.accent ?? .orange)

                Text("I sei kit originali sono disponibili solo come punto di partenza nel configuratore. Nessuna modifica viene applicata al cruscotto prima del salvataggio.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(15)
        }
        .background(Color.ecoBackground)
        .navigationTitle("Kit colori")
        .sheet(item: $editor) { item in
            EcoThemeEditorView(initial: item.palette, initialSlot: item.slot) { slot, palette in
                guard EcoThemePalette.save(palette, slot: slot) else { return }
                revision += 1
                activate(slot: slot)
            }
        }
        .confirmationDialog(
            "Svuotare lo slot \(deletingSlot ?? 0)?",
            isPresented: Binding(get: { deletingSlot != nil },
                                 set: { if !$0 { deletingSlot = nil } }),
            titleVisibility: .visible
        ) {
            Button("Elimina tema", role: .destructive) {
                guard let slot = deletingSlot else { return }
                EcoThemePalette.remove(slot: slot)
                if CockpitTheme(rawValue: selection)?.slotIndex == slot {
                    selection = CockpitTheme.copper.rawValue
                }
                revision += 1
                deletingSlot = nil
            }
            Button("Annulla", role: .cancel) { deletingSlot = nil }
        } message: {
            Text("Il tema salvato verrà eliminato soltanto da questo iPhone.")
        }
    }

    @ViewBuilder private func slotCard(_ slot: Int) -> some View {
        let palette = EcoThemePalette.load(slot: slot)
        let active = CockpitTheme(rawValue: selection)?.slotIndex == slot && palette != nil
        VStack(spacing: 10) {
            if let palette {
                Button { activate(slot: slot) } label: {
                    EcoThemePreview(palette: palette, active: active)
                }
                .buttonStyle(.plain)
                HStack {
                    Text("Slot \(slot) · \(palette.name)")
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)
                    Spacer()
                    Button("Modifica") { openEditor(slot: slot) }
                        .font(.footnote.weight(.semibold))
                    Button(role: .destructive) { deletingSlot = slot } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Elimina slot \(slot)")
                }
            } else {
                Button { openEditor(slot: slot) } label: {
                    VStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.system(size: 32, weight: .light))
                        Text("Slot \(slot)").font(.headline)
                        Text("Vuoto · Configura").font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: portrait ? 150 : 135)
                    .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [6, 4])))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.ecoCard.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
    }

    private func openEditor(slot: Int?) {
        let palette = slot.flatMap { EcoThemePalette.load(slot: $0) }
            ?? EcoThemePalette.template(.copper)
        editor = EcoThemeEditorSession(palette: palette, slot: slot)
    }

    private func activate(slot: Int) {
        guard EcoThemePalette.load(slot: slot) != nil else { return }
        let theme: CockpitTheme = slot == 1 ? .slot1 : (slot == 2 ? .slot2 : .slot3)
        selection = theme.rawValue
        revision += 1
    }
}

private struct EcoThemePreview: View {
    let palette: EcoThemePalette
    var active = false
    var editColor: ((Int) -> Void)? = nil

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color(themeHex: palette.colors[0]))
                // Anteprima fedele: una sola linea principale con bagliore regolabile.
                Capsule()
                    .fill(Color(themeHex: palette.colors[1]))
                    .frame(height: 3)
                    .shadow(color: Color(themeHex: palette.colors[1])
                                .opacity(palette.glowIntensity * 0.65), radius: 5)
                    .padding(.horizontal, 10)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 6)
                // Tre corone separate: potenza in uscita, ingresso e arco GPS.
                Circle()
                    .stroke(Color(themeHex: palette.colors[8]).opacity(0.88), lineWidth: 5)
                    .frame(width: 78, height: 78)
                Circle()
                    .stroke(Color(themeHex: palette.colors[9]).opacity(0.88), lineWidth: 5)
                    .frame(width: 66, height: 66)
                Circle()
                    .trim(from: 0.10, to: 0.77)
                    .stroke(Color(themeHex: palette.colors[10]),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(75))
                    .frame(width: 53, height: 53)
                Text("88")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color(themeHex: palette.colors[11]))
                HStack(spacing: 4) {
                    Image(systemName: "arrow.turn.up.left")
                        .foregroundStyle(Color(themeHex: palette.colors[13]))
                    Image(systemName: "arrow.turn.up.right")
                        .foregroundStyle(Color(themeHex: palette.colors[12]))
                    Circle()
                        .fill(Color(themeHex: palette.colors[14]))
                        .frame(width: 6, height: 6)
                }
                .font(.system(size: 10, weight: .bold))
                .offset(y: 40)
                HStack(spacing: 0) {
                    ForEach(4..<7, id: \.self) { i in
                        Color(themeHex: palette.colors[i])
                    }
                }
                .frame(width: 72, height: 5)
                .clipShape(Capsule())
                .offset(x: 64, y: 25)
                if active {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color(themeHex: palette.colors[1]))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(8)
                }
            }
            .frame(height: 100)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 5),
                      spacing: 5) {
                ForEach(0..<EcoThemePalette.colorCount, id: \.self) { index in
                    swatch(index)
                }
            }
            Text(palette.name.isEmpty ? "Il mio tema" : palette.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .padding(10)
        .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(active ? Color(themeHex: palette.colors[1]) : .secondary.opacity(0.23),
                    lineWidth: active ? 2 : 1))
    }

    private func swatch(_ index: Int) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(themeHex: palette.colors[index]))
            .frame(maxWidth: .infinity)
            .frame(height: editColor == nil ? 16 : 35)
            .overlay(RoundedRectangle(cornerRadius: 4)
                .strokeBorder(.white.opacity(0.22), lineWidth: 1))
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 0.45) { editColor?(index) }
            .accessibilityLabel("\(EcoThemePalette.labels[index]): \(palette.colors[index])")
            .accessibilityHint("Tieni premuto per modificare il colore")
            .accessibilityAddTraits(editColor == nil ? [] : [.isButton])
            .accessibilityAction { editColor?(index) }
    }
}

private struct EcoThemeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: EcoThemePalette
    @State private var colorID: EcoThemeColorID?
    @State private var selectedGroup: Int?
    @State private var chooseSlot = false
    @State private var overwriteSlot: Int?
    let initialSlot: Int?
    let onSave: (Int, EcoThemePalette) -> Void

    init(initial: EcoThemePalette, initialSlot: Int?,
         onSave: @escaping (Int, EcoThemePalette) -> Void) {
        _draft = State(initialValue: initial)
        self.initialSlot = initialSlot
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 17) {
                    TextField("Nome del tema", text: $draft.name)
                        .textInputAutocapitalization(.words)
                        .padding(12)
                        .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 10))

                    Menu {
                        ForEach(CockpitTheme.allCases.filter { $0.slotIndex == nil }) { theme in
                            Button(theme.rawValue) {
                                let name = draft.name
                                draft = EcoThemePalette.template(theme)
                                draft.name = name
                            }
                        }
                    } label: {
                        Label("Scegli un kit di partenza", systemImage: "paintpalette")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 10))
                    }

                    Text("Anteprima · Tieni premuto un quadratino per cambiarne il colore.")
                        .font(.subheadline).foregroundStyle(.secondary)

                    EcoThemePreview(palette: draft, editColor: { index in
                        colorID = EcoThemeColorID(id: index)
                    })

                    // Categoria velocità: quattro controlli distinti (fasi + limite).
                    // Gli slot storici e la griglia delle categorie non cambiano.
                    if let selectedGroup {
                        let group = EcoThemePalette.groups[selectedGroup]
                        Button {
                            withAnimation(.easeInOut(duration: 0.20)) {
                                self.selectedGroup = nil
                            }
                        } label: {
                            Label("Tutte le categorie", systemImage: "chevron.left")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 6)

                        Label(group.title, systemImage: categorySymbol(selectedGroup))
                            .font(.headline)
                            .foregroundStyle(.primary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 10)],
                                  spacing: 10) {
                            ForEach(group.range, id: \.self) { index in
                                colorRoleTile(index)
                            }
                        }
                    } else {
                        Text("Scegli una categoria per modificare i suoi colori.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                            GridItem(.flexible(), spacing: 12)],
                                  spacing: 12) {
                            ForEach(0..<EcoThemePalette.groups.count, id: \.self) { groupIndex in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.20)) {
                                        selectedGroup = groupIndex
                                    }
                                } label: {
                                    categoryTile(groupIndex)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(EcoThemePalette.groups[groupIndex].title)
                                .accessibilityHint("Apri i colori di questa categoria")
                            }
                        }
                    }

                    // Build 91 — intensità indipendenti delle due sfumature
                    // verticali; i colori si scelgono sopra nella categoria Layer top bar.
                    if selectedGroup == 5 {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 7) {
                                HStack {
                                    Label("Sfumatura alta · intensità", systemImage: "arrow.down.to.line")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text("\(Int((draft.topFadeIntensity * 100).rounded()))%")
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                Slider(value: $draft.topFadeIntensity, in: 0...1, step: 0.05)
                                    .tint(Color(themeHex: draft.colors[19]))
                            }
                            VStack(alignment: .leading, spacing: 7) {
                                HStack {
                                    Label("Sfumatura bassa · intensità", systemImage: "arrow.up.to.line")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text("\(Int((draft.bottomFadeIntensity * 100).rounded()))%")
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                Slider(value: $draft.bottomFadeIntensity, in: 0...1, step: 0.05)
                                    .tint(Color(themeHex: draft.colors[20]))
                            }
                            Text("Entrambe le sfumature restano solo nel layer esterno, fuori da tachimetro e ponte.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Bagliore esterno dei contorni", systemImage: "sun.max")
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("\(Int((draft.glowIntensity * 100).rounded()))%")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $draft.glowIntensity, in: 0...1, step: 0.05)
                            .tint(Color(themeHex: draft.colors[1]))
                        Text("Stessa intensità per top bar, anello arancione e ponte kW. Zero disattiva l'alone esterno.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 12))

                    Button {
                        chooseSlot = true
                    } label: {
                        Label("Salva tema in uno slot", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(draft.colors.count != EcoThemePalette.colorCount ||
                              !draft.glowIntensity.isFinite ||
                              !draft.topFadeIntensity.isFinite ||
                              !draft.bottomFadeIntensity.isFinite ||
                              !draft.colors.allSatisfy({ EcoThemePalette.validHex($0) }))
                }
                .padding(16)
            }
            .background(Color.ecoBackground)
            .navigationTitle("Configura tema")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
            }
            .sheet(item: $colorID) { selected in
                EcoThemeColorPicker(
                    title: EcoThemePalette.labels[selected.id],
                    initialHex: draft.colors[selected.id]
                ) { hex in
                    draft.colors[selected.id] = hex
                }
            }
            .confirmationDialog("In quale slot vuoi salvare il tema?",
                                isPresented: $chooseSlot, titleVisibility: .visible) {
                ForEach(1...3, id: \.self) { slot in
                    Button("Slot \(slot)" + (EcoThemePalette.load(slot: slot) == nil ? " · vuoto" : " · sostituisci")) {
                        if EcoThemePalette.load(slot: slot) == nil {
                            save(slot: slot)
                        } else {
                            overwriteSlot = slot
                        }
                    }
                }
                Button("Annulla", role: .cancel) {}
            }
            .alert("Sostituire il tema nello slot \(overwriteSlot ?? 0)?",
                   isPresented: Binding(get: { overwriteSlot != nil },
                                        set: { if !$0 { overwriteSlot = nil } })) {
                Button("Sostituisci", role: .destructive) {
                    guard let slot = overwriteSlot else { return }
                    save(slot: slot)
                    overwriteSlot = nil
                }
                Button("Annulla", role: .cancel) { overwriteSlot = nil }
            } message: {
                Text("Il tema già salvato in questo slot verrà sovrascritto.")
            }
        }
    }


    // La quinta categoria presenta le quattro fasi luminose della velocità.
    private func categorySymbol(_ index: Int) -> String {
        switch index {
        case 0: "paintpalette"
        case 1: "chart.bar.fill"
        case 2: "speedometer"
        case 3: "arrow.triangle.turn.up.right.diamond"
        case 5: "square.stack.3d.up"
        default: "speedometer"
        }
    }

    private func categoryTile(_ index: Int) -> some View {
        let group = EcoThemePalette.groups[index]
        return VStack(spacing: 10) {
            Image(systemName: categorySymbol(index))
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(Color(themeHex: draft.colors[1]))
                .frame(height: 36)

            Text(group.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(minHeight: 36)

            HStack(spacing: 5) {
                ForEach(group.range, id: \.self) { colorIndex in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(themeHex: draft.colors[colorIndex]))
                        .frame(maxWidth: .infinity)
                        .frame(height: 12)
                        .overlay(RoundedRectangle(cornerRadius: 3)
                            .strokeBorder(.white.opacity(0.16), lineWidth: 0.5))
                }
            }
            Text("\(group.range.count) colori")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 134)
        .padding(12)
        .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 14))
        .contentShape(RoundedRectangle(cornerRadius: 14))
    }

    // I colori del gruppo hanno etichette esplicite e long press come nella 64.
    private func colorRoleTile(_ index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 9) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(themeHex: draft.colors[index]))
                    .frame(width: 36, height: 36)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(.white.opacity(0.25), lineWidth: 1))
                Text(EcoThemePalette.labels[index])
                    .font(.system(size: 13, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            Text(EcoThemePalette.details[index])
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 11))
        .contentShape(RoundedRectangle(cornerRadius: 11))
        .onLongPressGesture(minimumDuration: 0.45) {
            colorID = EcoThemeColorID(id: index)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(EcoThemePalette.labels[index])
        .accessibilityHint(EcoThemePalette.details[index] + " Tieni premuto per cambiare colore.")
        .accessibilityAction { colorID = EcoThemeColorID(id: index) }
    }

    private func save(slot: Int) {
        var palette = draft
        palette.name = String(palette.name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(28))
        if palette.name.isEmpty { palette.name = "Tema \(slot)" }
        onSave(slot, palette)
        dismiss()
    }
}

// Build 92 — venti colori base; il cursore schiarisce o scurisce
// SOLO il colore selezionato, senza modificare gli altri ruoli del tema.
private struct EcoThemeColorPicker: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedHex: String
    @State private var referenceHex: String
    @State private var shadeLevel: Double = 0.50
    @State private var selectedBaseIndex: Int?

    let title: String
    let onConfirm: (String) -> Void

    init(title: String, initialHex: String, onConfirm: @escaping (String) -> Void) {
        self.title = title
        self.onConfirm = onConfirm
        _selectedHex = State(initialValue: initialHex)
        _referenceHex = State(initialValue: initialHex)
        _selectedBaseIndex = State(initialValue: Self.baseColors.firstIndex(of: initialHex.uppercased()))
    }

    // Esattamente 20 campioni fissi, non 72 gradazioni + filtri.
    // Sono colori di partenza: la luminosità fine si regola sotto.
    private static let baseColors: [String] = [
        "#E53935", "#F4511E", "#FF7043", "#FB8C00", "#FBC02D",
        "#C0CA33", "#7CB342", "#43A047", "#00897B", "#00ACC1",
        "#039BE5", "#1E88E5", "#3949AB", "#5E35B1", "#8E24AA",
        "#D81B60", "#F06292", "#795548", "#78909C", "#E0E0E0"
    ]

    // 0 = nero, 0.5 = colore di partenza, 1 = bianco.
    // Interpolazione RGB continua: conserva il colore originale dello slot
    // finché non si muove il cursore o non si sceglie una nuova base.
    private static func shade(baseHex: String, level: Double) -> String {
        let base = UIColor(Color(themeHex: baseHex))
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard base.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return baseHex
        }
        let progress = CGFloat(max(0, min(1, level)))
        func shift(_ channel: CGFloat) -> CGFloat {
            if progress <= 0.5 {
                return channel * (progress * 2)
            }
            return channel + (1 - channel) * ((progress - 0.5) * 2)
        }
        return EcoThemePalette.colorHex(UIColor(
            red: shift(red), green: shift(green), blue: shift(blue), alpha: 1))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 10) {
                        Text("Colore del tema").font(.title3.bold())
                        Spacer()
                        Button {
                            onConfirm(selectedHex)
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 54, height: 54)
                                .background(.blue, in: Circle())
                        }
                        .accessibilityLabel("Conferma colore")
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 54, height: 54)
                                .background(.red, in: Circle())
                        }
                        .accessibilityLabel("Annulla modifica")
                    }

                    Text("Scegli uno dei 20 colori base")
                        .font(.subheadline.weight(.semibold))
                    LazyVGrid(columns: Array(
                        repeating: GridItem(.flexible(), spacing: 9), count: 5),
                              spacing: 9) {
                        ForEach(Self.baseColors.indices, id: \.self) { index in
                            let hex = Self.baseColors[index]
                            Button {
                                selectedBaseIndex = index
                                referenceHex = hex
                                shadeLevel = 0.50
                                selectedHex = hex
                            } label: {
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(Color(themeHex: hex))
                                    .frame(height: 46)
                                    .overlay(RoundedRectangle(cornerRadius: 9)
                                        .strokeBorder(Color.black.opacity(0.16), lineWidth: 0.8))
                                    .overlay(RoundedRectangle(cornerRadius: 11)
                                        .strokeBorder(selectedBaseIndex == index ? Color.blue : .clear,
                                                      lineWidth: 3)
                                        .padding(-3))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Colore base \(index + 1): \(hex)")
                            .accessibilityAddTraits(selectedBaseIndex == index ? .isSelected : [])
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Regola il colore selezionato")
                            .font(.subheadline.weight(.semibold))
                        HStack(spacing: 10) {
                            Text("Scuro").font(.caption.weight(.medium))
                            Slider(value: $shadeLevel, in: 0...1, step: 0.01)
                                .tint(Color(themeHex: selectedHex))
                                .onChange(of: shadeLevel) { _, level in
                                    selectedHex = Self.shade(baseHex: referenceHex, level: level)
                                }
                                .accessibilityLabel("Da scuro a chiaro")
                            Text("Chiaro").font(.caption.weight(.medium))
                        }
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(themeHex: selectedHex))
                                .frame(width: 58, height: 44)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(.secondary.opacity(0.25), lineWidth: 1))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title).font(.subheadline.weight(.semibold))
                                Text(selectedHex).font(.subheadline.monospaced())
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                        }
                        Text("La regolazione cambia soltanto questo colore. Premi ✓ per salvarlo oppure × per annullare.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(18)
            }
            .background(Color(uiColor: .systemBackground))
            .navigationBarHidden(true)
        }
        .presentationDragIndicator(.visible)
    }
}
