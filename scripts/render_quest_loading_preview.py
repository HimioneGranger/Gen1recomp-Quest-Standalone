"""Render the deterministic V8 Quest loading preview and real-alpha logo.

The renderer shares the 36 approved V8 motif anchors, retained color changes,
14-pixel measured exclusions, destination-seeded fallback placement, and
alternating progress styles with src/ui/kit/QuestLoadingScreen.lua.
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
PROTECTED_MARGIN = 14
LOGO_MAX_SIZE = (710, 520)
LOGO_PATH = Path("assets/logo/gen1recomp_unplugged_tight.png")
V4_MOTIF_COUNT = 32
MOTIF_COUNT = 36

MOTIF_ANCHORS = [
    (89, 35, 17, "blue"), (262, 48, 21, "yellow"),
    (435, 38, 17, "red"), (580, 65, 17, "yellow"),
    (1069, 76, 27, "blue"), (1192, 76, 13, "yellow"),
    (1492, 96, 17, "red"),
    (1705, 92, 17, "red"), (1715, 174, 17, "yellow"),
    (1069, 193, 17, "red"),
    (1229, 205, 22, "blue"), (1349, 175, 13, "red"),
    (71, 372, 22, "red"), (1011, 329, 17, "red"),
    (1362, 320, 27, "blue"),
    (1486, 342, 13, "yellow"), (1872, 328, 27, "red"),
    (889, 446, 22, "yellow"), (911, 619, 22, "red"),
    (1198, 630, 13, "red"), (1645, 596, 27, "yellow"),
    (1814, 634, 27, "blue"), (61, 750, 22, "red"),
    (263, 760, 27, "red"), (405, 758, 17, "yellow"),
    (579, 750, 27, "blue"), (864, 761, 22, "blue"),
    (1186, 744, 13, "blue"),
    (1351, 778, 27, "yellow"), (1530, 723, 27, "red"),
    (1669, 747, 13, "red"), (1819, 734, 22, "yellow"),
    (125, 150, 14, "blue"), (330, 150, 20, "red"),
    (815, 165, 23, "blue"),
    (75, 575, 18, "yellow"),
]
FALLBACK_OFFSETS = [(0, 0)]
for distance in (45, 90, 140, 200, 280, 360, 430):
    FALLBACK_OFFSETS.extend((dx * distance, dy * distance) for dx, dy in (
        (-1, 0), (1, 0), (0, -1), (0, 1),
        (-1, -1), (1, -1), (-1, 1), (1, 1),
    ))


def protected_zone(name: str, x: float, y: float, width: float,
                   height: float):
    return (
        name, x - PROTECTED_MARGIN, y - PROTECTED_MARGIN,
        width + PROTECTED_MARGIN * 2, height + PROTECTED_MARGIN * 2,
    )


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
    widths = [font.getlength(line) for line in lines]
    height = font_size
    line_height = height + 8
    first_y = 238 - (len(lines) - 1) * line_height / 2
    min_x = min(1410 - width / 2 for width in widths)
    max_x = max(1410 + width / 2 for width in widths)
    zone = protected_zone(
        "destination", min_x, first_y - height / 2, max_x - min_x,
        height + (len(lines) - 1) * line_height,
    )
    return lines, font, first_y, line_height, zone


def background_layout(destination: str, zones):
    seed = destination_seed(destination)
    placed = []
    for index, ball in enumerate(MOTIF_ANCHORS, 1):
        resolved = place_ball(ball, zones, placed, seed, index)
        if resolved:
            placed.append(resolved)
    return placed


def layout_zones(logo: Image.Image, destination: str, font_path: Path,
                 progress: float = .7, total: int = 10):
    lines, name_font, first_y, line_height, destination_zone = \
        destination_geometry(destination, font_path)
    fitted_logo = logo.copy()
    fitted_logo.thumbnail(LOGO_MAX_SIZE, Image.Resampling.LANCZOS)
    logo_x = W / 4 - fitted_logo.width / 2
    logo_y = H / 2 - fitted_logo.height / 2
    complete = min(total, max(0, int(progress * total + .00001)))
    copy = f"LOADING MAP DATA - {round(progress * 100)}%  ({complete} / {total})"
    copy_font = ImageFont.truetype(str(font_path), 25)
    copy_width = copy_font.getlength(copy)
    zones = [
        protected_zone("logo", logo_x, logo_y,
                       fitted_logo.width, fitted_logo.height),
        destination_zone,
        protected_zone("progress", 988, 443, 804, 44),
        protected_zone("copy", 1422.5 - copy_width / 2,
                       585 - 25 / 2, copy_width, 25),
    ]
    return (lines, name_font, first_y, line_height, copy, copy_font,
            fitted_logo, zones)


def centered_text(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str,
                  font: ImageFont.FreeTypeFont, fill: tuple[int, int, int]) -> None:
    draw.text(xy, text, font=font, fill=fill, anchor="mm")


def render(alpha_logo: Image.Image, font_path: Path, destination: str,
           progress: float) -> Image.Image:
    image = Image.new("RGBA", (W, H), (254, 254, 253, 255))
    draw = ImageDraw.Draw(image)
    (name_lines, name_font, first_y, line_height, copy, copy_font, logo,
     zones) = layout_zones(alpha_logo, destination, font_path, progress)
    for ball in background_layout(destination, zones):
        draw_outline_ball(draw, ball)

    image.alpha_composite(logo, (round(478.75 - logo.width / 2), round(410.5 - logo.height / 2)))

    for index, line in enumerate(name_lines):
        centered_text(draw, (1410, round(first_y + index * line_height)), line, name_font, NAVY)

    complete = min(10, max(0, int(progress * 10 + .00001)))
    draw.line((1010, 465, 1770, 465), fill=(192, 207, 228), width=4)
    for index in range(1, 11):
        x = 1010 + (index - 1) * (760 / 9)
        draw_progress_ball(image, x, 465, 22, index, index <= complete)

    centered_text(draw, (1422, 585), copy, copy_font, NAVY)
    return image.convert("RGB")


def main() -> None:
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--logo", type=Path)
    source.add_argument("--master", type=Path)
    parser.add_argument("--alpha-output", type=Path)
    parser.add_argument("--jpeg-output", type=Path, required=True)
    parser.add_argument("--asset-output", type=Path)
    parser.add_argument("--font", type=Path, default=Path("assets/fonts/plainpixel/PlainPixel-Regular.ttf"))
    parser.add_argument("--destination", default="Pallet Town")
    parser.add_argument("--progress", type=float, default=.7)
    args = parser.parse_args()

    for output in (args.alpha_output, args.jpeg_output, args.asset_output):
        if output and output.exists():
            raise FileExistsError(f"refusing to overwrite {output}")
    if args.logo:
        alpha = Image.open(args.logo).convert("RGBA")
    else:
        alpha = extract_white_matte(Image.open(args.master))
    if args.alpha_output:
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
