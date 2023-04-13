library ieee, std;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
------------------------------------------------------------------------
package lcd_driver_pkg is

    type lcd_driver_input_record is record
        pixel_to_be_written : integer;
        write_is_requested : boolean;
    end record;

    constant init_lcd_driver : lcd_driver_input_record := (0, false);

    procedure setup_lcd_driver (
        signal self : out lcd_driver_input_record);

    procedure transmit_pixel (
        signal self : out lcd_driver_input_record;
        pixel : in integer);
--------------------------------------------------
--------------------------------------------------
    type lcd_driver_output_record is record
        pixel_has_been_written : boolean;
    end record;

    constant init_lcd_driver_out : lcd_driver_output_record := (pixel_has_been_written => false);

    function lcd_driver_is_ready ( self : lcd_driver_output_record)
        return boolean;

end package lcd_driver_pkg;
--------------------------------------------------
package body lcd_driver_pkg is

    procedure setup_lcd_driver
    (
        signal self : out lcd_driver_input_record
    ) is
    begin
        self.write_is_requested <= false;
    end setup_lcd_driver;

    procedure transmit_pixel
    (
        signal self : out lcd_driver_input_record;
        pixel : in integer
    ) is
    begin
        self.pixel_to_be_written <= pixel;
        self.write_is_requested <= true;
    end transmit_pixel;

    function lcd_driver_is_ready
    (
        self : lcd_driver_output_record
    )
    return boolean
    is
    begin
        return self.pixel_has_been_written;
    end lcd_driver_is_ready;

end package body lcd_driver_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
