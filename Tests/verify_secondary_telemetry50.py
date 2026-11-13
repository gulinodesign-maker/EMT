"""Regressioni telemetria build 65: quattro schede, DISL doppia e dati live."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
gps = (root / "Ecojumbo/Models/GPSRideManager.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 76;") == 2
dashboard = cockpit.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1)[0]
view = cockpit.split("private struct GPSExpandedReadings: View {", 1)[1].split(
    "// Altitudine GPS sul percorso effettivamente registrato dal trip.", 1)[0]

# Nessun spostamento del contenitore: stesso allineamento del dock, top bar e tachimetro.
assert "GPSExpandedReadings(theme: theme, now: now)" in dashboard
assert "let cardsTop = h * 0.099 + outerMargin" in dashboard
assert "let cardsBottom = h - dockBottom - dockHeight - outerMargin" in dashboard
assert ".position(x: panelLeft + panelWidth / 2, y: cardsCenterY)" in dashboard

# Due colonne, due righe (SOC e V BAT in alto, AUT e TRIP sotto).
assert "LazyVGrid(columns: [GridItem(.flexible(), spacing: tileGap)," in view
assert view.count('telemetryTile("') == 4
for label in ("SOC", "V BAT", "AUT", "TRIP"):
    assert 'telemetryTile("' + label + '"' in view
assert "let cardHeight = max(1, (innerHeight - headerHeight - 3 * tileGap) / 4)" in view
assert "let dislHeight = 2 * cardHeight" in view
assert "dislevelCard(height: dislHeight)" in view
assert 'Text("DISL")' in view
assert 'Text("TELEMETRIA")' in view
assert "Color.white.opacity(0.038)" in view  # no smoked opaque backdrop

# Live BMS, non visualizzare valori dimostrativi.
for placeholder in ('"35%"', '"72.4 V"', '"48 km"', '"0 m"'):
    assert placeholder not in view, placeholder
assert 'live.map { "\($0.soc)%" } ?? "—%"' in view
assert 'live.map { String(format: "%.1f V", $0.voltage) } ?? "— V"' in view
assert "EcoRangeEstimate(snapshot: live, session: bluetooth.session)" in view
assert "autonomy?.fractionOfFull" in view
assert "fraction: live.map { Double($0.soc) / 100.0 }" in view
assert "fraction: live.map { min(1, max(0, ($0.voltage - 50) / 23)) }" in view
assert "abs(now.timeIntervalSince($0.date)) < 10" in view
assert view.count("showsBar: true") == 3
assert "TelemetrySlimBar(fraction: fraction, theme: theme)" in view

# Il grafico è reale, e la sfumatura è tracciata solo dopo due letture GPS.
chart = cockpit.split("private struct GPSTripAltitudeSparkline: View {", 1)[1]
assert "if points.count >= 2" in chart
assert "points.map(\.altitudeMeters)" in chart
assert "area.fill(LinearGradient(" in chart
assert "line.stroke(color" in chart
assert "color.opacity(0.34)" in chart
assert "color.opacity(0.0)" in chart
assert "startPoint: .top, endPoint: .bottom" in chart
assert "closeToBottom: true" in chart
assert "Profilo GPS in attesa" in chart
assert "gps.tripElevationMeters" in view
assert "GPSTripAltitudeSparkline(points: gps.altitudeProfile, color: theme.accent)" in view

# Il tasto RESET rimane a pressione lunga e azzera solo il trip e la sua quota.
reset = cockpit.split("private struct GPSTripResetControl: View {", 1)[1].split(
    "private struct GPSHorizonLine: View {", 1)[0]
assert ".onLongPressGesture(minimumDuration: 0.5)" in reset
assert "gps.resetTrip()" in reset
assert "altitudeProfile.removeAll()" in gps
assert "tripKm = 0" in gps
assert 'UserDefaults.standard.set(0, forKey: "ecojumbo.gps.totalKm")' not in gps

# Su tutti gli iPhone landscape, card DISL esattamente alta quanto 2 tile.
for w, h in ((736, 414), (844, 390), (932, 430), (956, 440),
             (1536, 706), (1806, 831)):
    dock = max(51, min(83, h * .105))
    margin = max(8, h * .018)
    top = h * .099 + margin
    bottom = h - max(4, h * .006) - dock - margin
    height = bottom - top
    assert height > 160
    inset_y = max(6, min(13, height * .019))
    inner = height - 2 * inset_y
    header = max(24, min(40, inner * .105))
    gap = max(5, min(10, height * .022))
    card = (inner - header - 3 * gap) / 4
    disl = 2 * card
    assert card > 30, (w, h, card)
    assert disl > 2 * 30
    assert abs(header + 2 * card + gap + disl + 2 * gap - inner) < 1e-7
print("OK — build 65: 2×2 telemetria, DISL doppio, sfumatura reale e GPS invariato")
