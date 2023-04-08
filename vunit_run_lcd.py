#!/usr/bin/env python3

from pathlib import Path
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent
VU = VUnit.from_argv()

lcdlibrary = VU.add_library("lcdlibrary")
lcdlibrary.add_source_files(ROOT / "testbenches/plot_sine_tb.vhd")
lcdlibrary.add_source_files(ROOT / "testbenches/pixel_position_counter_tb.vhd")

VU.main()
