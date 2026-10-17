#!/usr/bin/env python3
"""Generates the app icon and native splash assets from one vector design.

Run from the project root:   python3 tool/brand/generate_brand_assets.py

Needs only Python 3 and `rsvg-convert` (brew install librsvg). It overwrites:
  * android/app/src/main/res/mipmap-*dpi/ic_launcher*.png
  * android/app/src/main/res/drawable-*dpi/{launch_logo,splash_icon}.png
  * ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png
  * ios/Runner/Assets.xcassets/LaunchImage.imageset/*.png
  * tool/brand/out/*.svg|png   (sources and a 1024 preview)

The mark is the app's own "done" check toggle: a gold ring with a pale tint, a
dark-gold check, and a row of seven streak segments (the last three gold).
Colours are the classical design tokens from lib/core/theme/app_tokens.dart.
"""
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "tool" / "brand" / "out"
RES = ROOT / "android" / "app" / "src" / "main" / "res"
XC = ROOT / "ios" / "Runner" / "Assets.xcassets"

PAPER = "#F3F2F2"
GOLD = "#B68235"
GOLD_TINT = "#FFF3E4"
GOLD_INK = "#7D5411"
NEUTRAL = "#C9C4C4"

# The mark lives in a 560 x 620 box. Painted content spans x 3..557, y 17..607.
MARK_CX, MARK_CY = 280, 312  # centre of the painted content
VIEWBOX_CROP = "0 10 560 600"  # tight crop used for splash logos


def mark(mono: bool = False) -> str:
    """The mark as SVG elements in mark coordinates."""
    if mono:
        # Android 13 themed icon: one colour, shape only (alpha is what counts).
        ring = f'<circle cx="280" cy="280" r="250" fill="none" stroke="#000" stroke-width="30"/>'
        check = ('<path d="M146 284 L236 374 L414 176" fill="none" stroke="#000" '
                 'stroke-width="38" stroke-linecap="round" stroke-linejoin="round"/>')
        bar = lambda i: f'<rect x="{3 + i * 82}" y="590" width="62" height="18" fill="#000" opacity="{0.45 if i < 4 else 1}"/>'
    else:
        ring = (f'<circle cx="280" cy="280" r="250" fill="{GOLD_TINT}" '
                f'stroke="{GOLD}" stroke-width="30"/>')
        check = (f'<path d="M146 284 L236 374 L414 176" fill="none" stroke="{GOLD_INK}" '
                 'stroke-width="38" stroke-linecap="round" stroke-linejoin="round"/>')
        bar = lambda i: f'<rect x="{3 + i * 82}" y="590" width="62" height="18" fill="{NEUTRAL if i < 4 else GOLD}"/>'
    return ring + check + "".join(bar(i) for i in range(7))


def placed(scale: float, mono: bool = False) -> str:
    """Mark centred on a 1024 canvas at the given scale."""
    tx = 512 - MARK_CX * scale
    ty = 512 - MARK_CY * scale
    return f'<g transform="translate({tx:.2f},{ty:.2f}) scale({scale})">{mark(mono)}</g>'


def svg(body: str, view: str = "0 0 1024 1024") -> str:
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view}">{body}</svg>'


ICON_FULL = svg(f'<rect width="1024" height="1024" fill="{PAPER}"/>' + placed(1.1))
ICON_LEGACY = svg(f'<rect width="1024" height="1024" rx="224" fill="{PAPER}"/>' + placed(1.1))
# Adaptive foreground: content must stay inside the central 61% safe circle.
ADAPTIVE_FG = svg(placed(0.74))
ADAPTIVE_MONO = svg(placed(0.74, mono=True))
# Android 12 splash icon: the OS shows it inside a circle of 2/3 of its canvas.
SPLASH_ICON = svg(placed(0.80))
LAUNCH_LOGO = svg(mark(), VIEWBOX_CROP)


def render(source: str, path: Path, width: int, height: int = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    cmd = ["rsvg-convert", "-w", str(width)]
    if height:
        cmd += ["-h", str(height)]
    cmd += ["-o", str(path)]
    subprocess.run(cmd, input=source.encode(), check=True)


def main() -> None:
    if shutil.which("rsvg-convert") is None:
        sys.exit("rsvg-convert not found. Install it with: brew install librsvg")

    OUT.mkdir(parents=True, exist_ok=True)
    for name, source in {
        "icon_full": ICON_FULL,
        "icon_legacy": ICON_LEGACY,
        "adaptive_foreground": ADAPTIVE_FG,
        "adaptive_monochrome": ADAPTIVE_MONO,
        "splash_icon": SPLASH_ICON,
        "launch_logo": LAUNCH_LOGO,
    }.items():
        (OUT / f"{name}.svg").write_text(source)
    render(ICON_FULL, OUT / "icon_1024.png", 1024)

    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    for d, f in densities.items():
        render(ICON_LEGACY, RES / f"mipmap-{d}" / "ic_launcher.png", round(48 * f))
        render(ADAPTIVE_FG, RES / f"mipmap-{d}" / "ic_launcher_foreground.png", round(108 * f))
        render(ADAPTIVE_MONO, RES / f"mipmap-{d}" / "ic_launcher_monochrome.png", round(108 * f))
        render(SPLASH_ICON, RES / f"drawable-{d}" / "splash_icon.png", round(288 * f))
        # 112dp wide logo for pre-Android-12 launch screens (600/560 aspect).
        w = round(112 * f)
        render(LAUNCH_LOGO, RES / f"drawable-{d}" / "launch_logo.png", w, round(w * 600 / 560))

    # iOS app icon: every size listed in the asset catalogue, opaque square.
    iconset = XC / "AppIcon.appiconset"
    contents = json.loads((iconset / "Contents.json").read_text())
    for image in contents["images"]:
        base = float(image["size"].split("x")[0])
        scale = int(image["scale"].rstrip("x"))
        render(ICON_FULL, iconset / image["filename"], round(base * scale))

    # iOS launch image: the mark, 120pt wide, 1x/2x/3x.
    launch = XC / "LaunchImage.imageset"
    for suffix, factor in (("", 1), ("@2x", 2), ("@3x", 3)):
        w = 120 * factor
        render(LAUNCH_LOGO, launch / f"LaunchImage{suffix}.png", w, round(w * 600 / 560))

    print("Brand assets generated. Preview:", OUT / "icon_1024.png")


if __name__ == "__main__":
    main()
