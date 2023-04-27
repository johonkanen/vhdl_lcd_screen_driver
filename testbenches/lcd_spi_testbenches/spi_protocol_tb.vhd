library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package lcd_spi_protocol_pkg is

    type spi_data_array is array (integer range <>) of std_logic_vector(7 downto 0);

    type lcd_spi_protocol_record is record
        input_data                 : spi_data_array(3 downto 0);
        output_data                : std_logic_vector(7 downto 0);
        frame_has_been_received    : boolean;
        number_of_words_to_receive : integer range 0 to 3;
    end record;

    constant init_lcd_spi_protocol : lcd_spi_protocol_record := ((others => (others => '0')), (others => '0'), false, 0);

------------------------------------------------------------------------
    function get_32_bit_data ( self : lcd_spi_protocol_record)
        return std_logic_vector;
------------------------------------------------------------------------
    function get_24_bit_data ( self : lcd_spi_protocol_record)
        return std_logic_vector;
------------------------------------------------------------------------
    function get_8_bit_data ( self : lcd_spi_protocol_record)
        return std_logic_vector;
------------------------------------------------------------------------

end package lcd_spi_protocol_pkg;

package body lcd_spi_protocol_pkg is

------------------------------------------------------------------------
    procedure create_lcd_spi_protocol
    (
        signal self : inout lcd_spi_protocol_record;
        byte_ready : boolean;
        byte : std_logic_vector(7 downto 0)
    ) is
    begin

        self.frame_has_been_received <= false;
        if byte_ready then
            self.input_data <= self.input_data(2 downto 0) & byte;

            self.number_of_words_to_receive <= self.number_of_words_to_receive - 1;
            if self.number_of_words_to_receive = 1 then
                self.frame_has_been_received <= true;
            end if;
        end if;
        
    end create_lcd_spi_protocol;
------------------------------------------------------------------------
    function get_32_bit_data
    (
        self : lcd_spi_protocol_record
    )
    return std_logic_vector 
    is
    begin
        return self.input_data(0) & self.input_data(1) & self.input_data(2);
    end get_32_bit_data;

------------------------------------------------------------------------
    function get_24_bit_data
    (
        self : lcd_spi_protocol_record
    )
    return std_logic_vector 
    is
    begin
        return self.input_data(0) & self.input_data(1);
    end get_24_bit_data;

------------------------------------------------------------------------
    function get_8_bit_data
    (
        self : lcd_spi_protocol_record
    )
    return std_logic_vector 
    is
    begin
        return self.input_data(0);
    end get_8_bit_data;

end package body lcd_spi_protocol_pkg;
------------------------------------------------------------------------
LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

    use work.lcd_spi_protocol_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity spi_protocol_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of spi_protocol_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 500;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

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


        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
