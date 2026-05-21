library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
use ieee.std_logic_textio.all;

library UNISIM;
use UNISIM.VComponents.all;

package common_parameters is

	constant BACKPRESSURE_DEPTH		: integer := 16;	-- Maximum number of clock cycles between rising edge of tvalid and the rising edge of tready
	constant INPUT_DATA_SAMPLE_RATE	: real := 625.0e+6;	-- Data rate before interpolation
	constant CLOCK_RATE				: real := 250.0e+6;
	constant BINARY_INPUT_DATA_SIZE	: integer := 32;
	constant ENCODED_BIT_SIZE		: integer := 4;
	constant SYMBOL_DATA_SIZE		: integer := 8;
	constant SAMPLES_PER_SYMBOL		: integer := 8;
	constant SYMBOLS_PER_WORD		: integer := BINARY_INPUT_DATA_SIZE/ENCODED_BIT_SIZE;
	constant FIR_SYMBOLS_PER_CLOCK	: integer := 8;

	constant PREAMBLE				: std_logic_vector(BINARY_INPUT_DATA_SIZE-1 downto 0) := x"F0F0F0F0";
	constant TRAINING_PATTERN 		: std_logic_vector(BINARY_INPUT_DATA_SIZE-1 downto 0) := x"DEADBEEF";
	
end package common_parameters;

package body common_parameters is
end package body common_parameters;
