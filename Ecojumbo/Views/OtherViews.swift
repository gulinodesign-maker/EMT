import SwiftUI
import Charts

// Guida contestuale: descrizioni tecniche e avvertenze disponibili a richiesta,
// senza occupare spazio permanente nelle schermate operative.
struct EcoInfoIcon: View {
    let title: String
    let message: String
    @State private var isPresented = false

    var body: some View {
        Button { isPresented = true } label: {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Informazioni: " + title)
        .accessibilityHint(message)
        .alert(title, isPresented: $isPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message)
        }
    }
}

struct TrendsView: View {
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if bluetooth.session.points.isEmpty {
                    ContentUnavailableView("Nessun dato registrato", systemImage: "chart.xyaxis.line",
                                           description: Text("In attesa dei dati BMS"))
                } else {
                    TrendChart(title: "Tensione batteria", points: bluetooth.session.points, type: .voltage)
                    TrendChart(title: "Corrente batteria", points: bluetooth.session.points, type: .current)
                    EcoCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Consumi della sessione").font(.headline)
                            row("Energia uscita", String(format: "%.3f kWh", bluetooth.session.dischargedKWh))
                            row("Energia ingresso", String(format: "%.3f kWh", bluetooth.session.chargedKWh))
                            row("Capacità uscita", String(format: "%.2f Ah", bluetooth.session.dischargedAh))
                            row("Capacità ingresso", String(format: "%.2f Ah", bluetooth.session.chargedAh))
                            EcoInfoIcon(title: "Energia", message: "L'energia in ingresso comprende ricarica e rigenerazione; senza un segnale del veicolo non è possibile distinguerle.")
                        }
                    }
                    Button(role: .destructive) { bluetooth.session.reset() } label: {
                        Label("Azzera sessione", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            }.padding(16)
        }
        .background(Color.ecoBackground)
        .navigationTitle("Grafici")
    }

    private func row(_ name: String, _ value: String) -> some View {
        HStack { Text(name).foregroundStyle(.secondary); Spacer(); Text(value).monospacedDigit() }
            .font(.subheadline)
    }
}

private struct TrendChart: View {
    enum ChartType { case voltage, current }
    let title: String
    let points: [RidePoint]
    let type: ChartType
    var body: some View {
        EcoCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(title).font(.headline)
                Chart(points) { point in
                    LineMark(x: .value("Tempo", point.timestamp),
                             y: .value("Valore", type == .voltage ? point.voltage : point.current))
                        .foregroundStyle(type == .voltage ? Color.ecoGreen : Color.cyan)
                        .interpolationMethod(.linear)
                }
                .frame(height: 200)
                HStack {
                    Text(type == .voltage ? "V" : "A")
                        .font(.footnote).foregroundStyle(.secondary)
                    if type == .current {
                        EcoInfoIcon(title: "Corrente", message: "Corrente positiva: carica. Corrente negativa: scarica.")
                    }
                }
            }
        }
    }
}

struct BluetoothView: View {
    @EnvironmentObject private var bluetooth: JKBluetoothManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                EcoCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Connessione BMS", systemImage: "antenna.radiowaves.left.and.right")
                            .font(.headline)
                        Text(bluetooth.state).font(.subheadline).foregroundStyle(.secondary)
                        if let device = bluetooth.deviceInfo {
                            if !device.name.isEmpty { Label(device.name, systemImage: "tag").font(.footnote) }
                            if !device.hardware.isEmpty { Label(device.hardware, systemImage: "cpu").font(.footnote) }
                            if !device.firmware.isEmpty { Label(device.firmware, systemImage: "square.stack").font(.footnote) }
                        }
                        HStack {
                            if bluetooth.isConnected {
                                Button("Scollega", role: .destructive) { bluetooth.disconnect() }
                                    .buttonStyle(.bordered)
                                Button("Richiedi lettura") { bluetooth.requestRead() }
                                    .buttonStyle(.borderedProminent).tint(Color.ecoGreen)
                            } else if bluetooth.isScanning {
                                Button("Ferma ricerca") { bluetooth.stopScan() }
                                    .buttonStyle(.bordered)
                            } else {
                                Button("Cerca dispositivi") { bluetooth.scan() }
                                    .buttonStyle(.borderedProminent).tint(Color.ecoGreen)
                            }
                        }
                    }
                }
                if !bluetooth.isConnected {
                    Label("Dispositivi", systemImage: "antenna.radiowaves.left.and.right")
                        .font(.headline)
                    if bluetooth.nearby.isEmpty {
                        HStack {
                            Label("Nessun BMS", systemImage: "antenna.radiowaves.left.and.right")
                            Spacer()
                            EcoInfoIcon(title: "Ricerca BMS", message: "Accendi il BMS e avvia la ricerca Bluetooth. Chiudi prima l'app JK ufficiale.")
                        }
                        .font(.subheadline).foregroundStyle(.secondary)
                    }
                    ForEach(bluetooth.nearby) { device in
                        Button { bluetooth.connect(device) } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "bluetooth").font(.title3)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(device.name).font(.headline)
                                    Text("\(device.rssi) dBm · Non verificato")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(14)
                            .foregroundStyle(.primary)
                            .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 14))
                        }.buttonStyle(.plain)
                    }
                }
                if let error = bluetooth.lastError {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .font(.footnote).foregroundStyle(.orange)
                }
                EcoCard {
                    VStack(alignment: .leading, spacing: 9) {
                        Label("Diagnostica", systemImage: "waveform.path.ecg").font(.headline)
                        HStack { Text("BLE"); Spacer(); Text("\(bluetooth.rawCount)") }.font(.footnote)
                        HStack { Text("JK"); Spacer(); Text("\(bluetooth.frameCount)") }.font(.footnote)
                        EcoInfoIcon(title: "Dati verificati", message: "Le misure compaiono solo dopo la verifica del protocollo JK e dei controlli di coerenza.")
                    }
                }
            }.padding(16)
        }
        .background(Color.ecoBackground)
        .navigationTitle("Bluetooth JK")
    }
}

private enum EcoSetupSection: String, CaseIterable, Identifiable {
    case battery, bms, appearance, scooter, bluetooth, charging
    case odometer, bars, power, weather, music, vehicle

    var id: Self { self }

    var title: String {
        switch self {
        case .battery: "Batteria"
        case .bms: "BMS"
        case .appearance: "Aspetto"
        case .scooter: "Scooter"
        case .bluetooth: "Bluetooth JK"
        case .charging: "Ricarica"
        case .odometer: "Chilometri"
        case .bars: "Barre luminose"
        case .power: "Scala potenza"
        case .weather: "Meteo"
        case .music: "Musica"
        case .vehicle: "Veicolo"
        }
    }

    var symbol: String {
        switch self {
        case .battery: "battery.100percent"
        case .bms: "waveform.path.ecg"
        case .appearance: "circle.lefthalf.filled"
        case .scooter: "bicycle"
        case .bluetooth: "antenna.radiowaves.left.and.right"
        case .charging: "bolt.circle"
        case .odometer: "road.lanes"
        case .bars: "chart.bar.fill"
        case .power: "gauge.with.dots.needle.67percent"
        case .weather: "cloud.sun"
        case .music: "music.note"
        case .vehicle: "car.side.fill"
        }
    }
}

struct EcoSettingsView: View {
    @EnvironmentObject private var gps: GPSRideManager
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    @EnvironmentObject private var powerMotion: EcoPowerMotionManager
    @StateObject private var music = EcoMusicManager.shared
    @State private var activeSection: EcoSetupSection?
    @State private var odometerText = ""
    @State private var odometerStatus: String?
    @State private var fullRangeText = ""
    @State private var fullRangeStatus: String?
    @State private var kmSinceFullText = ""
    @State private var kmSinceFullStatus: String?
    @FocusState private var odometerFieldFocused: Bool
    @FocusState private var distanceFieldFocused: Bool
    @AppStorage("ecojumbo.cellCount") private var cellCount = 20
    @AppStorage("ecojumbo.capacity") private var capacity = 206
    @AppStorage("ecojumbo.chargeAlert") private var chargeAlert = 80
    @AppStorage("ecojumbo.frameFormat") private var rawFormat = JKFrameFormat.automatic.rawValue
    @AppStorage("ecojumbo.bars.averagePowerMaxKW") private var averagePowerMaxKW = 5.0
    @AppStorage("ecojumbo.bars.vehicleSpeedMaxKmh") private var vehicleSpeedMaxKmh = 120.0
    @AppStorage("ecojumbo.bars.speedColorThresholdKmh") private var speedColorThresholdKmh = 80.0
    @AppStorage("ecojumbo.bars.speedLimitColorEnabled") private var speedLimitColorEnabled = true
    @AppStorage("ecojumbo.power.source") private var powerSource = EcoPowerSource.inertia.rawValue
    @AppStorage("ecojumbo.vehicle.mode") private var vehicleMode = EcoVehicleMode.bms.rawValue
    @AppStorage("ecojumbo.vehicle.fullRangeKm") private var fullRangeKm = 0.0
    @AppStorage("ecojumbo.vehicle.averageSpeedScaleKmh") private var averageSpeedScaleKmh = 130.0
    @AppStorage("ecojumbo.power.motionSensitivity") private var motionSensitivity = 0.5
    @AppStorage("ecojumbo.power.motionAxis") private var motionAxis = "z"
    @AppStorage("ecojumbo.power.reverseMotion") private var reverseMotion = false
    @AppStorage("ecojumbo.appearanceMode") private var appearanceMode = EcoAppearanceMode.dark.rawValue
    @AppStorage("ecojumbo.theme") private var themeName = CockpitTheme.copper.rawValue
    @AppStorage("ecojumbo.themeRevision") private var themeRevision = 0

    private var visibleSections: [EcoSetupSection] {
        guard vehicleMode == EcoVehicleMode.universal.rawValue else {
            return EcoSetupSection.allCases
        }
        // Non presentare configurazioni di celle/ricarica/JK quando il
        // cockpit usa solo iPhone: i dati BMS restano salvati per il ritorno.
        return EcoSetupSection.allCases.filter {
            ![.battery, .bms, .scooter, .bluetooth, .charging].contains($0)
        }
    }

    private var setupIconColor: Color {
        _ = themeRevision // aggiornamento anche quando si risalva lo slot già attivo
        return (CockpitTheme(rawValue: themeName) ?? .copper).accent
    }

    var body: some View {
        GeometryReader { area in
            let landscape = area.size.width > area.size.height
            let tileHeight = landscape
                ? max(54, min(78, area.size.height * 0.25))
                : max(80, min(118, area.size.height * 0.14))
            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 0), spacing: 10), count: 3),
                          spacing: 10) {
                    ForEach(visibleSections) { section in
                        Button {
                            if section == .vehicle {
                                fullRangeText = fullRangeKm >= 10 ? String(format: "%.0f", fullRangeKm) : ""
                                kmSinceFullText = gps.universalHasFull
                                    ? String(format: "%.1f", gps.universalKmSinceFull) : ""
                                fullRangeStatus = nil
                                kmSinceFullStatus = nil
                            }
                            activeSection = section
                        } label: {
                            VStack(spacing: landscape ? 4 : 8) {
                                Image(systemName: section.symbol)
                                    .font(.system(size: landscape ? 20 : 27, weight: .regular))
                                    .foregroundStyle(setupIconColor)
                                Text(section.title)
                                    .font(landscape ? .caption2 : .footnote)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.75)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: tileHeight)
                            .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Apri \(section.title)")
                    }
                }
                    .padding(.horizontal, landscape ? 16 : 18)
                    .padding(.vertical, landscape ? 8 : 16)
                }
                .scrollIndicators(.hidden)

                // Numero versione fuori dalla griglia, sempre in fondo sopra il dock.
                Text("Ecojumbo \(EcojumboBuildStamp.display) · build \(EcojumboBuildStamp.buildNumber)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, landscape ? 5 : 9)
                    .accessibilityLabel("Versione Ecojumbo \(EcojumboBuildStamp.display), build \(EcojumboBuildStamp.buildNumber)")
            }
            .background(Color.ecoBackground)
        }
        .navigationTitle("Impostazioni")
        .sheet(item: $activeSection) { section in
            setupSheet(for: section)
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            bluetooth.applyFormat(JKFrameFormat(rawValue: rawFormat) ?? .automatic, cells: cellCount)
            odometerText = gps.hasOdometer ? String(format: "%.1f", gps.totalKm) : ""
            fullRangeText = fullRangeKm >= 10 ? String(format: "%.0f", fullRangeKm) : ""
            kmSinceFullText = gps.universalHasFull ? String(format: "%.1f", gps.universalKmSinceFull) : ""
            powerSource = vehicleMode == EcoVehicleMode.universal.rawValue
                ? EcoPowerSource.inertia.rawValue : EcoPowerSource.bms.rawValue
            speedColorThresholdKmh = min(max(10, speedColorThresholdKmh), vehicleSpeedMaxKmh)
        }
        .onChange(of: vehicleMode) { _, mode in
            powerSource = mode == EcoVehicleMode.universal.rawValue
                ? EcoPowerSource.inertia.rawValue : EcoPowerSource.bms.rawValue
        }
        .onChange(of: vehicleSpeedMaxKmh) { _, newMax in
            speedColorThresholdKmh = min(speedColorThresholdKmh, newMax)
        }
    }

    // I controlli esistenti restano invariati nei rispettivi fogli modali.
    @ViewBuilder private func setupSheet(for section: EcoSetupSection) -> some View {
        NavigationStack {
            Group {
                switch section {
                case .battery:
                    GeometryReader { space in
                        CellsView(portrait: space.size.height > space.size.width)
                    }
                case .bms:
                    BluetoothView()
                default:
                    Form {
                        setupFields(for: section)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.ecoBackground)
                }
            }
            .navigationTitle(section.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") { activeSection = nil }
                }
                // Il tastierino decimale iOS non offre il tasto Invio in landscape.
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Conferma e salva") {
                        if section == .vehicle {
                            if distanceFieldFocused { saveKmSinceFull() }
                            else { saveFullRange() }
                        } else if section == .odometer { saveOdometer() }
                    }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder private func setupFields(for section: EcoSetupSection) -> some View {
        switch section {
        case .battery, .bms:
            EmptyView()
        case .vehicle:
            Section("Tipo di cockpit") {
                Picker("Modalità veicolo", selection: $vehicleMode) {
                    Label("BMS", systemImage: "battery.100percent")
                        .tag(EcoVehicleMode.bms.rawValue)
                    Label("Universale", systemImage: "car.side.fill")
                        .tag(EcoVehicleMode.universal.rawValue)
                }
                .pickerStyle(.segmented)
                EcoInfoIcon(title: "Modalità", message:
                    "BMS: letture elettriche JK reali e segnale di potenza del BMS, se disponibile. " +
                    "Universale: GPS e sensori inerziali iPhone, senza letture elettriche. " +
                    "Le impostazioni restano salvate quando cambi modalità.")
            }
            if vehicleMode == EcoVehicleMode.universal.rawValue {
                Section("Carburante stimato") {
                    HStack {
                        TextField("Autonomia con un pieno", text: $fullRangeText)
                            .keyboardType(.decimalPad)
                            .submitLabel(.done)
                            .onSubmit(saveFullRange)
                        Text("km").foregroundStyle(.secondary)
                        Button("Salva", action: saveFullRange)
                            .buttonStyle(.borderedProminent)
                    }
                    LabeledContent("Autonomia configurata",
                        value: fullRangeKm >= 10 ? String(format: "%.0f km", fullRangeKm) : "—")
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Distanza dal pieno")
                        HStack {
                            TextField("Km percorsi", text: $kmSinceFullText)
                                .keyboardType(.decimalPad)
                                .submitLabel(.done)
                                .focused($distanceFieldFocused)
                                .onSubmit(saveKmSinceFull)
                                .accessibilityLabel("Chilometri percorsi dall'ultimo pieno")
                            Text("km").foregroundStyle(.secondary)
                            Button("Salva", action: saveKmSinceFull)
                                .buttonStyle(.borderedProminent)
                                .accessibilityLabel("Salva distanza dal pieno")
                        }
                    }
                    if let fullRangeStatus {
                        Text(fullRangeStatus).font(.caption).foregroundStyle(.secondary)
                    }
                    if let kmSinceFullStatus {
                        Text(kmSinceFullStatus).font(.caption).foregroundStyle(.secondary)
                    }
                    EcoInfoIcon(title: "Stima, non sensore carburante", message:
                        "Inserisci l'autonomia con un pieno. Puoi impostare i km già percorsi " +
                        "dall'ultimo rifornimento, oppure premere Pieno nel cockpit dopo un pieno vero. " +
                        "I prossimi km GPS registrati si sommano alla distanza manuale; " +
                        "viaggi ad app chiusa, consumi variabili e rifornimenti parziali non sono rilevati.")
                }
                Section("Velocità media") {
                    Stepper("Fondoscala: \(Int(averageSpeedScaleKmh)) km/h",
                        value: $averageSpeedScaleKmh, in: 30...240, step: 10)
                    EcoInfoIcon(title: "Media viaggio GPS", message:
                        "Distanza del TRIP divisa per il tempo di movimento GPS registrato. " +
                        "Senza dati sufficienti appare un trattino. La barra è solo indicativa.")
                }
            }
        case .appearance:
            Section("Aspetto dell'app") {
                Picker("Modalità schermo", selection: $appearanceMode) {
                    ForEach(EcoAppearanceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                EcoInfoIcon(title: "Aspetto", message: "Automatico segue l'aspetto del dispositivo, anche il cambio giorno/notte. Vale per Home, pagine e Apple Maps.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        case .music:
            Section("Apple Music") {
                EcoInfoIcon(title: "Musica", message: "Apple Music è l'unico servizio musicale. In Telemetria e Mappa i comandi Musica sostituiscono i pulsanti standard. GPS e tachimetro restano attivi.")
                    .font(.footnote).foregroundStyle(.secondary)
                Button("Autorizza Apple Music") { music.requestAppleAccess() }
                EcoInfoIcon(title: "Apple Music", message: "La ricerca usa MusicKit e riproduce i brani in Ecojumbo. Sono necessari autorizzazione iOS, abbonamento al catalogo e servizio MusicKit abilitato.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        case .scooter:
            Section("Il mio Ecojumbo") {
                LabeledContent("Batteria", value: "EVE LF206 · LiFePO4")
                Stepper("Celle in serie: \(cellCount)", value: $cellCount, in: 1...24)
                Stepper("Capacità nominale: \(capacity) Ah", value: $capacity, in: 20...500, step: 1)
                LabeledContent("Pacco teorico", value: "\(cellCount)S1P")
                EcoInfoIcon(title: "Scooter", message: "Sono dati di progetto e non modificano la configurazione del BMS.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        case .bluetooth:
            Section("Bluetooth JK") {
                Picker("Formato frame", selection: $rawFormat) {
                    ForEach(JKFrameFormat.allCases) { variant in
                        Text(variant.rawValue).tag(variant.rawValue)
                    }
                }
                EcoInfoIcon(title: "Protocollo JK", message: "JK02 24S/32S indica il formato dei pacchetti, non il numero di celle. La compatibilità dipende dal firmware reale.")
                    .font(.footnote).foregroundStyle(.secondary)
                Button("Applica formato di lettura") {
                    bluetooth.applyFormat(JKFrameFormat(rawValue: rawFormat) ?? .automatic, cells: cellCount)
                }
            }
        case .charging:
            Section("Ricarica") {
                Stepper("Avviso: \(chargeAlert)%", value: $chargeAlert, in: 50...100, step: 5)
                EcoInfoIcon(title: "Avviso ricarica", message: "È solo un avviso visivo con app aperta e dati BMS/SOC disponibili: non interrompe la carica.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        case .odometer:
            Section(vehicleMode == EcoVehicleMode.universal.rawValue
                    ? "Chilometri totali veicolo" : "Chilometri totali dello scooter") {
                EcoInfoIcon(title: "Contachilometri", message: "Inserisci il chilometraggio originale. Ecojumbo aggiunge poi i km GPS senza azzerare il totale.")
                    .font(.footnote).foregroundStyle(.secondary)
                HStack {
                    TextField("Chilometri attuali", text: $odometerText)
                        .keyboardType(.decimalPad)
                        .focused($odometerFieldFocused)
                        .submitLabel(.done)
                        .onSubmit(saveOdometer)
                    Text("km").foregroundStyle(.secondary)
                    Button("Salva", action: saveOdometer)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.ecoGreen)
                }
                if let odometerStatus { Text(odometerStatus).font(.caption).foregroundStyle(.secondary) }
            }
        case .bars:
            Section("Scale delle barre luminose") {
                EcoInfoIcon(title: "Barre luminose", message: "Le scale sono grafiche, non limitano la velocità. Il tachimetro legge la velocità GPS reale.")
                    .font(.footnote).foregroundStyle(.secondary)
                if vehicleMode == EcoVehicleMode.universal.rawValue {
                    LabeledContent("Carburante", value: "0–100% stimato")
                    LabeledContent("Velocità media GPS", value: "0–\(Int(averageSpeedScaleKmh)) km/h")
                } else {
                    LabeledContent("SOC", value: "0–100%")
                    LabeledContent("Tensione 20S", value: "50–73 V")
                    Stepper("Potenza istantanea: 0–\(Int(averagePowerMaxKW)) kW",
                            value: $averagePowerMaxKW, in: 1...20, step: 1)
                }
                Stepper("Velocità massima veicolo: \(Int(vehicleSpeedMaxKmh)) km/h",
                        value: $vehicleSpeedMaxKmh, in: 30...240, step: 5)
                Toggle("Colore speciale oltre il limite", isOn: $speedLimitColorEnabled)
                Stepper("Cambio colore da: \(Int(speedColorThresholdKmh)) km/h",
                        value: $speedColorThresholdKmh,
                        in: 10...vehicleSpeedMaxKmh, step: 5)
                    .disabled(!speedLimitColorEnabled)
                EcoInfoIcon(title: "Limite velocità",
                    message: speedLimitColorEnabled
                        ? "Al limite prevale il colore scelto nel tema. È un avviso grafico, non un limitatore."
                        : "Avviso limite spento. Il LED segue i sensori inerziali o i watt BMS reali.")
            }
        case .power:
            Section("Sorgente automatica") {
                LabeledContent("Controllo",
                    value: vehicleMode == EcoVehicleMode.universal.rawValue ? "Inerzia" : "BMS")
                EcoInfoIcon(title: "Sorgente", message:
                    "La sorgente è determinata dalla modalità Veicolo. " +
                    "In Universale l'inerzia non misura watt; in BMS i watt si mostrano " +
                    "solo con campioni JK recenti, con fallback visivo all'inerzia.")
                HStack {
                    Label(vehicleMode == EcoVehicleMode.bms.rawValue ? "BMS" : "Sensori",
                          systemImage: vehicleMode == EcoVehicleMode.bms.rawValue
                            ? "battery.100percent" : "gyroscope")
                    Spacer()
                    Text(vehicleMode == EcoVehicleMode.bms.rawValue
                         && bluetooth.isConnected
                         && bluetooth.snapshot.map({ abs($0.date.timeIntervalSinceNow) < 10 }) == true
                         ? "Connesso" : (powerMotion.available ? "Inerzia" : "Non disponibile"))
                        .font(.caption).foregroundStyle(.secondary)
                }
                EcoInfoIcon(title: "Scala potenza",
                    message: "In modalità BMS i colori seguono ingresso/uscita dell'energia misurata; senza un BMS recente si usa l'inerzia. In Universale azzurro indica decelerazione e arancione accelerazione. I sensori non misurano watt.")
            }
            Section("Sensori inerziali") {
                HStack(spacing: 12) {
                    Image(systemName: "gyroscope")
                        .foregroundStyle(.secondary)
                    Slider(value: $motionSensitivity, in: 0...1, step: 0.01)
                        .accessibilityLabel("Sensibilità inerziale")
                    Text("\(Int((motionSensitivity * 100).rounded()))%")
                        .font(.caption.monospacedDigit()).frame(width: 44)
                }
                Picker("Asse iPhone", selection: $motionAxis) {
                    Text("Z").tag("z")
                    Text("X").tag("x")
                    Text("Y").tag("y")
                }
                .pickerStyle(.segmented)
                Toggle("Inverti direzione", isOn: $reverseMotion)
                EcoInfoIcon(title: "Orientamento iPhone",
                    message: "Fissa il telefono al supporto: Z è l'asse perpendicolare allo schermo, X/Y sono assi laterali. Se accelerazione e frenata hanno colori invertiti, usa Inverti. I sensori rilevano movimento, non watt o frenata rigenerativa.")
            }
        case .weather:
            Section("Temperatura esterna") {
                EcoInfoIcon(title: "Meteo", message: "Temperatura stimata a 2 m dal suolo, non misurata dall'iPhone. Richiede GPS e Internet; aggiornamento massimo ogni 15 minuti.")
                    .font(.footnote).foregroundStyle(.secondary)
                Label {
                    Link("Open-Meteo", destination: URL(string: "https://open-meteo.com")!)
                } icon: {
                    Image(systemName: "cloud.sun")
                }
                Label {
                    Link("CC BY 4.0", destination: URL(string: "https://creativecommons.org/licenses/by/4.0/")!)
                } icon: {
                    Image(systemName: "doc.text")
                }
            }
        }
    }

    private func saveFullRange() {
        let normalized = fullRangeText.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let kilometers = Double(normalized), kilometers.isFinite,
              (10...2500).contains(kilometers) else {
            fullRangeStatus = "Inserisci un'autonomia valida da 10 a 2500 km."
            return
        }
        fullRangeKm = kilometers
        fullRangeText = String(format: "%.0f", kilometers)
        fullRangeStatus = "Autonomia salvata. Per iniziare la stima premi Pieno nel cockpit."
    }

    private func saveKmSinceFull() {
        let normalized = kmSinceFullText.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let kilometers = Double(normalized), kilometers.isFinite,
              (0...1_000_000).contains(kilometers) else {
            kmSinceFullStatus = "Inserisci una distanza valida da 0 a 1.000.000 km."
            return
        }
        guard gps.setUniversalKmSinceFull(kilometers) else {
            kmSinceFullStatus = "Seleziona Universale e salva prima l'autonomia con un pieno."
            return
        }
        kmSinceFullText = String(format: "%.1f", gps.universalKmSinceFull)
        kmSinceFullStatus = "Distanza salvata. Il GPS sommerà i prossimi km percorsi."
        distanceFieldFocused = false
    }

    private func saveOdometer() {
        let normalized = odometerText.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let number = Double(normalized), number.isFinite,
              (0...9_999_999).contains(number) else {
            odometerStatus = "Inserisci un numero di chilometri valido."
            return
        }
        gps.setOdometer(number)
        odometerText = String(format: "%.1f", gps.totalKm)
        odometerStatus = "Chilometraggio aggiornato sul telefono."
        odometerFieldFocused = false
    }
}


// Il numero mostrato in Impostazioni deriva dai dati effettivi della build iOS.
// Esempio: versione App Store 1.0 e build 3 -> "1.03".
private enum EcojumboBuildStamp {
    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }
    static var display: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let buildString = buildNumber
        guard let build = Int(buildString), build >= 0 else {
            return "\(version) (\(buildString))"
        }
        return "\(version).\(String(format: "%02d", build))"
    }
}
