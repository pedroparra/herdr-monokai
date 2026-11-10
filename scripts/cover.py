"""Compose preview.png: a title band over a real screenshot of the layout.

    uv run --with pillow python scripts/cover.py <shot.png> <out.png> <fonts dir>

shot.png is `herdr-app shot` of the demo window; scripts/demo.sh shot runs this for you.
out.png is 1600x1000, the 16:10 of a herdr.dev gallery card, so the card shows all of it.
The fonts dir holds JetBrainsMono-Variable.ttf and Geist.ttf, the fonts Herdr uses.
"""
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

shot_path, out_path, fonts = sys.argv[1], sys.argv[2], sys.argv[3]
W, H = 1600, 1000
S = 2  # draw at 2x, scale down at the end for smooth edges

BG = "#272822"       # Monokai background
FG = "#f8f8f2"       # terminal text
MUTE = "#a5a59b"
COLORS = ["#f92672", "#fd971f", "#e6db74", "#a6e22e", "#66d9ef", "#ae81ff"]


def mono(size, weight):
    f = ImageFont.truetype(f"{fonts}/JetBrainsMono-Variable.ttf", size * S)
    f.set_variation_by_axes([weight])
    return f


def sans(size):
    return ImageFont.truetype(f"{fonts}/Geist.ttf", size * S)


img = Image.new("RGB", (W * S, H * S), BG)
d = ImageDraw.Draw(img)

# Title band.
x0, top = 72, 58
d.text((x0 * S, top * S), "A LAYOUT FOR HERDR", font=mono(22, 600), fill=MUTE)
d.text((x0 * S - 6 * S, (top + 26) * S), "Monokai", font=mono(128, 800), fill=FG)
# Six color chips under the word, in Monokai's order.
cy = top + 196
for i, c in enumerate(COLORS):
    cx = x0 + i * 46
    d.rounded_rectangle((cx * S, cy * S, (cx + 36) * S, (cy + 12) * S), radius=6 * S, fill=c)

# Tagline on the right, aligned to the right edge.
lines = [("The colors you know,", FG), ("now for your agents.", MUTE)]
rx = W - 72
ty = top + 70
for text, col in lines:
    f = sans(54)
    w = d.textlength(text, font=f) / S
    d.text(((rx - w) * S, ty * S), text, font=f, fill=col)
    ty += 66

# The screenshot: a card with rounded corners and a soft shadow, cut by the bottom edge.
shot = Image.open(shot_path).convert("RGB")
sw = W - 2 * 72
sh = round(shot.height * sw / shot.width)
shot = shot.resize((sw * S, sh * S), Image.LANCZOS)
sx, sy = 72, 300
radius = 18 * S

shadow = Image.new("L", img.size, 0)
ImageDraw.Draw(shadow).rounded_rectangle(
    (sx * S, (sy + 10) * S, (sx + sw) * S, (sy + sh + 10) * S), radius=radius, fill=200)
shadow = shadow.filter(ImageFilter.GaussianBlur(28 * S))
img.paste(Image.new("RGB", img.size, "#0b0c0a"), (0, 0), shadow)

mask = Image.new("L", shot.size, 0)
ImageDraw.Draw(mask).rounded_rectangle((0, 0, shot.width - 1, shot.height - 1), radius=radius, fill=255)
img.paste(shot, (sx * S, sy * S), mask)
ImageDraw.Draw(img).rounded_rectangle(
    (sx * S, sy * S, (sx + sw) * S - 1, (sy + sh) * S - 1), radius=radius, outline="#ffffff14", width=2 * S)

img.resize((W, H), Image.LANCZOS).save(out_path, optimize=True)
print(f"Saved {out_path}")
