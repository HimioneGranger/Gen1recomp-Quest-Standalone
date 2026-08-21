"""Render the deterministic Quest loading preview and real-alpha logo.

This script uses the supplied white-background logo master as its only logo
source. It removes the white matte by color decontamination, then uses the same
1915x821 geometry, measured text bounds, deterministic seeded Pokeball placement,
and alternating progress styles as src/ui/kit/QuestLoadingScreen.lua.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

W, H = 1915, 821
NAVY = (5, 58, 130)
RED = (242, 46, 51)
BLUE = (30, 120, 210)
YELLOW = (255, 209, 31)
WHITE = (255, 255, 255)
OUTLINE_COLORS = {"red": RED, "blue": BLUE, "yellow": YELLOW}

STATIC_ZONES = [
    ("logo", 85, 90, 790, 640),
    ("progress", 970, 390, 875, 145),
    ("copy", 1050, 545, 745, 125),
]

BASE_BALLS = [
    (105, 58, 31, "red"), (275, 62, 17, "blue"),
    (470, 62, 24, "yellow"), (700, 48, 17, "red"),
    (920, 62, 27, "blue"), (1100, 55, 18, "yellow"),
    (1300, 54, 23, "red"), (1545, 48, 27, "blue"),
    (1750, 72, 21, "yellow"), (1872, 155, 27, "red"),
    (54, 268, 25, "blue"), (930, 275, 18, "yellow"),
    (1880, 350, 26, "red"), (52, 520, 24, "yellow"),
    (935, 595, 18, "red"), (1878, 535, 25, "blue"),
    (62, 765, 27, "blue"), (255, 776, 17, "yellow"),
    (925, 765, 25, "red"), (1100, 752, 18, "blue"),
    (1320, 765, 24, "yellow"), (1545, 760, 17, "red"),
    (1765, 760, 27, "blue"), (1890, 700, 24, "yellow"),
    (955, 360, 15, "blue"),
    (965, 690, 15, "yellow"), (1830, 690, 16, "red"),
]

GUIDE_POINTS = [
    (310, 85), (810, 48), (560, 145), (990, 125),
    (1200, 90), (1430, 115), (1705, 155), (120, 180),
    (240, 195), (460, 205), (735, 205), (1090, 185),
    (1210, 190), (1400, 185), (1580, 190), (1760, 260),
    (70, 410), (210, 480), (270, 585), (390, 750),
    (470, 640), (550, 770), (685, 650), (770, 760),
    (800, 570), (865, 645), (885, 365), (1080, 350),
    (1180, 330), (1190, 550), (1040, 585), (1150, 665),
    (1280, 650), (1400, 690), (1500, 660), (1535, 610),
    (1650, 730), (1700, 600), (1750, 650), (1600, 350),
    (1420, 350), (1310, 270), (1250, 375), (900, 480),
]
BALL_SIZES = (13, 16, 19, 23, 27, 31)
BALL_COLORS = ("red", "blue", "yellow")
FALLBACK_OFFSETS = [(0, 0)]
for distance in (45, 90, 140, 200, 280, 360, 430):
    FALLBACK_OFFSETS.extend((dx * distance, dy * distance) for dx, dy in (
        (-1, 0), (1, 0), (0, -1), (0, 1),
        (-1, -1), (1, -1), (-1, 1), (1, 1),
    ))


def intersects(ball: tuple[int, int, int, str],
               zone: tuple[str, float, float, float, float]) -> bool:
    x, y, r, _ = ball
    _, zx, zy, zw, zh = zone
    return x + r >= zx and x - r <= zx + zw and y + r >= zy and y - r <= zy + zh


def destination_seed(destination: str) -> int:
    seed = 17
    for byte in destination.encode("utf-8"):
        seed = (seed * 131 + byte) % 2147483647
    return seed


def balls_overlap(a: tuple[int, int, int, str], b: tuple[int, int, int, str]) -> bool:
    dx, dy = a[0] - b[0], a[1] - b[1]
    distance = a[2] + b[2] + 7
    return dx * dx + dy * dy < distance * distance


def safe_ball(ball: tuple[int, int, int, str], zones, placed) -> bool:
    x, y, r, _ = ball
    return (
        x - r >= 0 and x + r <= W and y - r >= 0 and y + r <= H
        and not any(intersects(ball, zone) for zone in zones)
        and not any(balls_overlap(ball, other) for other in placed)
    )


def place_ball(requested: tuple[int, int, int, str], zones, placed,
               seed: int, index: int):
    fallback_count = len(FALLBACK_OFFSETS) - 1
    start = (seed + index * 97) % fallback_count + 1
    order = [0] + [1 + ((start - 1 + attempt) % fallback_count)
                   for attempt in range(fallback_count)]
    for offset_index in order:
        dx, dy = FALLBACK_OFFSETS[offset_index]
        ball = (requested[0] + dx, requested[1] + dy, requested[2], requested[3])
        if safe_ball(ball, zones, placed):
            return ball
    return None


def extract_white_matte(master: Image.Image) -> Image.Image:
    """Return decontaminated RGBA whose white composite matches the master."""
    if "A" in master.getbands() and master.getchannel("A").getextrema()[0] < 255:
        return master.convert("RGBA")
    rgb = master.convert("RGB")
    out = Image.new("RGBA", rgb.size, (0, 0, 0, 0))
    src = rgb.load()
    dst = out.load()
    for y in range(rgb.height):
        for x in range(rgb.width):
            r, g, b = src[x, y]
            distance = max(255 - r, 255 - g, 255 - b)
            # The master has light 1-10 level paper noise. Remove that noise,
            # preserve the connected colored logo edge, and unpremultiply the
            # white matte so a dark background cannot reveal a white halo.
            # A composited edge's distance from white is its minimum safe
            # coverage estimate. Keep that coverage after the paper-noise
            # cutoff. This lets white recomposition recover every retained
            # master pixel while the unpremultiplied edge stays halo-free.
            alpha = 0 if distance <= 12 else distance
            if alpha == 0:
                dst[x, y] = (0, 0, 0, 0)
                continue
            af = alpha / 255.0
            nr = round((r - 255 * (1 - af)) / af)
            ng = round((g - 255 * (1 - af)) / af)
            nb = round((b - 255 * (1 - af)) / af)
            dst[x, y] = (
                max(0, min(255, nr)), max(0, min(255, ng)),
                max(0, min(255, nb)), alpha,
            )
    return out


def draw_outline_ball(draw: ImageDraw.ImageDraw, ball: tuple[int, int, int, str]) -> None:
    x, y, r, color_name = ball
    base = OUTLINE_COLORS[color_name]
    color = tuple(round(c * 0.55 + 255 * 0.45) for c in base)
    box = (x - r, y - r, x + r, y + r)
    draw.ellipse(box, outline=color, width=2)
    draw.line((x - r, y, x + r, y), fill=color, width=2)
    draw.ellipse((x - r * .34, y - r * .34, x + r * .34, y + r * .34), outline=color, width=2)
    draw.ellipse((x - r * .16, y - r * .16, x + r * .16, y + r * .16), outline=color, width=1)


def draw_progress_ball(image: Image.Image, x: float, y: int, r: int,
                       index: int, active: bool) -> None:
    alpha = 255 if active else 72
    top = RED if index % 2 else BLUE
    bottom = WHITE if index % 2 else YELLOW
    layer = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    box = (round(x - r), y - r, round(x + r), y + r)
    draw.pieslice(box, 180, 360, fill=top + (alpha,))
    draw.pieslice(box, 0, 180, fill=bottom + ((255 if index % 2 else alpha),))
    edge_alpha = 255 if active else 108
    draw.ellipse(box, outline=NAVY + (edge_alpha,), width=3)
    draw.line((round(x - r), y, round(x + r), y), fill=NAVY + (edge_alpha,), width=3)
    draw.ellipse((round(x - 6), y - 6, round(x + 6), y + 6), fill=WHITE + (255,),
                 outline=NAVY + (edge_alpha,), width=2)
    image.alpha_composite(layer)


def split_name(name: str) -> list[str]:
    words = name.split()
    if len(words) <= 3:
        return [name]
    choices = []
    for split in range(2, min(3, len(words) - 2) + 1):
        left, right = " ".join(words[:split]), " ".join(words[split:])
        score = max(len(left), len(right)) * 10 + abs(len(left) - len(right))
        choices.append((score, [left, right]))
    return min(choices, key=lambda item: item[0])[1]


def destination_geometry(destination: str, font_path: Path):
    lines = split_name(destination)
    font_size = 48 if len(lines) == 1 else 40
    font = ImageFont.truetype(str(font_path), font_size)
    boxes = [font.getbbox(line) for line in lines]
    widths = [box[2] - box[0] for box in boxes]
    height = max(box[3] - box[1] for box in boxes)
    line_height = height + 8
    first_y = 238 - (len(lines) - 1) * line_height / 2
    padding = 18
    min_x = min(1410 - width / 2 for width in widths)
    max_x = max(1410 + width / 2 for width in widths)
    zone = ("destination", min_x - padding, first_y - padding,
            max_x - min_x + padding * 2,
            height + (len(lines) - 1) * line_height + padding * 2)
    return lines, font, first_y, line_height, zone


def background_layout(destination: str, destination_zone):
    zones = [*STATIC_ZONES, destination_zone]
    seed = destination_seed(destination)
    placed = []
    for index, ball in enumerate(BASE_BALLS, 1):
        resolved = place_ball(ball, zones, placed, seed, index)
        if resolved:
            placed.append(resolved)
    for index, (x, y) in enumerate(GUIDE_POINTS, 1):
        ball = (
            x, y,
            BALL_SIZES[(seed + index * 37) % len(BALL_SIZES)],
            BALL_COLORS[(seed + index * 53) % len(BALL_COLORS)],
        )
        resolved = place_ball(ball, zones, placed, seed, len(BASE_BALLS) + index)
        if resolved:
            placed.append(resolved)
    return placed


def centered_text(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str,
                  font: ImageFont.FreeTypeFont, fill: tuple[int, int, int]) -> None:
    draw.text(xy, text, font=font, fill=fill, anchor="mm")


def render(alpha_logo: Image.Image, font_path: Path, destination: str,
           progress: float) -> Image.Image:
    image = Image.new("RGBA", (W, H), (254, 254, 253, 255))
    draw = ImageDraw.Draw(image)
    name_lines, name_font, first_y, line_height, destination_zone = \
        destination_geometry(destination, font_path)
    for ball in background_layout(destination, destination_zone):
        draw_outline_ball(draw, ball)

    logo = alpha_logo.copy()
    logo.thumbnail((710, 520), Image.Resampling.LANCZOS)
    image.alpha_composite(logo, (round(478.75 - logo.width / 2), round(410.5 - logo.height / 2)))

    for index, line in enumerate(name_lines):
        centered_text(draw, (1410, round(first_y + index * line_height)), line, name_font, NAVY)

    complete = min(10, max(0, int(progress * 10 + .00001)))
    draw.line((1010, 465, 1770, 465), fill=(192, 207, 228), width=4)
    for index in range(1, 11):
        x = 1010 + (index - 1) * (760 / 9)
        draw_progress_ball(image, x, 465, 22, index, index <= complete)

    copy_font = ImageFont.truetype(str(font_path), 25)
    copy = f"LOADING MAP DATA - {round(progress * 100)}%  ({complete} / 10)"
    centered_text(draw, (1422, 585), copy, copy_font, NAVY)
    return image.convert("RGB")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--master", type=Path, required=True)
    parser.add_argument("--alpha-output", type=Path, required=True)
    parser.add_argument("--jpeg-output", type=Path, required=True)
    parser.add_argument("--asset-output", type=Path)
    parser.add_argument("--font", type=Path, default=Path("assets/fonts/plainpixel/PlainPixel-Regular.ttf"))
    parser.add_argument("--destination", default="Pallet Town")
    parser.add_argument("--progress", type=float, default=.7)
    args = parser.parse_args()

    for output in (args.alpha_output, args.jpeg_output, args.asset_output):
        if output and output.exists():
            raise FileExistsError(f"refusing to overwrite {output}")
    alpha = extract_white_matte(Image.open(args.master))
    args.alpha_output.parent.mkdir(parents=True, exist_ok=True)
    alpha.save(args.alpha_output, "PNG", optimize=True)
    if args.asset_output:
        args.asset_output.parent.mkdir(parents=True, exist_ok=True)
        alpha.save(args.asset_output, "PNG", optimize=True)
    preview = render(alpha, args.font, args.destination, max(0, min(1, args.progress)))
    args.jpeg_output.parent.mkdir(parents=True, exist_ok=True)
    preview.save(args.jpeg_output, "JPEG", quality=96, subsampling=0, optimize=True)


if __name__ == "__main__":
    main()
