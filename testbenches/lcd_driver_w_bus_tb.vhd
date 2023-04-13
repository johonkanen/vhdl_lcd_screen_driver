LIBRARY ieee, std; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;
    use std.textio.all;

    use work.fpga_interconnect_pkg.all;
    use work.image_configuration_pkg.all;
    use work.lcd_driver_pkg.all;
    use work.lcd_pixel_driver_pkg.all;

    use work.ram_read_port_pkg.all;
    use work.ram_write_port_pkg.all;

    use work.pixel_image_plotter_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity lcd_driver_w_bus_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of lcd_driver_w_bus_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := x_max*y_max*8;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal has_run                : boolean                       := false;

    signal lcd_driver_in          : lcd_driver_input_record       := init_lcd_driver;
    signal lcd_driver_out         : lcd_driver_output_record      := init_lcd_driver_out;

    signal has_finished : boolean := false;

    signal pixel_image_plotter : pixel_image_plotter_record := init_pixel_image_plotter;
    type std_array is array (integer range <>) of ramtype;
    signal test_ram       : std_array(0 to 1023)  := (others => (15 downto 0 => x"cccc", others => '0'));

    signal bus_from_lcd_driver : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_stimulus : fpga_interconnect_record := init_fpga_interconnect;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        -- tests
            check(has_run, "counter was never started");
            check(has_finished, "picture calculation never finished");
            check(get_x(pixel_image_plotter.pixel_position_counter) = xmax and get_y(pixel_image_plotter.pixel_position_counter) = ymax, 
            "did not stop at maximum, " & 
            " x = " &  integer'image(get_x(pixel_image_plotter.pixel_position_counter)) & 
            " y = " & integer'image(get_y(pixel_image_plotter.pixel_position_counter))
            );
        --
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)
        function get_sine_from_simulation_counter
        (
            counter : integer;
            frequency : real
        )
        return integer
        is
        begin
           return y_max - (integer(round(160.0 + 150.0*sin(real(counter)/real(x_max)*2.0*frequency*math_pi)))); 
        end get_sine_from_simulation_counter;
        alias ram_read_port is pixel_image_plotter.read_port;
        alias ram_write_port is pixel_image_plotter.ram_write_port;


    begin
        if rising_edge(simulator_clock) then

            create_pixel_image_plotter(pixel_image_plotter, lcd_driver_in, lcd_driver_out);
            ------------------------------------------------------------------------
            if ram_read_is_requested(ram_read_port) then
                ram_read_port.read_buffer <= test_ram(get_ram_read_address(ram_read_port));
            end if;

            if write_to_ram_is_requested(ram_write_port) then
                test_ram(ram_write_port.write_address) <= ram_write_port.write_buffer;
            end if;
            ------------------------------------------------------------------------

            if simulation_counter < x_max then
                write_data_to_ram(pixel_image_plotter.ram_write_port,simulation_counter, get_sine_from_simulation_counter(simulation_counter, 10.0));
            end if;

            ------------------------------
            -- simulator configuration
            ------------------------------
            simulation_counter <= simulation_counter + 1;
            if get_x(pixel_image_plotter.pixel_position_counter) = 0 and get_y(pixel_image_plotter.pixel_position_counter) = 0 then
                has_run <= true;
            end if;

            if figure_is_ready(pixel_image_plotter.pixel_position_counter) then
                has_finished <= figure_is_ready(pixel_image_plotter.pixel_position_counter);
            end if;

            if simulation_counter = 15 then
                request_image(pixel_image_plotter);
            end if;
            ------------------------------
        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
    bus_master : process(simulator_clock)
        use std.textio.all;
        file f : text open write_mode is "pixel_image_stream_from_bus_lcd_driver.txt";
        ----------------------------------------------------------------------
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
        ----------------------------------------------------------------------
        
    begin
        if rising_edge(simulator_clock) then
            init_bus(bus_from_stimulus);
            if write_from_bus_is_requested(bus_from_lcd_driver) then
                transmit_pixel(f,get_data(bus_from_lcd_driver));
            end if;

        end if; --rising_edge
    end process bus_master;	
------------------------------------------------------------------------
    u_lcd_driver : entity work.lcd_driver_w_bus
    port map(simulator_clock, lcd_driver_in, lcd_driver_out, bus_from_stimulus, bus_from_lcd_driver);
------------------------------------------------------------------------
end vunit_simulation;
