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


// Build 101: cinque colori indipendenti e due intensità per il layer diurno.
// I ruoli della palette notturna rimangono negli indici storici 2/15/16/19/20.
struct EcoDayTopBarPalette: Codable, Equatable {
    var left: String
    var right: String
    var high: String
    var low: String
    var underGlow: String
    var highIntensity: Double
    var lowIntensity: Double

    static func derived(from colors: [String]) -> EcoDayTopBarPalette {
        func pastel(_ hex: String, white: CGFloat = 0.72) -> String {
            let original = UIColor(Color(themeHex: hex))
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            guard original.getRed(&r, green: &g, blue: &b, alpha: &a) else {
                return "#DDE5EE"
            }
            return EcoThemePalette.colorHex(UIColor(red: r * (1 - white) + white,
                                                     green: g * (1 - white) + white,
                                                     blue: b * (1 - white) + white,
                                                     alpha: 1))
        }
        let left = colors.indices.contains(15) ? colors[15] : (colors.indices.contains(2) ? colors[2] : "#173A59")
        let right = colors.indices.contains(16) ? colors[16] : left
        let high = colors.indices.contains(19) ? colors[19] : left
        let low = colors.indices.contains(20) ? colors[20] : right
        let glow = colors.indices.contains(2) ? colors[2] : "#FF7008"
        return EcoDayTopBarPalette(
            left: pastel(left), right: pastel(right),
            high: pastel(high), low: pastel(low),
            underGlow: pastel(glow, white: 0.55),
            highIntensity: 0.22, lowIntensity: 0.22
        )
    }

    func hex(for role: Int) -> String {
        switch role {
        case 15: left
        case 16: right
        case 19: high
        case 20: low
        case 2: underGlow
        default: "#FFFFFF"
        }
    }

    mutating func set(_ hex: String, for role: Int) {
        switch role {
        case 15: left = hex
        case 16: right = hex
        case 19: high = hex
        case 20: low = hex
        case 2: underGlow = hex
        default: break
        }
    }

    var isValid: Bool {
        [left, right, high, low, underGlow].allSatisfy(EcoThemePalette.validHex)
            && highIntensity.isFinite && (0...1).contains(highIntensity)
            && lowIntensity.isFinite && (0...1).contains(lowIntensity)
    }
}

// Build 104: direzione unica della luce/ombra per top bar e tutte le card.
// 0° sinistra→destra, 90° alto→basso, 180° destra→sinistra,
// 270° basso→alto. SwiftUI usa coordinate verticali crescenti in basso.
enum EcoGradientDirection {
    static func points(angle: Double) -> (start: UnitPoint, end: UnitPoint) {
        let radians = angle * .pi / 180
        let dx = cos(radians) * 0.5
        let dy = sin(radians) * 0.5
        return (
            start: UnitPoint(x: CGFloat(0.5 - dx), y: CGFloat(0.5 - dy)),
            end: UnitPoint(x: CGFloat(0.5 + dx), y: CGFloat(0.5 + dy))
        )
    }
}

// Build 74: ruoli esistenti 10 (normale), 14 (decelerazione), 17 (limite); 18 (accelerazione).
// I valori 15 e 16 rimangono riservati e salvati per compatibilità.
struct EcoThemePalette: Codable, Equatable {
    var name: String
    var colors: [String]
    var glowIntensity: Double
    var topFadeIntensity: Double
    var bottomFadeIntensity: Double
    var dayTopBar: EcoDayTopBarPalette
    // Un cursore globale condiviso da Night/Day e card di telemetria.
    // Valori precedenti migrano a 0° (orizzontale sx → dx).
    var gradientAngle: Double
    // Build 105: opacità globale delle sfumature separata per Day e Night.
    // 0 = tutte le velature trasparenti, 1 = resa originaria.
    var gradientOpacity: Double
    var dayGradientOpacity: Double

    init(name: String, colors: [String], glowIntensity: Double = 0.60,
         topFadeIntensity: Double = 0.35, bottomFadeIntensity: Double = 0.35,
         dayTopBar: EcoDayTopBarPalette? = nil, gradientAngle: Double = 0,
         gradientOpacity: Double = 1, dayGradientOpacity: Double = 1) {
        self.name = name
        self.colors = colors
        self.glowIntensity = glowIntensity.isFinite ? min(1, max(0, glowIntensity)) : 0.60
        self.topFadeIntensity = topFadeIntensity.isFinite ? min(1, max(0, topFadeIntensity)) : 0.35
        self.bottomFadeIntensity = bottomFadeIntensity.isFinite ? min(1, max(0, bottomFadeIntensity)) : 0.35
        self.dayTopBar = dayTopBar ?? EcoDayTopBarPalette.derived(from: colors)
        self.gradientAngle = gradientAngle.isFinite
            ? min(360, max(0, gradientAngle)) : 0
        self.gradientOpacity = gradientOpacity.isFinite ? min(1, max(0, gradientOpacity)) : 1
        self.dayGradientOpacity = dayGradientOpacity.isFinite ? min(1, max(0, dayGradientOpacity)) : 1
    }

    // Le palette 63–72 non contenevano intensità: default retrocompatibile.
    private enum CodingKeys: String, CodingKey {
        case name, colors, glowIntensity, topFadeIntensity, bottomFadeIntensity, dayTopBar, gradientAngle,
             gradientOpacity, dayGradientOpacity
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
        dayTopBar = try data.decodeIfPresent(EcoDayTopBarPalette.self, forKey: .dayTopBar)
            ?? EcoDayTopBarPalette.derived(from: colors)
        let angle = try data.decodeIfPresent(Double.self, forKey: .gradientAngle) ?? 0
        gradientAngle = angle.isFinite ? min(360, max(0, angle)) : 0
        let nightOpacity = try data.decodeIfPresent(Double.self, forKey: .gradientOpacity) ?? 1
        let dayOpacity = try data.decodeIfPresent(Double.self, forKey: .dayGradientOpacity) ?? 1
        gradientOpacity = nightOpacity.isFinite ? min(1, max(0, nightOpacity)) : 1
        dayGradientOpacity = dayOpacity.isFinite ? min(1, max(0, dayOpacity)) : 1
    }

    func encode(to encoder: Encoder) throws {
        var data = encoder.container(keyedBy: CodingKeys.self)
        try data.encode(name, forKey: .name)
        try data.encode(colors, forKey: .colors)
        try data.encode(glowIntensity, forKey: .glowIntensity)
        try data.encode(topFadeIntensity, forKey: .topFadeIntensity)
        try data.encode(bottomFadeIntensity, forKey: .bottomFadeIntensity)
        try data.encode(dayTopBar, forKey: .dayTopBar)
        try data.encode(gradientAngle, forKey: .gradientAngle)
        try data.encode(gradientOpacity, forKey: .gradientOpacity)
        try data.encode(dayGradientOpacity, forKey: .dayGradientOpacity)
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
        "Numeri kW · energia in ingresso (ruolo storico nascosto)",
        "Barre di potenza · energia in uscita",
        "Barre di potenza · energia in entrata",
        "Velocità GPS · fase normale",
        "Numeri del tachimetro · km/h",
        "Navigatore · svolta a destra",
        "Navigatore · svolta a sinistra",
        "Velocità GPS · fase decelerazione",
        "Sfumature · colore luce",
        "Sfumature · colore ombra",
        "Velocità GPS · limite superato",
        "Velocità GPS · fase accelerazione",
        "Sfumature · velatura superiore",
        "Sfumature · velatura inferiore",
        "Cerchio concentrico luminoso · tachimetro"
    ]
    static let details = [
        "Fondo scuro dietro gli strumenti.",
        "Stesso colore per linee della top bar, contorni e tutte le icone della griglia 3×4 in Impostazioni.",
        "Colore modificabile della luce diffusa che traspare sotto il layer GPS.",
        "Colore dei dettagli effetto acciaio.",
        "Prima tonalità delle barre di telemetria.",
        "Tonalità centrale delle barre di telemetria.",
        "Tonalità brillante delle barre di telemetria.",
        "Ruolo kW storico conservato nei temi salvati, ora unificato con il colore Energia in entrata.",
        "Segmenti rossi della scala potenza nel ponte kW: energia in uscita.",
        "Segmenti azzurri della scala potenza nel ponte kW: energia in entrata o recupero.",
        "Colore normale dell’arco GPS quando la variazione resta entro ±5 km/h.",
        "Cifre grandi della velocità GPS al centro.",
        "Freccia e distanza della prossima svolta verso destra.",
        "Freccia e distanza della prossima svolta verso sinistra.",
        "Colore dell’arco GPS quando la velocità cala di oltre 5 km/h nella finestra di osservazione; non indica il freno fisico.",
        "Colore luce della sfumatura condivisa da top bar e card Telemetria.",
        "Colore ombra della sfumatura condivisa da top bar e card Telemetria.",
        "Colore della barra LED quando la velocità GPS raggiunge il limite attivato in Barre luminose.",
        "Colore dell’arco GPS quando la velocità aumenta di oltre 5 km/h nella finestra di osservazione.",
        "Velatura aggiuntiva alta della top bar, personalizzabile senza modificare la direzione globale.",
        "Velatura aggiuntiva bassa della top bar, personalizzabile senza modificare la direzione globale.",
        "Colore del cerchio luminoso rimasto attorno al tachimetro; bagliore regolabile qui, termina prima del ponte kW."
    ]
    // Ogni ruolo compare una sola volta. Barre in entrata/uscita e tutte
    // le fasi della velocità fanno parte del tachimetro, non della telemetria.
    static let groups: [(title: String, range: [Int])] = [
        ("Aspetto generale", [0]),
        ("Anelli e numeri del tachimetro", [1, 3, 21, 11, 10, 14, 18, 17, 8, 9]),
        ("Barre telemetria", [4, 5, 6]),
        ("Navigatore", [12, 13]),
        ("Sfumature · luce e ombra", [15, 16, 19, 20, 2])
    ]
    static let colorCount = 22
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
                   foreground.1, foreground.0, foreground.0]
        )
    }

    static func load(slot: Int) -> EcoThemePalette? {
        guard (1...3).contains(slot),
              let data = UserDefaults.standard.data(forKey: storagePrefix + String(slot)),
              let decoded = try? JSONDecoder().decode(EcoThemePalette.self, from: data),
              (decoded.colors.count == 8 || decoded.colors.count == 15 ||
               decoded.colors.count == 17 || decoded.colors.count == 18 ||
               decoded.colors.count == 19 || decoded.colors.count == 21 ||
               decoded.colors.count == 22 || decoded.colors.count == 23),
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
        // Build 95: 21→22, senza toccare alcuno dei colori esistenti.
        // Il nuovo cerchio eredita il colore principale del tema salvato.
        if migrated.colors.count == 21 {
            migrated.colors.append(migrated.colors[1])
        }
        // Build 101: il ruolo 22 è orfano dopo la rimozione del
        // secondo anello. Troncamento dell'UNICO valore non più usato;
        // tutti i colori 0...21 e il nuovo layer Day restano intatti.
        if migrated.colors.count == 23 {
            migrated.colors.removeLast()
        }
        return migrated
    }

    @discardableResult
    static func save(_ palette: EcoThemePalette, slot: Int) -> Bool {
        guard (1...3).contains(slot), palette.colors.count == colorCount,
              palette.glowIntensity.isFinite, (0...1).contains(palette.glowIntensity),
              palette.topFadeIntensity.isFinite, (0...1).contains(palette.topFadeIntensity),
              palette.bottomFadeIntensity.isFinite, (0...1).contains(palette.bottomFadeIntensity),
              palette.gradientAngle.isFinite, (0...360).contains(palette.gradientAngle),
              palette.gradientOpacity.isFinite, (0...1).contains(palette.gradientOpacity),
              palette.dayGradientOpacity.isFinite, (0...1).contains(palette.dayGradientOpacity),
              palette.dayTopBar.isValid,
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
    let isDay: Bool
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
                Text("Tre temi personali con anteprima dell'intero cockpit. Nel configuratore scegli una categoria, tocca il campione da modificare e salva nello slot.")
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

// Build 93: ogni slot e il configuratore mostrano una miniatura fedele
// dell'intero cockpit GPS, con colori del draft aggiornati in tempo reale.
// Non è più una collezione di cerchi, swatch o quadratini colore.
private struct EcoThemePreview: View {
    let palette: EcoThemePalette
    var active = false

    var body: some View {
        VStack(spacing: 8) {
            // Build 94: l'anteprima mostra SOLO il cruscotto.
            // Lo stato selezionato è espresso dal bordo esterno, mai da
            // icone flottanti che coprano il disegno del cockpit.
            EcoCockpitThemeMiniature(palette: palette)
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
}

private struct EcoThemeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: EcoThemePalette
    @State private var colorID: EcoThemeColorID?
    @State private var selectedGroup: Int?
    @State private var editingDayTopBar = false
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

                    Text("Anteprima completa del cockpit · aggiornamento immediato. Tocca un colore per modificarlo.")
                        .font(.subheadline).foregroundStyle(.secondary)

                    EcoThemePreview(palette: draft)
                        .preferredColorScheme(selectedGroup == 4
                            ? (editingDayTopBar ? .light : .dark) : nil)

                        if selectedGroup == 4 {
                            Picker("Modalità della sfumatura", selection: $editingDayTopBar) {
                                Text("☀️ Day Mode").tag(true)
                                Text("🌙 Night Mode").tag(false)
                            }
                            .pickerStyle(.segmented)
                            .accessibilityLabel("Modifica la top bar per giorno o notte")
                            Text(editingDayTopBar
                                 ? "Colori e intensità del giorno, indipendenti dalla notte."
                                 : "Colori e intensità della notte, indipendenti dal giorno.")
                                .font(.caption).foregroundStyle(.secondary)
                        }

                    // Build 105: controlli direttamente sotto l'anteprima. Luce/ombra condivise da top bar e Telemetria.
                    // L'orientamento è UNICO per Day e Night; i colori restano
                    // indipendenti e le velature verticali sono opzionali.
                    if selectedGroup == 4 {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 7) {
                                HStack {
                                    Label("Opacità di tutte le sfumature", systemImage: "circle.lefthalf.filled")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text("\(Int((gradientOpacityBinding.wrappedValue * 100).rounded()))%")
                                        .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                                }
                                Slider(value: gradientOpacityBinding, in: 0...1, step: 0.01)
                                    .tint(Color(themeHex: roleHex(15)))
                                    .accessibilityLabel("Opacità complessiva delle sfumature in modalità giorno o notte")
                                Text("0% rende trasparenti luce, ombra, velature alta e bassa e bagliore sotto il layer.")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Label("Orientamento globale · luce → ombra",
                                          systemImage: "arrow.up.left.and.arrow.down.right")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text("\(Int(draft.gradientAngle.rounded()))°")
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                Slider(value: $draft.gradientAngle, in: 0...360, step: 5)
                                    .tint(Color(themeHex: roleHex(15)))
                                    .accessibilityLabel("Ruota la sfumatura globale di top bar e telemetria")
                                HStack {
                                    Text("0° →")
                                    Spacer()
                                    Text("90° ↓")
                                    Spacer()
                                    Text("180° ←")
                                    Spacer()
                                    Text("270° ↑")
                                }
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.secondary)
                                let direction = EcoGradientDirection.points(angle: draft.gradientAngle)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(
                                        colors: [Color(themeHex: roleHex(15)),
                                                 Color(themeHex: roleHex(16))],
                                        startPoint: direction.start, endPoint: direction.end))
                                    .frame(height: 38)
                                    .accessibilityLabel("Anteprima della direzione luce e ombra")
                                Text("Un solo orientamento per top bar e tutte le card, in Giorno e Notte.")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Divider()
                            VStack(alignment: .leading, spacing: 7) {
                                HStack {
                                    Label("Sfumatura alta · intensità", systemImage: "arrow.down.to.line")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text("\(Int((topFadeBinding.wrappedValue * 100).rounded()))%")
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                Slider(value: topFadeBinding, in: 0...1, step: 0.05)
                                    .tint(Color(themeHex: roleHex(19)))
                            }
                            VStack(alignment: .leading, spacing: 7) {
                                HStack {
                                    Label("Sfumatura bassa · intensità", systemImage: "arrow.up.to.line")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text("\(Int((bottomFadeBinding.wrappedValue * 100).rounded()))%")
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                Slider(value: bottomFadeBinding, in: 0...1, step: 0.05)
                                    .tint(Color(themeHex: roleHex(20)))
                            }
                            Text("Le velature alte e basse sono aggiuntive alla sfumatura globale e restano fuori da tachimetro e ponte.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 12))
                    }



                    // Il gruppo tachimetro contiene tutte le fasi GPS,
                    // gli anelli luminosi e le barre di potenza del ponte.
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


                        if selectedGroup == 1 {
                            colorRoleSection("Anelli e luci", roles: [1, 3, 21])
                            colorRoleSection("Numeri e velocità GPS", roles: [11, 10, 14, 18, 17])
                            colorRoleSection("Barre di potenza", roles: [8, 9])
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 10)],
                                      spacing: 10) {
                                ForEach(group.range, id: \.self) { index in
                                    colorRoleTile(index)
                                }
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

                    if selectedGroup == 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Intensità delle luci del tachimetro", systemImage: "sun.max")
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
                    }

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
                              !draft.gradientAngle.isFinite ||
                              !draft.gradientOpacity.isFinite ||
                              !draft.dayGradientOpacity.isFinite ||
                              !(0...360).contains(draft.gradientAngle) ||
                              !draft.dayTopBar.isValid ||
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
                    title: EcoThemePalette.labels[selected.id]
                        + (selected.isDay ? " · Day Mode" : ""),
                    initialHex: selected.isDay
                        ? draft.dayTopBar.hex(for: selected.id)
                        : draft.colors[selected.id]
                ) { hex in
                    if selected.isDay {
                        draft.dayTopBar.set(hex, for: selected.id)
                    } else {
                        draft.colors[selected.id] = hex
                    }
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


    private func categorySymbol(_ index: Int) -> String {
        switch index {
        case 0: "paintpalette"
        case 1: "speedometer"
        case 2: "chart.bar.fill"
        case 3: "arrow.triangle.turn.up.right.diamond"
        case 4: "sun.horizon"
        default: "paintpalette"
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

    // Lo stesso ruolo 2/15/16/19/20 si modifica senza duplicazioni:
    // Day Mode ha 5 colori propri, Night Mode mantiene gli indici storici.
    private func roleHex(_ index: Int) -> String {
        selectedGroup == 4 && editingDayTopBar
            ? draft.dayTopBar.hex(for: index) : draft.colors[index]
    }

    private var gradientOpacityBinding: Binding<Double> {
        Binding(get: {
            editingDayTopBar ? draft.dayGradientOpacity : draft.gradientOpacity
        }, set: { value in
            if editingDayTopBar { draft.dayGradientOpacity = value }
            else { draft.gradientOpacity = value }
        })
    }

    private var topFadeBinding: Binding<Double> {
        Binding(get: {
            editingDayTopBar ? draft.dayTopBar.highIntensity : draft.topFadeIntensity
        }, set: { value in
            if editingDayTopBar { draft.dayTopBar.highIntensity = value }
            else { draft.topFadeIntensity = value }
        })
    }

    private var bottomFadeBinding: Binding<Double> {
        Binding(get: {
            editingDayTopBar ? draft.dayTopBar.lowIntensity : draft.bottomFadeIntensity
        }, set: { value in
            if editingDayTopBar { draft.dayTopBar.lowIntensity = value }
            else { draft.bottomFadeIntensity = value }
        })
    }

    private func colorRoleSection(_ title: String, roles: [Int]) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title).font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 10)],
                      spacing: 10) {
                ForEach(roles, id: \.self) { index in
                    colorRoleTile(index)
                }
            }
        }
    }

    // Build 101: un semplice tocco apre il selettore; nessun long press.
    private func colorRoleTile(_ index: Int) -> some View {
        Button {
            colorID = EcoThemeColorID(
                id: index, isDay: selectedGroup == 4 && editingDayTopBar)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 9) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(themeHex: roleHex(index)))
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
        }
        .buttonStyle(.plain)
        .accessibilityLabel(EcoThemePalette.labels[index])
        .accessibilityHint("Tocca per cambiare il colore.")
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
