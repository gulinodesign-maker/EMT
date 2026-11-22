"""Build 126: safe top bar, centered calibration, theme-owned inclinometer colors."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
c = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
t = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
p = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert p.count("CURRENT_PROJECT_VERSION = 126;") == 2
dash = c.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "private struct GPSTripResetControl: View {", 1)[0]
assert "let metalLowerEdge = h * 0.099 + GPSMetalContourStyle.inset(for: dialSize)" in dash
assert "GPSMetalContourStyle.strokeWidth(for: dialSize) / 2" in dash
assert "let inclinometerTopClearance = max(" in dash
assert ".padding(.top, inclinometerTopClearance)" in dash
assert "GPSExpandedReadings(theme: theme, now: now)" in dash
assert ".frame(width: panelWidth, height: cardsHeight)" in dash

panel = c.split("private struct GPSInclinationPanel: View {", 1)[1]
assert 'Image(systemName: roll ? "car.side.fill" : "car.rear.fill")' in panel
assert "Relativo · azzera in piano" not in panel
assert 'Label("AZZERA", systemImage: "scope")' in panel
footer = panel.split("VStack(spacing: 2) {", 1)[1].split(
    ".frame(height: h * 0.18)", 1)[0]
assert "Spacer(minLength:" not in footer
assert "motion.zeroInclination()" in footer
assert "Sensore non disponibile" in footer
for prop in ("inclinometerRingColor", "inclinometerHorizonColor", "inclinometerVehicleColor"):
    assert "theme." + prop in panel
assert "private var telemetryStyleBackground: some View" in panel
telemetry = c.split("private struct GPSExpandedReadings: View {", 1)[1]
for expr in (
    "theme.dayTopBar.left", "theme.dayTopBar.right",
    "theme.topBarGradientStart", "theme.topBarGradientEnd",
    "theme.dayGradientHighOpacity", "theme.dayGradientLowOpacity",
    ".init(color: from.opacity((day ? 0.38 : 0.32) * lightOpacity), location: 0)",
    ".init(color: to.opacity((day ? 0.38 : 0.32) * shadowOpacity), location: 1)",
    ".init(color: high.opacity(highOpacity * 0.32), location: 0)",
    ".init(color: low.opacity(lowOpacity * 0.32), location: 1)"
):
    assert expr in panel and expr in telemetry, expr

assert '("Inclinometro", [])' in t
assert 'case 5: "gyroscope"' in t
assert "inclinometerRoleSection()" in t
assert "var inclinometerColors: [String]" in t
assert "static let inclinometerLabels" in t
assert "defaultInclinometerColors(from: colors)" in t
assert "decodeIfPresent([String].self, forKey: .inclinometerColors)" in t
assert "data.encode(inclinometerColors, forKey: .inclinometerColors)" in t
assert "draft.inclinometerColors[index]" in t
assert "draft.inclinometerColors[selected.id - EcoThemePalette.colorCount] = hex" in t
assert "static let colorCount = 23" in t
assert "inclinometerColors.count == 3" in t
assert "return [accent, horizon, vehicle]" in t
assert "defaultInclinometerColors(from: colors)" in t
assert "try data.encode(inclinometerColors, forKey: .inclinometerColors)" in t
assert "savedPalette ?? EcoThemePalette.template(self)" in c

for w,h in ((736,414),(844,390),(932,430),(1179,510),(1536,706),(1806,831)):
    d=min(h*.965,w*.55)
    margin=max(8,h*.018)
    cards_top=h*.099+margin
    metal_edge=h*.099+d*(.992-.965)/2+max(1.5,d*.0035)/2
    clearance=max(18,metal_edge+max(12,h*.02)-cards_top)
    assert cards_top+clearance>metal_edge+10
    dock=max(51,min(83,h*.105))
    cards_bottom=h-max(4,h*.006)-dock-margin
    assert cards_bottom-(cards_top+clearance)>170
print("OK — build 126: rear-car pitch, inset, centered reset and theme colors")
