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
            if lcd_driver_in.write_is_requested then
                transmit_pixel(f,lcd_driver_in.pixel_to_be_written);
            end if;
        end if; --rising_edge
    end process drive_a_pixel;	


end write_to_file;
------------------------------------------------------------------------
LIBRARY ieee, std; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;
    use std.textio.all;

    use work.lcd_pixel_driver_pkg.all;
    use work.lcd_driver_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity lcd_driver_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of lcd_driver_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 480*320+100;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal pixel_position_counter : pixel_position_counter_record := init_pixel_position_counter;
    signal sinearray : intarray := init_intarray;
    signal has_run : boolean := false;
    signal lcd_driver_in : lcd_driver_input_record := init_lcd_driver;
    signal lcd_driver_out : lcd_driver_output_record := init_lcd_driver_out;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        check(get_x(pixel_position_counter) = xmax and get_y(pixel_position_counter) = ymax, "did not stop at maximum");
        check(has_run, "counter was never started");
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)

        variable pixel_value : integer;

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            create_pixel_position_counter(pixel_position_counter);
            setup_lcd_driver(lcd_driver_in);

            if get_x(pixel_position_counter) = 0 and get_y(pixel_position_counter) = 0 then
                has_run <= true;
            end if;

            if simulation_counter = 15 then
                request_pixel_counter(pixel_position_counter);
            end if;

            if pixel_position_is_updated(pixel_position_counter) then
                if get_y(pixel_position_counter) = sinearray(get_x(pixel_position_counter)) then
                    transmit_pixel(lcd_driver_in, 1);
                else
                    transmit_pixel(lcd_driver_in, 0);
                end if;
            end if;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
    u_lcr_driver : entity work.lcd_driver
    port map(simulator_clock, lcd_driver_in, lcd_driver_out);
------------------------------------------------------------------------
end vunit_simulation;
