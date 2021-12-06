set STD_CELL_LIBRARY sky130_fd_sc_hd

set RESULTS_PATH /results

set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um;

puts "\033\[94m"
read_liberty $::env(PDK_ROOT)/sky130A/libs.ref/$STD_CELL_LIBRARY/lib/$STD_CELL_LIBRARY\__tt_025C_1v80.lib;\

read_verilog /project_files/verilog/wrapped_hack_soc.v; 
read_verilog /project_files/verilog/wrapped_wishbone_demo.v; 
read_verilog /project_files/verilog/user_project_wrapper.v;
read_verilog /project_files/verilog/chip_io_PLACEHOLDER.v;
# read_verilog ./verilog/gl/chip_io.v; 

read_verilog /caravel/verilog/gl/digital_pll.v; 
read_verilog /caravel/verilog/gl/mgmt_core.v;
read_verilog /caravel/verilog/gl/mgmt_protect.v;
read_verilog /caravel/verilog/gl/caravel.v;
link_design caravel;

read_spef -path mprj/wrapped_hack_soc_6 /project_files/spef/wrapped_hack_soc.spef;
read_spef -path mprj/wrapped_wishbone_demo_13 /project_files/spef/wrapped_wishbone_demo.spef
read_spef -path mprj /project_files/spef/user_project_wrapper.spef;

read_spef -path soc/pll /caravel/spef/digital_pll.spef;
read_spef -path soc /caravel/spef/mgmt_core.spef;
read_spef -path mgmt_buffers /caravel/spef/mgmt_protect.spef;
read_spef /caravel/spef/caravel.spef;



read_sdc -echo /project_files/caravel.sdc;

puts "\033\[0m"


report_checks -fields {capacitance slew input_pins nets fanout} -path_delay min_max -format full_clock_expanded -group_count 20;
# report_checks -fields {capacitance slew input_pins nets fanout} -path_delay min_max -group_count 1000;
# report_check_types -max_slew -max_capacitance -max_fanout -violators;
# report_check_types -max_fanout -violators;

#report_checks -from [get_ports core_clk] -to [get_pins core/core_clk] -fields {slew cap input nets fanout} -format full_clock_expanded;\
#report_checks -from [get_ports core_clk] -to [get_pins DFFRAM/CLK] -fields {slew cap input nets fanout} -format full_clock_expanded;\


write_sdf $RESULTS_PATH/caravel.sdf;



