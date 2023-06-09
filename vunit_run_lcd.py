#!/usr/bin/env python3

from pathlib import Path
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent
VU = VUnit.from_argv()

lcdlibrary = VU.add_library("lcdlibrary")

lcdlibrary.add_source_files(ROOT / "hVHDL_fpga_interconnect/interconnect_configuration/data_15_address_15_bit_pkg.vhd")
lcdlibrary.add_source_files(ROOT / "hVHDL_fpga_interconnect/fpga_interconnect_pkg.vhd")

lcdlibrary.add_source_files(ROOT / "image_configuration/image_configuration_pkg.vhd")
lcdlibrary.add_source_files(ROOT / "pixel_position_counter/pixel_position_counter_pkg.vhd")
lcdlibrary.add_source_files(ROOT / "lcd_driver/lcd_driver_pkg.vhd")
lcdlibrary.add_source_files(ROOT / "lcd_driver/lcd_driver.vhd")
lcdlibrary.add_source_files(ROOT / "lcd_driver/lcd_driver_w_bus.vhd")
lcdlibrary.add_source_files(ROOT / "pixel_image_plotter/pixel_image_plotter_pkg.vhd")

lcdlibrary.add_source_files(ROOT / "ram/ram_configuration/data_width_16bit_pkg.vhd")
lcdlibrary.add_source_files(ROOT / "ram/ram_read_port_pkg.vhd")
lcdlibrary.add_source_files(ROOT / "ram/ram_write_port_pkg.vhd")

lcdlibrary.add_source_files(ROOT / "lcd_spi_driver/lcd_spi_driver_pkg.vhd")
lcdlibrary.add_source_files(ROOT / "SPI_driver/clock_divider_pkg.vhd")

lcdlibrary.add_source_files(ROOT / "testbenches/write_sine_to_file_tb.vhd")
lcdlibrary.add_source_files(ROOT / "testbenches/pixel_position_counter_tb.vhd")
lcdlibrary.add_source_files(ROOT / "testbenches/lcd_driver_tb.vhd")
lcdlibrary.add_source_files(ROOT / "testbenches/pixel_image_plotter_tb.vhd")
lcdlibrary.add_source_files(ROOT / "testbenches/lcd_driver_w_bus_tb.vhd")

lcdlibrary.add_source_files(ROOT / "testbenches/lcd_spi_testbenches/lcd_spi_driver_tb.vhd")
lcdlibrary.add_source_files(ROOT / "testbenches/lcd_spi_testbenches/spi_protocol_tb.vhd")

lcdlibrary.add_source_files(ROOT / "testbenches/lcd_spi_testbenches/spi_tb.vhd")

VU.main()
