set STD_CELL_LIBRARY sky130_fd_sc_hd
set SPECIAL_VOLTAGE_LIBRARY sky130_fd_sc_hvl


set RESULTS_PATH /results

# Some color
puts "\033\[94m"

set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um;

read_liberty $::env(PDK_ROOT)/sky130A/libs.ref/$STD_CELL_LIBRARY/lib/$STD_CELL_LIBRARY\__tt_025C_1v80.lib;
read_liberty $::env(PDK_ROOT)/sky130A/libs.ref/$SPECIAL_VOLTAGE_LIBRARY/lib/$SPECIAL_VOLTAGE_LIBRARY\__tt_025C_3v30.lib;



read_verilog /project_files/verilog/chip_io_PLACEHOLDER.v;
# read_verilog /project_files/verilog/user_project_wrapper_PLACEHOLDER.v; 

read_verilog /caravel/verilog/gl/gpio_logic_high.v 
read_verilog /caravel/verilog/gl/gpio_control_block.v 
read_verilog /caravel/verilog/gl/storage.v 
read_verilog /caravel/verilog/gl/user_id_programming.v
read_verilog /caravel/verilog/gl/mgmt_protect_hv.v; 
read_verilog /caravel/verilog/gl/mprj_logic_high.v; 
read_verilog /caravel/verilog/gl/mprj2_logic_high.v; 
read_verilog /caravel/verilog/gl/DFFRAM.v; 
read_verilog /caravel/verilog/gl/digital_pll.v; 
read_verilog /caravel/verilog/gl/mgmt_core.v;
read_verilog /caravel/verilog/gl/mgmt_protect.v;
read_verilog /caravel/verilog/gl/caravel.v;

link_design caravel;


for { set i 0}  {$i <= 1} {incr i} {
    read_spef -path gpio_control_bidir_1[$i] /caravel/spef/gpio_control_block.spef;
    read_spef -path gpio_control_bidir_2[$i] /caravel/spef/gpio_control_block.spef;

    read_spef -path gpio_control_bidir_1[$i]/gpio_logic_high /caravel/spef/gpio_logic_high.spef;
    read_spef -path gpio_control_bidir_2[$i]/gpio_logic_high /caravel/spef/gpio_logic_high.spef;
}
for { set i 0}  {$i <= 16} {incr i} {
    read_spef -path gpio_control_in_1[$i] /caravel/spef/gpio_control_block.spef;
    read_spef -path gpio_control_in_2[$i] /caravel/spef/gpio_control_block.spef;

    read_spef -path gpio_control_in_1[$i]/gpio_logic_high /caravel/spef/gpio_logic_high.spef;
    read_spef -path gpio_control_in_1[$i]/gpio_logic_high /caravel/spef/gpio_logic_high.spef;
}


read_spef -path storage /caravel/spef/storage.spef;
read_spef -path user_id_value /caravel/spef/user_id_programming.spef;
read_spef -path soc/soc.soc_mem.mem.SRAM /caravel/spef/mprj_logic_high.spef;
read_spef -path soc/soc.soc_mem.mem.SRAM /caravel/spef/mprj2_logic_high.spef;
read_spef -path soc/soc.soc_mem.mem.SRAM /caravel/spef/DFFRAM.spef;
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



