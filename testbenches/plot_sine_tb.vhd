library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package lcd_pixel_driver_pkg is

    constant xmax : integer := 479;
    constant ymax : integer := 319;

    type pixel_position_counter_record is record
        xpos : integer range 0 to xmax;
        ypos : integer range 0 to ymax;
        is_requested : boolean;
    end record;

    constant init_pixel_position_counter : pixel_position_counter_record := (xmax,ymax, false);
    
    procedure create_pixel_position_counter (
        signal self : inout pixel_position_counter_record);

    procedure request_pixel_counter (
        signal self : out pixel_position_counter_record);

    function get_x ( self : pixel_position_counter_record)
        return integer;
        
    function get_y ( self : pixel_position_counter_record)
        return integer;

    procedure procedure_increment_and_wrap (
        signal number : inout integer;
        wrap_at : in integer);

end package lcd_pixel_driver_pkg;
------------------------------------------------------------------------
package body lcd_pixel_driver_pkg is

    procedure create_pixel_position_counter
    (
        signal self : inout pixel_position_counter_record
    ) is
    begin
        self.is_requested <= false;
        if not ((self.xpos = xmax) and (self.ypos = ymax)) or self.is_requested then
            if self.xpos = xmax then
                procedure_increment_and_wrap(self.ypos, ymax);
            end if;
            procedure_increment_and_wrap(self.xpos, xmax);
        end if;
        
    end create_pixel_position_counter;
------------------------------------------------------------------------
    procedure request_pixel_counter
    (
        signal self : out pixel_position_counter_record
    ) is
    begin
        self.is_requested <= true;
    end request_pixel_counter;
------------------------------------------------------------------------
    function get_x
    (
        self : pixel_position_counter_record
    )
    return integer
    is
    begin
        return self.xpos;
    end get_x;
------------------------------------------------------------------------
    function get_y
    (
        self : pixel_position_counter_record
    )
    return integer
    is
    begin
        return self.ypos;
    end get_y;

    procedure procedure_increment_and_wrap
    (
        signal number : inout integer;
        wrap_at : in integer
    ) is
    begin
        if number < wrap_at then
            number <= number + 1;
        else
            number <= 0;
        end if;
        
    end procedure_increment_and_wrap;

end package body lcd_pixel_driver_pkg;
------------------------------------------------------------------------
LIBRARY ieee, std; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;
    use std.textio.all;

    use work.lcd_pixel_driver_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity plot_sine_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of plot_sine_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 480*320+100;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    constant xmax : integer := 479;
    constant ymax : integer := 319;

    signal pixel_position_counter : pixel_position_counter_record := init_pixel_position_counter;
    signal xpos : natural range 0 to xmax := 0;
    signal ypos : natural range 0 to ymax := 0;

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

        file f : text open write_mode is "lcd_stream_from_vhdl.txt";
        variable row : line;

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            if get_x(pixel_position_counter) = 0 and get_y(pixel_position_counter) = 0 then
                has_run <= true;
            end if;


            create_pixel_position_counter(pixel_position_counter);
            xpos <= get_x(pixel_position_counter);
            ypos <= get_y(pixel_position_counter);

            if simulation_counter = 15 then
                request_pixel_counter(pixel_position_counter);
            end if;

            if simulation_counter < 480 then
                write(row , sinearray(simulation_counter));
                writeline(f , row);
            end if;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
