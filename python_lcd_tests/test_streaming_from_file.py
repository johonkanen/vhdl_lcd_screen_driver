from lcdprint import lcdprint
from lcdprint import add_plot
from lcdprint import add_axes
from lcdprint import testi
from lcdprint import stream_from_file_to_lcd
import numpy as np

xsize = 480
ysize = 320

data  = testi(np.sin(np.linspace(0, 3  * np.pi,xsize)),0.9, xsize, ysize)
d = np.zeros([ysize,xsize])
d = add_plot(d, data, xsize, ysize)

np.savetxt("test_streaming_from_file.test", np.resize(d, [xsize*ysize]))

stream_from_file_to_lcd("test_streaming_from_file.test", xsize, ysize)
