from lcd_plotter import lcd
import numpy as np

xsize = 480
ysize = 320

lcd_plotter = lcd(xsize,ysize)

data  = lcd_plotter.testi(np.sin(np.linspace(0, 3  * np.pi,xsize)),0.9)
d = np.zeros([ysize,xsize])
d = lcd_plotter.add_plot(d, data)

np.savetxt("test_streaming_from_file.test", np.resize(d, [xsize*ysize]))

lcd_plotter.stream_from_file_to_lcd("test_streaming_from_file.test")
