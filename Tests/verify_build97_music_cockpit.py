#!/usr/bin/env python3
"""Regressione build 97: il lettore non modifica le funzioni di guida."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
read = lambda path: (root / path).read_text(encoding="utf-8")
app = read("Ecojumbo/EcojumboApp.swift")
root_view = read("Ecojumbo/Views/EcojumboRootView.swift")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
settings = read("Ecojumbo/Views/OtherViews.swift")
manager = read("Ecojumbo/Models/EcoMusicManager.swift")
panel = read("Ecojumbo/Views/EcoMusicCockpitPanel.swift")
plist = read("Ecojumbo/Info.plist")
project = read("Ecojumbo.xcodeproj/project.pbxproj")

# L'area musicale sostituisce solo le letture a destra, non tachimetro o mappa.
assert "let musicEnabled: Bool" in cockpit
assert "if musicEnabled {" in cockpit
assert "EcoMusicCockpitPanel(searchVisible: $musicSearchVisible, theme: theme)" in cockpit
assert "} else if mapEnabled {" in cockpit
assert "GPSCockpitMap(theme: theme)" in cockpit
assert "GPSExpandedReadings(theme: theme, now: now)" in cockpit
assert "OpenSpeedCluster(speed:" in cockpit
assert "GPSCockpitPowerReading(d:" in cockpit
assert "GPSHeader(theme: theme, now: now," in cockpit

# Sesto pulsante sempre nella home, separato dai comandi navigazione.
assert 'gpsButton("music.note", active: false,' in root_view
assert 'case "music.note": "Musica"' in root_view
assert "musicEnabled = true" in root_view
assert "Non cancellare mapEnabled" in root_view
assert "mapEnabled = false" in root_view
assert "telemetryPanelWidth - 6 * gpsSide" in root_view
assert "GPSCockpitDashboard(theme: theme, now: tick, mapEnabled: mapEnabled," in root_view

# Provider persistente e menu Setup, senza servizi inesistenti.
assert 'case apple = "Apple Music"' in manager
assert 'case spotify = "Spotify"' in manager
assert 'case youtube = "YouTube Music"' in manager
assert "Google Play Music" not in manager
assert '"ecojumbo.music.provider"' in settings
assert '"ecojumbo.spotifyClientID"' in settings
assert 'case .music: "Musica"' in settings
assert 'TextField("Client ID Spotify", text: $spotifyClientID)' in settings

# Controlli effettivi, copertine reali, nessun brano simulato.
assert "MPMusicPlayerController.systemMusicPlayer" in manager
for command in ["applePlayer.pause()", "applePlayer.play()", "applePlayer.skipToPreviousItem()", "applePlayer.skipToNextItem()"]:
    assert command in manager
for endpoint in ["/me/player", "/me/player/next", "/me/player/previous", "/me/player/pause", "/me/player/play"]:
    assert endpoint in manager
assert "AsyncImage(url: url)" in panel
assert "Image(uiImage: artwork)" in panel
assert "Nessun brano" in manager

# Spotify: PKCE S256, state vincolato, Keychain e mai Client Secret.
assert '"code_challenge_method", value: "S256"' in manager
assert 'get("state") == state' in manager
assert "SHA256.hash" in manager
assert "kSecClassGenericPassword" in manager
assert "refresh_token" in manager
assert "client_secret" not in manager.lower()
assert "EcoMusicManager.shared.handleSpotifyCallback(url)" in app
assert "<key>NSAppleMusicUsageDescription</key>" in plist
assert "<string>ecojumbo-spotify</string>" in plist
assert project.count("CURRENT_PROJECT_VERSION = 101;") == 2
for filename in ("EcoMusicManager.swift", "EcoMusicCockpitPanel.swift"):
    assert project.count(f"{filename} in Sources") >= 2

print("Build 97 music cockpit and provider wiring OK")
