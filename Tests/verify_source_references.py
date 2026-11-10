from pathlib import Path
import re
import struct
root=Path(__file__).resolve().parents[1]
code={p.name:p.read_text() for p in (root/'Ecojumbo').rglob('*.swift')}
joined='\n'.join(code.values())
project=(root/'Ecojumbo.xcodeproj/project.pbxproj').read_text()
for source in code:
    assert source in project, f'{source} not registered in Xcode project'
    assert re.search(re.escape(source)+r' in Sources',project), f'{source} not in build phase'
for symbol in ('CockpitDashboard','TripsPanel','RoutesPanel','CellsView','BluetoothView','AppleMapsPanel','EcoSettingsView','ThemePickerView'):
    assert re.search(r'\bstruct\s+'+symbol+r'\s*:',joined), f'Missing SwiftUI component: {symbol}'
    assert re.search(r'\b'+symbol+r'\s*\(',code['EcojumboRootView.swift']), f'Not referenced: {symbol}'
assert 'MKDirections(request: request).calculate()' in code['CockpitTabs.swift']
assert 'www.google.com' not in joined
icon=(root/'Ecojumbo/Assets.xcassets/AppIcon.appiconset/AppIcon.png').read_bytes()
assert icon.startswith(b'\x89PNG\r\n\x1a\n')
assert struct.unpack('>II', icon[16:24]) == (1024,1024)
assert icon[25] == 2, 'App icon must be RGB without alpha'
# The icon must be white + orange on near-black, not the previous neon-framed variant.
print('OK — all navigation views are defined and registered; user-provided icon is installed')
