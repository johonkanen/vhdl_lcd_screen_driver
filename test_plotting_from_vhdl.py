from lcdprint import lcdprint
from lcdprint import add_plot
from lcdprint import add_axes
from lcdprint import testi
from lcdprint import stream_from_file_to_lcd
from lcdprint import stream_lcd
import numpy as np

xsize = 480
ysize = 320

d = np.zeros([ysize,xsize])
data_from_vhdl = np.loadtxt("temp/lcd_stream_from_vhdl.txt")
d = add_plot(d, data_from_vhdl, xsize, ysize)

stream_lcd(d, xsize, ysize)

# stream_from_file_to_lcd("dabadii.testi", xsize, ysize)
