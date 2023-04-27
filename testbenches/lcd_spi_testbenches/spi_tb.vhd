LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

    use work.spi_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity spi_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of spi_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 5000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal self               : spi_record := init_spi;
    signal spi_clock          : std_logic := '1';
    signal clock_was_detected : boolean := false;
    signal clock_counter      : integer := 0;
    signal cs_n               : std_logic := '1';
    signal sdo : std_logic;
    signal capture_register : std_logic_vector(7 downto 0);

    signal sdi : std_logic;
    signal received_data_buffer : std_logic_vector(31+8 downto 0) := x"00" & x"acdcabba";

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        check(clock_was_detected, "clock was not detected");
        -- check(clock_counter = 8, "clock ran too many times, expected 8, got " & integer'image(clock_counter));
        -- check(self.receive_register = x"acdcabba", "did not get acdcabba");
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)
    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            create_spi(self, spi_clock, cs_n, sdo, sdi);
            if simulation_counter = 15 then
                read_32_bit_data(self, x"ac");
            end if;

            if read_is_ready(self) then
                check(get_read_data(self) = x"acdcabba", "did not get acdcabba");
            end if;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------

    sdi <= received_data_buffer(received_data_buffer'left);

    spi_receiver : process(spi_clock)
    begin
        if rising_edge(spi_clock) then
            clock_counter <= clock_counter + 1;
            clock_was_detected <= true;
            capture_register <= capture_register(6 downto 0) & sdo;
        end if; --rising_edge
    end process spi_receiver;	
    spi_transmitter : process(spi_clock)
        
    begin
        if falling_edge(spi_clock) then
            received_data_buffer <= received_data_buffer(30+8 downto 0) & '0';
        end if; --rising_edge
    end process spi_transmitter;	
------------------------------------------------------------------------
end vunit_simulation;
