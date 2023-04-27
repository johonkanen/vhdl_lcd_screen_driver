LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

    use work.clock_divider_pkg.all;

package lcd_spi_driver_pkg is

------------------------------------------------------------------------
    type lcd_spi_driver_record is record
        clock_divider          : clock_divider_record          ;
        shift_register         : std_logic_vector(15 downto 0) ;
        out_shift_register     : std_logic_vector(15 downto 0) ;
        spi_data_counter       : integer range 0 to 31         ;
        data_or_command_select : std_logic                     ;
    end record;

    constant init_lcd_spi_driver : lcd_spi_driver_record := (
        init_clock_divider(7) , (others => '0') , (others => '0') , 0 , '0');

------------------------------------------------------------------------
    procedure create_lcd_spi_driver (
        signal self         : inout lcd_spi_driver_record;
        signal spi_clock    : out std_logic;
        spi_data_in         : in std_logic;
        signal spi_data_out : out std_logic;
        signal data_or_command_select : out std_logic);
------------------------------------------------------------------------
    procedure request_spi_command (
        signal self : inout lcd_spi_driver_record;
        data_to_be_transmitted : in std_logic_vector );
------------------------------------------------------------------------
    function spi_is_ready ( self : lcd_spi_driver_record)
        return boolean;

end package lcd_spi_driver_pkg;

package body lcd_spi_driver_pkg is
------------------------------------------------------------------------
    procedure create_lcd_spi_driver
    (
        signal self                   : inout lcd_spi_driver_record;
        signal spi_clock              : out std_logic;
        spi_data_in                   : in std_logic;
        signal spi_data_out           : out std_logic;
        signal data_or_command_select : out std_logic
    ) is
    begin
        create_clock_divider(self.clock_divider);
        spi_clock <= not get_divided_clock(self.clock_divider);

        if data_delivered_on_falling_edge(self.clock_divider) then
            self.shift_register <= self.shift_register(14 downto 0) & spi_data_in;
            spi_data_out <= self.out_shift_register(15);
        end if;

        if data_delivered_on_rising_edge(self.clock_divider) then
            self.out_shift_register <= self.out_shift_register(14 downto 0) & '0';
            self.spi_data_counter <= self.spi_data_counter + 1;
            if self.spi_data_counter mod 8 = 6 then
                data_or_command_select <= self.data_or_command_select;
            else
                data_or_command_select <= '0';
            end if;
        end if;
    end create_lcd_spi_driver;
------------------------------------------------------------------------
    function spi_is_ready
    (
        self : lcd_spi_driver_record
    )
    return boolean
    is
    begin
        return clock_divider_is_ready(self.clock_divider);
    end spi_is_ready;
------------------------------------------------------------------------
    procedure transmit_spi_frame
    (
        signal self : inout lcd_spi_driver_record;
        data_to_be_transmitted : in std_logic_vector 
    ) is
        variable number_of_bits : natural;
        constant left : integer := self.out_shift_register'left;
    begin
        number_of_bits := data_to_be_transmitted'length;
        for i in 0 to number_of_bits-1 loop
            self.out_shift_register(left-i) <= data_to_be_transmitted(number_of_bits-1-i);
        end loop;
        request_clock_divider(self.clock_divider, number_of_bits);
        
    end transmit_spi_frame;
------------------------------------------------------------------------
    procedure request_spi_command
    (
        signal self : inout lcd_spi_driver_record;
        data_to_be_transmitted : in std_logic_vector 
    ) is
    begin
        transmit_spi_frame(self, data_to_be_transmitted);
        self.spi_data_counter <= 0;
        self.data_or_command_select <= '1';
        
    end request_spi_command;

    procedure request_spi_data
    (
        signal self : inout lcd_spi_driver_record;
        data_to_be_transmitted : in std_logic_vector 
    ) is
    begin
        transmit_spi_frame(self, data_to_be_transmitted);
        self.spi_data_counter <= 0;
        self.data_or_command_select <= '1';
        
    end request_spi_data;
------------------------------------------------------------------------

end package body lcd_spi_driver_pkg;
------------------------------------------------------------------------
LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.clock_divider_pkg.all;
    use work.lcd_spi_driver_pkg.all;

entity lcd_spi_driver_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of lcd_spi_driver_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 250;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    constant test_data : std_logic_vector(15 downto 0) := x"00dc";
    signal spi_clock : std_logic := '0';

    signal self : lcd_spi_driver_record := init_lcd_spi_driver;

    signal data_was_received : boolean := false;
    signal spi_data_out : std_logic := '0';

    signal test_data_out : std_logic_vector(15 downto 0) := test_data;
    signal data_or_command_select : std_logic;
begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        check(data_was_received, "data was not received correctly");
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)
    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            create_lcd_spi_driver(self,spi_clock, spi_data_out, spi_data_out, data_or_command_select);

            if spi_is_ready(self) then
                -- check(self.shift_register(15 downto 7) = test_data(7 downto 0), "expected " & to_string(test_data) & " got " & to_string(self.shift_register));
                data_was_received <= true;
            end if;

            if simulation_counter = 15 then 
                request_spi_command(self, test_data(7 downto 0));
            end if;

        end if; -- rising_edge
    end process stimulus;	

------------------------------------------------------------------------
    test_spi : process(spi_clock)
    begin
        if falling_edge(spi_clock) then
            test_data_out <= test_data_out(14 downto 0) & test_data_out(15);
        end if; --rising_edge
    end process test_spi;	
------------------------------------------------------------------------
end vunit_simulation;
