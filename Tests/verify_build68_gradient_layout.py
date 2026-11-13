"""Build 68 — editable matching GPS contour gradients + tangent-centered telemetry and dock."""
from pathlib import Path
from math import isclose
import re

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
tabs = (root / "Ecojumbo/Views/CockpitTabs.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 74;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2

# Existing 3 slots retain old shades. Both old 8- and 15-colour palettes migrate.
assert "static let colorCount = 19" in tabs
assert "decoded.colors.count == 8 || decoded.colors.count == 15 ||" in tabs
assert "decoded.colors.count == colorCount" in tabs
assert "if migrated.colors.count == 8 {" in tabs
assert "migrated.colors.append(contentsOf: extraDefaults)" in tabs
assert "migrated.colors[9] = decoded.colors[7]" in tabs
assert "if migrated.colors.count == 15 {" in tabs
assert "let edge = migrated.colors[2]" in tabs
assert "migrated.colors.append(contentsOf: [edge, edge])" in tabs
assert "+ standardBarColors + extraDefaults + [foreground.1, foreground.1, "#FF3B30"]" in tabs
assert '("Sfumatura top bar e ponte kW", 15..<17)' not in tabs
assert '"Top bar + ponte kW · sfumatura sinistra"' in tabs
assert '"Top bar + ponte kW · sfumatura destra"' in tabs
assert 'ForEach(0..<EcoThemePalette.groups.count, id:' in tabs
assert 'ForEach(group.range, id:' in tabs
assert 'draft.colors[selected.id] = hex' in tabs
assert "onSave(slot, palette)" in tabs
assert "EcoThemePalette.save(palette, slot: slot)" in tabs
labels = tabs.split("static let labels = [", 1)[1].split("]", 1)[0]
details = tabs.split("static let details = [", 1)[1].split("]", 1)[0]
assert len(re.findall(r'^\s*"[^"]+"', labels, flags=re.M)) == 19
assert len(re.findall(r'^\s*"[^"]+"', details, flags=re.M)) == 19

# Build 70 intentionally retires the extra colored area fills, while
# preserving the 17 stored palette values for backwards compatibility.
assert "var contourGradient: LinearGradient {" not in cockpit
assert "GPSAreaGradientStyle" not in cockpit
assert "GPSTopBandShade" not in cockpit
assert "GPSLowerAreaGradient" not in cockpit
horizon = cockpit.split("private struct GPSHorizonLine: View {", 1)[1].split(
    "@MainActor", 1)[0]
lower = cockpit.split("private struct GPSLowerGlow: View {", 1)[1].split(
    "// EJ 1.22", 1)[0]
# 69 regression: the 68 stroke-gradient error must NEVER return.
assert horizon.count("line.stroke(theme.contourGradient") == 0
assert lower.count(".stroke(theme.contourGradient,") == 0
assert "GPSTopBandShade()" not in horizon
assert ".fill(theme.contourGradient)" not in horizon
assert "GPSLowerAreaGradient(theme: theme)" not in cockpit
assert "GPSOuterProfileReinforcement" not in cockpit
assert "visibleOutsideRing.fill(style: FillStyle(eoFill: true))" in horizon
assert ".mask(RadialGradient" not in horizon
assert ".mask(GPSLowerTerminalFade())" in lower
assert "GPSLowerShade()" in lower
assert "GPSMetalInnerRing()" in cockpit

# Geometry: same true dial right tangent for telemetry and dock, regardless of screen width.
geo = home.split("enum EcoCockpitDockGeometry {", 1)[1].split(
    "struct EcojumboRootView: View {", 1)[0]
assert "return dialX + dial * 0.508 + rightInset(width: width)" in geo
assert "let telemetryPanelLeft = EcoCockpitDockGeometry.standardLeft(width: width, height: screenHeight)" in home
assert "let panelLeft = EcoCockpitDockGeometry.standardLeft(width: w, height: h)" in cockpit
assert ".position(x: panelLeft + panelWidth / 2, y: cardsCenterY)" in cockpit
assert ".frame(width: telemetryDock ? telemetryPanelWidth : nil, alignment: .leading)" in home
assert "let justifiedGap = max(0, (telemetryPanelWidth - 5 * gpsSide) / 4)" in home
for width, height in ((736, 414), (844, 390), (932, 430), (956, 440),
                      (1179, 510), (1536, 706), (1648, 928), (1806, 831)):
    d = min(height * 0.965, width * 0.55)
    dial_center = max(d * 0.51 + width * 0.010, width * 0.168 + d * 0.30)
    tangent = dial_center + d * 0.508
    margin = max(12, width * 0.018)
    left = tangent + margin
    right = width - margin
    assert 0 < tangent < left < right < width
    assert isclose((left + right) / 2, (tangent + width) / 2, abs_tol=1e-8)
    controls_height = max(51, min(83, height * 0.105))
    ideal_side = min(controls_height * 0.96, width * 0.052)
    safe_left = dial_center + d * 0.50 + max(10, width * 0.010)
    gap = width * 0.008
    side = min(ideal_side, max(20, (width - margin - safe_left - 6 * gap) / 7))
    assert right - left > 5 * side, (width, height, left, right, side)
    spacing = (right - left - 5 * side) / 4
    assert spacing > 0
    assert isclose(left + 5 * side + 4 * spacing, right, abs_tol=1e-8)

# UI changes do not alter real GPS/JK BMS measurement sources.
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in cockpit
assert "let live = bluetooth.snapshot" in cockpit
assert "GPSTripAltitudeSparkline(points: gps.altitudeProfile" in cockpit
print("OK — build 68/70: lossless palette migration and tangent-centered panels and dock without colored gradients")
