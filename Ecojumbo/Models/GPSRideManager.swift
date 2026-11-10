import Foundation
import CoreLocation
import Combine

struct RouteCoordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
}

/// GPS del telefono: nessuna velocità o distanza è simulata.
/// Le distanze accumulate riguardano soltanto le posizioni ricevute con app in uso.
@MainActor
final class GPSRideManager: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {
    @Published private(set) var speedKmh: Double?
    @Published private(set) var tripKm: Double
    @Published private(set) var totalKm: Double
    @Published private(set) var hasOdometer: Bool
    @Published private(set) var track: [RouteCoordinate]
    @Published private(set) var movingSeconds: TimeInterval = 0
    @Published private(set) var state: String = "GPS non avviato"
    @Published private(set) var isReceiving = false

    private let manager = CLLocationManager()
    private var previousLocation: CLLocation?
    private var lastValidAt: Date?
    private var lastMotionAt: Date?
    private var started = false

    override init() {
        tripKm = UserDefaults.standard.double(forKey: "ecojumbo.gps.tripKm")
        totalKm = UserDefaults.standard.double(forKey: "ecojumbo.gps.totalKm")
        hasOdometer = UserDefaults.standard.object(forKey: "ecojumbo.gps.odometerKnown") as? Bool
            ?? (UserDefaults.standard.double(forKey: "ecojumbo.gps.totalKm") > 0)
        if let data = UserDefaults.standard.data(forKey: "ecojumbo.gps.track"),
           let saved = try? JSONDecoder().decode([RouteCoordinate].self, from: data) {
            track = saved
        } else {
            track = []
        }
        movingSeconds = UserDefaults.standard.double(forKey: "ecojumbo.gps.movingSeconds")
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
        manager.distanceFilter = 2
        manager.pausesLocationUpdatesAutomatically = true
    }

    func start() {
        guard !started else { return }
        started = true
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            state = "Ricerca segnale GPS…"
        case .notDetermined:
            state = "Autorizza posizione durante l'uso"
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            state = "Permesso posizione negato"
        @unknown default:
            state = "GPS non disponibile"
        }
    }

    func stop() {
        started = false
        manager.stopUpdatingLocation()
        speedKmh = nil
        previousLocation = nil
        lastMotionAt = nil
        isReceiving = false
        state = "GPS in pausa"
    }

    func setOdometer(_ kilometers: Double) {
        guard kilometers.isFinite && kilometers >= 0 && kilometers <= 9_999_999 else { return }
        totalKm = kilometers
        hasOdometer = true
        UserDefaults.standard.set(totalKm, forKey: "ecojumbo.gps.totalKm")
        UserDefaults.standard.set(true, forKey: "ecojumbo.gps.odometerKnown")
    }

    func resetTrip() {
        tripKm = 0
        track.removeAll()
        UserDefaults.standard.removeObject(forKey: "ecojumbo.gps.track")
        movingSeconds = 0
        previousLocation = nil
        lastMotionAt = nil
        UserDefaults.standard.set(0, forKey: "ecojumbo.gps.tripKm")
        UserDefaults.standard.set(0, forKey: "ecojumbo.gps.movingSeconds")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard started else { return }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            state = "Ricerca segnale GPS…"
        case .denied, .restricted:
            speedKmh = nil
            isReceiving = false
            state = "Permesso posizione negato"
        case .notDetermined:
            state = "Autorizza posizione durante l'uso"
        @unknown default:
            state = "GPS non disponibile"
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard started else { return }
        for fix in locations.sorted(by: { $0.timestamp < $1.timestamp }) {
            // Ignoriamo punti vecchi, imprecisi o con velocità non misurata.
            guard abs(fix.timestamp.timeIntervalSinceNow) < 10,
                  fix.horizontalAccuracy >= 0, fix.horizontalAccuracy <= 35,
                  fix.speed >= 0, fix.speedAccuracy >= 0, fix.speedAccuracy <= 5,
                  fix.speed <= 50 else { continue }
            let kmh = fix.speed * 3.6
            speedKmh = kmh < 1.5 ? 0 : kmh
            state = "GPS attivo"
            isReceiving = true
            lastValidAt = fix.timestamp

            if let previous = previousLocation {
                let dt = fix.timestamp.timeIntervalSince(previous.timestamp)
                if dt > 0 && dt <= 30 {
                    let meters = fix.distance(from: previous)
                    // Rifiuta i salti dovuti al rumore GPS, soprattutto a veicolo fermo.
                    if fix.speed > 1.2 && meters >= 2 && meters <= dt * 50 + 4 {
                        let increment = meters / 1000
                        tripKm += increment
                        if hasOdometer { totalKm += increment }
                        UserDefaults.standard.set(tripKm, forKey: "ecojumbo.gps.tripKm")
                        if hasOdometer {
                            UserDefaults.standard.set(totalKm, forKey: "ecojumbo.gps.totalKm")
                        }
                        recordRoutePoint(fix)
                        if let lastMotionAt {
                            let motionDt = fix.timestamp.timeIntervalSince(lastMotionAt)
                            if motionDt > 0 && motionDt < 30 {
                                movingSeconds += motionDt
                                UserDefaults.standard.set(movingSeconds, forKey: "ecojumbo.gps.movingSeconds")
                            }
                        }
                        lastMotionAt = fix.timestamp
                    } else if fix.speed <= 1.2 {
                        lastMotionAt = nil
                    }
                } else { lastMotionAt = nil }
            }
            previousLocation = fix
        }
    }

    private func recordRoutePoint(_ fix: CLLocation) {
        let candidate = RouteCoordinate(latitude: fix.coordinate.latitude, longitude: fix.coordinate.longitude)
        if let last = track.last {
            let prev = CLLocation(latitude: last.latitude, longitude: last.longitude)
            guard fix.distance(from: prev) > 8 else { return }
        }
        track.append(candidate)
        if track.count > 1500 { track.removeFirst(track.count - 1500) }
        if let encoded = try? JSONEncoder().encode(track) {
            UserDefaults.standard.set(encoded, forKey: "ecojumbo.gps.track")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        speedKmh = nil
        isReceiving = false
        state = "GPS: " + error.localizedDescription
    }

    /// I dati GPS non devono restare visibili come correnti se la localizzazione si interrompe.
    func currentSpeed(at date: Date = Date()) -> Double? {
        guard let lastValidAt, date.timeIntervalSince(lastValidAt) < 8 else { return nil }
        return speedKmh
    }
}
