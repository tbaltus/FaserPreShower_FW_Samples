onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fps_sc_feeder_en_tb/x_nreset
add wave -noupdate /fps_sc_feeder_en_tb/x_clk
add wave -noupdate /fps_sc_feeder_en_tb/x_feeder_req
add wave -noupdate /fps_sc_feeder_en_tb/x_feeder_ack
add wave -noupdate /fps_sc_feeder_en_tb/x_feeder_err
add wave -noupdate /fps_sc_feeder_en_tb/x_req
add wave -noupdate /fps_sc_feeder_en_tb/x_ack
add wave -noupdate /fps_sc_feeder_en_tb/x_err
add wave -noupdate /fps_sc_feeder_en_tb/en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {172838 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 288
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {1077927 ps}
