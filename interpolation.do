onerror {resume}
quietly virtual signal -install /constellation_testbench/dut_interpolate { /constellation_testbench/dut_interpolate/complex_data_tdata(7 downto 0)} I0_data
quietly virtual signal -install /constellation_testbench/dut_interpolate { /constellation_testbench/dut_interpolate/complex_data_tdata(15 downto 8)} Q0_data
quietly virtual signal -install /constellation_testbench/dut_interpolate { /constellation_testbench/dut_interpolate/complex_data_tdata(23 downto 16)} I1_data
quietly virtual signal -install /constellation_testbench/dut_interpolate { /constellation_testbench/dut_interpolate/complex_data_tdata(31 downto 24)} Q1_data
quietly virtual signal -install /constellation_testbench/dut_interpolate { /constellation_testbench/dut_interpolate/i_data_tdata(7 downto 0)} I0_output
quietly virtual signal -install /constellation_testbench/dut_interpolate { /constellation_testbench/dut_interpolate/i_data_tdata(15 downto 8)} Q0_output
quietly virtual signal -install /constellation_testbench/dut_interpolate { /constellation_testbench/dut_interpolate/q_data_tdata(7 downto 0)} Q0_output001
quietly WaveActivateNextPane {} 0
add wave -noupdate /constellation_testbench/clock
add wave -noupdate /constellation_testbench/reset
add wave -noupdate /constellation_testbench/clock_high_speed
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
add wave -noupdate /constellation_testbench/i_data_tready
add wave -noupdate /constellation_testbench/i_data_tvalid
add wave -noupdate /constellation_testbench/i_data_tdata
add wave -noupdate /constellation_testbench/i_data_tlast
add wave -noupdate /constellation_testbench/i_data_tkeep
add wave -noupdate /constellation_testbench/q_data_tready
add wave -noupdate /constellation_testbench/q_data_tvalid
add wave -noupdate /constellation_testbench/q_data_tdata
add wave -noupdate /constellation_testbench/q_data_tlast
add wave -noupdate /constellation_testbench/q_data_tkeep
add wave -noupdate /constellation_testbench/dut_symbols/reset
add wave -noupdate /constellation_testbench/dut_symbols/clock
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tready
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tvalid
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tdata
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tlast
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tkeep
add wave -noupdate /constellation_testbench/dut_symbols/complex_data_tready
add wave -noupdate /constellation_testbench/dut_symbols/complex_data_tvalid
add wave -noupdate /constellation_testbench/dut_symbols/complex_data_tdata
add wave -noupdate /constellation_testbench/dut_symbols/complex_data_tlast
add wave -noupdate /constellation_testbench/dut_symbols/complex_data_tkeep
add wave -noupdate /constellation_testbench/dut_symbols/complex_data
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tvalid_pipe0
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tdata_pipe0
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tlast_pipe0
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tkeep_pipe0
add wave -noupdate /constellation_testbench/dut_symbols/constellation_data
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tvalid_pipe1
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tdata_pipe1
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tlast_pipe1
add wave -noupdate /constellation_testbench/dut_symbols/binary_data_tkeep_pipe1
add wave -noupdate /constellation_testbench/dut_symbols/s_aresetn
add wave -noupdate /constellation_testbench/dut_symbols/fifo_input_tready
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/reset
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/clock_input
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/clock_output
add wave -noupdate -color Red -itemcolor Tan /constellation_testbench/dut_interpolate/complex_data_tready
add wave -noupdate -color Cyan -itemcolor Cyan /constellation_testbench/dut_interpolate/complex_data_tvalid
add wave -noupdate -radix decimal /constellation_testbench/dut_interpolate/I0_data
add wave -noupdate -radix decimal /constellation_testbench/dut_interpolate/Q0_data
add wave -noupdate -radix decimal /constellation_testbench/dut_interpolate/I1_data
add wave -noupdate -radix decimal /constellation_testbench/dut_interpolate/Q1_data
add wave -noupdate -color Cyan -itemcolor Cyan /constellation_testbench/dut_interpolate/complex_data_tdata
add wave -noupdate -color Cyan -itemcolor Cyan /constellation_testbench/dut_interpolate/complex_data_tlast
add wave -noupdate -color Cyan -itemcolor Cyan /constellation_testbench/dut_interpolate/complex_data_tkeep
add wave -noupdate -color Cyan -itemcolor Cyan /constellation_testbench/dut_interpolate/i_data_tready
add wave -noupdate -color Red -itemcolor Tan /constellation_testbench/dut_interpolate/i_data_tvalid
add wave -noupdate -radix decimal /constellation_testbench/dut_interpolate/I0_output
add wave -noupdate -color Red -itemcolor Tan /constellation_testbench/dut_interpolate/i_data_tdata
add wave -noupdate -color Red -itemcolor Tan /constellation_testbench/dut_interpolate/i_data_tlast
add wave -noupdate -color Red -itemcolor Tan /constellation_testbench/dut_interpolate/i_data_tkeep
add wave -noupdate -color Cyan -itemcolor Cyan /constellation_testbench/dut_interpolate/q_data_tready
add wave -noupdate -color Red -itemcolor Tan /constellation_testbench/dut_interpolate/q_data_tvalid
add wave -noupdate -radix decimal /constellation_testbench/dut_interpolate/Q0_output001
add wave -noupdate -color Red -itemcolor Tan -subitemconfig {/constellation_testbench/dut_interpolate/q_data_tdata(63) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(62) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(61) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(60) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(59) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(58) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(57) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(56) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(55) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(54) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(53) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(52) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(51) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(50) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(49) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(48) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(47) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(46) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(45) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(44) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(43) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(42) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(41) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(40) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(39) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(38) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(37) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(36) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(35) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(34) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(33) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(32) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(31) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(30) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(29) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(28) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(27) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(26) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(25) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(24) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(23) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(22) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(21) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(20) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(19) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(18) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(17) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(16) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(15) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(14) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(13) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(12) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(11) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(10) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(9) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(8) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(7) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(6) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(5) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(4) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(3) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(2) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(1) {-color Red -itemcolor Tan} /constellation_testbench/dut_interpolate/q_data_tdata(0) {-color Red -itemcolor Tan}} /constellation_testbench/dut_interpolate/q_data_tdata
add wave -noupdate -color Red -itemcolor Tan /constellation_testbench/dut_interpolate/q_data_tlast
add wave -noupdate -color Red -itemcolor Tan /constellation_testbench/dut_interpolate/q_data_tkeep
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/interpolated_data_i
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/interpolated_data_q
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_read_enable_i
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_data_out_i
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_full_i
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_overflow_i
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_empty_i
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_valid_i
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_underflow_i
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_read_enable_q
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_data_out_q
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_full_q
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_overflow_q
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_empty_q
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_valid_q
add wave -noupdate -color Tan -itemcolor Tan /constellation_testbench/dut_interpolate/fifo_underflow_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1606675 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 188
configure wave -valuecolwidth 135
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
WaveRestoreZoom {1767188 ps} {1773945 ps}
