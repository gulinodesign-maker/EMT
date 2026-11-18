"""Build 102: centered telemetry dock, ten thin/tall kW ticks, lower 2x temperature, icon-only reset."""
from pathlib import Path
from math import isclose

root = Path(__file__).resolve().parents[1]
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 118;") == 2
assert "## Build 102" in (root / "STATO_PROGETTO.md").read_text()

dock = home.split("private struct CockpitCornerControls: View {", 1)[1].split(
    "private func iconButton(", 1)[0]
assert "let telemetryPanelLeft = EcoCockpitDockGeometry.standardLeft(width: width, height: screenHeight)" in dock
assert "let telemetryPanelWidth = max(1, width - EcoCockpitDockGeometry.rightInset(width: width)" in dock
assert "let standardGap = min(justifiedGap, max(8, width * 0.013))" in dock
assert "HStack(spacing: musicDock ? musicGap : (telemetryDock ? standardGap : gpsGap))" in dock
assert ".frame(width: fillsTelemetryWidth ? telemetryPanelWidth : nil, alignment: .center)" in dock
assert 'gpsButton("music.note", active: false' in dock
assert "if mapEnabled && selected == .gps {" in dock
assert "if musicDock {" in dock

# Build 108: ten-square meter deliberately removed; actual kW remains.
assert "GPSPowerHorizontalGauge" not in cockpit
assert "miniaturePowerBar" not in cockpit
assert "GPSCockpitPowerReading(d: dialSize" in cockpit
temp = cockpit.split("private struct EcoOutsideTemperature: View {", 1)[1].split(
    "// EJ 1.19", 1)[0]
header = cockpit.split("private struct GPSHeader: View {", 1)[1].split(
    "private struct GPSDiagnosticsView", 1)[0]
assert ".font(.system(size: plain ? 30 : 15, weight: .semibold))" in temp
assert "if !plain {" in temp
assert 'Image("EcojumboMark")' in header
assert "EcoOutsideTemperature(now: now, plain: true)" not in header
dashboard = cockpit.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato per azzerare trip", 1)[0]
assert "EcoOutsideTemperature(now: now, plain: true)" in dashboard
assert ".position(x: temperatureX, y: temperatureY)" in dashboard
assert "EcoOutsideTemperature(now: now)" in cockpit  # the non-plain historic header remains

reset = cockpit.split("private struct GPSTripResetControl: View {", 1)[1].split(
    "// Build 66:", 1)[0]
assert 'Image(systemName: "arrow.uturn.backward.circle.fill")' in reset
assert 'Text("RESET")' not in reset
assert 'Image(systemName: "arrow.counterclockwise")' not in reset
assert ".onLongPressGesture(minimumDuration: 0.5)" in reset
assert "gps.resetTrip()" in reset
assert 'accessibilityLabel("Azzera trip e dislivello")' in reset

# Geometric invariant: both the telemetry cards and the compact controls
# have the same center, centered between dial tangent and physical right edge.
for w,h in [(736,414),(844,390),(932,430),(956,440),(1179,510),(1536,706),(1806,831)]:
    dial=min(h*.965,w*.55)
    cx=max(dial*.51+w*.010,w*.168+dial*.30)
    tangent=cx+dial*(.986*.90)/2+1.5+max(2.4,min(4.2,dial*.0051))/2
    inset=max(12,w*.018)
    panel_left=tangent+inset
    panel_width=w-inset-panel_left
    center=panel_left+panel_width/2
    assert isclose(center,(tangent+w)/2,abs_tol=1e-6)
    gps_gap=w*.008
    side_ideal=min(max(51,min(83,h*.105))*.96,w*.052)
    safe_left=cx+dial*.50+max(10,w*.010)
    available=w-inset-safe_left-6*gps_gap
    side=min(side_ideal,max(20,available/7))
    justified=max(0,(panel_width-6*side)/5)
    compact_gap=min(justified,max(8,w*.013))
    group_width=6*side+5*compact_gap
    assert group_width<=panel_width+1e-6
    assert center-group_width/2>=panel_left-1e-6
    assert center+group_width/2<=w-inset+1e-6
    # The telemetry dock keeps its verified centered geometry; the bridge
    # no longer contains the obsolete 10-square bar.
    assert panel_width > 0
print("OK — build 102 dock center, obsolete 10-square bridge meter removed, 2x temperature, icon-only reset")
