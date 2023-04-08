#!/usr/bin/env python3

from pathlib import Path
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent
VU = VUnit.from_argv()

lcdlibrary = VU.add_library("lcdlibrary")
lcdlibrary.add_source_files(ROOT / "pixel_position_counter/pixel_position_counter_pkg.vhd")
lcdlibrary.add_source_files(ROOT / "lcd_driver/lcd_driver.vhd")

lcdlibrary.add_source_files(ROOT / "testbenches/plot_sine_tb.vhd")
lcdlibrary.add_source_files(ROOT / "testbenches/pixel_position_counter_tb.vhd")
lcdlibrary.add_source_files(ROOT / "testbenches/lcd_driver_tb.vhd")

VU.main()
