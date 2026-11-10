import Foundation

/// Normalizzazione delle sei barre laterali (solo grafica).
/// nil significa misura mancante: la barra resta vuota, mai inventata.
enum CockpitBarMath {
    static func unit(_ value: Double?, minimum: Double = 0, maximum: Double) -> Double? {
        guard let value, value.isFinite, minimum.isFinite, maximum.isFinite,
              maximum > minimum else { return nil }
        return Swift.min(1, Swift.max(0, (value - minimum) / (maximum - minimum)))
    }

    /// Il contachilometri non ha un massimo assoluto. La barra mostra
    /// l'avanzamento nell'intervallo configurabile (di default 1.000 km).
    static func odometerCycle(_ kilometers: Double?, cycle: Double) -> Double? {
        guard let kilometers, kilometers.isFinite, kilometers >= 0,
              cycle.isFinite, cycle > 0 else { return nil }
        return (kilometers.truncatingRemainder(dividingBy: cycle)) / cycle
    }
}
