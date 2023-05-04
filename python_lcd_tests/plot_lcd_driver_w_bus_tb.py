#plot_lcd_driver_w_bus_tb
from lcd_plotter import *
import numpy as np

xsize = 480
ysize = 320

lcd_plotter = lcd(xsize,ysize)

data_from_vhdl = np.loadtxt("../temp/pixel_image_stream_from_bus_lcd_driver.txt")
lcd_plotter.stream_lcd(data_from_vhdl)
