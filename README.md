# vhdl_lcd_screen_driver
a vhdl project for plotting waveforms to lcd screen 

To run the tests, you need [VUnit](https://github.com/VUnit/vunit) and [GHDL](https://github.com/ghdl/ghdl) and [gtkwave](https://github.com/gtkwave/gtkwave). 

For windows the easiest way to get ghdl and gtkwave is via MSYS2 package manager and vunit can be installed using pip install vunit-hdl. The only configuration you need is an environment variable VUNIT_SIMULATOR with value ghdl and both ghdl and gtkwave need to found from PATH. 

To run the vunit script, run the vunit_run_lcd.py from the temp folder using python ../vunit_run_lcd.py -p 16. The python scripts to plot the pixel images after running the vunit_run_lcd.py script can be found in the python_lcd_tests folder
