library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
use ieee.std_logic_textio.all;

library UNISIM;
use UNISIM.VComponents.all;

package common_functions is
	
	function prbs_32bit (seed_value	: in std_logic_vector(31 downto 0)) return std_logic_vector;
	
	type complex_iq_data is record
		i : std_logic_vector(7 downto 0);
		q : std_logic_vector(7 downto 0);
	end record complex_iq_data;
	
	function qam16_converter (nibble_data : in std_logic_vector(3 downto 0)) return complex_iq_data;
	
end package common_functions;

package body common_functions is
	-- PRBS pattern generator
	-- Performs a single shift which means that the calling code must instantiate this for each pattern
	function prbs_32bit (seed_value	: in std_logic_vector(31 downto 0)) return std_logic_vector is
		variable lfsr_shift_register	: std_logic_vector(31 downto 0);	
		variable feedback_bit			: std_logic;
	begin
		feedback_bit		:= (seed_value(31) xor seed_value(21)) xor (seed_value(1) xor seed_value(0));
		lfsr_shift_register := seed_value(seed_value'high-1 downto 0) & feedback_bit;
		return lfsr_shift_register;
	end function prbs_32bit;
	
	-- Convert four bits of binary data to complex number consisting of I and Q values
	function qam16_converter (nibble_data : in std_logic_vector(3 downto 0)) return complex_iq_data is
		variable complex_signal	: complex_iq_data;
	begin
		case (nibble_data) is
			when "0000" => 
				complex_signal.i	:= std_logic_vector(to_signed(-1, 8));
				complex_signal.q	:= std_logic_vector(to_signed(-1, 8));
			when "0001" => 
				complex_signal.i	:= std_logic_vector(to_signed(-1, 8));
				complex_signal.q	:= std_logic_vector(to_signed(-3, 8));
			when "0010" => 
				complex_signal.i	:= std_logic_vector(to_signed(-1, 8));
				complex_signal.q	:= std_logic_vector(to_signed(+1, 8));
			when "0011" => 
				complex_signal.i	:= std_logic_vector(to_signed(-1, 8));
				complex_signal.q	:= std_logic_vector(to_signed(+3, 8));
			when "0100" => 
				complex_signal.i	:= std_logic_vector(to_signed(-3, 8));
				complex_signal.q	:= std_logic_vector(to_signed(-1, 8));
			when "0101" => 
				complex_signal.i	:= std_logic_vector(to_signed(-3, 8));
				complex_signal.q	:= std_logic_vector(to_signed(-3, 8));
			when "0110" => 
				complex_signal.i	:= std_logic_vector(to_signed(-3, 8));
				complex_signal.q	:= std_logic_vector(to_signed(+1, 8));
			when "0111" => 
				complex_signal.i	:= std_logic_vector(to_signed(-3, 8));
				complex_signal.q	:= std_logic_vector(to_signed(+3, 8));
			when "1000" => 
				complex_signal.i	:= std_logic_vector(to_signed(+1, 8));
				complex_signal.q	:= std_logic_vector(to_signed(-1, 8));
			when "1001" => 
				complex_signal.i	:= std_logic_vector(to_signed(+1, 8));
				complex_signal.q	:= std_logic_vector(to_signed(-3, 8));
			when "1010" => 
				complex_signal.i	:= std_logic_vector(to_signed(+1, 8));
				complex_signal.q	:= std_logic_vector(to_signed(+1, 8));
			when "1011" => 
				complex_signal.i	:= std_logic_vector(to_signed(+1, 8));
				complex_signal.q	:= std_logic_vector(to_signed(+3, 8));
			when "1100" => 
				complex_signal.i	:= std_logic_vector(to_signed(+3, 8));
				complex_signal.q	:= std_logic_vector(to_signed(-1, 8));
			when "1101" => 
				complex_signal.i	:= std_logic_vector(to_signed(+3, 8));
				complex_signal.q	:= std_logic_vector(to_signed(-3, 8));
			when "1110" => 
				complex_signal.i	:= std_logic_vector(to_signed(+3, 8));
				complex_signal.q	:= std_logic_vector(to_signed(+1, 8));
			when "1111" => 
				complex_signal.i	:= std_logic_vector(to_signed(+3, 8));
				complex_signal.q	:= std_logic_vector(to_signed(+3, 8));
			when others =>
		end case;
		
		return complex_signal;
	end function qam16_converter;
	
end package body common_functions;
