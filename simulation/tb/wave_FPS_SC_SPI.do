onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider CLK_RESET_SIGNALS
add wave -noupdate -color white /FPS_SC_SPI_tb/x_nreset
add wave -noupdate -color Yellow /FPS_SC_SPI_tb/x_clk
add wave -noupdate /FPS_SC_SPI_tb/FPS_SC_SPI_dut/sl_int_pulse
add wave -noupdate -divider SPI_SIGNALS
add wave -noupdate -color Orange /FPS_SC_SPI_tb/x_clk_SPI
add wave -noupdate /FPS_SC_SPI_tb/FPS_SC_SPI_dut/sl_int_count
add wave -noupdate -color Pink /FPS_SC_SPI_tb/x_CS
add wave -noupdate -color {Light Green} /FPS_SC_SPI_tb/x_mosi
add wave -noupdate -divider X_REG
add wave -noupdate -color White /FPS_SC_SPI_tb/x_reg
add wave -noupdate -divider START_ACK
add wave -noupdate /FPS_SC_SPI_tb/x_start
add wave -noupdate -color {Cornflower Blue} /FPS_SC_SPI_tb/x_ack
add wave -noupdate -divider STATES
add wave -noupdate /FPS_SC_SPI_tb/FPS_SC_SPI_dut/sl_int_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {360000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 271
configure wave -valuecolwidth 142
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2391004 ps}
