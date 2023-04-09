LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.ram_read_port_pkg.all;
    use work.ram_write_port_pkg.all;
    use work.ram_configuration_pkg.all;

entity signal_plot_buffer_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of signal_plot_buffer_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 500;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal read_port      : ram_read_port_record  := init_ram_read_port;
    signal ram_write_port : ram_write_port_record := init_ram_write_port;
    signal ram_memory : integer_array(0 to lookup_table_size - 1) := init_ram_data_with_indices;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            create_ram_read_port(read_port       , ram_memory);
            create_ram_write_port(ram_write_port , ram_memory);

            if simulation_counter = 15 then
                request_data_from_ram(read_port, 10);
            end if;
            if ram_read_is_ready(read_port) then
                check(ram_memory(10) = get_ram_data(read_port), "did not get correct data from ram");
            end if;


        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
