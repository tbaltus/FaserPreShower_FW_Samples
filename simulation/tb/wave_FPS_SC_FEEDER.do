onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color white /fps_sc_feeder_tb/x_nreset
add wave -noupdate -color Yellow /fps_sc_feeder_tb/x_clk
add wave -noupdate -divider DPRAM
add wave -noupdate -color {Cornflower Blue} -radix unsigned /fps_sc_feeder_tb/x_wraddress
add wave -noupdate /fps_sc_feeder_tb/x_wr
add wave -noupdate -color Pink -radix unsigned /fps_sc_feeder_tb/x_data
add wave -noupdate -color {Light Blue} -radix unsigned /fps_sc_feeder_tb/x_rdaddress
add wave -noupdate /fps_sc_feeder_tb/x_q
add wave -noupdate -divider WRAPPER
add wave -noupdate -color Magenta /fps_sc_feeder_tb/C_FPS_SC_FEEDER/x_start
add wave -noupdate -color White /fps_sc_feeder_tb/C_FPS_SC_FEEDER/x_ack
add wave -noupdate -color {Cornflower Blue} /fps_sc_feeder_tb/x_err
add wave -noupdate /fps_sc_feeder_tb/C_FPS_SC_FEEDER/x_valid_word
add wave -noupdate -divider SPI
add wave -noupdate -color Cyan /fps_sc_feeder_tb/C_FPS_SC_FEEDER/x_spi_req
add wave -noupdate -color {Dark Orange} /fps_sc_feeder_tb/C_FPS_SC_FEEDER/x_spi_reg
add wave -noupdate /fps_sc_feeder_tb/C_FPS_SC_FEEDER/x_spi_ack
add wave -noupdate -divider INTERNAL_SIGNALS
add wave -noupdate -color {Light Yellow} /fps_sc_feeder_tb/C_FPS_SC_FEEDER/sl_int_state
add wave -noupdate -color Silver /fps_sc_feeder_tb/C_FPS_SC_FEEDER/sl_int_programming_count
add wave -noupdate /fps_sc_feeder_tb/x_sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {189862895 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 473
configure wave -valuecolwidth 240
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
WaveRestoreZoom {189405032 ps} {190422803 ps}
