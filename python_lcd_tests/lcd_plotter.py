from matplotlib import pyplot as plt
import numpy as np

class lcd:
    def __init__(self, xsize, ysize):
        self.xsize = xsize
        self.ysize = ysize

    def lcdprint(self, data_in):
        scale = 1.25/2.54 #iterated to roughly correct size
        plt.rcParams["figure.figsize"] = [7.344*scale, 4.896*scale]
        plt.rcParams["figure.autolayout"] = True
        plt.imshow(data_in, origin='upper')
        plt.show()

    def stream_lcd(self, data_in):
        self.lcdprint(np.resize(data_in,[self.ysize, self.xsize])) 

    def stream_from_file_to_lcd(self, filename):
        data_from_file = np.loadtxt(filename)
        self.stream_lcd(data_from_file)

    def add_plot(self, figure, input_buffer):
        for y in range(self.ysize):
            for x in range(self.xsize):
                if y == input_buffer[x]:
                    figure[y,x] = 1.0

        return figure

    def add_axes(figure):
        for y in range(self.ysize):
            for x in range(self.xsize):
                if x == round(self.xsize/2) or x == round(self.xsize/2)+1:
                    figure[y,x] = 1.0

        r_self.ysize = round(self.ysize/2)
        figure[[r_self.ysize]] = np.ones([1,self.xsize])
        figure[[r_self.ysize+1]] = np.ones([1,self.xsize])

        return figure

    def flip_y_axis(self, data_in, scale):
        return  self.ysize - np.round(data_in * self.ysize/2 * scale + self.ysize/2)
