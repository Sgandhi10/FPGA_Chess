# import an image of file format .png/.jpg etc and convert it to a .mif format for intel rom.
# For the colors use the following color pallette:
# 0 = 0xD9D9D9
# 1 = 0x000000
# 2 = 0x69923e
# 3 = 0xFFFFFF
# if the color is not in the pallette, use 0xD9D9D9 and print a warning message.
# Image should be 640x480 pixels.

from PIL import Image
import os

# --- 1. Define the fixed 4-color palette ---
PALETTE = {
    (217, 217, 217): 0,  # 0xD9D9D9 - Default
    (0, 0, 0): 1,        # 0x000000 - Black
    (105, 146, 62): 2,   # 0x69923e - Green
    (255, 255, 255): 3   # 0xFFFFFF - White
}

PALETTE_RGB = list(PALETTE.keys())
INDEX_TO_RGB = {v: k for k, v in PALETTE.items()}

# --- 2. Helper functions ---
def color_distance(c1, c2):
    return sum((a - b) ** 2 for a, b in zip(c1, c2))  # No sqrt needed

def map_to_palette_index(rgb):
    if rgb in PALETTE:
        return PALETTE[rgb]
    # Find closest
    closest = min(PALETTE_RGB, key=lambda c: color_distance(c, rgb))
    print(f"Warning: Color {rgb} not in palette. Mapped to closest {closest}")
    return PALETTE[closest]

# --- 3. Main conversion ---
def convert_image_to_mif(input_path, output_path):
    # Load and resize
    image = Image.open(input_path).convert('RGB')
    image = image.resize((640, 480), Image.NEAREST)

    width, height = image.size
    total_pixels = width * height

    # Create remapped image
    remapped_img = Image.new("RGB", (width, height))

    with open(output_path, 'w') as f:
        f.write(f"WIDTH=2;\nDEPTH={total_pixels};\n\n")
        f.write("ADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")

        address = 0
        for y in range(height):
            for x in range(width):
                original_rgb = image.getpixel((x, y))
                index = map_to_palette_index(original_rgb)
                palette_rgb = INDEX_TO_RGB[index]

                remapped_img.putpixel((x, y), palette_rgb)
                f.write(f"    {address:05X} : {index:X};\n")
                address += 1

        f.write("END;\n")

    # Save and show the remapped image
    # output_img_path = output_path.replace(".mif", "_remapped.png")
    # remapped_img.save(output_img_path)

    print(f"MIF written to: {output_path}")
    print(f"Remapped image saved to: {output_img_path}")

# Example usage:
# convert_image_to_mif('input.png', 'output.mif')

if __name__ == "__main__":
    # Create a for loop that goes through all .png in the directory and converts them to .mif and saves them in a directory
    for file in os.listdir("C:\Digital_Design_2\PRJ_Final\images"):
        if file.endswith(".png"):
            input_path = os.path.join("C:\Digital_Design_2\PRJ_Final\images", file)
            output_path = os.path.join("C:\Digital_Design_2\PRJ_Final\\bitmaps", file.replace(".png", ".mif"))
            convert_image_to_mif(input_path, output_path)

    # if len(sys.argv) != 3:
    #     print("Usage: python convert_to_mif.py <input_image> <output_mif>")
    # else:
    #     convert_image_to_mif(sys.argv[1], sys.argv[2])
        
