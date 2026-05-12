#!/usr/bin/env python3
# Port of dots-hyprland (ii) generate_colors_material.py, specialised to emit
# foot.ini [colors]. Same harmonize/boost logic and same scheme-base.json so
# output matches ii 1:1 for the 16 ANSI slots.
import argparse
import json
import math
import sys

from PIL import Image
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.hct import Hct
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.utils.color_utils import argb_from_rgb, rgba_from_argb
from materialyoucolor.utils.math_utils import (
    difference_degrees,
    rotation_direction,
    sanitize_degrees_double,
)

ap = argparse.ArgumentParser()
ap.add_argument("--path", required=True, help="wallpaper image")
ap.add_argument("--termscheme", required=True, help="ii scheme-base.json")
ap.add_argument("--output", required=True, help="foot.ini destination")
ap.add_argument("--size", type=int, default=128)
ap.add_argument("--mode", choices=["dark", "light"], default="dark")
ap.add_argument("--scheme", default="scheme-tonal-spot")
ap.add_argument("--contrast", type=float, default=0.0)
ap.add_argument("--harmony", type=float, default=0.8)
ap.add_argument("--harmonize_threshold", type=float, default=100.0)
ap.add_argument("--term_fg_boost", type=float, default=0.35)
ap.add_argument("--blend_bg_fg", action="store_true", default=True)
args = ap.parse_args()


def argb_to_hex(argb):
    return "{:02X}{:02X}{:02X}".format(*map(round, rgba_from_argb(argb)[:3]))


def hex_to_argb(s):
    s = s.lstrip("#")
    return argb_from_rgb(int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))


def harmonize(design, source, threshold, harmony):
    f, t = Hct.from_int(design), Hct.from_int(source)
    diff = difference_degrees(f.hue, t.hue)
    rot = min(diff * harmony, threshold)
    hue = sanitize_degrees_double(f.hue + rot * rotation_direction(f.hue, t.hue))
    return Hct.from_hct(hue, f.chroma, f.tone).to_int()


def boost_chroma_tone(argb, chroma=1.0, tone=1.0):
    h = Hct.from_int(argb)
    return Hct.from_hct(h.hue, h.chroma * chroma, h.tone * tone).to_int()


def fit_size(w, h, target):
    area = w * h
    bitmap = target * target
    s = math.sqrt(bitmap / area) if area > bitmap else 1
    return max(1, round(w * s)), max(1, round(h * s))


img = Image.open(args.path)
if img.format == "GIF":
    img.seek(1)
if img.mode in ("L", "P"):
    img = img.convert("RGB")
nw, nh = fit_size(*img.size, args.size)
if (nw, nh) != img.size:
    img = img.resize((nw, nh), Image.Resampling.BICUBIC)
quantized = QuantizeCelebi(list(img.getdata()), 128)
source_argb = Score.score(quantized)[0]
source_hct = Hct.from_int(source_argb)

scheme_map = {
    "scheme-fruit-salad": "scheme_fruit_salad.SchemeFruitSalad",
    "scheme-expressive": "scheme_expressive.SchemeExpressive",
    "scheme-monochrome": "scheme_monochrome.SchemeMonochrome",
    "scheme-rainbow": "scheme_rainbow.SchemeRainbow",
    "scheme-tonal-spot": "scheme_tonal_spot.SchemeTonalSpot",
    "scheme-neutral": "scheme_neutral.SchemeNeutral",
    "scheme-fidelity": "scheme_fidelity.SchemeFidelity",
    "scheme-content": "scheme_content.SchemeContent",
    "scheme-vibrant": "scheme_vibrant.SchemeVibrant",
}
mod_path, cls_name = scheme_map.get(args.scheme, scheme_map["scheme-tonal-spot"]).split(".")
mod = __import__(f"materialyoucolor.scheme.{mod_path}", fromlist=[cls_name])
Scheme = getattr(mod, cls_name)
darkmode = args.mode == "dark"
scheme = Scheme(source_hct, darkmode, args.contrast)

material_colors = {}
for name in vars(MaterialDynamicColors).keys():
    attr = getattr(MaterialDynamicColors, name)
    if hasattr(attr, "get_hct"):
        material_colors[name] = argb_to_hex(attr.get_hct(scheme).to_int())

with open(args.termscheme) as f:
    base = json.load(f)["dark" if darkmode else "light"]

primary_key = hex_to_argb("#" + material_colors["primary_paletteKeyColor"])
term = {}
for name, val in base.items():
    if args.scheme == "scheme-monochrome":
        term[name] = val.lstrip("#").upper()
        continue
    if args.blend_bg_fg and name == "term0":
        h = boost_chroma_tone(hex_to_argb("#" + material_colors["surfaceContainerLow"]), 1.2, 0.95)
    elif args.blend_bg_fg and name == "term15":
        h = boost_chroma_tone(hex_to_argb("#" + material_colors["onSurface"]), 3.0, 1.0)
    else:
        h = harmonize(hex_to_argb(val), primary_key, args.harmonize_threshold, args.harmony)
        h = boost_chroma_tone(h, 1.0, 1.0 + args.term_fg_boost * (1 if darkmode else -1))
    term[name] = argb_to_hex(h)

# foot.ini [colors] — same 16-slot mapping as ii's kitty-theme.conf
lines = ["[colors]"]
lines.append(f"background            = {term['term0']}")
lines.append(f"foreground            = {term['term7']}")
lines.append(f"selection-foreground  = {material_colors['secondaryContainer']}")
lines.append(f"selection-background  = {material_colors['onSecondaryContainer']}")
lines.append("")
for i in range(8):
    lines.append(f"regular{i} = {term[f'term{i}']}")
lines.append("")
for i in range(8):
    lines.append(f"bright{i} = {term[f'term{i + 8}']}")
out = "\n".join(lines) + "\n"

with open(args.output, "w") as f:
    f.write(out)
