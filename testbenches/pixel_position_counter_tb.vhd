------------------------------------------------------------------------
LIBRARY ieee, std; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;
    use std.textio.all;

    use work.image_configuration_pkg.xmax;
    use work.image_configuration_pkg.ymax;
    use work.pixel_position_counter_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity pixel_position_counter_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of pixel_position_counter_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := (xmax + 1)*(ymax + 1)+100;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal pixel_position_counter : pixel_position_counter_record := init_pixel_position_counter;
    signal xpos : natural range 0 to xmax := 0;
    signal ypos : natural range 0 to ymax := 0;

    signal sinearray : intarray := init_intarray;

    signal has_run : boolean := false;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        check(xpos = xmax and ypos = ymax, "did not stop at maximum");
        check(has_run, "counter was never started");
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)

        file f : text open write_mode is "pixel_position_counter_tb.txt";
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

        variable pixel_value : integer;

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            create_pixel_position_counter(pixel_position_counter);

            if pixel_position_is_updated(pixel_position_counter) then
                if get_y(pixel_position_counter) = sinearray(get_x(pixel_position_counter)) then
                    pixel_value := 1;
                else
                    pixel_value := 0;
                end if;
                transmit_pixel(f,pixel_value);
            end if;

            -- test signals
            if simulation_counter = 15 then
                request_pixel_counter(pixel_position_counter);
            end if;

            if get_x(pixel_position_counter) = 0 and get_y(pixel_position_counter) = 0 then
                has_run <= true;
            end if;
            xpos <= get_x(pixel_position_counter);
            ypos <= get_y(pixel_position_counter);

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
