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
    constant simtime_in_clocks : integer := 480*320*8;
    
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
        check(get_x(pixel_position_counter) = xmax and get_y(pixel_position_counter) = ymax, "did not stop at maximum, " & 
        " x = " &  integer'image(get_x(pixel_position_counter)) & 
        " y = " & integer'image(get_y(pixel_position_counter))
        );
        check(has_run, "counter was never started");
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)
    begin
        if rising_edge(simulator_clock) then
            create_pixel_position_counter(pixel_position_counter, lcd_driver_is_ready(lcd_driver_out));
            setup_lcd_driver(lcd_driver_in);

            if pixel_position_is_updated(pixel_position_counter) then
                if get_y(pixel_position_counter) = sinearray(get_x(pixel_position_counter)) then
                    transmit_pixel(lcd_driver_in, 1);
                else
                    transmit_pixel(lcd_driver_in, 0);
                end if;
            end if;

            ------------------------------
            -- simulator configuration
            ------------------------------
            simulation_counter <= simulation_counter + 1;
            if get_x(pixel_position_counter) = 0 and get_y(pixel_position_counter) = 0 then
                has_run <= true;
            end if;

            if simulation_counter = 15 then
                request_pixel_counter(pixel_position_counter);
            end if;
            ------------------------------
        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
    u_lcr_driver : entity work.lcd_driver
    port map(simulator_clock, lcd_driver_in, lcd_driver_out);
------------------------------------------------------------------------
end vunit_simulation;
