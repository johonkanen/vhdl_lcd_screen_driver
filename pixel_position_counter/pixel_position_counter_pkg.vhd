library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

package lcd_pixel_driver_pkg is

    constant xmax : integer := 479;
    constant ymax : integer := 319;
    type intarray is array (integer range 0 to 479) of integer;
    function init_intarray return intarray;

    type pixel_position_counter_record is record
        xpos : integer range 0 to xmax;
        ypos : integer range 0 to ymax;
        is_requested : boolean;
        is_updated : boolean;
        is_ready : boolean;
    end record;

    constant init_pixel_position_counter : pixel_position_counter_record := (xmax,ymax, false, false, false);
    
    procedure create_pixel_position_counter (
        signal self : inout pixel_position_counter_record);

    procedure create_pixel_position_counter (
        signal self : inout pixel_position_counter_record;
        calculate : boolean);

    procedure request_pixel_counter (
        signal self : out pixel_position_counter_record);

    function pixel_position_is_updated ( self : pixel_position_counter_record)
        return boolean;

    function get_x ( self : pixel_position_counter_record)
        return integer;
        
    function get_y ( self : pixel_position_counter_record)
        return integer;

    procedure procedure_increment_and_wrap (
        signal number : inout integer;
        wrap_at : in integer);

    function figure_is_ready ( self : pixel_position_counter_record)
        return boolean;


end package lcd_pixel_driver_pkg;
------------------------------------------------------------------------
package body lcd_pixel_driver_pkg is
------------------------------------------------------------------------

    procedure update_position
    (
        signal self : inout pixel_position_counter_record
    ) is
    begin
        if not ((self.xpos = xmax) and (self.ypos = ymax)) or self.is_requested then
            self.is_updated <= true;
            if self.xpos = xmax then
                procedure_increment_and_wrap(self.ypos, ymax);
            end if;
            procedure_increment_and_wrap(self.xpos, xmax);
            if self.ypos = ymax and self.xpos = xmax-1 then
                self.is_ready <= true;
            end if;
        end if;
    end update_position;

    procedure init_flags
    (
        signal self : inout pixel_position_counter_record
    ) is
    begin
        self.is_requested <= false;
        self.is_updated <= false;
        self.is_ready <= false;
    end init_flags;

------------------------------------------------------------------------
    procedure create_pixel_position_counter
    (
        signal self : inout pixel_position_counter_record;
        calculate : boolean
    ) is
    begin
        init_flags(self);
        if self.is_requested or calculate then
            update_position(self);
        end if;
    end create_pixel_position_counter;

    -----

    procedure create_pixel_position_counter
    (
        signal self : inout pixel_position_counter_record
    ) is
    begin
        create_pixel_position_counter(self, true);
        
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
------------------------------------------------------------------------
    function pixel_position_is_updated
    (
        self : pixel_position_counter_record
    )
    return boolean
    is
    begin
        return self.is_updated;
    end pixel_position_is_updated;
------------------------------------------------------------------------

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

    function figure_is_ready
    (
        self : pixel_position_counter_record
    )
    return boolean
    is
    begin
        return self.is_ready;
    end figure_is_ready;

    ------------------------------------------------------------------------
    function init_intarray return intarray
    is
        variable return_value : intarray;
        constant length : real := real(intarray'length);
    begin
        for i in intarray'range loop
            return_value(i) := 320 - integer(round(sin(real(i)/length*3.0*math_pi)*160.0*0.9+160.0));
        end loop;
        return return_value;
        
    end init_intarray;
    ------------------------------------------------------------------------
end package body lcd_pixel_driver_pkg;
