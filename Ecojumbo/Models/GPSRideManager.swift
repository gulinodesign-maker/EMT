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
    @Published private(set) var speedDiagnostic = "Velocità GPS non ancora misurata"
    // Ultima posizione reale accurata, usata come partenza da MapKit.
    @Published private(set) var lastGPSCoordinate: CLLocationCoordinate2D?
    @Published private(set) var lastHorizontalAccuracy: CLLocationAccuracy?
    @Published private(set) var courseDegrees: CLLocationDirection?
    @Published private(set) var compassHeadingDegrees: CLLocationDirection?
    private var lastGoodCoordinateAt: Date?
    private var lastCourseAt: Date?
    private var lastCompassAt: Date?
    private var lastOneShotRequestAt: Date?
    @Published private(set) var tripKm: Double
    @Published private(set) var totalKm: Double
    @Published private(set) var hasOdometer: Bool
    @Published private(set) var track: [RouteCoordinate]
    @Published private(set) var movingSeconds: TimeInterval = 0
    @Published private(set) var state: String = "GPS non avviato"
    @Published private(set) var isReceiving = false

    private let manager = CLLocationManager()
    private var previousLocation: CLLocation?
    private var previousSpeedFix: CLLocation?
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
        // Primo fix rapido; precisione di navigazione dopo il primo fix valido.
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .automotiveNavigation
        // La localizzazione non deve sospendersi mentre lo scooter è fermo:
        // MapKit deve poter acquisire una partenza anche prima di muoversi.
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
    }

    var isPermissionDenied: Bool {
        manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted
    }

    // Un fix valido per la mappa non assicura una misura di velocità.
    func speedStatus(at date: Date = Date()) -> String {
        if isPermissionDenied { return "Posizione negata: apri Impostazioni" }
        if !CLLocationManager.locationServicesEnabled() {
            return "Localizzazione disattivata sul dispositivo"
        }
        if manager.accuracyAuthorization == .reducedAccuracy {
            return "Attiva Posizione precisa per la velocità"
        }
        if currentCoordinate(at: date) == nil { return state }
        if let lastHorizontalAccuracy, lastHorizontalAccuracy > 65 {
            return "Posizione ±\(Int(lastHorizontalAccuracy)) m: velocità non affidabile"
        }
        if currentSpeed(at: date) != nil { return speedDiagnostic }
        return "Posizione disponibile: " + speedDiagnostic
    }

    func start() {
        guard !started else { return }
        started = true
        retryLocation()
    }

    /// Riprova anche dopo un timeout o una sospensione di Core Location.
    /// Se i permessi sono negati, non inventiamo una posizione sostitutiva.
    func retryLocation() {
        started = true
        guard CLLocationManager.locationServicesEnabled() else {
            state = "Servizi di localizzazione disattivati sul dispositivo"
            isReceiving = false
            return
        }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Lo stream resta attivo, ma una richiesta singola aiuta ad
            // ottenere il primo fix senza aspettare il movimento.
            manager.startUpdatingLocation()
            if CLLocationManager.headingAvailable() { manager.startUpdatingHeading() }
            let now = Date()
            if currentCoordinate(at: now) == nil,
               lastOneShotRequestAt.map({ now.timeIntervalSince($0) > 15 }) ?? true {
                lastOneShotRequestAt = now
                manager.requestLocation()
            }
            state = "Ricerca posizione del dispositivo…"
        case .notDetermined:
            state = "Autorizza l'accesso alla posizione"
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            state = "Posizione negata: abilitala nelle Impostazioni"
            isReceiving = false
        @unknown default:
            state = "Posizione non disponibile sul dispositivo"
        }
    }

    func stop() {
        started = false
        manager.stopUpdatingLocation()
        if CLLocationManager.headingAvailable() { manager.stopUpdatingHeading() }
        speedKmh = nil
        lastGPSCoordinate = nil
        lastHorizontalAccuracy = nil
        lastGoodCoordinateAt = nil
        lastValidAt = nil
        courseDegrees = nil
        lastCourseAt = nil
        compassHeadingDegrees = nil
        lastCompassAt = nil
        lastOneShotRequestAt = nil
        previousLocation = nil
        previousSpeedFix = nil
        lastMotionAt = nil
        speedDiagnostic = "Velocità GPS non ancora misurata"
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
            retryLocation()
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
            // La posizione per MapKit funziona anche da fermi e non richiede
            // una misura di velocità valida. Precisione massima 300 m per
            // evitare partenze chilometriche errate nella navigazione.
            // Trip richiede <= 35 m; tachimetro nativo <= 65 m.
            // La stima alternativa richiede due fix reali entro 20 m.
            guard abs(fix.timestamp.timeIntervalSinceNow) < 25,
                  fix.horizontalAccuracy >= 0, fix.horizontalAccuracy <= 300,
                  CLLocationCoordinate2DIsValid(fix.coordinate) else {
                if fix.horizontalAccuracy > 300 {
                    state = "Posizione troppo imprecisa: attiva Posizione precisa"
                    isReceiving = false
                }
                continue
            }
            // La rotta GPS esiste solo quando lo scooter si muove.
            // Core Location usa -1 per un corso non determinato.
            if fix.speed >= 1.3, fix.course >= 0, fix.course < 360 {
                courseDegrees = fix.course
                lastCourseAt = fix.timestamp
            }
            lastGPSCoordinate = fix.coordinate
            if fix.horizontalAccuracy <= 65 &&
               manager.desiredAccuracy != kCLLocationAccuracyBestForNavigation {
                manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            }
            lastHorizontalAccuracy = fix.horizontalAccuracy
            lastGoodCoordinateAt = fix.timestamp
            state = fix.horizontalAccuracy > 35
                ? "Posizione approssimata (±\(Int(fix.horizontalAccuracy)) m)"
                : "GPS attivo"
            isReceiving = true
            // La velocità nativa viene accettata quando affidabile anche
            // se speedAccuracy == -1 (dato di incertezza non disponibile).
            // Mai ricavare la velocità da punti MapKit simulati.
            let usableSpeed = abs(fix.timestamp.timeIntervalSinceNow) < 20
                && fix.horizontalAccuracy <= 65
                && fix.speed >= 0 && fix.speed <= 50
                && (fix.speedAccuracy < 0 || fix.speedAccuracy <= 7)
            if usableSpeed {
                let kmh = fix.speed * 3.6
                speedKmh = kmh < 1.5 ? 0 : kmh
                lastValidAt = fix.timestamp
                speedDiagnostic = "Velocità nativa Core Location"
            } else {
                // Fallback solo con due misure reali nettamente separate rispetto
                // all'errore GPS: è una stima da distanza/tempo, mai una simulazione.
                var estimatedSpeed: Double?
                if let previous = previousSpeedFix,
                   fix.horizontalAccuracy <= 20,
                   previous.horizontalAccuracy >= 0,
                   previous.horizontalAccuracy <= 20 {
                    let dt = fix.timestamp.timeIntervalSince(previous.timestamp)
                    if dt >= 3 && dt <= 15 {
                        let meters = fix.distance(from: previous)
                        let uncertainty = fix.horizontalAccuracy + previous.horizontalAccuracy
                        let metersPerSecond = meters / dt
                        if meters >= max(15, uncertainty * 1.7 + 8),
                           metersPerSecond >= 2, metersPerSecond <= 40 {
                            estimatedSpeed = metersPerSecond * 3.6
                        }
                    }
                }
                if let estimatedSpeed {
                    speedKmh = estimatedSpeed
                    lastValidAt = fix.timestamp
                    speedDiagnostic = "Velocità stimata da movimento GPS reale"
                } else if fix.speed < 0 {
                    speedDiagnostic = "Core Location non fornisce la velocità"
                } else if fix.horizontalAccuracy > 65 {
                    speedDiagnostic = "Posizione troppo imprecisa per la velocità"
                } else if fix.speedAccuracy > 7 {
                    speedDiagnostic = "Precisione della velocità insufficiente"
                } else {
                    speedDiagnostic = "Misura della velocità non utilizzabile"
                }
            }
            previousSpeedFix = fix

            // Trip/odometro: filtri severi invariati contro il rumore GPS.
            guard abs(fix.timestamp.timeIntervalSinceNow) < 10,
                  fix.horizontalAccuracy >= 0, fix.horizontalAccuracy <= 35,
                  fix.speed >= 0, fix.speedAccuracy >= 0, fix.speedAccuracy <= 5,
                  fix.speed <= 50 else { continue }

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

    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        // Bussola reale come fallback del course quando lo scooter è fermo.
        // Ignora letture non attendibili e assenza del sensore.
        guard started, heading.headingAccuracy >= 0,
              heading.headingAccuracy <= 45 else { return }
        let degrees = heading.trueHeading >= 0
            ? heading.trueHeading : heading.magneticHeading
        guard degrees >= 0, degrees < 360 else { return }
        compassHeadingDegrees = degrees
        lastCompassAt = Date()
    }

    func currentHeading(at date: Date = Date()) -> CLLocationDirection? {
        if let course = currentCourse(at: date) { return course }
        guard let lastCompassAt, let compassHeadingDegrees,
              date.timeIntervalSince(lastCompassAt) >= 0,
              date.timeIntervalSince(lastCompassAt) < 20 else { return nil }
        return compassHeadingDegrees
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // Alcuni sistemi sospendono gli aggiornamenti da fermi nonostante
        // pausesLocationUpdatesAutomatically = false.
        guard started else { return }
        retryLocation()
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
        if let locationError = error as? CLError,
           locationError.code == .locationUnknown {
            state = "Ricerca posizione in corso: attendi o premi Riprova"
            return
        }
        speedKmh = nil
        isReceiving = false
        state = "GPS: " + error.localizedDescription
    }

    /// Nessuna posizione inventata o vecchia per la partenza dell'itinerario.
    func currentCoordinate(at date: Date = Date()) -> CLLocationCoordinate2D? {
        guard let lastGoodCoordinateAt,
              date.timeIntervalSince(lastGoodCoordinateAt) >= 0,
              date.timeIntervalSince(lastGoodCoordinateAt) < 45 else { return nil }
        return lastGPSCoordinate
    }

    /// Direzione di marcia ricavata dal GPS durante il movimento, mai simulata.
    func currentCourse(at date: Date = Date()) -> CLLocationDirection? {
        guard let lastCourseAt, date.timeIntervalSince(lastCourseAt) >= 0,
              date.timeIntervalSince(lastCourseAt) < 12 else { return nil }
        return courseDegrees
    }

    /// I dati GPS non devono restare visibili come correnti se la localizzazione si interrompe.
    func currentSpeed(at date: Date = Date()) -> Double? {
        guard let speedKmh, let lastValidAt else { return nil }
        let age = date.timeIntervalSince(lastValidAt)
        guard age >= -2 else { return nil }
        if speedKmh < 1.5 {
            // A scooter fermo gli aggiornamenti validi possono essere più radi.
            guard age < 30, currentCoordinate(at: date) != nil else { return nil }
        } else {
            // Mai mantenere un valore positivo se il segnale si interrompe.
            guard age < 12 else { return nil }
        }
        return speedKmh
    }
}
