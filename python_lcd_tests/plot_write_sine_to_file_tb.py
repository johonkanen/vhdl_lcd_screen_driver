from lcd_plotter import lcd
import numpy as np

xsize = 480
ysize = 320

lcd_plotter = lcd(xsize,ysize)

d = np.zeros([ysize,xsize])
data_from_vhdl = np.loadtxt("../temp/write_sine_to_file_tb.txt")
d = lcd_plotter.add_plot(d, data_from_vhdl)

lcd_plotter.stream_lcd(d)
