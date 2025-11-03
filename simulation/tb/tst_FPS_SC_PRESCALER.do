# Quit any ongoing simulation
quit -sim

# Compile files
vcom  -2008 -work work ../../src/FPS_SC_PRESCALER.vhd
vcom  -2008 -work work ../src/FPS_SC_PRESCALER_tb.vhd

# Launch simulation
vsim -t ps FPS_SC_PRESCALER_tb

do wave_FPS_SC_PRESCALER.do

run 1000 ns
wave zoom full