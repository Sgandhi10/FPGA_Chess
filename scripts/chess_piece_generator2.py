from PIL import Image

# Settings
SPRITE_W, SPRITE_H = 56, 56
ROWS, COLS = 2, 6
TOTAL_SPRITES = ROWS * COLS
IMG_PATH = "chess_pieces_single56.png"  # Replace with correct filename
MIF_PATH = "chess_pieces_rom2.mif"

# Palette
PALETTE = {
    (0, 0, 0): 2,          # Black
    (255, 255, 255): 3     # White
}
TRANSPARENT_INDEX = 0
WIDTH_BITS = 2
DEPTH = TOTAL_SPRITES * SPRITE_W * SPRITE_H

def get_palette_index(rgba):
    r, g, b, a = rgba
    if a < 128:
        return TRANSPARENT_INDEX
    return PALETTE.get((r, g, b), TRANSPARENT_INDEX)

# Load image
img = Image.open(IMG_PATH).convert('RGBA')
img_width, img_height = img.size

with open(MIF_PATH, 'w') as f:
    f.write(f"WIDTH={WIDTH_BITS};\nDEPTH={DEPTH};\n\n")
    f.write("ADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\n")
    f.write("CONTENT BEGIN\n")

    addr = 0
    for sprite_idx in range(TOTAL_SPRITES):
        col = sprite_idx % COLS
        row = sprite_idx // COLS
        origin_x = col * SPRITE_W
        origin_y = row * SPRITE_H + 16  # vertical offset for padding

        for y in range(SPRITE_H):
            for x in range(SPRITE_W):
                px = origin_x + x
                py = origin_y + y

                if px >= img_width or py >= img_height:
                    idx = TRANSPARENT_INDEX  # prevent out-of-range
                else:
                    idx = get_palette_index(img.getpixel((px, py)))

                f.write(f"    {addr:05X} : {idx:X};\n")
                addr += 1

    f.write("END;\n")

print(f"✅ MIF written: {MIF_PATH}")
