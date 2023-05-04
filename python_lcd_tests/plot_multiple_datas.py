from lcd_plotter import lcd
import numpy as np

xsize = 480
ysize = 320

lcd_plotter = lcd(xsize,ysize)

data  = lcd_plotter.flip_y_axis(np.sin(np.linspace(0 , 3  * np.pi , xsize)) , 0.9)
data2 = lcd_plotter.flip_y_axis(np.sin(np.linspace(0 , 9  * np.pi , xsize)) , 0.3)
data3 = lcd_plotter.flip_y_axis(np.sin(np.linspace(0 , 15 * np.pi , xsize)) , 0.1)
data4 = lcd_plotter.flip_y_axis(np.sin(np.linspace(0 , 21 * np.pi , xsize)) , 0.05)

d = np.zeros([ysize,xsize])
d = lcd_plotter.add_plot(d, data)
d = lcd_plotter.add_plot(d, data2)
d = lcd_plotter.add_plot(d, data3)
d = lcd_plotter.add_plot(d, data4)
d = lcd_plotter.add_plot(d, data+data2+data3+data4-round(3*ysize/2))

lcd_plotter.lcdprint(d)
