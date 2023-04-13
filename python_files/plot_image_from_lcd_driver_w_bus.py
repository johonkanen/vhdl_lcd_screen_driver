from lcdprint import lcdprint
from lcdprint import add_plot
from lcdprint import stream_lcd
import numpy as np

xsize = 480
ysize = 320

data_from_vhdl = np.loadtxt("../temp/pixel_image_stream_from_bus_lcd_driver.txt")

stream_lcd(data_from_vhdl, xsize, ysize)
