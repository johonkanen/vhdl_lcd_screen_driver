echo off

FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)

ghdl -a --ieee=synopsys --std=08 %project_root%\hVHDL_fpga_interconnect\interconnect_configuration\data_15_address_15_bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %project_root%\hVHDL_fpga_interconnect\fpga_interconnect_pkg.vhd

ghdl -a --ieee=synopsys --std=08 ram/ram_configuration/data_width_16bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 ram/ram_read_port_pkg.vhd
ghdl -a --ieee=synopsys --std=08 ram/ram_write_port_pkg.vhd

ghdl -a --ieee=synopsys --std=08 %project_root%\image_configuration\image_configuration_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %project_root%\pixel_position_counter\pixel_position_counter_pkg.vhd

ghdl -a --ieee=synopsys --std=08 %project_root%\SPI_driver\clock_divider_pkg.vhd

ghdl -a --ieee=synopsys --std=08 %project_root%\lcd_spi_driver/lcd_spi_driver_pkg.vhd

ghdl -a --ieee=synopsys --std=08 %project_root%\lcd_driver\lcd_driver_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %project_root%\lcd_driver\lcd_driver.vhd
ghdl -a --ieee=synopsys --std=08 %project_root%\lcd_driver\lcd_driver_w_bus.vhd

ghdl -a --ieee=synopsys --std=08 %project_root%\pixel_image_plotter\pixel_image_plotter_pkg.vhd

