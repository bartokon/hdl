#!/bin/python3

import PIL
from PIL import Image
from matplotlib import pyplot
import numpy as np
#from matplotlib import image

image = Image.open("pmod_vga/photo.jpg")
image = image.resize([int(640/2), int(480/2)])
image = image.rotate(-90)
#image = image.quantize(colors=256)

print(image.size)
image = image.convert("RGB")

#RED QUANT 0 -> 255 to 0 -> 15
#GREEN QUANT 0 -> 255 to 0 -> 7
#BLUE QUANT 0 -> 255 to 0 -> 3
#pyplot.imshow(image)
#pyplot.show()
red, green, blue = image.split()
# Create an image with only the red channel
red_image = Image.merge('RGB', (red, Image.new('L', image.size), Image.new('L', image.size)))
# Create an image with only the green channel
green_image = Image.merge('RGB', (Image.new('L', image.size), green, Image.new('L', image.size)))
# Create an image with only the blue channel
blue_image = Image.merge('RGB', (Image.new('L', image.size), Image.new('L', image.size), blue))
#pyplot.imshow(red_img)
#pyplot.show()

content = "memory_initialization_radix=2;\n\
memory_initialization_vector=\
"
h, w = image.size
print(h, w)
for col in range(0, w):
    for row in range(0, h):
        r, g, b = image.getpixel((row, col))
        #r, g, b = str(bin(r)[2:]), str(bin(g)[2:]), str(bin(b)[2:])
        cell = f'{int(r / 255 * 15):04b}' + f'{int(g / 255 * 15):04b}' + f'{int(b / 255 * 15):04b}'
        #cell = str((col * h + row) % h + 1)
        #if (len(cell) > 12):
        #    print(f"fuck up {cell}")
        #print(cell)
        cell = cell + " "
        content = content + cell
content = content[:-1] + ";"

f = open("pmod_vga/coe.coe", "w")
f.write(content)
f.close()