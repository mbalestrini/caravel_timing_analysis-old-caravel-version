CARAVEL_ROOT = $(shell pwd)/caravel
STD_CELL_LIBRARY = sky130_fd_sc_hd
SPECIAL_VOLTAGE_LIBRARY ?= sky130_fd_sc_hvl

OPENLANE_IMAGE_NAME=efabless/openlane:mpw-3a

#RESULTS_PATH = $(shell pwd)/results
# PROJECT_FILES = $(shell pwd)/project_files


caravel_sta-%: caravel_rcx
	echo "\n\033[94mRunning Caravel Timing Analysis\033[0m\n"

	$(eval RESULTS_PATH := $(shell pwd)/results/$*)
	$(eval PROJECT_FILES := $(shell pwd)/user_projects/$*)

	mkdir -p $(RESULTS_PATH)

	docker run -it -v $(PROJECT_FILES):/project_files -v $(RESULTS_PATH):/results -v $(OPENLANE_ROOT):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -v $(CARAVEL_ROOT):/caravel -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(OPENLANE_IMAGE_NAME) \
	sh -c " cd /caravel; sta -exit /project_files/sta_caravel.tcl |& tee /results/sta_$*_$(shell date +%y%m%d_%H%M%S).log" 


caravel_rcx: $(CARAVEL_ROOT)/spef/mgmt_protect.spef $(CARAVEL_ROOT)/spef/caravel.spef $(CARAVEL_ROOT)/spef/mgmt_core.spef $(CARAVEL_ROOT)/spef/digital_pll.spef 


$(CARAVEL_ROOT)/spef/%.spef:

	$(eval RESULTS_PATH := $(shell pwd)/results/caravel)
	
	echo "\n\033[94mGenerating $*.spef\033[0m\n"

	mkdir -p $(CARAVEL_ROOT)/spef
	mkdir -p $(RESULTS_PATH)/tmp

	python3 $(OPENLANE_ROOT)/scripts/mergeLef.py -i $(PDK_ROOT)/sky130A/libs.ref/$(STD_CELL_LIBRARY)/techlef/$(STD_CELL_LIBRARY).tlef $(PDK_ROOT)/sky130A/libs.ref/$(STD_CELL_LIBRARY)/lef/*.lef -o $(RESULTS_PATH)/merged.lef

	echo "\
			read_liberty $(PDK_ROOT)/sky130A/libs.ref/$(STD_CELL_LIBRARY)/lib/$(STD_CELL_LIBRARY)__tt_025C_1v80.lib;\
			read_liberty $(PDK_ROOT)/sky130A/libs.ref/$(SPECIAL_VOLTAGE_LIBRARY)/lib/$(SPECIAL_VOLTAGE_LIBRARY)__tt_025C_3v30.lib;\
			set std_cell_lef /results/merged.lef;\
			if {[catch {read_lef \$$std_cell_lef} errmsg]} {\
					puts stderr \$$errmsg;\
					exit 1;\
			};\
			foreach lef_file [glob /caravel/lef/*.lef] {\
				if {[catch {read_lef \$$lef_file} errmsg]} {\
					puts stderr \$$errmsg;\
					exit 1;\
				}\
			};\
			if {[catch {read_def -order_wires /caravel/def/$*.def} errmsg]} {\
				puts stderr \$$errmsg;\
				exit 1;\
			};\
			set_propagated_clock [all_clocks];\
			set rc_values \"mcon 9.249146E-3,via 4.5E-3,via2 3.368786E-3,via3 0.376635E-3,via4 0.00580E-3\";\
			set vias_rc [split \$$rc_values ","];\
			foreach via_rc \$$vias_rc {\
					set layer_name [lindex \$$via_rc 0];\
					set resistance [lindex \$$via_rc 1];\
					set_layer_rc -via \$$layer_name -resistance \$$resistance;\
			};\
			set_wire_rc -signal -layer met2;\
			set_wire_rc -clock -layer met5;\
			define_process_corner -ext_model_index 0 X;\
			extract_parasitics -ext_model_file ${PDK_ROOT}/sky130A/libs.tech/openlane/rcx_rules.info -corner_cnt 1 -max_res 50 -coupling_threshold 0.1 -cc_model 10 -context_depth 5;\
			write_spef /caravel/spef/$*.spef" > $(RESULTS_PATH)/tmp/or_rcx_$*.tcl

	## Generate Spef file
	docker run -it -v $(PROJECT_FILES):/project_files -v $(RESULTS_PATH):/results -v $(OPENLANE_ROOT):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -v $(CARAVEL_ROOT):/caravel -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(OPENLANE_IMAGE_NAME) \
	sh -c " cd /caravel; openroad -exit /results/tmp/or_rcx_$*.tcl |& tee /results/or_rcx_$*.log" 

	

