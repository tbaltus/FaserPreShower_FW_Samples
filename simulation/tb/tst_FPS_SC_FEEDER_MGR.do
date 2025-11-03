# Quit any ongoing simulation
quit -sim

# Compile files
vcom  -2008 -work work ../src/FPS_SC_FEEDER_MGR_tb.vhd
vcom  -2008 -work work ../../src/FPS_SC_FEEDER_MGR.vhd

# Launch simulation
vsim -t ps FPS_SC_FEEDER_MGR_tb

do wave_FPS_SC_FEEDER_MGR.do

run 1200 ns
wave zoom full