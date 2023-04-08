rem simulate lcd.vhd
echo off

FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)

ghdl -a --ieee=synopsys --std=08 %project_root%\pixel_position_counter\pixel_position_counter_pkg.vhd
