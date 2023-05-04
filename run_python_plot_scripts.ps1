cd temp
python ../vunit_run_lcd.py -p 16

cd ../python_lcd_tests
start python plot_pixel_position_counter_tb.py
start python plot_lcd_driver_tb.py
start python plot_lcd_driver_w_bus_tb.py
start python plot_multiple_datas.py
start python plot_write_sine_to_file_tb.py
start python test_streaming_from_file.py
cd ..
