"""Build 67: no GPS top-bar terminal fade, real meteo and iPhone battery."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 73;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert project.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2

# Keep the GPS dial ring exclusion but remove only the fade at its two joins.
gps_horizon = cockpit.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "@MainActor", 1
)[0]
home_horizon = cockpit.split("private struct ContinuousHorizonLine: View {", 1)[1].split(
    "// Disegniamo il pittogramma", 1
)[0]
assert ".mask(visibleOutsideRing.fill(style: FillStyle(eoFill: true)))" in gps_horizon
assert ".mask(RadialGradient(stops:" not in gps_horizon
assert ".mask(RadialGradient(stops:" in home_horizon

weather = cockpit.split("final class EcoOutsideWeather: ObservableObject {", 1)[1].split(
    "private struct EcoOutsideTemperature: View {", 1
)[0]
temp = cockpit.split("private struct EcoOutsideTemperature: View {", 1)[1].split(
    "// EJ 1.23", 1
)[0]
assert "URLSession.shared.data(from: endpoint)" in weather
assert "URLQueryItem(name: \"current\", value: \"temperature_2m\")" in weather
assert "temperatureC == nil ? 60 : 15 * 60" in weather
assert 'String(format: "%.0f°C", $0)' in temp
assert 'Image(systemName: "thermometer.medium")' not in temp
assert "guard let updatedAt = weather.updatedAt" in temp
assert "gps.currentCoordinate(at: now) != nil" not in temp
assert "weather.refreshIfNeeded(at: coordinate)" in temp
assert "weather.refreshIfNeeded(at: gps.currentCoordinate(at: newDate))" in temp

phone = cockpit.split("private struct PhoneChargeMeter: View {", 1)[1].split(
    "// Arco in coordinate di schermo", 1
)[0]
assert "UIDevice.current.isBatteryMonitoringEnabled = true" in phone
assert "UIDevice.current.batteryLevel" in phone
assert "chargePercent.map" in phone
for icon in ("battery.0percent", "battery.25percent", "battery.50percent",
             "battery.75percent", "battery.100percent"):
    assert icon in phone
assert "Image(systemName: batterySymbol)" in phone
assert "batteryLevelDidChangeNotification" in phone
assert "batteryStateDidChangeNotification" in phone
assert "phase == .active" in phone
assert "—%" in phone  # non inventare letture iPhone indisponibili
print("OK — build 67: raccordi GPS netti, meteo reale e batteria telefono dinamica")
