#!/usr/bin/env python3
"""Compare a REAL Ecojumbo simulator screenshot with the user-provided reference.

Usage:
  python3 tools/compare_visual_reference.py --reference reference.jpg \
      --candidate cockpit-simulator.png --out visual-report
Requires Pillow and NumPy; scikit-image optionally enables SSIM.
No fixture image or simulated telemetry is ever included in the app.
"""
import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw


REFERENCE_SIZE = (1536, 709)
# Only mutable data are excluded; material, illumination and geometries remain.
DYNAMIC_BOXES = (
    (140, 0, 288, 70),      # actual time
    (1170, 0, 1536, 68),    # GPS/BLE/iPhone battery status
    (22, 76, 172, 154),    # outside temperature
    (314, 275, 530, 478),  # GPS speed, ODO
    (334, 478, 502, 558),  # real power kW
    (870, 143, 1105, 334), # changing SOC / AUT values
    (1230, 143, 1460, 335),# actual voltage / trip
    (1328, 367, 1512, 440),# current altitude
)


def load_image(path):
    return Image.open(path).convert("RGB")


def scale_to_reference(candidate):
    cw, ch = candidate.size
    desired = REFERENCE_SIZE[0] / REFERENCE_SIZE[1]
    ratio = cw / ch
    # Simulator capture must be landscape. A portrait capture is a failure.
    if ratio < 1.30:
        raise ValueError("Screenshot in portrait: rotate the simulated iPhone.")
    if abs(ratio / desired - 1.0) > 0.13:
        raise ValueError(f"Aspect ratio {ratio:.4f} not comparable to {desired:.4f}")
    # Crop only the aspect discrepancy in the centre, then match reference.
    if ratio > desired:
        target_w = int(round(ch * desired))
        left = max(0, (cw - target_w) // 2)
        candidate = candidate.crop((left, 0, left + target_w, ch))
    else:
        target_h = int(round(cw / desired))
        top = max(0, (ch - target_h) // 2)
        candidate = candidate.crop((0, top, cw, top + target_h))
    return candidate.resize(REFERENCE_SIZE, Image.Resampling.LANCZOS)


def dynamic_mask(size, exclude):
    mask = np.ones((size[1], size[0]), dtype=bool)
    if exclude:
        for left, top, right, bottom in DYNAMIC_BOXES:
            mask[top:bottom, left:right] = False
    return mask


def edges(pixels):
    lum = pixels.astype(np.float32) @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
    gx = np.abs(np.diff(lum, axis=1, prepend=lum[:, :1]))
    gy = np.abs(np.diff(lum, axis=0, prepend=lum[:1, :]))
    return np.clip(gx + gy, 0, 255)


def shift_image(image, dx, dy):
    # Never wrap pixels across opposite sides.
    output = np.zeros_like(image)
    height, width = image.shape[:2]
    x0, x1 = max(0, dx), min(width, width + dx)
    y0, y1 = max(0, dy), min(height, height + dy)
    output[y0:y1, x0:x1] = image[y0 - dy:y1 - dy, x0 - dx:x1 - dx]
    return output


def align(reference, candidate, mask):
    # Establish global registration using bright geometric edges outside
    # masked telemetry. A +-16 px search detects gross layout offsets.
    re = edges(reference)
    ce = edges(candidate)
    sample = (slice(0, None, 4), slice(0, None, 4))
    best = (float("inf"), 0, 0)
    for dx in range(-16, 17, 2):
        for dy in range(-16, 17, 2):
            shifted = shift_image(ce, dx, dy)
            valid = mask.copy()
            if dx > 0:
                valid[:, :dx] = False
            elif dx < 0:
                valid[:, dx:] = False
            if dy > 0:
                valid[:dy, :] = False
            elif dy < 0:
                valid[dy:, :] = False
            diff = np.abs(re[sample] - shifted[sample])
            goodness = float(np.mean(diff[valid[sample]]))
            if goodness < best[0]:
                best = (goodness, dx, dy)
    return shift_image(candidate, best[1], best[2]), best[1:]


def report(reference, candidate, output, exclude_dynamic=True):
    output.mkdir(parents=True, exist_ok=True)
    baseline_image = load_image(reference)
    if baseline_image.size != REFERENCE_SIZE:
        raise ValueError(f"Reference must be {REFERENCE_SIZE}, got {baseline_image.size}")
    actual_image = load_image(candidate)
    actual_image = scale_to_reference(actual_image)
    ref = np.asarray(baseline_image, dtype=np.uint8)
    raw = np.asarray(actual_image, dtype=np.uint8)
    mask = dynamic_mask(REFERENCE_SIZE, exclude_dynamic)
    aligned, offset = align(ref, raw, mask)
    delta = np.abs(ref.astype(np.float32) - aligned.astype(np.float32))
    mae = float(np.mean(delta[mask]))
    rmse = float(np.sqrt(np.mean(np.square(delta[mask]))))
    overlay = ((ref.astype(np.float32) + aligned.astype(np.float32)) / 2).astype(np.uint8)
    magnitude = delta.mean(axis=2)
    heat = np.zeros_like(ref)
    heat[:, :, 0] = np.clip(magnitude * 4, 0, 255).astype(np.uint8)
    heat[:, :, 1] = np.clip((magnitude - 22) * 1.5, 0, 140).astype(np.uint8)
    heat[~mask] = ref[~mask] // 4
    try:
        from skimage.metrics import structural_similarity
        ssim_value = float(structural_similarity(ref, aligned,
                           channel_axis=2, data_range=255))
    except ImportError:
        ssim_value = None

    image_map = {
        "reference.png": ref,
        "candidate_aligned.png": aligned,
        "overlay_50.png": overlay,
        "difference_heatmap.png": heat,
        "side_by_side.png": np.concatenate([ref, aligned], axis=1),
    }
    for name, pixels in image_map.items():
        Image.fromarray(pixels).save(output / name)
    result = {
        "reference_size": list(REFERENCE_SIZE),
        "candidate_source_size": list(load_image(candidate).size),
        "alignment_translation_pixels": list(offset),
        "masked_dynamic_regions": exclude_dynamic,
        "mean_absolute_rgb_difference": round(mae, 3),
        "root_mean_square_rgb_difference": round(rmse, 3),
        "ssim_unmasked_global": round(ssim_value, 5) if ssim_value is not None else None,
        "comparison_method": "LANCZOS aspect crop, 2px edge-search, masked RGB errors",
        "caution": "A simulator screenshot is required; geometry and high-end glow must also be inspected visually.",
    }
    (output / "report.json").write_text(json.dumps(result, indent=2) + "\n")
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--reference", required=True, type=Path)
    parser.add_argument("--candidate", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--include-dynamic", action="store_true")
    args = parser.parse_args()
    print(json.dumps(report(args.reference, args.candidate, args.out,
                            exclude_dynamic=not args.include_dynamic), indent=2))
