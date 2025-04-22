"""/*from PIL import Image

# --- Config ---
TILE_WIDTH = 56
TILE_HEIGHT = 56
GRID_COLS = 6
GRID_ROWS = 2
MIF_WIDTH = 2  # 2-bit: 0=transparent, 1=white, 2=black

PALETTE = {
    (255, 255, 255): 3,  # white piece
    (0, 0, 0): 1         # black piece
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
    input_img = r"C:\ECE4514\DD2_Final_PRJ\images\2-bit-transp\chess_pieces_single56.png"       # your exported image from Figma
    output_mif = r"C:\ECE4514\DD2_Final_PRJ\bitmaps\2-bit-transp\chess_pieces_single562.mif"
    convert_piece_grid_to_mif(input_img, output_mif)
    """""
    
    
from PIL import Image

# --- Config ---
TILE_WIDTH = 56
TILE_HEIGHT = 56
GRID_COLS = 6
GRID_ROWS = 2
MIF_WIDTH = 3  # 2-bit output: 1=black, 3=white, 2=background

PALETTE = {
    (255, 255, 255): 3,  # white piece
    (0, 0, 0): 1         # black piece
}

TRANSPARENT_INDEX = 4  # Set this to the index you want for transparency

PALETTE_RGB = list(PALETTE.keys())

def color_distance(c1, c2):
    return sum((a - b) ** 2 for a, b in zip(c1, c2))

def map_to_palette_index(rgb, alpha):
    if alpha < 128:
        return TRANSPARENT_INDEX
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
    input_img = r"C:\ECE4514\DD2_Final_PRJ\images\2-bit-transp\chess_pieces_single56.png"
    output_mif = r"C:\ECE4514\DD2_Final_PRJ\bitmaps\2-bit-transp\chess_pieces_single562.mif"
    convert_piece_grid_to_mif(input_img, output_mif)

