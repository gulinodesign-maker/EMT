#!/usr/bin/env python3
"""Verify that unchanged build-122 code and all assets survive feature builds 125–126."""
from pathlib import Path
from hashlib import sha1

root = Path(__file__).resolve().parents[1]
expected = {
    "Ecojumbo/Assets.xcassets/AppIcon.appiconset/AppIcon.png": "38584727e08dddfcff86ad30a2472c1215c637db",
    "Ecojumbo/Assets.xcassets/AppIcon.appiconset/Contents.json": "0fe6aaf796a7e5b10b91dd141e39f8ae4c0c0c91",
    "Ecojumbo/Assets.xcassets/AutoAlfaRomeo.imageset/Contents.json": "77b658aa16e5bff9391e4ba30478f0d3a23e65df",
    "Ecojumbo/Assets.xcassets/AutoAlfaRomeo.imageset/logo.svg": "e9b2936f96b4332645906b2d519514ae8dbfd768",
    "Ecojumbo/Assets.xcassets/AutoAudi.imageset/Contents.json": "77b658aa16e5bff9391e4ba30478f0d3a23e65df",
    "Ecojumbo/Assets.xcassets/AutoAudi.imageset/logo.svg": "8892cfe6cc1f2dea51f41bef2c58fe6f08483d09",
    "Ecojumbo/Assets.xcassets/AutoBMW.imageset/Contents.json": "77b658aa16e5bff9391e4ba30478f0d3a23e65df",
    "Ecojumbo/Assets.xcassets/AutoBMW.imageset/logo.svg": "0000b372756e330a7024fc284fda88fcfbca1ba9",
    "Ecojumbo/Assets.xcassets/AutoCupra.imageset/Contents.json": "77b658aa16e5bff9391e4ba30478f0d3a23e65df",
    "Ecojumbo/Assets.xcassets/AutoCupra.imageset/logo.svg": "4d284736dccc69b4592b5590d8a3d50d2538ed91",
    "Ecojumbo/Assets.xcassets/AutoFerrari.imageset/Contents.json": "77b658aa16e5bff9391e4ba30478f0d3a23e65df",
    "Ecojumbo/Assets.xcassets/AutoFerrari.imageset/logo.svg": "cc62aa7a3301ed926bb2b7bdf4ece92faf3f92dd",
    "Ecojumbo/Assets.xcassets/AutoLamborghini.imageset/Contents.json": "77b658aa16e5bff9391e4ba30478f0d3a23e65df",
    "Ecojumbo/Assets.xcassets/AutoLamborghini.imageset/logo.svg": "710745f352503f8fdd3071c9b06d0a155c702330",
    "Ecojumbo/Assets.xcassets/AutoMercedes.imageset/Contents.json": "77b658aa16e5bff9391e4ba30478f0d3a23e65df",
    "Ecojumbo/Assets.xcassets/AutoMercedes.imageset/logo.svg": "6930d697d72e064429b8687196f5c02afb132449",
    "Ecojumbo/Assets.xcassets/CarbonWeave.imageset/CarbonWeave.png": "b8f6d542a8c47fbcd1ecd241d70df3fd07ccf3bd",
    "Ecojumbo/Assets.xcassets/CarbonWeave.imageset/Contents.json": "e16048d15760166811f1916091b8e16ee8cc6b53",
    "Ecojumbo/Assets.xcassets/Contents.json": "c47b5f2f12ac2bf752efeae1cf23dd76194fd29b",
    "Ecojumbo/Assets.xcassets/EcojumboMark.imageset/Contents.json": "3438cd247803ede2f1fc788bd8d8a7fbdf83582e",
    "Ecojumbo/Assets.xcassets/EcojumboMark.imageset/EcojumboMark.png": "a27a59a19054d983a9ad9d6db4d613fa353d7d86",
    "Ecojumbo/Bluetooth/JKBluetoothManager.swift": "9c2bec1a9da13e096bbbad86d4d2b4cf3a970c3a",
    "Ecojumbo/EcojumboApp.swift": "2380079ec7b509c9c5c9664eedbff980bc8c31d5",
    "Ecojumbo/Info.plist": "74f1691f1860c46f636659efd7dc482cf20444c6",
    "Ecojumbo/Models/CockpitBarMath.swift": "9070cd65c3f45c7fa61be3c3aad6155c7bac4574",
    "Ecojumbo/Models/EcoMusicManager.swift": "bdf3741beaef702cf24e1e2d503337e38c90cf78",
    "Ecojumbo/Models/JKProtocol.swift": "295887fc9f9d26ad54ab6c835b48cf431209d311",
    "Ecojumbo/Models/RideSession.swift": "c503a0dd4011a44bc122c9878c69bcfec1addff8",
    "Ecojumbo/Views/CellsView.swift": "790c8009147a510e92be566cce9b6f3442a0f068",
    "Ecojumbo/Views/EcoMusicCockpitPanel.swift": "cc13016276ce2b2760c5c05c0b0fc45fadb358da",
    "Ecojumbo/Views/OtherViews.swift": "16d71058274e5dac9da62cca5d211e8fca44eb5b",
}
actual = {p.relative_to(root).as_posix() for p in (root / "Ecojumbo").rglob("*") if p.is_file()}
changed_for_125 = {
    "Ecojumbo/Models/GPSRideManager.swift",
    "Ecojumbo/Views/CockpitComponents.swift",
    "Ecojumbo/Views/CockpitTabs.swift",
    "Ecojumbo/Views/EcojumboRootView.swift",
}
assert actual == set(expected) | changed_for_125, (
    f"Unexpected Ecojumbo files: {actual - set(expected) - changed_for_125}"
)
for path, object_sha in expected.items():
    content = (root / path).read_bytes()
    raw = b"blob " + str(len(content)).encode("ascii") + b"\x00" + content
    assert sha1(raw).hexdigest() == object_sha, f"Build 122 source mismatch: {path}"
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text(encoding="utf-8")
assert project.count("CURRENT_PROJECT_VERSION = 129;") == 2
assert project.count("MARKETING_VERSION = 1.0;") == 2
assert project.count("IPHONEOS_DEPLOYMENT_TARGET = 17.0;") == 4
assert "runs-on: macos-15-intel" in (root / ".github/workflows/ios-build.yml").read_text(encoding="utf-8")
assert (root / "Ecojumbo/Assets.xcassets/AutoAudi.imageset/logo.svg").exists()
print("OK — unchanged 122 files/assets remain byte-exact; Audi preserved in build 125")
