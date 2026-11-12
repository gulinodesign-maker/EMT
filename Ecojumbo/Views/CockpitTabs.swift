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


// Build 63: otto colori individuali, persistiti localmente in tre slot.
struct EcoThemePalette: Codable, Equatable {
    var name: String
    var colors: [String]

    static let labels = [
        "Fondo", "Luce", "Ombra", "Acciaio",
        "Barra scura", "Barra media", "Barra luminosa", "Rigenerazione"
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
            colors: ["#040405", foreground.0, foreground.1, "#D9DEE3"] + standardBarColors
        )
    }

    static func load(slot: Int) -> EcoThemePalette? {
        guard (1...3).contains(slot),
              let data = UserDefaults.standard.data(forKey: storagePrefix + String(slot)),
              let decoded = try? JSONDecoder().decode(EcoThemePalette.self, from: data),
              decoded.colors.count == 8,
              decoded.colors.allSatisfy({ validHex($0) }) else { return nil }
        return decoded
    }

    @discardableResult
    static func save(_ palette: EcoThemePalette, slot: Int) -> Bool {
        guard (1...3).contains(slot), palette.colors.count == 8,
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
                Circle()
                    .stroke(Color(themeHex: palette.colors[2]), lineWidth: 3)
                    .frame(width: 64, height: 64)
                Circle()
                    .trim(from: 0.1, to: 0.84)
                    .stroke(Color(themeHex: palette.colors[1]),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(85))
                    .frame(width: 55, height: 55)
                Text("—").font(.title2.bold()).foregroundStyle(Color(themeHex: palette.colors[3]))
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

            HStack(spacing: 5) {
                ForEach(0..<8, id: \.self) { index in
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

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(0..<8, id: \.self) { index in
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(themeHex: draft.colors[index]))
                                    .frame(width: 20, height: 20)
                                Text(EcoThemePalette.labels[index]).font(.caption)
                                    .lineLimit(1)
                                Spacer(minLength: 0)
                            }
                            .padding(10)
                            .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 8))
                            .contentShape(Rectangle())
                            .onLongPressGesture(minimumDuration: 0.45) {
                                colorID = EcoThemeColorID(id: index)
                            }
                            .accessibilityAction { colorID = EcoThemeColorID(id: index) }
                        }
                    }

                    Button {
                        chooseSlot = true
                    } label: {
                        Label("Salva tema in uno slot", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!draft.colors.allSatisfy({ EcoThemePalette.validHex($0) }))
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

    private func save(slot: Int) {
        var palette = draft
        palette.name = String(palette.name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(28))
        if palette.name.isEmpty { palette.name = "Tema \(slot)" }
        onSave(slot, palette)
        dismiss()
    }
}

private struct EcoThemeColorPicker: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedHex: String
    @State private var pickerColor: Color
    @State private var filter = 0

    let title: String
    let onConfirm: (String) -> Void

    init(title: String, initialHex: String, onConfirm: @escaping (String) -> Void) {
        self.title = title
        self.onConfirm = onConfirm
        _selectedHex = State(initialValue: initialHex)
        _pickerColor = State(initialValue: Color(themeHex: initialHex))
    }

    // Righe per tonalità, sei gradazioni per riga, come nel selettore di riferimento.
    private static let spectrum: [String] = {
        let hues: [CGFloat] = [0, 0.055, 0.12, 0.175, 0.27, 0.35,
                              0.47, 0.54, 0.61, 0.70, 0.77, 0.89]
        return hues.flatMap { hue in
            (0..<6).map { step in
                EcoThemePalette.colorHex(UIColor(
                    hue: hue, saturation: [0.07, 0.20, 0.38, 0.60, 0.80, 0.98][step],
                    brightness: [1.0, 1.0, 1.0, 0.99, 0.91, 0.72][step],
                    alpha: 1
                ))
            }
        }
    }()
    private static let neutrals: [String] =
        ["#FFFFFF", "#F2F2F2", "#D9D9D9", "#AAAAAA", "#555555", "#000000"]

    private var displayedColors: [String] {
        switch filter {
        case 1: Self.spectrum.filter { hex in
            UIColor(Color(themeHex: hex)).cgColor.components?.first ?? 0 > 0.7
        }
        case 2: Self.spectrum.filter { hex in
            let color = UIColor(Color(themeHex: hex))
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            return color.getHue(&h, saturation: &s, brightness: &b, alpha: &a) && s > 0.75
        }
        case 3: Self.neutrals
        default: Self.spectrum + Self.neutrals
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    HStack(spacing: 10) {
                        Text("Tag colore").font(.title3.bold())
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
                    HStack(spacing: 8) {
                        filterButton(0, symbol: "square.fill", title: "Tutti")
                        filterButton(1, symbol: "square.on.square", title: "Chiari")
                        filterButton(2, symbol: "a", title: "Accesi")
                        filterButton(3, symbol: "circle.lefthalf.filled", title: "Grigi")
                    }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 6),
                              spacing: 8) {
                        ForEach(displayedColors, id: \.self) { hex in
                            Button {
                                selectedHex = hex
                                pickerColor = Color(themeHex: hex)
                            } label: {
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(Color(themeHex: hex))
                                    .frame(height: 41)
                                    .overlay(RoundedRectangle(cornerRadius: 9)
                                        .strokeBorder(Color.black.opacity(0.13), lineWidth: 0.8))
                                    .overlay(RoundedRectangle(cornerRadius: 11)
                                        .strokeBorder(selectedHex == hex ? Color.blue : .clear,
                                                      lineWidth: 3)
                                        .padding(-3))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Colore \(hex)")
                            .accessibilityAddTraits(selectedHex == hex ? .isSelected : [])
                        }
                    }
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(themeHex: selectedHex))
                            .frame(width: 40, height: 40)
                        Text("\(title): \(selectedHex)").font(.subheadline.monospaced())
                        Spacer()
                        ColorPicker("Altro colore", selection: $pickerColor, supportsOpacity: false)
                            .labelsHidden()
                            .onChange(of: pickerColor) { _, newColor in
                                selectedHex = EcoThemePalette.colorHex(UIColor(newColor))
                            }
                    }
                }
                .padding(18)
            }
            .background(Color(uiColor: .systemBackground))
            .navigationBarHidden(true)
        }
        .presentationDragIndicator(.visible)
    }

    private func filterButton(_ value: Int, symbol: String, title: String) -> some View {
        Button {
            filter = value
        } label: {
            VStack(spacing: 4) {
                Image(systemName: symbol).font(.system(size: 19))
                Text(title).font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(filter == value ? .white : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(filter == value ? Color.blue : Color(uiColor: .secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
