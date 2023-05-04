from lcd_plotter import *
import numpy as np

xsize = 480
ysize = 320

lcd_plotter = lcd(xsize,ysize)


d = np.zeros([ysize,xsize])
data_from_vhdl = np.loadtxt("../temp/pixel_image_stream_from_vhdl.txt")
lcd_plotter.stream_lcd(data_from_vhdl)
