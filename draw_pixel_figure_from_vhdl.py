from lcdprint import lcdprint
from lcdprint import add_plot
from lcdprint import stream_lcd
import numpy as np

xsize = 480
ysize = 320

d = np.zeros([ysize,xsize])
data_from_vhdl = np.loadtxt("temp/pixel_image_stream_from_vhdl.txt")
d = add_plot(d, data_from_vhdl, xsize, ysize)

stream_lcd(d, xsize, ysize)
