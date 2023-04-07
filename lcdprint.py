from matplotlib import pyplot as plt
import numpy as np

def lcdprint(data_in):
    scale = 1.25/2.54 #iterated to roughly correct size
    plt.rcParams["figure.figsize"] = [7.344*scale, 4.896*scale]
    plt.rcParams["figure.autolayout"] = True
    plt.imshow(data_in, origin='upper')
    plt.show()

def add_plot(figure, input_buffer, xsize, ysize):
    for y in range(ysize):
        for x in range(xsize):
            if y == input_buffer[x]:
                figure[y,x] = 1.0

    return figure

def create_axes(figure, xsize, ysize):
    for y in range(ysize):
        for x in range(xsize):
            if x == xsize/2 or x == xsize/2+1:
                figure[y,x] = 1.0

    figure[[160]] = np.ones([1,xsize])
    figure[[161]] = np.ones([1,xsize])

    return figure

def testi(data_in, scale, xsize, ysize):
    return  ysize - np.round(data_in * ysize/2 * scale + ysize/2)
