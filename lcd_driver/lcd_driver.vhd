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
