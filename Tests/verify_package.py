from pathlib import Path
import json, subprocess
root = Path(__file__).resolve().parents[1]
pbx = (root / 'Ecojumbo.xcodeproj/project.pbxproj').read_text()
files = list((root / 'Ecojumbo').rglob('*.swift'))
assert len(files) >= 6, files
for file in files:
    assert file.name in pbx, file
assert 'it.ecojumbo.battery' in pbx
assert 'TARGETED_DEVICE_FAMILY = 1;' in pbx
assert 'INFOPLIST_FILE = Ecojumbo/Info.plist' in pbx
assert 'NSBluetoothAlwaysUsageDescription' in (root / 'Ecojumbo/Info.plist').read_text()
assert '0x96' in (root / 'Ecojumbo/Models/JKProtocol.swift').read_text()
assert '0x97' in (root / 'Ecojumbo/Models/JKProtocol.swift').read_text()
assert '0x96' in (root / 'Ecojumbo/Bluetooth/JKBluetoothManager.swift').read_text()
assert '0x97' in (root / 'Ecojumbo/Bluetooth/JKBluetoothManager.swift').read_text()
assert 'SEVCON' not in ''.join(p.read_text() for p in files)
assert (root / 'Ecojumbo/Assets.xcassets/AppIcon.appiconset/AppIcon.png').stat().st_size > 10000
iconmeta = json.loads((root / 'Ecojumbo/Assets.xcassets/AppIcon.appiconset/Contents.json').read_text())
assert iconmeta['images'][0]['size'] == '1024x1024'
print('OK — project files, Info.plist, privacy, icon, iPhone target, read-only commands')
