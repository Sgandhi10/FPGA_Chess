from PIL import Image

# --- Config ---
TILE_WIDTH = 56
TILE_HEIGHT = 56
GRID_COLS = 8
GRID_ROWS = 4
MIF_WIDTH = 2  # 2-bit: 0=transparent, 1=white, 2=black

PALETTE = {
    (255, 255, 255): 1,  # white piece
    (0, 0, 0): 2         # black piece
}

PALETTE_RGB = list(PALETTE.keys())

def color_distance(c1, c2):
    return sum((a - b) ** 2 for a, b in zip(c1, c2))

def map_to_palette_index(rgb, alpha):
    if alpha < 128:
        return 0  # transparent
    if rgb in PALETTE:
        return PALETTE[rgb]
    closest = min(PALETTE_RGB, key=lambda c: color_distance(c, rgb))
    print(f"⚠️ {rgb} not in palette, mapped to {closest}")
    return PALETTE[closest]

def convert_piece_grid_to_mif(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size
    total_tiles = GRID_ROWS * GRID_COLS
    total_pixels = TILE_WIDTH * TILE_HEIGHT * total_tiles

    with open(output_path, "w") as f:
        f.write(f"WIDTH={MIF_WIDTH};\nDEPTH={total_pixels};\n")
        f.write("ADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")

        addr = 0
        for row in range(GRID_ROWS):
            for col in range(GRID_COLS):
                for y in range(TILE_HEIGHT):
                    for x in range(TILE_WIDTH):
                        px = col * TILE_WIDTH + x
                        py = row * TILE_HEIGHT + y
                        r, g, b, a = img.getpixel((px, py))
                        idx = map_to_palette_index((r, g, b), a)
                        f.write(f"    {addr:05X} : {idx:X};\n")
                        addr += 1
        f.write("END;\n")
    print(f"✅ MIF file created: {output_path}")

# Run it
if __name__ == "__main__":
    input_img = "chess_pieces.png"       # your exported image from Figma
    output_mif = "chess_piece_rom.mif"
    convert_piece_grid_to_mif(input_img, output_mif)
