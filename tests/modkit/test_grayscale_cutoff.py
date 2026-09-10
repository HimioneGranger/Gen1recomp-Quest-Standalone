"""ROM-free regression for Modkit's grayscale duplicate-image cutoff."""

import importlib.util
from pathlib import Path
import unittest

from PIL import Image


REPO = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("modkit", REPO / "tools/modkit.py")
MODKIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODKIT)


def fixed_cutoff_hash(image):
    """The pre-C5 behavior, retained only as a regression comparison."""
    grayscale = image.convert("L")
    pixels = list(grayscale.get_flattened_data()
                  if hasattr(grayscale, "get_flattened_data")
                  else grayscale.getdata())
    return sum(1 << index for index, pixel in enumerate(pixels)
               if pixel <= 200)


def synthetic_image(background, ink_values):
    """Build an original, deterministic 8x8 grayscale-in-RGB fixture."""
    image = Image.new("RGB", (8, 8), (background,) * 3)
    for (x, y), value in ink_values.items():
        image.putpixel((x, y), (value,) * 3)
    return image


class GrayscaleCutoffTest(unittest.TestCase):
    def test_dark_boulder_style_icon_uses_its_own_mean(self):
        shape = {
            (2, 1), (3, 1), (4, 1), (5, 1),
            (1, 2), (6, 2),
            (1, 3), (3, 3), (4, 3), (6, 3),
            (1, 4), (2, 4), (5, 4), (6, 4),
            (1, 5), (3, 5), (4, 5), (6, 5),
            (2, 6), (3, 6), (4, 6), (5, 6),
        }
        image = synthetic_image(160, {point: 80 for point in shape})

        self.assertEqual(fixed_cutoff_hash(image), (1 << 64) - 1)
        self.assertEqual(MODKIT.ahash(image), 0x3C5A665A423C00)

    def test_light_background_conversion_is_unchanged(self):
        ink = {
            (index % 8, index // 8): (index % 3) * 80
            for index in range(16)
        }
        image = synthetic_image(255, ink)

        self.assertEqual(MODKIT.ahash(image), fixed_cutoff_hash(image))


if __name__ == "__main__":
    unittest.main()
