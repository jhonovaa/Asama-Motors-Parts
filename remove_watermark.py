from PIL import Image
import sys

def fix():
    path = 'src/main/webapp/resources/logo-asama.png'
    try:
        img = Image.open(path).convert('RGBA')
        width, height = img.size
        pixels = img.load()
        # Watermark is in the bottom right corner.
        for x in range(width - 60, width):
            for y in range(height - 60, height):
                if x >= 0 and y >= 0:
                    pixels[x, y] = (0, 0, 0, 0)
        img.save(path)
        print("Logo watermark removed successfully")
    except Exception as e:
        print("Error:", e)

fix()
