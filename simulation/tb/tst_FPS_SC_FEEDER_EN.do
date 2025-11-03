# Quit any ongoing simulation
quit -sim

# Compile files
vcom  -2008 -work work ../../src/FPS_SC_CODE_MGR.vhd
vcom  -2008 -work work ../../src/FPS_SC_FEEDER_MGR.vhd
vcom  -2008 -work work ../../src/FPS_SC_FEEDER_EN.vhd
vcom  -2008 -work work ../src/FPS_SC_FEEDER_EN_tb.vhd


# Launch simulation
vsim -t ps FPS_SC_FEEDER_EN_tb

do wave_FPS_SC_FEEDER_EN.do

run 2000 ns
wave zoom full