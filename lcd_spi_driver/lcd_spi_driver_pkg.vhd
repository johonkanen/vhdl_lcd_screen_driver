library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package spi_pkg is

    type spi_record is record
        clock_counter          : integer;
        number_of_clock_cycles : integer;
        transmit_register      : std_logic_vector(8 downto 0);
        receive_register       : std_logic_vector(31 downto 0);
        read_is_ready          : boolean;
    end record;

    constant spi_counter_max : integer := 50;
    constant init_spi : spi_record := (spi_counter_max, 0, (others => '0'), (others => '0'), false);

    procedure create_spi (
        signal self         : inout spi_record;
        signal spi_clock    : out std_logic;
        signal cs_n         : out std_logic;
        signal spi_data_out : out std_logic;
        signal spi_data_in  : in std_logic);

    procedure transmit_data (
        signal self            : out spi_record;
        data_to_be_sent        : std_logic_vector;
        number_of_clock_cycles : integer);

    procedure read_8_bit_data (
        signal self : out spi_record;
        data_to_be_sent : std_logic_vector);

    procedure read_24_bit_data (
        signal self : out spi_record;
        data_to_be_sent : std_logic_vector);

    procedure read_32_bit_data (
        signal self : out spi_record;
        data_to_be_sent : std_logic_vector);

    function read_is_ready ( self : spi_record)
        return boolean;

    function get_read_data ( self : spi_record)
        return std_logic_vector ;

end package spi_pkg;

------------------------------------------------------------------------
package body spi_pkg is

------------------------------------------------------------------------
    procedure count_and_wrap
    (
        signal counter : inout integer;
        counter_enabled : boolean
    ) is
    begin
        if counter > 1 and counter_enabled then
            counter <= counter - 1;
        else
            counter <= spi_counter_max;
        end if;
        
    end count_and_wrap;
------------------------------------------------------------------------
    procedure create_ready_flag
    (
        signal self : inout spi_record
    ) is
    begin
        self.read_is_ready <= false;
        if self.clock_counter = 1 and self.number_of_clock_cycles = 0 then
            self.read_is_ready <= true;
        end if;
    end create_ready_flag;

------------------------------------------------------------------------
    procedure create_spi
    (
        signal self         : inout spi_record;
        signal spi_clock    : out std_logic;
        signal cs_n         : out std_logic;
        signal spi_data_out : out std_logic;
        signal spi_data_in  : in std_logic
    ) is
    begin

        count_and_wrap(self.clock_counter, self.number_of_clock_cycles > 0);
        create_ready_flag(self);

        if self.clock_counter = 1 and self.number_of_clock_cycles > 0 then
            self.number_of_clock_cycles <= self.number_of_clock_cycles - 1;
        end if;

        if self.clock_counter > spi_counter_max/2 then
            spi_clock <= '1';
        else
            spi_clock <= '0';
        end if;

        spi_data_out <= self.transmit_register(8);
        if self.clock_counter = spi_counter_max/2 then
            self.transmit_register <= self.transmit_register(7 downto 0) & '0';
            self.receive_register <= self.receive_register(30 downto 0) & spi_data_in;
        end if;

        if self.clock_counter > 0 and self.number_of_clock_cycles > 0 then
            cs_n <= '0';
        else
            cs_n <= '1';
        end if;


    end create_spi;
------------------------------------------------------------------------
    procedure transmit_data
    (
        signal self : out spi_record;
        data_to_be_sent : std_logic_vector ;
        number_of_clock_cycles : integer
    ) is
    begin
        self.number_of_clock_cycles <= 8 + number_of_clock_cycles;
        self.transmit_register      <= '0' & data_to_be_sent;
    end transmit_data;
------------------------------------------------------------------------
    procedure read_8_bit_data
    (
        signal self : out spi_record;
        data_to_be_sent : std_logic_vector
    ) is
    begin
        transmit_data(self, data_to_be_sent, 8);
    end read_8_bit_data;

    procedure read_24_bit_data
    (
        signal self : out spi_record;
        data_to_be_sent : std_logic_vector
    ) is
    begin
        transmit_data(self, data_to_be_sent, 24);
    end read_24_bit_data;

    procedure read_32_bit_data
    (
        signal self : out spi_record;
        data_to_be_sent : std_logic_vector
    ) is
    begin
        transmit_data(self, data_to_be_sent, 32);
    end read_32_bit_data;

    function read_is_ready
    (
        self : spi_record
    )
    return boolean
    is
    begin
        return self.read_is_ready;
    end read_is_ready;

    function get_read_data
    (
        self : spi_record
    )
    return std_logic_vector 
    is
    begin
        return self.receive_register;
    end get_read_data;

end package body spi_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
