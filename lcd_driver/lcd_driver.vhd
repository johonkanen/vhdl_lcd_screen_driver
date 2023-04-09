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
library ieee, std;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.lcd_driver_pkg.all;

entity lcd_driver is
    port (
        clock : in std_logic;
        lcd_driver_in : in lcd_driver_input_record;
        lcd_driver_out : out lcd_driver_output_record 
    );
end entity lcd_driver;


architecture write_to_file of lcd_driver is

    signal delay_counter : integer range 0 to 7 := 0;


begin

    drive_a_pixel : process(clock)
        use std.textio.all;

        file f : text open write_mode is "pixel_image_stream_from_lcd_driver.txt";
        ------------------------------------------------------------------------
        procedure transmit_pixel
        (
            file file_handle : text;
            pixel : in integer
        ) is
            variable row : line;
        begin
            write(row , pixel);
            writeline(file_handle , row);
        end transmit_pixel;
        ------------------------------------------------------------------------
        
    begin
        if rising_edge(clock) then
            lcd_driver_out.pixel_has_been_written <= false;
            if lcd_driver_in.write_is_requested then
                transmit_pixel(f,lcd_driver_in.pixel_to_be_written);
                delay_counter <= 4;
            end if;

            if delay_counter > 0 then
                delay_counter <= delay_counter - 1;
            end if;

            if delay_counter = 1 then
                lcd_driver_out.pixel_has_been_written <= true;
            end if;
        end if; --rising_edge
    end process drive_a_pixel;	


end write_to_file;
