# Caravel timing analysis test


### Environment variables needed
`PDK_ROOT`

`OPENLANE_ROOT`


## run 
`make caravel_sta`



## run caravel .spef generation only 
`make caravel_rcx`


## results
spef files in `/caravel/spef`

sta log files in `/results`

temp script files in `/results/tmp`

---

## some notes
Right now it only uses the following modules for doing the analysis:
- /carvel/verilog/gl/digital_pll.v
- /carvel/verilog/gl/mgmt_core.v
- /carvel/verilog/gl/mgmt_protect.v
- /carvel/verilog/gl/caravel.v

It also uses a placeholder for the *chip_io* module that forwards the clock to core_clock:
- extra_caravel_files/chip_io_PLACEHOLDER.v

Right now is only using the *sky130_fd_sc_hd* cell lib


