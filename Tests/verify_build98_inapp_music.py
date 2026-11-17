"""Build 98: MusicKit search inside EMT, contextual dock, GPS masks, top bar and Siri."""
from pathlib import Path
r=Path(__file__).resolve().parents[1]
read=lambda p:(r/p).read_text()
u=read("Ecojumbo/Views/EcojumboRootView.swift")
c=read("Ecojumbo/Views/CockpitComponents.swift")
p=read("Ecojumbo/Views/EcoMusicCockpitPanel.swift")
s=read("Ecojumbo/Views/OtherViews.swift")
x=read("Ecojumbo.xcodeproj/project.pbxproj")
assert x.count("CURRENT_PROJECT_VERSION = 111;")==2

# Music entry in map and telemetry, no standard menu/navigation in music dock.
dock=u.split("private struct CockpitCornerControls: View",1)[1].split("private func iconButton(",1)[0]
mus=dock.split("if musicDock {",1)[1].split("\n                    } else {\n",1)[0]
for label in ("Telemetria", "Indietro", "Play/Pausa", "Avanti", "Cerca"):
    assert '"'+label+'"' in mus
assert 'gpsButton("chart.bar.xaxis"' in mus
assert 'gpsButton("map.fill"' not in mus
assert 'gpsButton("music.note"' not in mus
assert "musicSearchVisible.toggle()" in mus
assert "musicEnabled = false" in mus
assert "mapEnabled = false" in mus
assert 'gpsButton("music.note", active: false' in dock
assert "Non cancellare mapEnabled" in dock
assert 'musicEnabled: musicEnabled,' in u
assert 'musicSearchVisible: $musicSearchVisible' in u
assert "let musicGap = max(0, (telemetryPanelWidth - 5 * gpsSide) / 4)" in dock

# Artwork and map use identical display footprint and clipping masks.
dash=c.split("struct GPSCockpitDashboard: View {",1)[1].split("// Pulsante dedicato",1)[0]
art=dash.split("if musicEnabled {",1)[1].split("} else if mapEnabled {",1)[0]
for item in ("EcoMusicCockpitPanel(searchVisible: $musicSearchVisible, theme: theme)",
             "w * 0.64, height: h * 0.955", "GPSMapDialClearanceClip()",
             "GPSMapTopContourClip()", "GPSMapLowerContourClip()",
             "position(x: w * 0.68, y: h * 0.5225)"):
    assert item in art,item
assert "GPSCockpitMap(theme: theme)" in dash
assert "GPSExpandedReadings(theme: theme, now: now)" in dash
assert "OpenSpeedCluster(speed: gps.currentSpeed(at: now)" in dash
assert "GPSCockpitPowerReading(d: dialSize," in dash

# Actual MusicKit catalog request and app-owned queue, not external launch or mock tracks.
assert "private func playbackButton(" not in p
assert 'Apri Apple Music' not in p
assert "openSelectedApp()" not in p
assert "MusicCatalogSearchRequest" in p
assert "ApplicationMusicPlayer.shared" in p
assert "MusicAuthorization.request()" in p
assert "await apple.play(song)" in p
assert 'TextField("Cerca brano, artista o album"' in p
assert "ForEach(results)" in p
assert "AsyncImage(url: url)" in p
assert "song.artwork?.url" in p
assert "MusicKit" in s

# Siri button deliberately doesn't promise unsupported programmatic Siri launch.
assert "GPSSiriControl" not in dash
assert ".position(x: resetX, y: resetY)" in dash
header=c.split("private struct GPSHeader: View",1)[1].split("private struct GPSDiagnosticsView:",1)[0]
assert 'EcoOutsideTemperature(now: now, plain: true)' not in header
assert 'EcoOutsideTemperature(now: now, plain: true)' in c.split("struct GPSCockpitDashboard: View",1)[1]
assert "private struct GPSSiriControl: View" not in c
assert 'Text("SIRI")' not in c
print("OK — build 98: MusicKit inside EMT, contextual dock, map masks and Siri limitations")
