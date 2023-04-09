echo off

FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)

ghdl -a --ieee=synopsys --std=08 %project_root%\pixel_position_counter\pixel_position_counter_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %project_root%\lcd_driver\lcd_driver.vhd

SET source=%project_root%\hVHDL_memory_library
ghdl -a --ieee=synopsys --std=08 %source%/fpga_ram/ram_configuration/ram_configuration_16x1024_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/fpga_ram/ram_read_port_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/fpga_ram/ram_write_port_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/fpga_ram/fpga_dual_port_ram_pkg.vhd
