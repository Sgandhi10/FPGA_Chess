from PIL import Image

# Fixed 4-color palette
PALETTE = {
    (238, 238, 210): 0,  # #EEEED2 – light squares
    (105, 146, 62): 1,   # #69923E – dark green squares
    (75, 72, 71): 2,     # #4B4847 – background
    (255, 255, 255): 3   # #FFFFFF – text
}

PALETTE_RGB = list(PALETTE.keys())

def color_distance(c1, c2):
    return sum((a - b) ** 2 for a, b in zip(c1, c2))

def map_to_palette_index(rgb):
    if rgb in PALETTE:
        return PALETTE[rgb]
    closest = min(PALETTE_RGB, key=lambda c: color_distance(c, rgb))
    print(f"⚠️ Warning: {rgb} not in palette, mapped to {closest}")
    return PALETTE[closest]

def convert_image_to_mif(input_path, output_path):
    image = Image.open(input_path).convert('RGB').resize((640, 480), Image.Resampling.NEAREST)
    total_pixels = 640 * 480

    with open(output_path, 'w') as f:
        f.write(f"WIDTH=2;\nDEPTH={total_pixels};\n\n")
        f.write("ADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")
        addr = 0
        for y in range(480):
            for x in range(640):
                rgb = image.getpixel((x, y))
                idx = map_to_palette_index(rgb)
                f.write(f"    {addr:05X} : {idx:X};\n")
                addr += 1
        f.write("END;\n")
    print(f"✅ MIF generated: {output_path}")


# ---- 4. Example Usage ----
if __name__ == "__main__":
    #input_img = r"C:\ECE4514\DD2_Final_PRJ\images\title_screen.png"            # <-- Change this to your input
   # output_mif = "title_screen.mif"   # Output .mif file
    
   # input_img = "C:\ECE4514\DD2_Final_PRJ\images\player_screen.png"            # <-- Change this to your input
  #  output_mif = "player_screen.mif"   # Output .mif file
    
  #  input_img = "C:\ECE4514\DD2_Final_PRJ\images\chess_board.jpg"            # <-- Change this to your input
  #  output_mif = "chess_board_palette.mif"   # Output .mif file
    #input_img = r"chess_board2.png"            # <-- Change this to your input
    #output_mif = "chess_board2.mif"   # Output .mif file
    input_img = "chess_board.png"       # <- update with your image path
    output_mif = "chess_board.mif"

    convert_image_to_mif(input_img, output_mif)



# ---- 4. Run Script (Example usage) ----


















