#!/usr/bin/env python3
"""Build ChatGPT Web and social-sharing assets from Malou's desktop package."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
CELL_WIDTH = 192
CELL_HEIGHT = 208
NEUTRAL_CELL = (0, 6)


def first_existing(paths: list[Path]) -> Path | None:
    return next((path for path in paths if path.is_file()), None)


def load_font(size: int, *, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    filename = "seguisb.ttf" if bold else "segoeui.ttf"
    font_path = first_existing(
        [
            Path("C:/Windows/Fonts") / filename,
            Path("/usr/share/fonts/truetype/dejavu")
            / ("DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf"),
            Path("/Library/Fonts/Arial Unicode.ttf"),
        ]
    )
    return ImageFont.truetype(str(font_path), size) if font_path else ImageFont.load_default()


def build_web_atlas() -> Path:
    source = ROOT / "dist" / "malou" / "spritesheet.webp"
    output = ROOT / "dist" / "chatgpt-web" / "malou" / "spritesheet.png"
    output.parent.mkdir(parents=True, exist_ok=True)

    with Image.open(source) as atlas_source:
        atlas = atlas_source.convert("RGBA")

    row, column = NEUTRAL_CELL
    transparent = Image.new("RGBA", (CELL_WIDTH, CELL_HEIGHT), (0, 0, 0, 0))
    atlas.paste(transparent, (column * CELL_WIDTH, row * CELL_HEIGHT))
    atlas.save(output, optimize=True)
    return output


def build_share_card() -> Path:
    output = ROOT / "assets" / "malou-look-directions-share.png"
    canvas = Image.new("RGB", (1200, 1200), "#f7f1e8")
    draw = ImageDraw.Draw(canvas)
    title_font = load_font(58, bold=True)
    subtitle_font = load_font(30)
    label_font = load_font(21, bold=True)

    draw.text((70, 42), "Meet Malou", font=title_font, fill="#3d2418")
    draw.text(
        (72, 112),
        "16 clockwise look directions — ready to adopt in ChatGPT",
        font=subtitle_font,
        fill="#76533d",
    )

    directions = [
        "000",
        "022.5",
        "045",
        "067.5",
        "090",
        "112.5",
        "135",
        "157.5",
        "180",
        "202.5",
        "225",
        "247.5",
        "270",
        "292.5",
        "315",
        "337.5",
    ]
    labels = [
        "0° up",
        "22.5° up-right",
        "45° up-right",
        "67.5° up-right",
        "90° right",
        "112.5° down-right",
        "135° down-right",
        "157.5° down-right",
        "180° down",
        "202.5° down-left",
        "225° down-left",
        "247.5° down-left",
        "270° left",
        "292.5° up-left",
        "315° up-left",
        "337.5° up-left",
    ]

    tile_width, tile_height, gap = 250, 230, 18
    left = (1200 - (4 * tile_width + 3 * gap)) // 2
    top = 190

    for index, (degrees, label) in enumerate(zip(directions, labels, strict=True)):
        row, column = divmod(index, 4)
        x = left + column * (tile_width + gap)
        y = top + row * (tile_height + gap)
        draw.rounded_rectangle(
            (x, y, x + tile_width, y + tile_height),
            radius=24,
            fill="#fffdf9",
            outline="#ead9c7",
            width=3,
        )

        frame_path = ROOT / "source" / "frames" / "look-directions" / f"{degrees}.png"
        with Image.open(frame_path) as frame_source:
            frame = frame_source.convert("RGBA")
        frame.thumbnail((178, 178), Image.Resampling.NEAREST)
        canvas.paste(
            frame,
            (x + (tile_width - frame.width) // 2, y + 12),
            frame,
        )

        label_box = draw.textbbox((0, 0), label, font=label_font)
        label_width = label_box[2] - label_box[0]
        draw.text(
            (x + (tile_width - label_width) // 2, y + 197),
            label,
            font=label_font,
            fill="#4a2d20",
        )

    canvas.save(output, optimize=True)
    return output


if __name__ == "__main__":
    print(build_web_atlas())
    print(build_share_card())
