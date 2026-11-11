from pathlib import Path

root = Path(__file__).resolve().parents[1]
gps = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()

# Velocità GPS della build 45: nessuna modifica consentita.
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in gps
assert "let usableSpeed = abs(fix.timestamp.timeIntervalSinceNow) < 10" in gps
assert "fix.speedAccuracy <= 5 && fix.speed <= 50" in gps
assert "date.timeIntervalSince(lastValidAt) < 8" in gps

# Profilo altimetrico GPS reale, persistente, non calcolato dalla mappa.
assert "struct TripAltitudePoint: Codable, Equatable" in gps
assert "var tripElevationMeters: Double?" in gps
assert "last.altitudeMeters - first.altitudeMeters" in gps
assert 'ecojumbo.gps.altitudeProfile' in gps
assert "fix.verticalAccuracy >= 0, fix.verticalAccuracy <= 20" in gps
assert "recordTripAltitude(fix)" in gps
assert "distanceKm >= 0.02" in gps
assert "altitudeProfile.count > 512" in gps

# Reset del trip svuota traccia e altimetria ma lascia odometro totale invariato.
start = gps.index("    func resetTrip() {")
end = gps.index("    func locationManagerDidChangeAuthorization", start)
reset = gps[start:end]
for statement in (
    "tripKm = 0",
    "track.removeAll()",
    "altitudeProfile.removeAll()",
    'removeObject(forKey: "ecojumbo.gps.altitudeProfile")',
):
    assert statement in reset, statement
assert "totalKm = 0" not in reset
assert 'UserDefaults.standard.set(0, forKey: "ecojumbo.gps.totalKm")' not in reset

# Cinque schede e grafico basato su misure, non punti dimostrativi.
expanded = cockpit[cockpit.index("private struct GPSExpandedReadings: View {"):]
assert expanded.count('telemetryRow("') == 5
assert 'telemetryRow("DISL"' in expanded
assert 'GPSTripAltitudeSparkline(points: gps.altitudeProfile' in expanded
assert "if points.count >= 2" in expanded
assert "points.map(\\.altitudeMeters)" in expanded
assert "showAltitudeGraph: true" in expanded
assert "minimumDuration: resettable ? 0.5 : 1.3" in expanded
assert 'String(format: "%+.0f m", $0)' in expanded
print("OK — build 46, dislivello GPS reale, grafico, reset e velocità preservata")
