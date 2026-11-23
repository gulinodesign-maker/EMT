#!/usr/bin/env python3
"""Build 113: Apple Music only, original Ecojumbo initial shields, exact JSON presets."""
from pathlib import Path
import hashlib
import json
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
read = lambda name: (root / name).read_text(encoding="utf-8")
tabs = read("Ecojumbo/Views/CockpitTabs.swift")
manager = read("Ecojumbo/Models/EcoMusicManager.swift")
panel = read("Ecojumbo/Views/EcoMusicCockpitPanel.swift")
settings = read("Ecojumbo/Views/OtherViews.swift")
app = read("Ecojumbo/EcojumboApp.swift")
plist = read("Ecojumbo/Info.plist")
project = read("Ecojumbo.xcodeproj/project.pbxproj")

assert project.count("CURRENT_PROJECT_VERSION = 134;") == 2
assert 'case apple = "Apple Music"' in manager
assert "case spotify =" not in manager
assert "case youtube =" not in manager
assert "api.spotify.com" not in manager
assert "accounts.spotify.com" not in manager
assert "YouTube Music" not in panel
assert "Spotify" not in panel
assert 'Section("Apple Music")' in settings
assert "Collega Spotify" not in settings
assert "YouTube Music" not in settings
assert "handleSpotifyCallback" not in app
assert "ecojumbo-spotify" not in plist
assert "<key>NSAppleMusicUsageDescription</key>" in plist
assert "MusicCatalogSearchRequest" in panel
assert "ApplicationMusicPlayer.shared" in panel
assert "func playLocalLibrary(" in manager
assert "applePlayer.play()" in manager
assert "if musicDock {" in read("Ecojumbo/Views/EcojumboRootView.swift")

# JSON originali dell'utente: SHA256 sull'oggetto theme canonico (sort_keys).
expected = {
    "ferrariFactory": ("Ferrari", "0dec80e42a369102cbe716535a280d4405654dde73f2448b2cf9a15ae4febe94"),
    "cupraFactory": ("Cupra", "d09b287a7270a4b8ea6223238ccd862906e3533953c5ef56bab54e80099b6b37"),
}
for property_name, (brand, expected_digest) in expected.items():
    pattern = r"private static let " + property_name + r': EcoThemePalette = \{\s*let json = ##"(.*?)"##'
    match = re.search(pattern, tabs, re.DOTALL)
    assert match, f"Embedded factory JSON missing: {property_name}"
    source = json.loads(match.group(1))
    assert source["name"] == brand and source["brandID"] == brand
    assert len(source["colors"]) == len(source["glowLevels"]) == 23
    canonical = json.dumps(source, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    assert hashlib.sha256(canonical.encode()).hexdigest() == expected_digest, brand
assert "if preset == .glacier { return ferrariFactory }" in tabs
assert "if preset == .racing { return cupraFactory }" in tabs
assert "static let storagePrefix = " in tabs
assert "EcoThemePalette.save" in tabs or "save(slot:" in tabs

# Icone originali: unico scudo/fulmine, colore e iniziale specifici.
assets = [
    ("AutoAlfaRomeo", "A", "#C22636"),
    ("AutoBMW", "B", "#1C69D4"),
    ("AutoCupra", "C", "#B87333"),
    ("AutoLamborghini", "L", "#DDB321"),
    ("AutoFerrari", "F", "#ED1C24"),
    ("AutoMercedes", "M", "#B6B6B6"),
]
common = None
for asset, initial, color in assets:
    svg = read(f"Ecojumbo/Assets.xcassets/{asset}.imageset/logo.svg")
    xml = ET.fromstring(svg)
    assert xml.attrib.get("aria-label") == f"Ecojumbo {initial}"
    assert color in svg and "#FF7900" in svg
    paths = [e.attrib.get("d", "") for e in xml if e.tag.endswith("path")]
    assert len(paths) == 5
    shared = tuple(paths[i] for i in (0, 1, 3, 4))
    if common is None:
        common = shared
    else:
        assert shared == common, f"Non matching shield geometry: {asset}"
    assert paths[2] != shared[0]
    assert "<text" not in svg  # vettori senza font dipendenti dal dispositivo
    assert all(token not in svg.lower() for token in ("ferrari-logo", "cupra-logo", "bmw-logo"))

print("OK — build 113: only Apple Music, six unified original shields, exact complete Ferrari/Cupra JSON")
