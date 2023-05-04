from lcd_plotter import *
xsize = 480
ysize = 320
lcd_plotter = lcd(xsize,ysize)

d = np.random.rand(ysize, xsize)
lcd_plotter.lcdprint(d)
