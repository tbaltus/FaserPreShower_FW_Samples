# cd J:/vhdl_db/trunk/projets/FPS_FaserPreShower/ProbeCard/simulation/etc

# Quit any ongoing simulation
quit -sim

# Compile files
vcom  -2008 -work work ../../exp/FPS_SlowControl.vhd
vcom  -2008 -work work ../../src/FPS_SC_FEEDER.vhd
vcom  -2008 -work work ../src/DPRAM.vhd
vcom  -2008 -work work ../src/FPS_SC_FEEDER_tb.vhd

# Launch simulation
vsim -t ps FPS_SC_FEEDER_tb

do wave_FPS_SC_FEEDER.do

run 200000 ns
wave zoom full