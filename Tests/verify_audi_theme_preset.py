#!/usr/bin/env python3
"""Audi is the seventh automotive theme; legacy presets and three slots remain intact."""
from pathlib import Path
import re
import json
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
read = lambda name: (root / name).read_text(encoding="utf-8")
cockpit = read("Ecojumbo/Views/CockpitComponents.swift")
tabs = read("Ecojumbo/Views/CockpitTabs.swift")

assert 'case audi = "Audi"' in cockpit
for token in ('case .audi: return "Audi"', 'case .audi: return "AutoAudi"', 'var automotiveBrand: String?', 'var brandLogoAssetName: String?'):
    assert token in cockpit, token
for old in ('case copper = "Rame"', 'case glacier = "Ghiaccio"', 'case green = "Verde"',
            'case aquamarine = "Acquamarina"', 'case brown = "Marrone"', 'case racing = "Racing"',
            'case slot1 = "Slot 1"', 'case slot2 = "Slot 2"', 'case slot3 = "Slot 3"'):
    assert old in cockpit, old

assert '"Cupra", "Audi"' in tabs
assert 'case "Audi": return "AutoAudi"' in tabs
assert 'ForEach(CockpitTheme.allCases.filter { $0.slotIndex == nil })' in tabs
assert 'selection = theme.rawValue' in tabs
assert 'EcoAutomotiveBrandLogo(brand: theme.displayName, size: 50)' in tabs
assert 'brandID: preset.automotiveBrand' in tabs
assert 'if preset == .glacier { return ferrariFactory }' in tabs
assert 'if preset == .racing { return cupraFactory }' in tabs
case = re.search(r'case \.audi:[^\n]*\n\s*\(base, main, shade, bright, metal, contrast, signal\)\s*=\s*\n\s*\(([^\n]+)\)', tabs)
assert case, "Audi template missing"
palette = re.findall(r'"(#[0-9A-F]{6})"', case.group(1))
assert palette == ["#07090C", "#D61F2C", "#2F353D", "#E6EAED", "#AEB7BF", "#FFFFFF", "#D61F2C"]
assert 'base, main, shade, metal,' in tabs
assert 'shade, main, "#FF3B30", signal,' in tabs
assert 'colors: colors,' in tabs and 'altitudeGraphColor: bright' in tabs
assert 'static let colorCount = 23' in tabs

asset = root / "Ecojumbo/Assets.xcassets/AutoAudi.imageset"
svg = (asset / "logo.svg").read_text(encoding="utf-8")
meta = json.loads((asset / "Contents.json").read_text(encoding="utf-8"))
xml = ET.fromstring(svg)
assert xml.attrib.get("aria-label") == "Ecojumbo A"
assert "#D61F2C" in svg and "#FF7900" in svg
assert len([item for item in xml if item.tag.endswith("path")]) == 5
assert "<text" not in svg
assert meta["images"][0]["filename"] == "logo.svg"
assert meta["properties"]["preserves-vector-representation"] is True
print("OK — Audi factory preset, brand ID, 23 roles, original shield and legacy themes")
