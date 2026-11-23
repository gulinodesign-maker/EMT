"""Build 133: design requests must affect the inclinometer SwiftUI source."""
from pathlib import Path

root=Path(__file__).resolve().parents[1]
code=(root/"Ecojumbo/Views/CockpitComponents.swift").read_text()
pbx=(root/"Ecojumbo.xcodeproj/project.pbxproj").read_text()
theme=(root/"Ecojumbo/Views/CockpitTabs.swift").read_text()
assert pbx.count("CURRENT_PROJECT_VERSION = 133;")==2
dashboard=code.split("struct GPSCockpitDashboard: View {",1)[1].split(
    "private struct GPSTripResetControl: View {",1)[0]
shape=code.split("private struct GPSInclinationCardShape: Shape {",1)[1].split(
    "private struct GPSInclinationPanel: View {",1)[0]
panel=code.split("private struct GPSInclinationPanel: View {",1)[1]
assert "let topbarSlope: CGFloat" in panel
assert "GPSHorizonSymmetry.corners(width: w, height: h).rightKnee.x" in dashboard
assert "GPSHorizonSymmetry.corners(width: w, height: h).rightContact.x" in dashboard
assert "GPSHorizonSymmetry.corners(width: w, height: h).rightContact.y" in dashboard
assert ".padding(.top, inclinometerTopClearance)" in dashboard
assert "let chamferWidth = min(w * 0.14," in panel
assert "chamferDepth * max(0.1, topbarSlope)" in panel
assert "path.move(to: CGPoint(x: run, y: 0))" in shape
assert "path.addLine(to: CGPoint(x: 0, y: drop))" in shape
assert "telemetryStyleBackground(chamferWidth: chamferWidth," in panel
assert ".clipShape(GPSInclinationCardShape(" in panel
for role in ("theme.dayTopBar.left","theme.dayTopBar.right",
             "theme.dayTopBar.high","theme.dayTopBar.low",
             "theme.topBarGradientStart","theme.topBarGradientEnd",
             "theme.dayGradientLightOpacity","theme.dayGradientShadowOpacity"):
    assert role in panel,role
assert 'Text("INCLINOMETRO")' in panel
assert "Text(label)" not in panel
assert 'Text(value.map { String(format: "%+.1f°", $0) } ?? "—°")' in panel
assert "let enlargedDial = baseDial * 1.20" in panel
assert "let resetWidth = max(58, min(78, w * 0.23))" in panel
assert "let dialWidthLimit = (w - 2 * horizontalInset - resetWidth - 2 * dialGap) / 2" in panel
dials=panel.split("HStack(spacing: dialGap) {",1)[1].split(
    ".padding(.horizontal, horizontalInset)",1)[0]
assert dials.index('dialView(label: "ROLLIO"') < dials.index('Label("AZZERA"') < dials.index('dialView(label: "BECCHEGGIO"')
assert "motion.zeroInclination()" in dials
assert "Sensore non disponibile" in dials
assert ".frame(width: resetWidth)" in dials
assert 'Image(systemName: roll ? "car.rear.fill" : "car.side.fill")' in panel
assert "ForEach(0..<72, id: \\.self) { tick in" in panel
assert '.rotationEffect(.degrees(roll ? (value ?? 0) : -(value ?? 0)))' in panel
assert "inclinometerRoleSection()" in theme
assert "Relativo · azzera in piano" not in panel
for w,h in ((205,185),(245,205),(295,230),(350,260),(450,325),(600,430),(760,560)):
    inset=max(4,w*.010)
    vert=max(4,h*.014)
    head=max(24,min(35,h*.12))
    gap=max(4,w*.012)
    reset=max(58,min(78,w*.23))
    target=max(48,min((w-42)*.46,h*.48))*1.20
    dial=max(28,min(target,(w-2*inset-reset-2*gap)/2,
                    h-2*vert-head-max(22,target*.20)))
    assert 2*dial+reset+2*gap+2*inset <=w+1e-7
    assert dial+head+max(22,target*.20)+2*vert <=h+1e-7
print("OK — build133: topbar chamfer, telemetry fades, centered dials and reset")
