import Foundation
import CoreLocation
import Combine
import CoreMotion
import UIKit

// Direzione visualizzata dal cursore velocità, non misura dei watt fittizi.
enum EcoPowerFlow: Equatable {
    case neutral, incoming, outgoing
}
enum EcoPowerSource: String, CaseIterable {
    case inertia, bms
}

// Build 115: modalità persistente indipendente dal vecchio selettore potenza.
enum EcoVehicleMode: String, CaseIterable, Identifiable {
    case bms = "BMS"
    case universal = "Universale"
    var id: String { rawValue }
}

// Build 109: classificazione inerziale senza contributo della velocità GPS.
// Core Motion combina accelerometro e giroscopio per rimuovere la gravità;
// il giroscopio puro misura rotazione, non accelerazione longitudinale.
@MainActor
final class EcoPowerMotionManager: ObservableObject {
    @Published private(set) var flow: EcoPowerFlow = .neutral
    @Published private(set) var available = false
    @Published private(set) var lastUpdate: Date = .distantPast
    @Published private(set) var inclinationRollDegrees: Double?
    @Published private(set) var inclinationPitchDegrees: Double?

    private let sensor = CMMotionManager()
    private var filteredAcceleration: Double = 0
    private var pendingFlow: EcoPowerFlow?
    private var pendingSince: Date?
    private var lastTransition: Date = .distantPast
    private var started = false
    private var inclinationActive = false
    private var latestInclinationGravity: VehicleGravityVector?
    private var inclinationZeroGravity: VehicleGravityVector?
    private var inclinationZeroLandscapeLeft: Bool?
    private var lastInclinationPublish: Date = .distantPast

    func start() {
        guard !started else { return }
        available = sensor.isDeviceMotionAvailable
        guard available else {
            flow = .neutral
            lastUpdate = .distantPast
            return
        }
        started = true
        filteredAcceleration = 0
        pendingFlow = nil
        pendingSince = nil
        lastTransition = .distantPast
        sensor.deviceMotionUpdateInterval = 1.0 / 30.0
        sensor.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion else { return }
            let accel = motion.userAcceleration
            let gravity = VehicleGravityVector(x: motion.gravity.x, y: motion.gravity.y, z: motion.gravity.z)
            let rotation = motion.rotationRate
            let turnRate = sqrt(rotation.x * rotation.x
                                + rotation.y * rotation.y
                                + rotation.z * rotation.z)
            Task { @MainActor [weak self] in
                let time = Date()
                self?.consume(x: accel.x, y: accel.y, z: accel.z,
                              rotationRate: turnRate, at: time)
                self?.consumeInclination(gravity: gravity, at: time)
            }
        }
    }

    func stop() {
        sensor.stopDeviceMotionUpdates()
        started = false
        filteredAcceleration = 0
        pendingFlow = nil
        pendingSince = nil
        flow = .neutral
        lastUpdate = .distantPast
        lastTransition = .distantPast
        latestInclinationGravity = nil
        inclinationRollDegrees = nil
        inclinationPitchDegrees = nil
    }

    // Il cockpit e' landscape, ma Core Motion usa gli assi fissi dell'iPhone.
    // L'interfaccia (non UIDeviceOrientation) determina destra/sinistra.
    private func inclinationLandscapeLeft() -> Bool {
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            guard scene.activationState != .background else { continue }
            switch scene.interfaceOrientation {
            case .landscapeLeft: return true
            case .landscapeRight: return false
            default: continue
            }
        }
        return false
    }

    // Condivide Core Motion con l'inerzia. Aprire la card NON azzera la pendenza:
    // fino a una taratura esplicita su strada piana mostriamo —°, mai gradi inventati.
    func setInclinationActive(_ active: Bool) {
        guard inclinationActive != active else { return }
        inclinationActive = active
        lastInclinationPublish = .distantPast
        if !active {
            inclinationRollDegrees = nil
            inclinationPitchDegrees = nil
        }
    }

    // AZZERA va premuto SOLO quando l'auto e' ferma e su una superficie piana.
    // Memorizza la direzione reale di gravita', non un attitude Euler arbitrario.
    func zeroInclination() {
        guard inclinationActive, let gravity = latestInclinationGravity else { return }
        let landscapeLeft = inclinationLandscapeLeft()
        guard VehicleInclinationMath.angles(gravity: gravity, landscapeLeft: landscapeLeft,
                                            zeroGravity: gravity) != nil else { return }
        inclinationZeroGravity = gravity
        inclinationZeroLandscapeLeft = landscapeLeft
        inclinationRollDegrees = 0
        inclinationPitchDegrees = 0
    }

    private func consumeInclination(gravity: VehicleGravityVector, at date: Date) {
        latestInclinationGravity = gravity
        guard inclinationActive, date.timeIntervalSince(lastInclinationPublish) >= 0.09 else {
            return
        }
        let landscapeLeft = inclinationLandscapeLeft()
        if let original = inclinationZeroLandscapeLeft, original != landscapeLeft {
            // Se il telefono viene ruotato, la taratura precedente non e' piu' valida.
            inclinationZeroGravity = nil
            inclinationZeroLandscapeLeft = nil
        }
        guard let angles = VehicleInclinationMath.angles(
            gravity: gravity, landscapeLeft: landscapeLeft,
            zeroGravity: inclinationZeroGravity
        ) else {
            inclinationRollDegrees = nil
            inclinationPitchDegrees = nil
            return
        }

        // I valori sono in gradi fisici dal vettore gravita' normalizzato.
        // Il filtro attenua vibrazioni senza alterare la scala angolare.
        lastInclinationPublish = date
        let roll = angles.rollDegrees
        let pitch = angles.pitchDegrees
        inclinationRollDegrees = (inclinationRollDegrees ?? roll) * 0.70 + roll * 0.30
        inclinationPitchDegrees = (inclinationPitchDegrees ?? pitch) * 0.70 + pitch * 0.30
    }

    private func consume(x: Double, y: Double, z: Double,
                         rotationRate: Double, at date: Date) {
        guard x.isFinite, y.isFinite, z.isFinite, rotationRate.isFinite else {
            pendingFlow = nil
            pendingSince = nil
            return
        }
        lastUpdate = date
        let settings = UserDefaults.standard
        let axis = settings.string(forKey: "ecojumbo.power.motionAxis") ?? "z"
        // Build 108 invertiva per errore l'asse Z, causando colori opposti.
        let longitudinal = switch axis {
        case "x": x
        case "y": y
        default: z
        }
        let sign = settings.bool(forKey: "ecojumbo.power.reverseMotion") ? -1.0 : 1.0
        // Filtro passa-basso: attenua vibrazioni/micro-accelerazioni
        // prima di qualunque decisione di colore.
        filteredAcceleration = 0.86 * filteredAcceleration + 0.14 * longitudinal * sign

        // Curve o cambi di assetto: congela la decisione invece di alternare
        // rapidamente arancio/azzurro. La corrente BMS non ne è influenzata.
        guard rotationRate < 1.15 else {
            pendingFlow = nil
            pendingSince = nil
            if date.timeIntervalSince(lastTransition) > 1.2 {
                flow = .neutral
                lastTransition = date
            }
            return
        }

        let sensitivity = min(1, max(0,
            settings.object(forKey: "ecojumbo.power.motionSensitivity") as? Double ?? 0.5))
        // Sensibilità alta = soglia più bassa, ma non nulla.
        let enterThreshold = 0.21 - sensitivity * 0.16 // 0.05...0.21 g
        let leaveThreshold = enterThreshold * 0.48
        let candidate: EcoPowerFlow
        switch flow {
        case .neutral:
            if filteredAcceleration > enterThreshold {
                candidate = .outgoing  // accelerazione => arancione
            } else if filteredAcceleration < -enterThreshold {
                candidate = .incoming  // decelerazione => azzurro
            } else {
                candidate = .neutral
            }
        case .outgoing:
            candidate = filteredAcceleration >= leaveThreshold ? .outgoing : .neutral
        case .incoming:
            candidate = filteredAcceleration <= -leaveThreshold ? .incoming : .neutral
        }
        if candidate == flow {
            pendingFlow = nil
            pendingSince = nil
            return
        }
        if pendingFlow != candidate {
            pendingFlow = candidate
            pendingSince = date
            return
        }
        guard let since = pendingSince else { return }
        // Nessun salto diretto tra accelerazione e decelerazione:
        // passaggio per neutro + tempo minimo di tenuta del colore.
        let requiredDwell = candidate == .neutral ? 0.60 : 0.70
        guard date.timeIntervalSince(since) >= requiredDwell,
              date.timeIntervalSince(lastTransition) >= 1.10 else { return }
        flow = candidate
        lastTransition = date
        pendingFlow = nil
        pendingSince = nil
    }

    func currentFlow(at time: Date = Date()) -> EcoPowerFlow {
        guard available, started, time.timeIntervalSince(lastUpdate) < 1 else {
            return .neutral
        }
        return flow
    }
}

struct RouteCoordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
}

// Un punto GPS altimetrico associato ai chilometri già accettati dal trip.
struct TripAltitudePoint: Codable, Equatable {
    let distanceKm: Double
    let altitudeMeters: Double
}

// Build 114: solo viaggi GPS conclusi con il reset esplicito del TRIP.
// Non conserva coordinate né inventa viaggi anteriori alla registrazione.
struct EcoCompletedTrip: Codable, Equatable {
    let completedAt: Date
    let distanceKm: Double
}

/// GPS del telefono: nessuna velocità o distanza è simulata.
/// Le distanze accumulate riguardano soltanto le posizioni ricevute con app in uso.
@MainActor
final class GPSRideManager: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {
    @Published private(set) var speedKmh: Double?
    @Published private(set) var speedDiagnostic = "Velocità GPS non ancora misurata"
    @Published private(set) var lastNativeSpeed: Double?
    @Published private(set) var lastNativeSpeedAccuracy: Double?
    @Published private(set) var lastGPSFixTime: Date?
    // Ultima posizione reale accurata, usata come partenza da MapKit.
    @Published private(set) var lastGPSCoordinate: CLLocationCoordinate2D?
    @Published private(set) var lastHorizontalAccuracy: CLLocationAccuracy?
    @Published private(set) var courseDegrees: CLLocationDirection?
    @Published private(set) var compassHeadingDegrees: CLLocationDirection?
    private var lastGoodCoordinateAt: Date?
    private var lastCourseAt: Date?
    private var lastCompassAt: Date?
    @Published private(set) var tripKm: Double
    @Published private(set) var totalKm: Double
    @Published private(set) var hasOdometer: Bool
    @Published private(set) var track: [RouteCoordinate]
    @Published private(set) var altitudeProfile: [TripAltitudePoint]
    @Published private(set) var completedTrips: [EcoCompletedTrip]
    var tripElevationMeters: Double? {
        guard let first = altitudeProfile.first, let last = altitudeProfile.last else { return nil }
        return last.altitudeMeters - first.altitudeMeters
    }
    @Published private(set) var movingSeconds: TimeInterval = 0
    // Distanza GPS dal pieno, distinta dal TRIP e dal contachilometri.
    @Published private(set) var universalKmSinceFull: Double
    @Published private(set) var universalHasFull: Bool
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
        if let savedData = UserDefaults.standard.data(forKey: "ecojumbo.gps.altitudeProfile"),
           let saved = try? JSONDecoder().decode([TripAltitudePoint].self, from: savedData),
           saved.count <= 512,
           saved.allSatisfy({ $0.distanceKm.isFinite && $0.altitudeMeters.isFinite
               && $0.distanceKm >= 0 && abs($0.altitudeMeters) <= 10_000 }) {
            altitudeProfile = saved
        } else {
            altitudeProfile = []
        }
        movingSeconds = UserDefaults.standard.double(forKey: "ecojumbo.gps.movingSeconds")
        let storedFullKm = UserDefaults.standard.double(forKey: "ecojumbo.vehicle.kmSinceFull")
        universalKmSinceFull = storedFullKm.isFinite && storedFullKm >= 0 && storedFullKm <= 1_000_000
            ? storedFullKm : 0
        universalHasFull = UserDefaults.standard.bool(forKey: "ecojumbo.vehicle.hasFull")
        // Le vecchie installazioni partono senza storico: nessun dato sintetico.
        let savedTrips: [EcoCompletedTrip]
        if let bytes = UserDefaults.standard.data(forKey: "ecojumbo.gps.completedTrips.v1"),
           let decoded = try? JSONDecoder().decode([EcoCompletedTrip].self, from: bytes) {
            savedTrips = decoded
        } else {
            savedTrips = []
        }
        let now = Date()
        completedTrips = Array(savedTrips.filter {
            $0.distanceKm.isFinite && (0.05...10_000).contains($0.distanceKm)
                && $0.completedAt <= now
                && $0.completedAt > now.addingTimeInterval(-7 * 24 * 60 * 60)
        }.suffix(128))
        super.init()
        manager.delegate = self
        // Ripristinati i parametri della build 33: precisione di navigazione
        // immediata, senza attendere un primo fix entro 65 metri.
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
        // La localizzazione non deve sospendersi mentre lo scooter è fermo:
        // MapKit deve poter acquisire una partenza anche prima di muoversi.
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
    }

    var hasPreciseLocation: Bool { manager.accuracyAuthorization == .fullAccuracy }

    var authorizationDescription: String {
        switch manager.authorizationStatus {
        case .authorizedAlways: "Sempre"
        case .authorizedWhenInUse: "Durante l'uso"
        case .denied: "Negata"
        case .restricted: "Limitata"
        case .notDetermined: "Non richiesta"
        @unknown default: "Non disponibile"
        }
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
        if let lastHorizontalAccuracy, lastHorizontalAccuracy > 35 {
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
            // Come nella build 33: acquisizione continua senza richiesta one-shot.
            manager.startUpdatingLocation()
            if CLLocationManager.headingAvailable() { manager.startUpdatingHeading() }
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
        previousLocation = nil
        lastMotionAt = nil
        speedDiagnostic = "Velocità GPS non ancora misurata"
        lastNativeSpeed = nil
        lastNativeSpeedAccuracy = nil
        lastGPSFixTime = nil
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

    // Fondoscala TRIP: media aritmetica dei viaggi REALMENTE conclusi
    // negli ultimi sette giorni mobili. Il viaggio in corso non entra nella media.
    func averageRecentTripKm(at date: Date = Date()) -> Double? {
        let cutoff = date.addingTimeInterval(-7 * 24 * 60 * 60)
        let recent = completedTrips.filter {
            $0.completedAt > cutoff && $0.completedAt <= date
                && $0.distanceKm.isFinite && $0.distanceKm >= 0.05
        }
        guard !recent.isEmpty else { return nil }
        return recent.reduce(0) { $0 + $1.distanceKm } / Double(recent.count)
    }

    // Solo velocità media di movimento: distanza GPS valida / tempo in
    // movimento registrato. Nessuna velocità ricavata in assenza di fix.
    var averageMovingSpeedKmh: Double? {
        guard movingSeconds.isFinite, movingSeconds >= 60,
              tripKm.isFinite, tripKm >= 0.05 else { return nil }
        let average = tripKm / (movingSeconds / 3600)
        guard average.isFinite, average >= 0, average <= 300 else { return nil }
        return average
    }

    // Nessun "pieno" fittizio all'installazione o al cambio di modalità.
    // La conferma dell'utente calibra a pieno la stima solo dopo aver
    // indicato quanti chilometri può percorrere con un pieno.
    @discardableResult
    func recordUniversalFull() -> Bool {
        guard UserDefaults.standard.string(forKey: "ecojumbo.vehicle.mode") == EcoVehicleMode.universal.rawValue,
              let fullRange = UserDefaults.standard.object(forKey: "ecojumbo.vehicle.fullRangeKm") as? Double,
              fullRange.isFinite, (10...2500).contains(fullRange) else { return false }
        universalKmSinceFull = 0
        universalHasFull = true
        UserDefaults.standard.set(0.0, forKey: "ecojumbo.vehicle.kmSinceFull")
        UserDefaults.standard.set(true, forKey: "ecojumbo.vehicle.hasFull")
        return true
    }

    // Calibrazione manuale della distanza dall'ultimo pieno, utile anche se
    // il conducente ha guidato con Ecojumbo chiusa. Non azzera TRIP/ODO.
    // Solo un inserimento esplicito abilita la stima; il GPS continuerà
    // ad aggiungere esclusivamente i successivi incrementi validati.
    @discardableResult
    func setUniversalKmSinceFull(_ kilometers: Double) -> Bool {
        guard UserDefaults.standard.string(forKey: "ecojumbo.vehicle.mode") == EcoVehicleMode.universal.rawValue,
              let fullRange = UserDefaults.standard.object(forKey: "ecojumbo.vehicle.fullRangeKm") as? Double,
              fullRange.isFinite, (10...2500).contains(fullRange),
              kilometers.isFinite, (0...1_000_000).contains(kilometers) else { return false }
        universalKmSinceFull = kilometers
        universalHasFull = true
        UserDefaults.standard.set(kilometers, forKey: "ecojumbo.vehicle.kmSinceFull")
        UserDefaults.standard.set(true, forKey: "ecojumbo.vehicle.hasFull")
        return true
    }

    func universalEstimatedRemainingKm(fullRange: Double) -> Double? {
        guard universalHasFull, fullRange.isFinite, (10...2500).contains(fullRange),
              universalKmSinceFull.isFinite, universalKmSinceFull >= 0 else { return nil }
        return max(0, fullRange - universalKmSinceFull)
    }

    func universalEstimatedFuelFraction(fullRange: Double) -> Double? {
        guard let remaining = universalEstimatedRemainingKm(fullRange: fullRange) else { return nil }
        return min(1, max(0, remaining / fullRange))
    }

    func resetTrip() {
        // Un viaggio è completato solo al reset esplicito; non contare
        // reset ripetuti a 0 km o letture GPS invalide.
        if tripKm.isFinite && (0.05...10_000).contains(tripKm) {
            let now = Date()
            let retained = completedTrips.filter {
                $0.completedAt > now.addingTimeInterval(-7 * 24 * 60 * 60)
                    && $0.completedAt <= now
            }
            completedTrips = Array((retained + [
                EcoCompletedTrip(completedAt: now, distanceKm: tripKm)
            ]).suffix(128))
            if let bytes = try? JSONEncoder().encode(completedTrips) {
                UserDefaults.standard.set(bytes, forKey: "ecojumbo.gps.completedTrips.v1")
            }
        }
        tripKm = 0
        track.removeAll()
        altitudeProfile.removeAll()
        UserDefaults.standard.removeObject(forKey: "ecojumbo.gps.track")
        UserDefaults.standard.removeObject(forKey: "ecojumbo.gps.altitudeProfile")
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
            if abs(fix.timestamp.timeIntervalSinceNow) <= 25 {
                lastGPSFixTime = fix.timestamp
                lastNativeSpeed = fix.speed
                lastNativeSpeedAccuracy = fix.speedAccuracy
                lastHorizontalAccuracy = fix.horizontalAccuracy >= 0 ? fix.horizontalAccuracy : nil
            }
            // La posizione per MapKit funziona anche da fermi e non richiede
            // una misura di velocità valida. Precisione massima 300 m per
            // evitare partenze chilometriche errate nella navigazione.
            // Come nella build 33: tachimetro e trip richiedono <= 35 m.
            // La posizione per la mappa è indipendente (fino a 300 m).
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
            lastHorizontalAccuracy = fix.horizontalAccuracy
            lastGoodCoordinateAt = fix.timestamp
            state = fix.horizontalAccuracy > 35
                ? "Posizione approssimata (±\(Int(fix.horizontalAccuracy)) m)"
                : "GPS attivo"
            isReceiving = true
            // La modalità Universale accetta anche velocità automobilistiche
            // superiori a 180 km/h; precisione e limiti anti-salto restano.
            let maxTrustedSpeed: Double = UserDefaults.standard.string(
                forKey: "ecojumbo.vehicle.mode") == EcoVehicleMode.universal.rawValue ? 80 : 50
            // Identici criteri di precisione GPS della build 33.
            // Nessuna stima da coordinate e nessuna lettura simulata.
            let usableSpeed = abs(fix.timestamp.timeIntervalSinceNow) < 10
                && fix.horizontalAccuracy >= 0 && fix.horizontalAccuracy <= 35
                && fix.speed >= 0 && fix.speedAccuracy >= 0
                && fix.speedAccuracy <= 5 && fix.speed <= maxTrustedSpeed
            if usableSpeed {
                let kmh = fix.speed * 3.6
                speedKmh = kmh < 1.5 ? 0 : kmh
                lastValidAt = fix.timestamp
                speedDiagnostic = "Velocità GPS nativa (parametri build 33)"
                state = "GPS attivo"
            } else if fix.speed < 0 {
                speedDiagnostic = "Core Location non fornisce la velocità"
            } else if fix.horizontalAccuracy > 35 {
                speedDiagnostic = "Precisione posizione oltre 35 m"
            } else if fix.speedAccuracy < 0 || fix.speedAccuracy > 5 {
                speedDiagnostic = "Precisione velocità fuori 0–5 m/s"
            } else {
                speedDiagnostic = "Velocità nativa non valida o non recente"
            }

            // Trip/odometro: filtri severi invariati contro il rumore GPS.
            guard abs(fix.timestamp.timeIntervalSinceNow) < 10,
                  fix.horizontalAccuracy >= 0, fix.horizontalAccuracy <= 35,
                  fix.speed >= 0, fix.speedAccuracy >= 0, fix.speedAccuracy <= 5,
                  fix.speed <= maxTrustedSpeed else { continue }

            // Primo campione attendibile del viaggio, anche prima di partire.
            if altitudeProfile.isEmpty { recordTripAltitude(fix) }

            if let previous = previousLocation {
                let dt = fix.timestamp.timeIntervalSince(previous.timestamp)
                if dt > 0 && dt <= 30 {
                    let meters = fix.distance(from: previous)
                    // Rifiuta i salti dovuti al rumore GPS, soprattutto a veicolo fermo.
                    if fix.speed > 1.2 && meters >= 2 && meters <= dt * maxTrustedSpeed + 4 {
                        let increment = meters / 1000
                        tripKm += increment
                        if hasOdometer { totalKm += increment }
                        // Accumula solo km realmente osservati DOPO il pieno.
                        // Non viene azzerato dal reset TRIP, né aggiornato in
                        // modalità BMS o prima della calibrazione esplicita.
                        if universalHasFull,
                           UserDefaults.standard.string(forKey: "ecojumbo.vehicle.mode")
                               == EcoVehicleMode.universal.rawValue {
                            universalKmSinceFull += increment
                            UserDefaults.standard.set(universalKmSinceFull,
                                forKey: "ecojumbo.vehicle.kmSinceFull")
                        }
                        UserDefaults.standard.set(tripKm, forKey: "ecojumbo.gps.tripKm")
                        if hasOdometer {
                            UserDefaults.standard.set(totalKm, forKey: "ecojumbo.gps.totalKm")
                        }
                        recordRoutePoint(fix)
                        recordTripAltitude(fix)
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

    // Solo altitudini GPS reali riferite alle distanze valide del trip.
    // Esclude letture con precisione verticale scarsa e salti irrealistici.
    private func recordTripAltitude(_ fix: CLLocation) {
        guard fix.verticalAccuracy >= 0, fix.verticalAccuracy <= 20,
              fix.altitude.isFinite, abs(fix.altitude) <= 10_000,
              fix.horizontalAccuracy >= 0, fix.horizontalAccuracy <= 35 else { return }

        let measured = fix.altitude
        var recorded = measured
        if let previous = altitudeProfile.last {
            let distanceKm = tripKm - previous.distanceKm
            guard distanceKm >= 0.02 else { return }
            guard abs(measured - previous.altitudeMeters)
                <= max(8.0, distanceKm * 1000 * 0.55 + fix.verticalAccuracy) else { return }
            recorded = previous.altitudeMeters * 0.65 + measured * 0.35
        }
        altitudeProfile.append(TripAltitudePoint(distanceKm: tripKm, altitudeMeters: recorded))
        // Conserva il punto iniziale, decimando i campioni quando la rotta cresce.
        if altitudeProfile.count > 512 {
            let initial = altitudeProfile[0]
            let reduced = altitudeProfile.dropFirst().enumerated().compactMap {
                index, point in index.isMultiple(of: 2) ? point : nil
            }
            altitudeProfile = [initial] + reduced
        }
        if let data = try? JSONEncoder().encode(altitudeProfile) {
            UserDefaults.standard.set(data, forKey: "ecojumbo.gps.altitudeProfile")
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
        // Build 33: non mantenere visibili misurazioni GPS oltre 8 secondi.
        guard let lastValidAt, date.timeIntervalSince(lastValidAt) < 8 else { return nil }
        return speedKmh
    }
}
