from pathlib import Path
import plistlib
root=Path(__file__).resolve().parents[1]
project=(root/'Ecojumbo.xcodeproj/project.pbxproj').read_text()
assert project.count('MARKETING_VERSION = 1.0;') == 2
assert project.count('CURRENT_PROJECT_VERSION = 74;') == 2
assert project.count('PRODUCT_BUNDLE_IDENTIFIER = it.ecojumbo.battery;') == 2
other=(root/'Ecojumbo/Views/OtherViews.swift').read_text()
assert 'Text("Ecojumbo \\(EcojumboBuildStamp.display) · build \\(EcojumboBuildStamp.buildNumber)")' in other
assert 'CFBundleShortVersionString' in other and 'CFBundleVersion' in other
assert 'String(format: "%02d", build)' in other
with (root/'Ecojumbo/Info.plist').open('rb') as f:
    plist=plistlib.load(f)
assert plist['CFBundleShortVersionString'] == '$(MARKETING_VERSION)'
assert plist['CFBundleVersion'] == '$(CURRENT_PROJECT_VERSION)'
# Dichiarazione Apple per crittografia assente o esente (vale da nuove build).
assert plist['ITSAppUsesNonExemptEncryption'] is False
print('OK — Marketing version 1.0, build 74, bundle ID unchanged')
