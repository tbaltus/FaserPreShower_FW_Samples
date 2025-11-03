onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider CLK_RESET_SIGNALS
add wave -noupdate /fps_sc_feeder_mgr_tb/FPS_SC_FEEDER_MGR_DUT/x_nreset
add wave -noupdate /fps_sc_feeder_mgr_tb/FPS_SC_FEEDER_MGR_DUT/x_clk
add wave -noupdate -divider FEEDER_SIGNALS
add wave -noupdate /fps_sc_feeder_mgr_tb/FPS_SC_FEEDER_MGR_DUT/x_start
add wave -noupdate /fps_sc_feeder_mgr_tb/FPS_SC_FEEDER_MGR_DUT/x_ack
add wave -noupdate /fps_sc_feeder_mgr_tb/FPS_SC_FEEDER_MGR_DUT/x_err
add wave -noupdate -divider WRAPPER_SIGNALS
add wave -noupdate /fps_sc_feeder_mgr_tb/FPS_SC_FEEDER_MGR_DUT/x_req
add wave -noupdate /fps_sc_feeder_mgr_tb/FPS_SC_FEEDER_MGR_DUT/en
add wave -noupdate -divider OUTPUT
add wave -noupdate /fps_sc_feeder_mgr_tb/FPS_SC_FEEDER_MGR_DUT/x_code
add wave -noupdate -divider STATE
add wave -noupdate /fps_sc_feeder_mgr_tb/FPS_SC_FEEDER_MGR_DUT/sl_int_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {68168 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 415
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
WaveRestoreZoom {0 ps} {379319 ps}
