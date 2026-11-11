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

struct EcoSettingsView: View {
    @EnvironmentObject private var gps: GPSRideManager
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    @State private var odometerText = ""
    @State private var odometerStatus: String?
    @FocusState private var odometerFieldFocused: Bool
    @AppStorage("ecojumbo.cellCount") private var cellCount = 20
    @AppStorage("ecojumbo.capacity") private var capacity = 206
    @AppStorage("ecojumbo.chargeAlert") private var chargeAlert = 80
    @AppStorage("ecojumbo.frameFormat") private var rawFormat = JKFrameFormat.automatic.rawValue
    @AppStorage("ecojumbo.bars.averagePowerMaxKW") private var averagePowerMaxKW = 5.0
    @AppStorage("ecojumbo.appearanceMode") private var appearanceMode = EcoAppearanceMode.dark.rawValue

    var body: some View {
        Form {
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
            Section("Il mio Ecojumbo") {
                LabeledContent("Batteria", value: "EVE LF206 · LiFePO4")
                Stepper("Celle in serie: \(cellCount)", value: $cellCount, in: 1...24)
                Stepper("Capacità nominale: \(capacity) Ah", value: $capacity, in: 20...500, step: 1)
                LabeledContent("Pacco teorico", value: "\(cellCount)S1P")
                Text("Questi sono dati di progetto. Non modificano la configurazione del BMS.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
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
            Section("Ricarica") {
                Stepper("Avviso: \(chargeAlert)%", value: $chargeAlert, in: 50...100, step: 5)
                Text("Avviso visuale soltanto con app aperta, BMS collegato e SOC ricevuto. Non interrompe la carica.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
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
            Section("Scale delle barre luminose") {
                Text("Tre barre reali per carica batteria, tensione e potenza istantanea. Nessuna barra nelle tre schede chilometriche. Le scale sono solo grafiche, non limiti di sicurezza.")
                    .font(.footnote).foregroundStyle(.secondary)
                LabeledContent("SOC", value: "0–100%")
                LabeledContent("Tensione 20S", value: "50–73 V")
                Stepper("Potenza istantanea: 0–\(Int(averagePowerMaxKW)) kW",
                        value: $averagePowerMaxKW, in: 1...20, step: 1)
            }
            Section("GPS e viaggi") {
                Text("Il tachimetro usa soltanto Core Location e mostra — quando il segnale GPS non è disponibile. I chilometri vengono accumulati solo con posizioni valide e l’app attiva. Non sostituisce il tachimetro omologato del veicolo.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Temperatura esterna") {
                Text("È una stima meteorologica a 2 metri dal suolo, non la misura di un termometro dell’iPhone. Richiede GPS e Internet; aggiornata al massimo ogni 15 minuti, senza inviare la posizione precisa.")
                    .font(.footnote).foregroundStyle(.secondary)
                Link("Fonte dati: Open-Meteo", destination: URL(string: "https://open-meteo.com")!)
                Link("Licenza dati (CC BY 4.0)", destination: URL(string: "https://creativecommons.org/licenses/by/4.0/")!)
            }
            Section("Sicurezza e privacy") {
                Label("Sola lettura dei dati BMS", systemImage: "lock.shield")
                Label("Nessuna simulazione", systemImage: "checkmark.seal")
                Label("I dati della sessione restano sul telefono", systemImage: "iphone")
                Text("I grafici non sono registrati durante la chiusura dell'app. Non utilizzare Ecojumbo come unico indicatore di sicurezza durante la guida.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Versione") {
                LabeledContent("Ecojumbo", value: EcojumboBuildStamp.display)
                LabeledContent("Numero build", value: EcojumboBuildStamp.buildNumber)
                Text("App iPhone dedicata esclusivamente allo scooter Ecojumbo e al suo BMS.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.ecoBackground)
        .navigationTitle("Scooter")
        // .decimalPad non offre il tasto Invio su iPhone in landscape:
        // il pulsante sopra la tastiera permette di SALVARE e chiuderla.
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Conferma e salva", action: saveOdometer)
                    .fontWeight(.semibold)
            }
        }
        .onAppear {
            bluetooth.applyFormat(JKFrameFormat(rawValue: rawFormat) ?? .automatic, cells: cellCount)
            odometerText = gps.hasOdometer ? String(format: "%.1f", gps.totalKm) : ""
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
