"""Build 49: map-only SOC indicator and grounded remaining-range card."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
c = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
g = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
u = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()

dashboard = c.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1)[0]
rail = c.split("private struct GPSMapBatteryRail: View {", 1)[1].split(
    "// Autonomia basata su percorrenza GPS", 1)[0]
standard = c.split("private struct GPSExpandedReadings: View {", 1)[1].split(
    "private struct GPSTripAltitudeSparkline", 1)[0]

# The vertical rail exists only in the map-on branch of the cockpit.
map_branch = dashboard.split("if mapEnabled {", 1)[1].split("} else {", 1)[0]
assert "GPSMapBatteryRail(theme: theme, now: now)" in map_branch
assert "railRightInset" in map_branch
assert ".zIndex(29)" in map_branch
assert "GPSMapBatteryRail" not in dashboard.split("} else {", 1)[1]
assert "let railTop = h * 0.255" in dashboard
assert "let railBottom = h - dockBottom - dockHeight - max(10, h * 0.020)" in dashboard

# No BMS frames or stale snapshots -> no fabricated percentage or filled bar.
assert "guard bluetooth.isConnected, let snap = bluetooth.snapshot" in rail
assert "abs(now.timeIntervalSince(snap.date)) < 10" in rail
assert 'Text(snapshot.map { "\($0.soc)%" } ?? "—%")' in rail
assert "if let charge {" in rail
assert "Double($0.soc) / 100.0" in rail

# Same five telemetry cards, but replacing total odometer with trip
# and former trip slot with energy-based estimated range with its own bar.
assert standard.count('telemetryRow("') == 5
assert 'telemetryRow("AUT"' in standard
assert 'telemetryRow("TRIP"' in standard
assert 'telemetryRow("Chilometraggio"' not in standard
assert 'telemetryRow("Trip parziale"' not in standard
assert standard.count("showsBar: true") == 3
assert "resettable: true" not in standard
assert "GPSTripResetControl(theme: theme)" in dashboard
assert "GPSTripAltitudeSparkline(points: gps.altitudeProfile" in standard

# Estimate uses real energy and observed GPS distance; no predefined km per charge.
assert "session.observedTripKm" in c
assert "km >= 5, session.dischargedKWh > 0.1" in c
assert "session.dischargedKWh / km" in c
assert "snapshot.remainingAh * snapshot.voltage / 1000" in c
assert "snapshot.remainingAh / snapshot.ratedAh" in c
assert "EcoRangeEstimate(snapshot: live, session: bluetooth.session)" in standard
assert "autonomy?.fractionOfFull" in standard

# Speedometer and navigation remain connected to real GPS as in build 45.
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in dashboard
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in g
assert "let usableSpeed = abs(fix.timestamp.timeIntervalSinceNow) < 10" in g
assert "fix.speedAccuracy <= 5 && fix.speed <= 50" in g
assert "date.timeIntervalSince(lastValidAt) < 8" in g
assert "if mapEnabled && selected == .gps {" in u

# Landscape proportions: percent rail does not overlap search or button dock.
for w,h in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    dock_height = max(51,min(83,h*.105))
    dock_bottom = max(4,h*.006)
    top=h*.255
    bottom=h-dock_bottom-dock_height-max(10,h*.020)
    rail_width=max(36,min(52,w*.037))
    right=max(9,w*.010)
    assert bottom>top and rail_width>0
    assert top>=h*.099
    assert bottom < h-dock_height-dock_bottom
    assert w-right-rail_width > w*.85
print("OK — build 51, SOC map-only and grounded remaining-range card")
