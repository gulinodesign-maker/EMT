"""Ecojumbo build 50: unified telemetry display design + live-data regressions."""
from pathlib import Path

root=Path(__file__).resolve().parents[1]
c=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
g=(root/"Ecojumbo/Models/GPSRideManager.swift").read_text()
p=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert p.count("CURRENT_PROJECT_VERSION = 50;") == 2
dashboard=c.split("struct GPSCockpitDashboard: View {",1)[1].split("private struct GPSHorizonLine: View {",1)[0]
view=c.split("private struct GPSExpandedReadings: View {",1)[1].split(
    "// Altitudine GPS sul percorso effettivamente registrato dal trip.",1)[0]

# One integrated panel, not five separate rounded cards.
assert "GPSExpandedReadings(theme: theme, now: now)" in dashboard
assert "let cardsTop = h * 0.099 + outerMargin" in dashboard
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in dashboard
assert 'Text("TELEMETRIA")' in view
assert "VStack(spacing: 0)" in view
assert "private func telemetryDivider(height: CGFloat)" in view
assert "RoundedRectangle(cornerRadius: max(14, min(29, height * 0.055))" in view
assert "LinearGradient(colors: colorScheme == .light ? [" in view
assert "private struct TelemetrySlimBar: View" in view
assert view.count('telemetryRow("') == 5
assert view.count("telemetryDivider(height: dividerHeight)") == 4
assert view.count("showsBar: true") == 3

# Exact labels and data in the design; no demo values shipped.
for label in ('SOC','V BAT','AUT','TRIP','DISL'):
    assert 'telemetryRow("'+label+'"' in view
for placeholder in ('"35%"','"72.4 V"','"48 km"','"0 m"'):
    assert placeholder not in view,placeholder
assert 'live.map { "\($0.soc)%" } ?? "—%"' in view
assert 'live.map { String(format: "%.1f V", $0.voltage) } ?? "— V"' in view
assert "EcoRangeEstimate(snapshot: live, session: bluetooth.session)" in view
assert "autonomy?.fractionOfFull" in view
assert "fraction: live.map { Double($0.soc) / 100.0 }" in view
assert "fraction: live.map { min(1, max(0, ($0.voltage - 50) / 23)) }" in view
assert "abs(now.timeIntervalSince($0.date)) < 10" in view
assert "gps.tripElevationMeters" in view
assert "GPSTripAltitudeSparkline(points: gps.altitudeProfile" in view
assert "if let progress, progress > 0" in view

# 0.5 second long press resets both trip/elevation exactly as before.
assert 'telemetryRow("TRIP"' in view
assert "minimumDuration: resettable ? 0.5 : 1.3" in view
assert "gps.resetTrip()" in view
assert "altitudeProfile.removeAll()" in g
assert "tripKm = 0" in g

# All other GPS and map paths untouched.
assert "GPSCockpitMap(theme: theme)" in dashboard
assert "GPSMapBatteryRail(theme: theme, now: now)" in dashboard
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in dashboard
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in g
assert "let usableSpeed = abs(fix.timestamp.timeIntervalSinceNow) < 10" in g
assert "fix.speedAccuracy <= 5 && fix.speed <= 50" in g
assert "date.timeIntervalSince(lastValidAt) < 8" in g

# The header and five data rows fit between the top bar and dock on
# all supported landscape sizes, with positive space for the sparkline.
for w,h in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    dock=max(51,min(83,h*.105))
    top=h*.099+max(8,h*.018)
    bottom=h-max(4,h*.006)-dock-max(8,h*.018)
    panel=bottom-top
    inset=max(7,min(17,panel*.022))
    inner=panel-2*inset
    header=max(24,min(42,inner*.105))
    row=(inner-header-4*.8)/5
    assert row>35, (w,h,row)
    assert 5*row+4*.8+header+2*inset<=panel+1e-6
    assert max(11,row*.31) < row*.41
print("OK — build 50: telemetria unificata, dati live, GPS invariato")
