"""Build 51: transparent telemetry, dedicated reset and ODO in speedometer."""
from pathlib import Path
from math import hypot

root=Path(__file__).resolve().parents[1]
source=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
gps=(root/"Ecojumbo/Models/GPSRideManager.swift").read_text()
project=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 66;") == 2
dashboard=source.split("struct GPSCockpitDashboard: View {",1)[1].split(
    "private struct GPSHorizonLine: View {",1)[0]
speed=source.split("private struct OpenSpeedCluster: View {",1)[1].split(
    "// Calcola la posizione più a sinistra possibile",1)[0]
reset=source.split("private struct GPSTripResetControl: View {",1)[1].split(
    "private struct GPSHorizonLine: View {",1)[0]
telemetry=source.split("private struct GPSExpandedReadings: View {",1)[1].split(
    "// Progressi sottili e luminosi",1)[0]

# Build 65: individual minimal cards in a 2×2 grid, DISL double-height.
# The shared CarbonBackdrop remains visible through subtle translucent tiles.
assert "VStack(spacing: tileGap)" in telemetry
assert 'Text("TELEMETRIA")' in telemetry
assert "LazyVGrid(columns: [GridItem(.flexible(), spacing: tileGap)," in telemetry
assert telemetry.count('telemetryTile("') == 4
assert telemetry.count("showsBar: true") == 3
assert "let dislHeight = 2 * cardHeight" in telemetry
assert "dislevelCard(height: dislHeight)" in telemetry
assert "TelemetrySlimBar(fraction: fraction, theme: theme)" in telemetry
assert "GPSTripAltitudeSparkline(points: gps.altitudeProfile" in telemetry
assert "Color.white.opacity(0.038)" in telemetry
assert "minimumDuration: resettable" not in telemetry
assert "gps.resetTrip()" not in telemetry

# ODO is in the common dial only when enabled by the GPS cockpit.
assert "var showsOdometer: Bool = false" in speed
assert "var odometerKm: Double? = nil" in speed
assert 'Text("km/h")' in speed
assert 'String(format: "ODO %.0f km", $0)' in speed
assert '"ODO — km"' in speed
assert 'if showsOdometer {' in speed
assert 'y: d * 0.690' in speed
assert "showsOdometer: true" in dashboard
assert "odometerKm: gps.hasOdometer ? gps.totalKm : nil" in dashboard
assert 'OpenSpeedCluster(speed: gps.currentSpeed(at: now)' in dashboard

# One reset button in the GPS scene irrespective of mapEnabled.
map_branch=dashboard.split("if mapEnabled {",1)[1].split("} else {",1)[0]
assert "GPSTripResetControl(theme: theme)" not in map_branch
assert "GPSTripResetControl(theme: theme)" in dashboard.split(
    "GPSLowerGlow(theme: theme)",1)[1]
assert "let resetX = max(resetSide / 2" in dashboard
assert "dialCenterX - dialSize * 0.56" in dashboard
assert "let resetY = min(h - resetSide * 0.58, h * 0.840)" in dashboard
assert '.zIndex(38)' in dashboard
assert 'Image(systemName: "arrow.counterclockwise")' in reset
assert 'Text("RESET")' in reset
assert '.onLongPressGesture(minimumDuration: 0.5)' in reset
assert "gps.resetTrip()" in reset
assert 'accessibilityLabel("Azzera trip e dislivello")' in reset

# Existing reset never changes totalKm, only trip and altitude profile.
fn=gps.split("    func resetTrip() {",1)[1].split(
    "    func locationManagerDidChangeAuthorization",1)[0]
assert "tripKm = 0" in fn
assert "altitudeProfile.removeAll()" in fn
assert "totalKm = 0" not in fn
assert 'UserDefaults.standard.set(0, forKey: "ecojumbo.gps.totalKm")' not in fn

# Speeds must remain measured, not estimated. Do not regress build 45.
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in gps
assert "let usableSpeed = abs(fix.timestamp.timeIntervalSinceNow) < 10" in gps
assert "fix.speedAccuracy <= 5 && fix.speed <= 50" in gps
assert "date.timeIntervalSince(lastValidAt) < 8" in gps
assert "SpeedLEDStream(d: d, speed: speed)" in speed

# The reset button sits to the lower left OUTSIDE the gauge ring on
# landscape iPhones and stays fully inside the scene.
for w,h in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    d=min(h*.965,w*.55)
    cx=max(d*.51+w*.010,w*.168+d*.30)
    cy=h*.494
    side=max(42,min(58,h*.08))
    x=max(side/2+max(10,w*.008),cx-d*.56)
    y=min(h-side*.58,h*.840)
    assert side/2 < x < cx
    assert side/2 < y < h-side/2
    assert hypot(cx-x,cy-y) > d*.50+side*.20,(w,h,x,y,cx,cy)
    assert 0.690+0.055/2 < 0.755-0.065/2  # ODO above km/h
print("OK — build 51: Telemetria no container, ODO above km/h and reset 0.5s")
