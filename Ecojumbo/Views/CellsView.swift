import SwiftUI

/// Panoramica delle celle del BMS JK. Nessun dato viene simulato.
struct CellsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var bluetooth: JKBluetoothManager
    @AppStorage("ecojumbo.cellCount") private var cellCount = 20

    private let columns = [GridItem(.adaptive(minimum: 142, maximum: 230), spacing: 12)]

    var body: some View {
        TimelineView(.periodic(from: .now, by: 2)) { time in
            ScrollView {
                if let snapshot = verifiedSnapshot(at: time.date) {
                    liveContent(snapshot)
                } else {
                    ContentUnavailableView(
                        "Celle non disponibili",
                        systemImage: "battery.0percent",
                        description: Text("Collega il BMS JK via Bluetooth e attendi una lettura reale verificata. Nessun valore viene inventato.")
                    )
                    .padding(.top, 24)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.ecoBackground)
        }
        .navigationTitle("Batteria · 20 celle")
    }

    private func verifiedSnapshot(at time: Date) -> JKSnapshot? {
        guard bluetooth.isConnected,
              let snapshot = bluetooth.snapshot,
              abs(time.timeIntervalSince(snapshot.date)) < 10,
              !snapshot.cells.isEmpty else { return nil }
        return snapshot
    }

    private func liveContent(_ snapshot: JKSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                summaryTile("Carica", value: "\(snapshot.soc)%", icon: "battery.100percent")
                summaryTile("Tensione", value: String(format: "%.2f V", snapshot.voltage), icon: "bolt.fill")
                summaryTile("Differenza celle", value: String(format: "%.0f mV", snapshot.deltaCellMillivolts), icon: "arrow.left.and.right")
                summaryTile("Celle ricevute", value: "\(snapshot.cells.count)", icon: "square.grid.3x3")
            }
            .frame(maxWidth: .infinity)

            if snapshot.errorBits != 0 {
                Label("Il BMS segnala allarmi. Consulta l'app JK ufficiale per i dettagli.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.footnote)
                    .padding(.horizontal, 4)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(snapshot.cells.enumerated()), id: \.offset) { index, voltage in
                    cellTile(number: index + 1, voltage: voltage, snapshot: snapshot)
                }
            }
            Text("Valori in sola lettura, ricevuti via Bluetooth dal BMS. L'isolamento, il bilanciamento e le protezioni rimangono gestiti dal BMS.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
    }

    private func summaryTile(_ title: String, value: String, icon: String) -> some View {
        EcoCard {
            VStack(alignment: .leading, spacing: 5) {
                Label(title, systemImage: icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(colorScheme == .light ? Color(white: 0.14) : .white)
                    .monospacedDigit()
                    .minimumScaleFactor(0.65)
                    .lineLimit(1)
            }
        }
    }

    private func cellTile(number: Int, voltage: Double, snapshot: JKSnapshot) -> some View {
        let low = snapshot.cells.min() ?? voltage
        let high = snapshot.cells.max() ?? voltage
        let outlier = (high - low) > 0.05 && (voltage == high || voltage == low)
        return HStack(spacing: 10) {
            Image(systemName: "battery.100percent")
                .foregroundStyle(outlier ? Color.orange : Color.ecoGreen)
            VStack(alignment: .leading, spacing: 3) {
                Text("Cella \(number)").font(.caption).foregroundStyle(.secondary)
                Text(String(format: "%.3f V", voltage))
                    .font(.system(.headline, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(colorScheme == .light ? Color(white: 0.14) : .white)
            }
            Spacer(minLength: 0)
        }
        .padding(13)
        .background(Color.ecoCard, in: RoundedRectangle(cornerRadius: 12))
    }
}
