"""Build 99: shared gray top-bar clip, no Siri, usable local Apple Music fallback."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
cockpit = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
panel = (root / "Ecojumbo/Views/EcoMusicCockpitPanel.swift").read_text()
manager = (root / "Ecojumbo/Models/EcoMusicManager.swift").read_text()
home = (root / "Ecojumbo/Views/EcojumboRootView.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()
assert project.count("CURRENT_PROJECT_VERSION = 102;") == 2
assert project.count("PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;") == 2

# Both MapKit and artwork crop below the real lower edge of the gray metal
# stroke, not the 0.099 neon geometry plus a two-point fake clearance.
clip = cockpit.split("private struct GPSMapTopContourClip: Shape {", 1)[1].split(
    "private struct GPSMapLowerContourClip", 1)[0]
for expression in (
    "GPSDialLayout.size(width: w, height: h)",
    "GPSMetalContourStyle.inset(for: d)",
    "GPSMetalContourStyle.strokeWidth(for: d) / 2",
    "let lowerEdge = metalBottom + clearance",
    "GPSHorizonSymmetry.corners(width: w, height: h)",
    "corners.rightContact.y + lowerEdge",
    "corners.rightKnee.y + lowerEdge",
    "h * 0.099 + lowerEdge",
    "GPSMapContourSpace.local(",
    "path.addArc(tangent1End: elbow, tangent2End: start, radius: corner)",
):
    assert expression in clip, expression
assert "h * 0.099 + clearance" not in clip

dashboard = cockpit.split("struct GPSCockpitDashboard: View {", 1)[1].split(
    "// Pulsante dedicato", 1)[0]
map_view = cockpit.split("private struct GPSCockpitMap: View {", 1)[1].split(
    "private func startNavigation()", 1)[0]
assert "EcoMusicCockpitPanel(searchVisible: $musicSearchVisible, theme: theme)" in dashboard
assert ".mask(GPSMapTopContourClip())" in dashboard
assert map_view.count(".mask(GPSMapTopContourClip())") == 2, "Clip Map and overlay separately"
assert ".padding(.top, h * 0.0565 + max(8, h * 0.014))" in map_view
assert "GPSHorizonLine(theme: theme)" in dashboard
assert ".zIndex(8)" in dashboard and ".zIndex(5)" in dashboard

# The overlay is fully gone: it must not leave its button, alert or geometry.
assert "GPSSiriControl" not in cockpit
assert 'Text("SIRI")' not in cockpit
assert 'EcoOutsideTemperature(now: now, plain: true)' in cockpit.split(
    "private struct GPSHeader: View", 1)[1]
assert "GPSTripResetControl(theme: theme)" in dashboard

# An actual search of the on-device library works without MusicKit token,
# and selecting a song configures an in-app controlled system-player queue.
for source in (
    "func searchLocalLibrary(", "MPMediaQuery.songs().items",
    "localizedStandardContains(search)", "item.title?", "item.artist?",
    "item.albumTitle?", "func playLocalLibrary(_ song: MPMediaItem)",
    "MPMediaItemCollection(items: [song])", "applePlayer.setQueue(with:",
    "applePlayer.play()",
):
    assert source in manager, source

# The online catalog is preserved, but missing Apple App Service produces
# a useful error and a local fallback rather than an inert search screen.
for source in (
    "MusicCatalogSearchRequest(term: text, types: [Song.self])",
    "MusicTokenRequestError", ".developerTokenRequestFailed",
    "catalogTokenUnavailable = true", "libraryResults = music.searchLocalLibrary(term)",
    "ForEach(libraryResults, id: \\.persistentID)",
    "await apple.play(song)", "music.playLocalLibrary(item)",
    "apple.surrenderToSystemPlayer()", "Riprova catalogo Apple Music",
    "TextField(", ".focused($searchFieldFocused)", "searchRevision += 1",
):
    assert source in panel, source
assert 'Apri Apple Music' not in panel

# Mode switches stay the same: music remains available in Map and
# telemetry; there is a dedicated five-control music dock.
assert 'gpsButton("music.note", active: false' in home
assert "if musicDock {" in home
assert 'gpsButton("chart.bar.xaxis"' in home

# Check vertical safety analytically across representative landscapes.
for w, h in [(736, 414), (844, 390), (932, 430), (956, 440),
             (1179, 510), (1536, 706), (1806, 831)]:
    d = min(h * 0.965, w * 0.55)
    metal_inset = d * (0.992 - 0.965) / 2
    metal_stroke = max(1.5, d * 0.0035)
    lower_gray_edge = h * 0.099 + metal_inset + metal_stroke / 2
    map_clip_edge = lower_gray_edge + max(1.5, h * 0.002)
    assert map_clip_edge > lower_gray_edge
    assert map_clip_edge < h * 0.14
    map_local_y = map_clip_edge - h * 0.045
    assert 0 < map_local_y < h * 0.955

print("OK — build 99: map and cover below gray metal, Siri removed, working local music fallback")
