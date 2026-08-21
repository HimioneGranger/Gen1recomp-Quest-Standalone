"""Deterministic source/preview contract for the V8 Quest loading screen."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path
import shutil
import subprocess

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
RENDERER_PATH = ROOT / "scripts" / "render_quest_loading_preview.py"
LOGO_PATH = ROOT / "assets" / "logo" / "gen1recomp_unplugged_tight.png"
FONT_PATH = ROOT / "assets" / "fonts" / "plainpixel" / "PlainPixel-Regular.ttf"

V5_MOTIF_ANCHORS = (
    (89, 35, 17, "blue"), (262, 48, 21, "yellow"),
    (435, 38, 17, "red"), (580, 65, 17, "yellow"),
    (1069, 76, 27, "blue"), (1192, 76, 13, "yellow"),
    (1373, 91, 13, "yellow"), (1492, 96, 17, "red"),
    (1705, 92, 17, "red"), (1715, 174, 17, "yellow"),
    (911, 198, 13, "blue"), (1069, 193, 17, "red"),
    (1229, 205, 22, "blue"), (1349, 175, 13, "red"),
    (71, 372, 22, "red"), (1011, 329, 17, "blue"),
    (916, 357, 22, "blue"), (1362, 320, 27, "blue"),
    (1486, 342, 13, "yellow"), (1872, 328, 27, "red"),
    (889, 446, 22, "yellow"), (911, 619, 22, "red"),
    (1198, 630, 13, "red"), (1645, 596, 27, "yellow"),
    (1814, 634, 27, "yellow"), (61, 750, 22, "red"),
    (263, 760, 27, "red"), (405, 758, 17, "yellow"),
    (579, 750, 27, "blue"), (864, 761, 22, "blue"),
    (1061, 766, 13, "yellow"), (1186, 744, 13, "yellow"),
    (1351, 778, 27, "yellow"), (1530, 723, 27, "red"),
    (1669, 747, 13, "red"), (1819, 734, 22, "yellow"),
    (125, 150, 14, "blue"), (330, 150, 20, "red"),
    (610, 150, 16, "yellow"), (815, 165, 23, "blue"),
    (75, 575, 18, "yellow"), (930, 550, 15, "red"),
)
V6_COLOR_CHANGES = {16: "red", 25: "blue", 32: "blue", 42: "blue"}
V7_REMOVED = {(911, 198), (916, 357), (930, 550)}
V8_REMOVED = V7_REMOVED | {(1373, 91), (1061, 766), (610, 150)}

spec = importlib.util.spec_from_file_location("loading_preview", RENDERER_PATH)
assert spec and spec.loader
preview = importlib.util.module_from_spec(spec)
spec.loader.exec_module(preview)


def lua_positions(destination: str, widths: dict[str, tuple[float, int]]):
    luajit = shutil.which("luajit")
    assert luajit, "luajit is required for source/preview parity"
    measurements = "\n".join(
        f"  [{json.dumps(text)}] = {{{width:.9f}, {height}}},"
        for text, (width, height) in widths.items()
    )
    lua = f'''package.path = "./?.lua;./?/init.lua;" .. package.path
local Screen = require("src.ui.kit.QuestLoadingScreen")
local measurements = {{
{measurements}
}}
local layout = Screen.layout({json.dumps(destination)}, 0.7, 10,
  function(text, size)
    local value = measurements[text]
    if value then return value[1], value[2] end
    return #text * size * 0.62, size
  end)
for _, ball in ipairs(layout.background) do
  io.write(string.format("%.9f\\t%.9f\\t%d\\t%s\\n",
    ball.x, ball.y, ball.r, ball.color))
end
'''
    result = subprocess.run(
        [luajit, "-e", lua], cwd=ROOT, check=True,
        capture_output=True, text=True,
    )
    rows = []
    for line in result.stdout.splitlines():
        x, y, radius, color = line.split("\t")
        rows.append((float(x), float(y), int(radius), color))
    return rows


def assert_clear(positions, zones) -> None:
    for ball in positions:
        assert not any(preview.intersects(ball, zone) for zone in zones)
    for index, ball in enumerate(positions):
        assert not any(
            preview.balls_overlap(ball, other)
            for other in positions[index + 1:]
        )


def main() -> None:
    logo = Image.open(LOGO_PATH)
    assert logo.mode == "RGBA"
    assert logo.getchannel("A").getbbox() == (0, 0, logo.width, logo.height)
    assert logo.size == (1344, 759)
    assert preview.PROTECTED_MARGIN == 14
    assert preview.protected_zone("sample", 100, 200, 30, 40) == \
        ("sample", 86, 186, 58, 68)
    assert preview.V4_MOTIF_COUNT == 32
    assert preview.MOTIF_COUNT == 36
    expected_v6 = list(V5_MOTIF_ANCHORS)
    for index, color in V6_COLOR_CHANGES.items():
        x, y, radius, _ = expected_v6[index - 1]
        expected_v6[index - 1] = (x, y, radius, color)
    expected_v8 = [ball for ball in expected_v6
                   if ball[:2] not in V8_REMOVED]
    assert preview.MOTIF_ANCHORS == expected_v8
    assert sum(before != after for before, after in
               zip(V5_MOTIF_ANCHORS, expected_v6)) == 4

    destinations = (
        "Pallet Town",
        "Seafoam Islands Lower",
        "Pokemon Mansion Basement Floor",
        "Silph Company Executive Meeting Room",
    )
    pallet_positions = None
    for destination in destinations:
        (lines, name_font, _, _, copy, copy_font, _, zones) = \
            preview.layout_zones(logo, destination, FONT_PATH)
        assert " ".join(lines) == destination
        assert copy == "LOADING MAP DATA - 70%  (7 / 10)"
        python_positions = preview.background_layout(destination, zones)
        assert len(python_positions) == preview.MOTIF_COUNT
        assert python_positions == preview.background_layout(destination, zones)
        assert_clear(python_positions, zones)

        widths = {line: (name_font.getlength(line), name_font.size)
                  for line in lines}
        widths[copy] = (copy_font.getlength(copy), copy_font.size)
        source_positions = lua_positions(destination, widths)
        assert len(source_positions) == len(python_positions)
        for source, rendered in zip(source_positions, python_positions):
            assert abs(source[0] - rendered[0]) < 1e-6
            assert abs(source[1] - rendered[1]) < 1e-6
            assert source[2:] == rendered[2:]
        if destination == "Pallet Town":
            pallet_positions = python_positions

    assert pallet_positions is not None
    left = [ball for ball in pallet_positions if ball[0] < preview.W / 2]
    right_blue = [ball for ball in pallet_positions
                  if ball[0] >= preview.W / 2 and ball[3] == "blue"]
    assert len(left) >= 15
    assert len(right_blue) == 5
    assert {ball[3] for ball in left} == {"red", "blue", "yellow"}
    assert len({ball[2] for ball in left}) >= 5

    rendered_a = preview.render(logo, FONT_PATH, "Pallet Town", .7)
    rendered_b = preview.render(logo, FONT_PATH, "Pallet Town", .7)
    assert rendered_a.tobytes() == rendered_b.tobytes()
    print("PASS: Quest loading preview contract")


if __name__ == "__main__":
    main()
