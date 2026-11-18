from pathlib import Path

root = Path(__file__).resolve().parents[1]
gps = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()

# Test regressione acquisizione build 33 + hotfix disponibilità tachimetro build 119.
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
    "freshSpeedFix && newerSpeedFix",
    "fix.horizontalAccuracy >= 0",
    "fix.horizontalAccuracy <= 70",
    "fix.speed >= 0",
    "fix.speedAccuracy >= 0",
    "fix.speedAccuracy <= 5",
    "fix.speed <= maxTrustedSpeed",
):
    assert condition in native, condition
assert "let fixAge = Date().timeIntervalSince(fix.timestamp)" in gps
assert "let freshSpeedFix = fixAge >= -1.5 && fixAge < 8.0" in gps
assert "let newerSpeedFix = lastValidAt.map { fix.timestamp > $0 } ?? true" in gps
assert "let kmh = fix.speed * 3.6" in gps
assert "speedKmh = kmh < 1.5 ? 0 : kmh" in gps
assert "guard age >= -1.6 && age < 6.0" in gps
# TRIP/ODO preservano i filtri più restrittivi; nessun chilometro inventato.
trip = gps.split("// Trip/odometro: filtri severi invariati", 1)[1].split(
    "// Primo campione attendibile del viaggio", 1)[0]
assert "fix.horizontalAccuracy <= 35" in trip
assert "fix.speedAccuracy <= 5" in trip
assert "abs(fix.timestamp.timeIntervalSinceNow) < 10" in trip

# Nessuna stima artificiale; rimangono le funzionalità successive alla 33.
assert "manager.requestLocation()" not in gps
assert "estimatedSpeed" not in gps
assert "previousSpeedFix" not in gps
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in cockpit
assert "GPSDiagnosticsView()" in cockpit
assert "fix.horizontalAccuracy <= 300" in gps
assert "UserDefaults.standard.set(tripKm" in gps
print("OK — GPS build 119: real native speed recovered, fresh and strict TRIP criteria retained")
