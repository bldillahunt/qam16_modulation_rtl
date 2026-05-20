onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /constellation_testbench/clock
add wave -noupdate /constellation_testbench/reset
add wave -noupdate /constellation_testbench/binary_data_tready
add wave -noupdate /constellation_testbench/binary_data_tvalid
add wave -noupdate /constellation_testbench/binary_data_tdata
add wave -noupdate /constellation_testbench/binary_data_tlast
add wave -noupdate /constellation_testbench/binary_data_tkeep
add wave -noupdate /constellation_testbench/complex_data_tready
add wave -noupdate /constellation_testbench/complex_data_tvalid
add wave -noupdate /constellation_testbench/complex_data_tdata
add wave -noupdate /constellation_testbench/complex_data_tlast
add wave -noupdate /constellation_testbench/complex_data_tkeep
add wave -noupdate /constellation_testbench/data_gen_state
add wave -noupdate /constellation_testbench/dut/reset
add wave -noupdate /constellation_testbench/dut/clock
add wave -noupdate -color Red /constellation_testbench/dut/binary_data_tready
add wave -noupdate -color Cyan -itemcolor Cyan /constellation_testbench/dut/binary_data_tvalid
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /constellation_testbench/dut/binary_data_tdata
add wave -noupdate -color Cyan -itemcolor Cyan /constellation_testbench/dut/binary_data_tlast
add wave -noupdate -color Cyan -itemcolor Cyan /constellation_testbench/dut/binary_data_tkeep
add wave -noupdate -color Cyan -itemcolor Cyan /constellation_testbench/dut/complex_data_tready
add wave -noupdate -color Red /constellation_testbench/dut/complex_data_tvalid
add wave -noupdate -color Red /constellation_testbench/dut/complex_data_tdata
add wave -noupdate -color Red /constellation_testbench/dut/complex_data_tlast
add wave -noupdate -color Red /constellation_testbench/dut/complex_data_tkeep
add wave -noupdate /constellation_testbench/dut/binary_data_tvalid_pipe0
add wave -noupdate -childformat {{/constellation_testbench/dut/complex_data(0) -radix decimal} {/constellation_testbench/dut/complex_data(1) -radix decimal} {/constellation_testbench/dut/complex_data(2) -radix decimal} {/constellation_testbench/dut/complex_data(3) -radix decimal} {/constellation_testbench/dut/complex_data(4) -radix decimal} {/constellation_testbench/dut/complex_data(5) -radix decimal} {/constellation_testbench/dut/complex_data(6) -radix decimal} {/constellation_testbench/dut/complex_data(7) -radix decimal}} -expand -subitemconfig {/constellation_testbench/dut/complex_data(0) {-height 15 -radix decimal} /constellation_testbench/dut/complex_data(1) {-height 15 -radix decimal} /constellation_testbench/dut/complex_data(2) {-height 15 -radix decimal} /constellation_testbench/dut/complex_data(3) {-height 15 -radix decimal} /constellation_testbench/dut/complex_data(4) {-height 15 -radix decimal} /constellation_testbench/dut/complex_data(5) {-height 15 -radix decimal} /constellation_testbench/dut/complex_data(6) {-height 15 -radix decimal} /constellation_testbench/dut/complex_data(7) {-height 15 -radix decimal}} /constellation_testbench/dut/complex_data
add wave -noupdate /constellation_testbench/dut/binary_data_tdata_pipe0
add wave -noupdate /constellation_testbench/dut/binary_data_tlast_pipe0
add wave -noupdate /constellation_testbench/dut/binary_data_tkeep_pipe0
add wave -noupdate /constellation_testbench/dut/constellation_data
add wave -noupdate /constellation_testbench/dut/binary_data_tvalid_pipe1
add wave -noupdate /constellation_testbench/dut/binary_data_tdata_pipe1
add wave -noupdate /constellation_testbench/dut/binary_data_tlast_pipe1
add wave -noupdate /constellation_testbench/dut/binary_data_tkeep_pipe1
add wave -noupdate /constellation_testbench/dut/s_aresetn
add wave -noupdate /constellation_testbench/dut/fifo_input_tready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1090000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 193
configure wave -valuecolwidth 124
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {1211538 ps}
