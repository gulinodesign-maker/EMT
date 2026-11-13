"""Build 52: ODO keyboard confirmation, centered rail/vehicle and red speed."""
from pathlib import Path
from math import cos, sin, radians, isclose

root=Path(__file__).resolve().parents[1]
cockpit=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
settings=(root/"Ecojumbo/Views/OtherViews.swift").read_text()
gps=(root/"Ecojumbo/Models/GPSRideManager.swift").read_text()
project=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 74;") == 2

dashboard=cockpit.split("struct GPSCockpitDashboard: View {",1)[1].split(
    "private struct GPSTripResetControl: View {",1)[0]
m=cockpit.split("private struct GPSCockpitMap: View {",1)[1].split(
    "// Indicatore verticale SOC esclusivo della modalità mappa.",1)[0]
speed=cockpit.split("private struct OpenSpeedCluster: View {",1)[1].split(
    "// Calcola la posizione più a sinistra possibile",1)[0]

# ODO decimalPad has no submit key in landscape. Explicit keyboard toolbar
# has a visible confirm action and shares save logic with the inline button.
assert "@FocusState private var odometerFieldFocused: Bool" in settings
assert ".keyboardType(.decimalPad)" in settings
assert ".focused($odometerFieldFocused)" in settings
assert "ToolbarItemGroup(placement: .keyboard)" in settings
assert 'Button("Conferma e salva", action: saveOdometer)' in settings
assert 'Button("Salva", action: saveOdometer)' in settings
assert ".onSubmit(saveOdometer)" in settings
assert "private func saveOdometer()" in settings
assert "gps.setOdometer(number)" in settings
assert "odometerFieldFocused = false" in settings
assert '"Inserisci un numero di chilometri valido."' in settings
assert "gps.hasOdometer ? String(format:" in settings
assert 'UserDefaults.standard.set(totalKm, forKey: "ecojumbo.gps.totalKm")' in gps

# Topbar-to-dock midpoint includes the whole SOC rail, not just bar fill.
for k in ("railTopBound","railBottomBound","railHeight","railCenterY"):
    assert k in dashboard
assert "let railTopBound = h * 0.099" in dashboard
assert "let railBottomBound = h - dockBottom - dockHeight" in dashboard
assert "let railCenterY = (railTopBound + railBottomBound) / 2" in dashboard
assert "y: railCenterY" in dashboard
for w,h in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    dock_h=max(51,min(83,h*.105))
    dock_b=max(4,h*.006)
    t=h*.099
    b=h-dock_b-dock_h
    margin=max(10,h*.020)
    rail_h=min(max(70,h*.615),max(70,b-t-2*margin))
    center=(t+b)/2
    assert center-rail_h/2>=t+margin-1e-7
    assert center+rail_h/2<=b-margin+1e-7
    assert isclose(center-t,b-center)

# Vehicle marker and route remain on their real GPS coordinates;
# camera is offset on the screen to center the vehicle in visible lane.
assert 'Annotation("", coordinate: coordinate, anchor: .center)' in m
assert "MapPolyline(roadRoute.polyline)" in m
assert "mapViewportSize = geo.size" in m
assert ".onChange(of: geo.size)" in m
assert "let targetX = (dialRightX + batteryLeftX) / 2 - fullWidth * 0.36" in m
assert "let horizontalPixels = max(-mapWidth * 0.25," in m
assert "let cameraLateralMeters = mapHeight > 1" in m
assert "let northMeters = lookAhead * cos(bearing) + cameraLateralMeters * sin(bearing)" in m
assert "let eastMeters = lookAhead * sin(bearing) - cameraLateralMeters * cos(bearing)" in m
assert "MapCamera(centerCoordinate: center" in m
for w,h in [(736,414),(844,390),(932,430),(956,440),(1536,706),(1806,831)]:
    d=min(h*.965,w*.55)
    dial_x=max(d*.51+w*.010,w*.168+d*.30)
    dial_right=dial_x+d*.508
    rail_left=w-max(9,w*.010)-max(36,min(52,w*.037))
    target=(dial_right+rail_left)/2
    map_left=w*.36
    map_w=w*.64
    local_target=target-map_left
    shift=local_target-map_w/2
    assert dial_right<target<rail_left
    assert 0<local_target<map_w
    assert shift>0, (w,h,shift)  # previously vehicle was too far left
    assert abs(shift)<map_w*.25  # lateral camera shift not clamped
    # Heading 0 moves camera center west; heading 90 moves it north.
    lateral=350
    assert isclose(lateral*sin(radians(0)),0,abs_tol=1e-9)
    assert isclose(-lateral*cos(radians(0)),-350,abs_tol=1e-9)
    assert isclose(lateral*sin(radians(90)),350,abs_tol=1e-9)

# Color only: no new artificial GPS speed smoothing or thresholds.
assert 'Text(String(Int(speed.rounded())))' in speed
assert ".foregroundStyle(CockpitTheme.speedDigitsAccent)" in speed
assert ".foregroundStyle(Color(red: 1.0, green: 0.43, blue: 0.04))" not in speed
assert 'Text("km/h")' in speed
assert 'String(format: "ODO %.0f km", $0)' in speed
assert "manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation" in gps
assert "fix.speedAccuracy <= 5 && fix.speed <= 50" in gps
assert "date.timeIntervalSince(lastValidAt) < 8" in gps
print("OK — build 52: ODO confirm, rail and GPS target centered, red speed")
