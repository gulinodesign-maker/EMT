import Foundation
import Combine

struct RidePoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let voltage: Double
    let current: Double
}

/// Only integrates readings actually received while the app is running in the foreground.
/// Positive current from JK means charging, negative means discharge.
final class RideSession: ObservableObject {
    @Published private(set) var points: [RidePoint] = []
    @Published private(set) var dischargedAh: Double = 0
    @Published private(set) var chargedAh: Double = 0
    @Published private(set) var dischargedKWh: Double = 0
    @Published private(set) var chargedKWh: Double = 0
    @Published private(set) var observedSeconds: TimeInterval = 0
    // Media della potenza erogata durante il tempo effettivamente osservato via BLE.
    var averageDischargeKW: Double? {
        guard observedSeconds >= 30 else { return nil }
        return dischargedKWh * 3600 / observedSeconds
    }
    @Published private(set) var observedTripKm: Double?
    private var tripKmAtFirstSample: Double?
    private var last: JKSnapshot?

    func observeDistance(_ currentTripKm: Double) {
        guard !points.isEmpty, currentTripKm.isFinite, currentTripKm >= 0 else { return }
        if tripKmAtFirstSample == nil { tripKmAtFirstSample = currentTripKm }
        if let first = tripKmAtFirstSample {
            observedTripKm = max(0, currentTripKm - first)
        }
    }

    func add(_ snapshot: JKSnapshot) {
        if let prior = last {
            let dt = snapshot.date.timeIntervalSince(prior.date)
            if dt > 0 && dt <= 10 {
                observedSeconds += dt
                let averageCurrent = (prior.current + snapshot.current) / 2
                let averageVoltage = (prior.voltage + snapshot.voltage) / 2
                let ah = averageCurrent * dt / 3600
                let kWh = averageCurrent * averageVoltage * dt / 3_600_000
                if ah >= 0 { chargedAh += ah } else { dischargedAh -= ah }
                if kWh >= 0 { chargedKWh += kWh } else { dischargedKWh -= kWh }
            }
        }
        points.append(RidePoint(timestamp: snapshot.date, voltage: snapshot.voltage, current: snapshot.current))
        if points.count > 900 { points.removeFirst(points.count - 900) }
        last = snapshot
    }

    func pause() { last = nil }
    func reset() {
        points.removeAll()
        last = nil
        dischargedAh = 0
        chargedAh = 0
        dischargedKWh = 0
        chargedKWh = 0
        observedSeconds = 0
        observedTripKm = nil
        tripKmAtFirstSample = nil
    }
}
