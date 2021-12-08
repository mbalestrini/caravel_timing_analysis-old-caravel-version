# Caravel timing analysis test


### Environment variables needed
`PDK_ROOT`

`OPENLANE_ROOT`


## run the default empty caravel with no user project inside 
`make caravel_sta-empty`

## run some custom user project
`make caravel_sta-[NAME_OF_PROJECT_FOLDER]`


## run caravel .spef generation only 
`make caravel_rcx`


## create a new user project
- Create the folder `/user_projects/[NAME_OF_PROJECT_FOLDER]` (you can duplicate `user_projects/empty` to use as a template)
- Add the extra verilog and spef files you need to `/user_projects/[NAME_OF_PROJECT_FOLDER]`
- Create or modify the script file `/user_projects/[NAME_OF_PROJECT_FOLDER]/sta_caravel.tcl` to  use the extra files
- The folder `/user_projects/[NAME_OF_PROJECT_FOLDER]` is going to be mapped to `/project_files`, so use that path in the .tcl script to refer to your extra files (ej: read_verilog /project_files/verilog/user_project_wrapper.v)
- Create or modify the SDC file `/user_projects/[NAME_OF_PROJECT_FOLDER]/caravel.sdc`

## results
caravel spef files in `/caravel/spef`

sta log files in `/results/[NAME_OF_PROJECT_FOLDER]`

---

## some notes
The default script right now only uses the following caravel modules for doing the analysis:
- digital_pll
- mgmt_core
- mgmt_protect
- caravel

It also uses a placeholder for the *chip_io* module that forwards the clock to core_clock:
- [NAME_OF_PROJECT_FOLDER]/verilog/chip_io_PLACEHOLDER.v

Right now is only using the *sky130_fd_sc_hd* cell lib


## TODO

- Confirm that the current mpw-3a tag of the efabless/caravel repository is correct
- Confirm that the default `make rcx-module` from the caravel Makefile is the correct way to generate the missing caravel module's .spef files?  (as the current `make caravel_rcx` is a copy of that script with a minor change)
- Analyze all the warnings to check if there might me some files missing that are really needed or might affect the results
- Make some user_project_wrapper with some identifiable cells to connect the ports of the user area and analyze the input and output delays  
