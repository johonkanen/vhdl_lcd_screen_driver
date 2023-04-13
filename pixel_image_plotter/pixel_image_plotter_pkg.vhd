library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.image_configuration_pkg.all;
    use work.lcd_pixel_driver_pkg.all;
    use work.lcd_driver_pkg.all;

    use work.ram_read_port_pkg.all;
    use work.ram_write_port_pkg.all;
    use work.ram_data_width_pkg.all;

package pixel_image_plotter_pkg is


    type pixel_image_plotter_record is record
        pixel_position_counter : pixel_position_counter_record;
        read_port              : ram_read_port_record;
        ram_write_port         : ram_write_port_record;
    end record;

    constant init_pixel_image_plotter : pixel_image_plotter_record := (
         init_pixel_position_counter,
         init_ram_read_port, init_ram_write_port);

    procedure create_pixel_image_plotter (
        signal self : inout pixel_image_plotter_record;
        signal lcd_driver_in : out lcd_driver_input_record;
        lcd_driver_out : in lcd_driver_output_record);

    procedure request_image ( signal self : inout pixel_image_plotter_record);

end package pixel_image_plotter_pkg;
------------------------------
package body pixel_image_plotter_pkg is

------------------------------------------------------------------------
    procedure create_pixel_image_plotter
    (
        signal self : inout pixel_image_plotter_record;
        signal lcd_driver_in : out lcd_driver_input_record;
        lcd_driver_out : in lcd_driver_output_record
    ) is
    begin
        create_pixel_position_counter(self.pixel_position_counter, lcd_driver_is_ready(lcd_driver_out));
        setup_lcd_driver(lcd_driver_in);

        create_ram_read_port(self.read_port);
        create_ram_write_port(self.ram_write_port);

        if pixel_position_is_updated(self.pixel_position_counter) then
            if get_x(self.pixel_position_counter)+1 < x_max then
                request_data_from_ram(self.read_port, get_x(self.pixel_position_counter)+1);
            else
                request_data_from_ram(self.read_port, 0);
            end if;
            if get_y(self.pixel_position_counter) = get_ram_data(self.read_port) then
                transmit_pixel(lcd_driver_in, 1);
            else
                transmit_pixel(lcd_driver_in, 0);
            end if;
        end if;
        
    end create_pixel_image_plotter;

------------------------------------------------------------------------
    procedure request_image
    (
        signal self : inout pixel_image_plotter_record
    ) is
    begin
        request_pixel_counter(self.pixel_position_counter);
        request_data_from_ram(self.read_port, 319);
    end request_image;
------------------------------------------------------------------------

end package body pixel_image_plotter_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
