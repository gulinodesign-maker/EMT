"""Build 54: l'ora sul cockpit segue l'orologio e le impostazioni locali dell'iPhone."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
components = (root / "Ecojumbo/Views/CockpitComponents.swift").read_text()
project = (root / "Ecojumbo.xcodeproj/project.pbxproj").read_text()

assert project.count("CURRENT_PROJECT_VERSION = 56;") == 2
assert "private struct SystemClockText: View" in components
assert "TimelineView(.periodic(from: .now, by: 1))" in components
assert "Text(timeline.date.formatted(" in components
assert "Date.FormatStyle(date: .omitted, time: .shortened," in components
assert "locale: .autoupdatingCurrent" in components
assert "timeZone: .autoupdatingCurrent" in components
assert components.count("SystemClockText()") == 2, "Home e GPS devono usare l'orologio di sistema"
assert "Text(now.formatted(date: .omitted, time: .shortened))" not in components
print("OK — build 54: orologio Home/GPS sincronizzato con data, locale e fuso iOS")
