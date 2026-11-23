"""Build 125: one Home card toggles telemetry with real dual-dial inclinometer."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
rootview = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
motion = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 135;") == 2
assert '@State private var inclinometerEnabled = false' in rootview
assert 'inclinometerEnabled: $inclinometerEnabled' in rootview
assert 'gpsButton(inclinometerEnabled ? "chart.bar.xaxis" : "gyroscope",' in rootview
assert 'inclinometerEnabled.toggle()' in rootview
assert "let justifiedGap = max(0, (telemetryPanelWidth - 7 * gpsSide) / 6)" in rootview
assert "if selected == .gps && !mapEnabled" in rootview
assert "if enabled { inclinometerEnabled = false }" in rootview

dashboard = cockpit.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1
)[0]
assert "if inclinometerEnabled {" in dashboard
assert "GPSInclinationPanel(" in dashboard
assert "topLeftSlope:" in dashboard
assert "GPSExpandedReadings(theme: theme, now: now)" in dashboard
assert ".frame(width: panelWidth, height: cardsHeight)" in dashboard
assert ".position(x: panelLeft + panelWidth / 2, y: cardsCenterY)" in dashboard

card = cockpit.split("private struct GPSInclinationPanel: View {", 1)[1]
for snippet in [
    'Text("INCLINOMETRO")', '"ROLLIO"', '"BECCHEGGIO"',
    'motion.inclinationRollDegrees', 'motion.inclinationPitchDegrees',
    'motion.zeroInclination()', 'motion.setInclinationActive(true)',
    'motion.setInclinationActive(false)', 'String(format: "%+.1f°", $0)',
    'Sensore non disponibile'
]:
    assert snippet in card, snippet
assert "private let sensor = CMMotionManager()" in motion
assert "VehicleInclinationMath.angles(" in motion
assert "lastInclinationPublish" in motion
assert "setInclinationActive(_ active: Bool)" in motion
assert "func zeroInclination()" in motion
print("OK — build 125: calibrated dual inclinometer in same telemetry frame, 7-button Home")
