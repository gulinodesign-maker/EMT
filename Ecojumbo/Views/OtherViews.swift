import SwiftUI
import Charts

struct TrendsView: View {
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if bluetooth.session.points.isEmpty {
                    ContentUnavailableView("Nessun dato registrato", systemImage: "chart.xyaxis.line",
                                           description: Text("I grafici usano soltanto i campioni ricevuti realmente dal BMS quando l'app è in primo piano."))
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
                            Text("L'energia in ingresso comprende sia la ricarica sia l'eventuale rigenerazione: senza un segnale del veicolo non possiamo distinguerle.")
                                .font(.footnote).foregroundStyle(.secondary)
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
                Text(type == .voltage ? "Volt (V)" : "Ampere (A) · positivo = carica, negativo = scarica")
                    .font(.footnote).foregroundStyle(.secondary)
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
                            if !device.name.isEmpty { Text("Modello: \(device.name)").font(.footnote) }
                            if !device.hardware.isEmpty { Text("Hardware: \(device.hardware)").font(.footnote) }
                            if !device.firmware.isEmpty { Text("Firmware: \(device.firmware)").font(.footnote) }
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
                    Text("Dispositivi Bluetooth nelle vicinanze")
                        .font(.headline)
                    if bluetooth.nearby.isEmpty {
                        Text("Nessun dispositivo trovato. Accendi il BMS e avvia la ricerca. Chiudi prima l'app JK ufficiale.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    ForEach(bluetooth.nearby) { device in
                        Button { bluetooth.connect(device) } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "bluetooth").font(.title3)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(device.name).font(.headline)
                                    Text("Segnale \(device.rssi) dBm · Identità non verificata")
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
                        Text("Diagnostica collegamento").font(.headline)
                        HStack { Text("Notifiche BLE ricevute"); Spacer(); Text("\(bluetooth.rawCount)") }.font(.footnote)
                        HStack { Text("Frame JK validi"); Spacer(); Text("\(bluetooth.frameCount)") }.font(.footnote)
                        Text("La connessione Bluetooth non basta: le misure compaiono soltanto dopo la verifica del protocollo e dei controlli di coerenza.")
                            .font(.footnote).foregroundStyle(.secondary)
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
    case odometer, bars, weather

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
        case .weather: "Meteo"
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
        case .weather: "cloud.sun"
        }
    }
}

struct EcoSettingsView: View {
    @EnvironmentObject private var gps: GPSRideManager
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    @State private var activeSection: EcoSetupSection?
    @State private var odometerText = ""
    @State private var odometerStatus: String?
    @FocusState private var odometerFieldFocused: Bool
    @AppStorage("ecojumbo.cellCount") private var cellCount = 20
    @AppStorage("ecojumbo.capacity") private var capacity = 206
    @AppStorage("ecojumbo.chargeAlert") private var chargeAlert = 80
    @AppStorage("ecojumbo.frameFormat") private var rawFormat = JKFrameFormat.automatic.rawValue
    @AppStorage("ecojumbo.bars.averagePowerMaxKW") private var averagePowerMaxKW = 5.0
    @AppStorage("ecojumbo.bars.vehicleSpeedMaxKmh") private var vehicleSpeedMaxKmh = 120.0
    @AppStorage("ecojumbo.bars.speedColorThresholdKmh") private var speedColorThresholdKmh = 80.0
    @AppStorage("ecojumbo.appearanceMode") private var appearanceMode = EcoAppearanceMode.dark.rawValue
    @AppStorage("ecojumbo.theme") private var themeName = CockpitTheme.copper.rawValue
    @AppStorage("ecojumbo.themeRevision") private var themeRevision = 0

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
                    ForEach(EcoSetupSection.allCases) { section in
                        Button {
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
            speedColorThresholdKmh = min(max(10, speedColorThresholdKmh), vehicleSpeedMaxKmh)
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
                    Button("Conferma e salva", action: saveOdometer)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder private func setupFields(for section: EcoSetupSection) -> some View {
        switch section {
        case .battery, .bms:
            EmptyView()
        case .appearance:
            Section("Aspetto dell'app") {
                Picker("Modalità schermo", selection: $appearanceMode) {
                    ForEach(EcoAppearanceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                Text("Automatico segue l'aspetto del dispositivo (anche il cambio programmato giorno/notte). La scelta vale per la Home, tutte le pagine e Apple Maps.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        case .scooter:
            Section("Il mio Ecojumbo") {
                LabeledContent("Batteria", value: "EVE LF206 · LiFePO4")
                Stepper("Celle in serie: \(cellCount)", value: $cellCount, in: 1...24)
                Stepper("Capacità nominale: \(capacity) Ah", value: $capacity, in: 20...500, step: 1)
                LabeledContent("Pacco teorico", value: "\(cellCount)S1P")
                Text("Questi sono dati di progetto. Non modificano la configurazione del BMS.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        case .bluetooth:
            Section("Bluetooth JK") {
                Picker("Formato frame", selection: $rawFormat) {
                    ForEach(JKFrameFormat.allCases) { variant in
                        Text(variant.rawValue).tag(variant.rawValue)
                    }
                }
                Text("JK02 24S/32S indicano il formato dei pacchetti, non il numero delle celle. La compatibilità con il firmware reale sarà verificata dopo l'acquisto.")
                    .font(.footnote).foregroundStyle(.secondary)
                Button("Applica formato di lettura") {
                    bluetooth.applyFormat(JKFrameFormat(rawValue: rawFormat) ?? .automatic, cells: cellCount)
                }
            }
        case .charging:
            Section("Ricarica") {
                Stepper("Avviso: \(chargeAlert)%", value: $chargeAlert, in: 50...100, step: 5)
                Text("Avviso visuale soltanto con app aperta, BMS collegato e SOC ricevuto. Non interrompe la carica.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        case .odometer:
            Section("Chilometri totali dello scooter") {
                Text("Per uno scooter già usato inserisci il valore mostrato dal contachilometri originale. Ecojumbo aggiungerà i chilometri GPS registrati in seguito, senza azzerare il totale.")
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
                Text("Le scale delle barre sono solo grafiche e non limitano la velocità effettiva del veicolo. Il tachimetro usa sempre la velocità GPS reale.")
                    .font(.footnote).foregroundStyle(.secondary)
                LabeledContent("SOC", value: "0–100%")
                LabeledContent("Tensione 20S", value: "50–73 V")
                Stepper("Potenza istantanea: 0–\(Int(averagePowerMaxKW)) kW",
                        value: $averagePowerMaxKW, in: 1...20, step: 1)
                Stepper("Velocità massima veicolo: \(Int(vehicleSpeedMaxKmh)) km/h",
                        value: $vehicleSpeedMaxKmh, in: 30...240, step: 5)
                Stepper("Cambio colore da: \(Int(speedColorThresholdKmh)) km/h",
                        value: $speedColorThresholdKmh,
                        in: 10...vehicleSpeedMaxKmh, step: 5)
                Text("Da questa soglia la barra LED della velocità usa il colore oltre soglia scelto nel tema. Non è un limitatore di velocità.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        case .weather:
            Section("Temperatura esterna") {
                Text("È una stima meteorologica a 2 metri dal suolo, non la misura di un termometro dell’iPhone. Richiede GPS e Internet; aggiornata al massimo ogni 15 minuti, senza inviare la posizione precisa.")
                    .font(.footnote).foregroundStyle(.secondary)
                Link("Fonte dati: Open-Meteo", destination: URL(string: "https://open-meteo.com")!)
                Link("Licenza dati (CC BY 4.0)", destination: URL(string: "https://creativecommons.org/licenses/by/4.0/")!)
            }
        }
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
