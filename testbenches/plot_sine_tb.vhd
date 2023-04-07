LIBRARY ieee, std; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;
    use std.textio.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity plot_sine_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of plot_sine_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 480*320;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    constant x_max : integer := 479;
    constant y_max : integer := 319;

    signal x_pos : natural range 0 to x_max := 0;
    signal y_pos : natural range 0 to 319 := 0;
    type intarray is array (integer range 0 to 479) of integer;

    function init_intarray return intarray
    is
        variable return_value : intarray;
        constant length : real := real(intarray'length);
    begin
        for i in intarray'range loop
            return_value(i) := integer(round(sin(real(i)/length*15.0*math_pi)*160.0*0.9+160.0));
        end loop;
        return return_value;
        
    end init_intarray;

    signal sinearray : intarray := init_intarray;

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

        file f : text open write_mode is "lcd_stream_from_vhdl.txt";
        variable row : line;

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            -- write(row , integer(round(sin(real(simulation_counter)/480.0*15.0*math_pi)*160.0*0.9+160.0)), left, 4);
            if simulation_counter < 480 then
                write(row , sinearray(simulation_counter));
                writeline(f , row);
            end if;


        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
