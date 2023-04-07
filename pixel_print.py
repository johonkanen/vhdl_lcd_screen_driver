from lcdprint import lcdprint
from lcdprint import add_plot
from lcdprint import create_axes
from lcdprint import testi
import numpy as np

xsize = 480
ysize = 320

data  = testi(np.sin(np.linspace(0, 3  * np.pi,xsize)),0.9, xsize, ysize)
data2 = testi(np.sin(np.linspace(0, 9  * np.pi,xsize)),0.3, xsize, ysize)
data3 = testi(np.sin(np.linspace(0, 15 * np.pi,xsize)),0.1, xsize, ysize)

d = np.zeros([ysize,xsize])
d = add_plot(d, data, xsize, ysize)
d = add_plot(d, data2, xsize, ysize)
d = add_plot(d, data3, xsize, ysize)

d = create_axes(d, xsize, ysize)
            
lcdprint(d)
