# cd J:/vhdl_db/trunk/projets/FPS_FaserPreShower/simulation/tb

# Quit any ongoing simulation
quit -sim

# Compile files
vcom  -2008 -work work ../../exp/FPS_SlowControl.vhd
vcom  -2008 -work work ../../src/FPS_SC_SPI.vhd
vcom  -2008 -work work ../src/FPS_SC_SPI_tb.vhd

# Launch simulation
vsim -t ps FPS_SC_SPI_tb

do wave_FPS_SC_SPI.do

run 5500 ns
wave zoom full