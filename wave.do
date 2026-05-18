onerror {resume}
quietly virtual signal -install /qam16_testbench/dut { /qam16_testbench/dut/axis_tdata_in(31 downto 0)} i_input_data
quietly virtual signal -install /qam16_testbench/dut { /qam16_testbench/dut/axis_tdata_in(63 downto 32)} q_input_data
quietly WaveActivateNextPane {} 0
add wave -noupdate /qam16_testbench/clock
add wave -noupdate /qam16_testbench/reset
add wave -noupdate /qam16_testbench/rx_data_tready
add wave -noupdate /qam16_testbench/rx_data_tvalid
add wave -noupdate /qam16_testbench/rx_data_tdata
add wave -noupdate /qam16_testbench/rx_data_tkeep
add wave -noupdate /qam16_testbench/rx_data_tlast
add wave -noupdate /qam16_testbench/rx_index_tready
add wave -noupdate /qam16_testbench/rx_index_tvalid
add wave -noupdate /qam16_testbench/rx_index_tdata
add wave -noupdate /qam16_testbench/rx_index_tkeep
add wave -noupdate /qam16_testbench/rx_index_tlast
add wave -noupdate /qam16_testbench/rx_generator_state
add wave -noupdate /qam16_testbench/beat_counter
add wave -noupdate /qam16_testbench/transaction_counter
add wave -noupdate /qam16_testbench/dut/reset
add wave -noupdate /qam16_testbench/dut/clock
add wave -noupdate /qam16_testbench/dut/axis_tready_out
add wave -noupdate /qam16_testbench/dut/axis_tvalid_in
add wave -noupdate -radix hexadecimal /qam16_testbench/dut/i_input_data
add wave -noupdate -radix hexadecimal /qam16_testbench/dut/q_input_data
add wave -noupdate /qam16_testbench/dut/axis_tdata_in
add wave -noupdate /qam16_testbench/dut/axis_tkeep_in
add wave -noupdate /qam16_testbench/dut/axis_tlast_in
add wave -noupdate /qam16_testbench/dut/axis_tready_in
add wave -noupdate /qam16_testbench/dut/axis_tvalid_out
add wave -noupdate /qam16_testbench/dut/axis_tdata_out
add wave -noupdate /qam16_testbench/dut/axis_tkeep_out
add wave -noupdate /qam16_testbench/dut/axis_tlast_out
add wave -noupdate /qam16_testbench/dut/axis_tready
add wave -noupdate -childformat {{/qam16_testbench/dut/error_vector_i(0) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(1) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(2) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(3) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(4) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(5) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(6) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(7) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(8) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(9) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(10) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(11) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(12) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(13) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(14) -radix hexadecimal} {/qam16_testbench/dut/error_vector_i(15) -radix hexadecimal}} -expand -subitemconfig {/qam16_testbench/dut/error_vector_i(0) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(1) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(2) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(3) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(4) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(5) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(6) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(7) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(8) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(9) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(10) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(11) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(12) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(13) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(14) {-radix hexadecimal} /qam16_testbench/dut/error_vector_i(15) {-radix hexadecimal}} /qam16_testbench/dut/error_vector_i
add wave -noupdate -childformat {{/qam16_testbench/dut/error_vector_q(0) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(1) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(2) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(3) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(4) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(5) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(6) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(7) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(8) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(9) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(10) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(11) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(12) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(13) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(14) -radix hexadecimal} {/qam16_testbench/dut/error_vector_q(15) -radix hexadecimal}} -expand -subitemconfig {/qam16_testbench/dut/error_vector_q(0) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(1) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(2) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(3) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(4) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(5) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(6) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(7) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(8) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(9) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(10) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(11) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(12) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(13) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(14) {-radix hexadecimal} /qam16_testbench/dut/error_vector_q(15) {-radix hexadecimal}} /qam16_testbench/dut/error_vector_q
add wave -noupdate /qam16_testbench/dut/tvalid_in_pipe0
add wave -noupdate /qam16_testbench/dut/tkeep_in_pipe0
add wave -noupdate /qam16_testbench/dut/tlast_in_pipe0
add wave -noupdate /qam16_testbench/dut/tready_in_pipe0
add wave -noupdate /qam16_testbench/dut/error_vector
add wave -noupdate /qam16_testbench/dut/tvalid_in_pipe1
add wave -noupdate /qam16_testbench/dut/tkeep_in_pipe1
add wave -noupdate /qam16_testbench/dut/tlast_in_pipe1
add wave -noupdate /qam16_testbench/dut/tready_in_pipe1
add wave -noupdate -childformat {{/qam16_testbench/dut/minimum_error_0(0) -radix decimal} {/qam16_testbench/dut/minimum_error_0(1) -radix decimal} {/qam16_testbench/dut/minimum_error_0(2) -radix decimal} {/qam16_testbench/dut/minimum_error_0(3) -radix decimal} {/qam16_testbench/dut/minimum_error_0(4) -radix decimal} {/qam16_testbench/dut/minimum_error_0(5) -radix decimal} {/qam16_testbench/dut/minimum_error_0(6) -radix decimal} {/qam16_testbench/dut/minimum_error_0(7) -radix decimal}} -expand -subitemconfig {/qam16_testbench/dut/minimum_error_0(0) {-radix decimal} /qam16_testbench/dut/minimum_error_0(1) {-radix decimal} /qam16_testbench/dut/minimum_error_0(2) {-radix decimal} /qam16_testbench/dut/minimum_error_0(3) {-radix decimal} /qam16_testbench/dut/minimum_error_0(4) {-radix decimal} /qam16_testbench/dut/minimum_error_0(5) {-radix decimal} /qam16_testbench/dut/minimum_error_0(6) {-radix decimal} /qam16_testbench/dut/minimum_error_0(7) {-radix decimal}} /qam16_testbench/dut/minimum_error_0
add wave -noupdate /qam16_testbench/dut/minimum_index_0
add wave -noupdate /qam16_testbench/dut/tvalid_in_pipe2
add wave -noupdate /qam16_testbench/dut/tkeep_in_pipe2
add wave -noupdate /qam16_testbench/dut/tlast_in_pipe2
add wave -noupdate /qam16_testbench/dut/tready_in_pipe2
add wave -noupdate /qam16_testbench/dut/minimum_error_1
add wave -noupdate /qam16_testbench/dut/minimum_index_1
add wave -noupdate /qam16_testbench/dut/tvalid_in_pipe3
add wave -noupdate /qam16_testbench/dut/tkeep_in_pipe3
add wave -noupdate /qam16_testbench/dut/tlast_in_pipe3
add wave -noupdate /qam16_testbench/dut/tready_in_pipe3
add wave -noupdate /qam16_testbench/dut/minimum_error_2
add wave -noupdate /qam16_testbench/dut/minimum_index_2
add wave -noupdate /qam16_testbench/dut/tvalid_in_pipe4
add wave -noupdate /qam16_testbench/dut/tkeep_in_pipe4
add wave -noupdate /qam16_testbench/dut/tlast_in_pipe4
add wave -noupdate /qam16_testbench/dut/tready_in_pipe4
add wave -noupdate -radix decimal /qam16_testbench/dut/minimum_error
add wave -noupdate /qam16_testbench/dut/minimum_index
add wave -noupdate /qam16_testbench/dut/tvalid_in_pipe5
add wave -noupdate /qam16_testbench/dut/tkeep_in_pipe5
add wave -noupdate /qam16_testbench/dut/tlast_in_pipe5
add wave -noupdate /qam16_testbench/dut/tready_in_pipe5
add wave -noupdate /qam16_testbench/dut/controller_state
add wave -noupdate /qam16_testbench/dut/tvalid_shift_register
add wave -noupdate /qam16_testbench/dut/tdata_shift_register
add wave -noupdate /qam16_testbench/dut/tkeep_shift_register
add wave -noupdate /qam16_testbench/dut/tlast_shift_register
add wave -noupdate /qam16_testbench/dut/shift_register_index
add wave -noupdate /qam16_testbench/dut/current_index
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1025076 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 164
configure wave -valuecolwidth 235
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
WaveRestoreZoom {1014393 ps} {1019314 ps}
