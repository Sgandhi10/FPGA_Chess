from PIL import Image
import os

# --- 1. Define the fixed 3-color palette including transparent ---
PALETTE = {
    (0, 0, 0): 1,         # 0x000000 - Black
    (255, 255, 255): 3,   # 0xFFFFFF - White
    "TRANSPARENT": 4      # Transparency
}

PALETTE_RGB = [color for color in PALETTE if isinstance(color, tuple)]
INDEX_TO_RGB = {v: k for k, v in PALETTE.items() if isinstance(k, tuple)}
INDEX_TO_RGB[0] = (0, 0, 0, 0)  # Represent transparency

# --- 2. Helper functions ---
def color_distance(c1, c2):
    return sum((a - b) ** 2 for a, b in zip(c1, c2))

def map_to_palette_index(rgb):
    if rgb in PALETTE:
        return PALETTE[rgb]
    closest = min(PALETTE_RGB, key=lambda c: color_distance(c, rgb))
    print(f"Warning: Color {rgb} not in palette. Mapped to closest {closest}")
    return PALETTE[closest]

# --- 3. Main conversion ---
def convert_image_to_mif(input_path, output_path):
    # Load and resize
    image = Image.open(input_path).convert('RGBA')

    width, height = image.size
    total_pixels = width * height

    remapped_img = Image.new("RGBA", (width, height))

    with open(output_path, 'w') as f:
        f.write(f"WIDTH=2;\nDEPTH={total_pixels};\n\n")
        f.write("ADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")

        address = 0
        for y in range(height):
            for x in range(width):
                r, g, b, a = image.getpixel((x, y))

                if a == 0:
                    index = PALETTE["TRANSPARENT"]
                    remapped_img.putpixel((x, y), (0, 0, 0, 0))
                else:
                    index = map_to_palette_index((r, g, b))
                    remapped_img.putpixel((x, y), INDEX_TO_RGB[index])

                f.write(f"    {address:05X} : {index:X};\n")
                address += 1

        f.write("END;\n")

    output_img_path = output_path.replace(".mif", "_remapped.png")
    remapped_img.save(output_img_path)

    print(f"MIF written to: {output_path}")
    print(f"Remapped image saved to: {output_img_path}")

# --- 4. Batch conversion ---
if __name__ == "__main__":
    for file in os.listdir(r"C:\Digital_Design_2\PRJ_Final\images\2-bit-transp"):
        if file.endswith(".png"):
            input_path = os.path.join(r"C:\Digital_Design_2\PRJ_Final\images\2-bit-transp", file)
            output_path = os.path.join(r"C:\Digital_Design_2\PRJ_Final\bitmaps\2-bit-transp", file.replace(".png", "2.mif"))
            convert_image_to_mif(input_path, output_path)
