from pathlib import Path

root = Path(__file__).resolve().parents[1]
gps = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()

# Test di regressione esplicito: parametri di acquisizione/velocità build 33.
for setting in (
    "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation",
    "manager.activityType = .automotiveNavigation",
    "manager.distanceFilter = kCLDistanceFilterNone",
    "manager.pausesLocationUpdatesAutomatically = false",
    "manager.startUpdatingLocation()",
):
    assert setting in gps, setting

native = gps.split("let usableSpeed =", 1)[1].split("if usableSpeed {", 1)[0]
for condition in (
    "abs(fix.timestamp.timeIntervalSinceNow) < 10",
    "fix.horizontalAccuracy >= 0",
    "fix.horizontalAccuracy <= 35",
    "fix.speed >= 0",
    "fix.speedAccuracy >= 0",
    "fix.speedAccuracy <= 5",
    "fix.speed <= 50",
):
    assert condition in native, condition
assert "let kmh = fix.speed * 3.6" in gps
assert "speedKmh = kmh < 1.5 ? 0 : kmh" in gps
assert "date.timeIntervalSince(lastValidAt) < 8" in gps

# Nessuna stima artificiale; rimangono le funzionalità successive alla 33.
assert "manager.requestLocation()" not in gps
assert "estimatedSpeed" not in gps
assert "previousSpeedFix" not in gps
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in cockpit
assert "GPSDiagnosticsView()" in cockpit
assert "fix.horizontalAccuracy <= 300" in gps
assert "UserDefaults.standard.set(tripKm" in gps
print("OK — GPS nativo con parametri build 33, telemetria e UI preservate")
