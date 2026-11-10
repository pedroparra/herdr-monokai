"""Turn frames of the demo window into states.gif for the README.

    uv run --with pillow python scripts/states-gif.py <out.gif> <frame.png>...

scripts/demo.sh gif films the frames and runs this. Each frame is cropped to the
sidebar, the tab bar and the focused pane, where the agent states show, and lasts
as long as it did on screen (from the files' times), so the GIF plays in real time.
"""
import os
import sys
from PIL import Image

out, frames = sys.argv[1], sorted(sys.argv[2:])
WIDTH = 900          # README column
CROP = 0.605         # of the window's width: sidebar, tabs and the left pane with its ring

images, times = [], []
for path in frames:
    im = Image.open(path).convert("RGB")
    im = im.crop((0, 0, round(im.width * CROP), im.height))
    im = im.resize((WIDTH, round(im.height * WIDTH / im.width)), Image.LANCZOS)
    images.append(im)
    times.append(os.stat(path).st_mtime)

# One palette for every frame, from a frame of each state, so colors never flicker.
picks = [images[i] for i in range(0, len(images), max(1, len(images) // 6))]
sheet = Image.new("RGB", (WIDTH, sum(p.height for p in picks)))
y = 0
for p in picks:
    sheet.paste(p, (0, y))
    y += p.height
palette = sheet.quantize(colors=255, method=Image.Quantize.MEDIANCUT)
quantized = [im.quantize(palette=palette, dither=Image.Dither.NONE) for im in images]

gaps = [round((b - a) * 1000) for a, b in zip(times, times[1:])]
durations = gaps + [round(sum(gaps) / len(gaps)) if gaps else 100]
quantized[0].save(out, save_all=True, append_images=quantized[1:], duration=durations,
                  loop=0, optimize=True, disposal=1)
print(f"Saved {out}: {len(images)} frames, {sum(durations) / 1000:.1f}s, "
      f"{os.path.getsize(out) / 1e6:.1f} MB")
