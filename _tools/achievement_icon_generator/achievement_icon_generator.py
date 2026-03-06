import os
import glob
from PIL import Image

def process_achievements(input_pattern, output_folder, dark_factor=0.5):
    # Create output directories
    color_dir = os.path.join(output_folder, "color")
    gray_dir = os.path.join(output_folder, "gray")
    
    os.makedirs(color_dir, exist_ok=True)
    os.makedirs(gray_dir, exist_ok=True)

    # Use glob to find all files matching the pattern
    image_paths = glob.glob(input_pattern)
    
    if not image_paths:
        print(f"No images found matching: {input_pattern}")
        return

    for img_path in image_paths:
        try:
            with Image.open(img_path) as img:
                # 1. Resize 256x256 Nearest Neighbor
                img_resized = img.resize((256, 256), resample=Image.Resampling.NEAREST)
                
                base_name = os.path.splitext(os.path.basename(img_path))[0]
                
                # --- Save Color ---
                img_resized.convert("RGB").save(os.path.join(color_dir, f"{base_name}.jpg"), "JPEG")
                
                # --- Save Grayscale + Darkened ---
                gray_img = img_resized.convert("L")
                dark_gray_img = gray_img.point(lambda p: p * dark_factor)
                dark_gray_img.save(os.path.join(gray_dir, f"{base_name}_locked.jpg"), "JPEG")
                
                print(f"Processed: {base_name}")
                
        except Exception as e:
            print(f"Error processing {img_path}: {e}")

if __name__ == "__main__":
    # CONFIGURATION:
    # Point this to your folder followed by /*.png
    SOURCE_DIR = "/mnt/c/docs/gamedev/bugscraper/bugscraper/images/achievements/*.png"
    OUTPUT_DIR = "generated_icons"
    DARKEN_BY = 0.4  # Lower is darker
    
    process_achievements(SOURCE_DIR, OUTPUT_DIR, DARKEN_BY)