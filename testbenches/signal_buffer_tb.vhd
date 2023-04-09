library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.lcd_pixel_driver_pkg.all;
    use work.lcd_driver_pkg.all;

    use work.ram_read_port_pkg.all;
    use work.ram_write_port_pkg.all;
    use work.ram_configuration_pkg.all;

package pixel_image_plotter_pkg is

    type pixel_image_plotter_record is record
        pixel_position_counter : pixel_position_counter_record;
        read_port      : ram_read_port_record;
        ram_write_port : ram_write_port_record;
        ram_memory : integer_array(0 to 480 - 1);
    end record;

    constant init_pixel_image_plotter : pixel_image_plotter_record := (
         init_pixel_position_counter,
         init_ram_read_port, init_ram_write_port, (others => 15));

end package pixel_image_plotter_pkg;
------------------------------
package body pixel_image_plotter_pkg is

end package body pixel_image_plotter_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
LIBRARY ieee, std; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;
    use std.textio.all;

    use work.lcd_pixel_driver_pkg.all;
    use work.lcd_driver_pkg.all;

    use work.ram_read_port_pkg.all;
    use work.ram_write_port_pkg.all;
    use work.ram_configuration_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity signal_buffer_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of signal_buffer_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 480*320*8;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal has_run                : boolean                       := false;

    signal pixel_position_counter : pixel_position_counter_record := init_pixel_position_counter;
    signal lcd_driver_in          : lcd_driver_input_record       := init_lcd_driver;
    signal lcd_driver_out         : lcd_driver_output_record      := init_lcd_driver_out;

    signal has_finished : boolean := false;

    signal read_port      : ram_read_port_record  := init_ram_read_port;
    signal ram_write_port : ram_write_port_record := init_ram_write_port;

    signal ram_memory : integer_array(0 to lookup_table_size - 1) := init_ram_data_with_indices;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        -- tests
            check(has_run, "counter was never started");
            check(has_finished, "picture calculation never finished");
            check(get_x(pixel_position_counter) = xmax and get_y(pixel_position_counter) = ymax, 
            "did not stop at maximum, " & 
            " x = " &  integer'image(get_x(pixel_position_counter)) & 
            " y = " & integer'image(get_y(pixel_position_counter))
            );
        --
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

            create_ram_read_port(read_port       , ram_memory);
            create_ram_write_port(ram_write_port , ram_memory);

            if pixel_position_is_updated(pixel_position_counter) then
                request_data_from_ram(read_port, get_x(pixel_position_counter)+1);
                if get_y(pixel_position_counter) = get_ram_data(read_port) then
                    transmit_pixel(lcd_driver_in, 1);
                else
                    transmit_pixel(lcd_driver_in, 0);
                end if;
            end if;

            if simulation_counter = 15 then
                request_data_from_ram(read_port, 10);
            end if;
            ------------------------------
            -- simulator configuration
            ------------------------------
            simulation_counter <= simulation_counter + 1;
            if get_x(pixel_position_counter) = 0 and get_y(pixel_position_counter) = 0 then
                has_run <= true;
            end if;

            if figure_is_ready(pixel_position_counter) then
                has_finished <= figure_is_ready(pixel_position_counter);
            end if;

            if simulation_counter = 15 then
                request_pixel_counter(pixel_position_counter);
                request_data_from_ram(read_port, 319);
            end if;
            ------------------------------
        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
    u_lcd_driver : entity work.lcd_driver
    port map(simulator_clock, lcd_driver_in, lcd_driver_out);
------------------------------------------------------------------------
end vunit_simulation;
