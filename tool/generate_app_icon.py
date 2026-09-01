#!/usr/bin/env python3
"""Rasterize the ExpenseTracker launcher icon at 1024x1024.

Concept: a 3-slice donut pie chart (the home dashboard) in white/mint on
brand green. Geometry stays inside the Android adaptive 66% safe zone.
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

SIZE = 1024
# Full / iOS icon: padded so the mark is clearly inset.
OUTER_R = 308
INNER_R = 128
# Adaptive foreground is inset 16% by flutter_launcher_icons, so draw larger.
ADAPTIVE_OUTER_R = 430
ADAPTIVE_INNER_R = 178
GAP_DEG = 9.0

BRAND_DARK = (27, 94, 32)  # #1B5E20
BRAND_LIGHT = (67, 160, 71)  # #43A047
SLICE_A = (255, 255, 255)
SLICE_B = (200, 230, 201)  # #C8E6C9
SLICE_C = (129, 199, 132)  # #81C784

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "icon"


def lerp(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    t = max(0.0, min(1.0, t))
    return (
        int(a[0] + (b[0] - a[0]) * t),
        int(a[1] + (b[1] - a[1]) * t),
        int(a[2] + (b[2] - a[2]) * t),
    )


def radial_background(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    cx = cy = size / 2
    max_r = size * 0.72
    for y in range(size):
        dy = y - cy
        for x in range(size):
            t = math.sqrt((x - cx) ** 2 + dy * dy) / max_r
            px[x, y] = lerp(BRAND_LIGHT, BRAND_DARK, t)
    return img


def slice_angles() -> list[tuple[float, float, tuple[int, int, int]]]:
    """Start at 12 o'clock. PIL: 0° is 3 o'clock, clockwise."""
    weights = (0.50, 0.32, 0.18)
    colors = (SLICE_A, SLICE_B, SLICE_C)
    usable = 360.0 - GAP_DEG * len(weights)
    start = -90.0 + GAP_DEG / 2
    slices: list[tuple[float, float, tuple[int, int, int]]] = []
    for weight, color in zip(weights, colors):
        span = usable * weight
        slices.append((start, start + span, color))
        start += span + GAP_DEG
    return slices


def draw_donut(
    canvas: Image.Image,
    outer_r: float = OUTER_R,
    inner_r: float = INNER_R,
) -> None:
    size = canvas.size[0]
    cx = cy = size / 2
    scale = size / SIZE
    outer = outer_r * scale
    inner = inner_r * scale
    box = [cx - outer, cy - outer, cx + outer, cy + outer]
    hole = [cx - inner, cy - inner, cx + inner, cy + inner]
    draw = ImageDraw.Draw(canvas)
    for start, end, color in slice_angles():
        draw.pieslice(box, start, end, fill=color)
    draw.ellipse(hole, fill=(0, 0, 0, 0))


def polar(cx: float, cy: float, r: float, deg: float) -> tuple[float, float]:
    rad = math.radians(deg)
    return cx + r * math.cos(rad), cy + r * math.sin(rad)


def donut_path(
    start: float,
    end: float,
    outer: float = OUTER_R,
    inner: float = INNER_R,
) -> str:
    cx = cy = SIZE / 2
    large = 1 if (end - start) % 360 > 180 else 0
    ox1, oy1 = polar(cx, cy, outer, start)
    ox2, oy2 = polar(cx, cy, outer, end)
    ix2, iy2 = polar(cx, cy, inner, end)
    ix1, iy1 = polar(cx, cy, inner, start)
    return (
        f"M{ox1:.2f},{oy1:.2f} "
        f"A{outer},{outer} 0 {large} 1 {ox2:.2f},{oy2:.2f} "
        f"L{ix2:.2f},{iy2:.2f} "
        f"A{inner},{inner} 0 {large} 0 {ix1:.2f},{iy1:.2f} Z"
    )


def write_svg() -> None:
    fills = []
    for start, end, color in slice_angles():
        hex_color = f"#{color[0]:02X}{color[1]:02X}{color[2]:02X}"
        fills.append(
            f'    <path fill="{hex_color}" d="{donut_path(start, end)}"/>'
        )
    svg = f"""\
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024" role="img" aria-label="ExpenseTracker icon">
  <defs>
    <radialGradient id="bg" cx="50%" cy="50%" r="72%">
      <stop offset="0%" stop-color="#43A047"/>
      <stop offset="100%" stop-color="#1B5E20"/>
    </radialGradient>
  </defs>
  <rect width="1024" height="1024" fill="url(#bg)"/>
{chr(10).join(fills)}
</svg>
"""
    path = OUT / "icon.svg"
    OUT.mkdir(parents=True, exist_ok=True)
    path.write_text(svg)
    print(f"wrote {path.relative_to(ROOT)}")


def save(img: Image.Image, name: str) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    img.save(path, "PNG", optimize=True)
    print(f"wrote {path.relative_to(ROOT)} ({img.size[0]}x{img.size[1]})")


def main() -> None:
    write_svg()
    supersample = SIZE * 2

    pie = Image.new("RGBA", (supersample, supersample), (0, 0, 0, 0))
    draw_donut(pie, ADAPTIVE_OUTER_R, ADAPTIVE_INNER_R)
    pie = pie.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    save(pie, "adaptive_foreground.png")

    background = radial_background(supersample).resize(
        (SIZE, SIZE),
        Image.Resampling.LANCZOS,
    )
    save(background.convert("RGBA"), "adaptive_background.png")

    full_pie = Image.new("RGBA", (supersample, supersample), (0, 0, 0, 0))
    draw_donut(full_pie, OUTER_R, INNER_R)
    full_pie = full_pie.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    full = background.convert("RGBA")
    full.alpha_composite(full_pie)
    save(full, "icon.png")


if __name__ == "__main__":
    main()
