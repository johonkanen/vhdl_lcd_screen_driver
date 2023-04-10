library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package image_configuration_pkg is
    constant x_max : integer := 480;
    constant y_max : integer := 320;

    constant xmax : integer := 480 - 1;
    constant ymax : integer := 320 - 1;

end package image_configuration_pkg;
