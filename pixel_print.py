from lcdprint import lcdprint
from lcdprint import make_screen_plot
from lcdprint import create_axes
import numpy as np

xsize = 480
ysize = 320

data = 320 - np.round(np.sin(np.linspace(0, 3*np.pi,480))*160*0.9+160)
data2 = 320 - np.round(np.sin(np.linspace(0, 9*np.pi,480))*160*0.3+160)
d = np.zeros([320,480])
d = make_screen_plot(d, data, xsize, ysize)
d = make_screen_plot(d, data2, xsize, ysize)

d = create_axes(d, xsize, ysize)
            
lcdprint(d)
