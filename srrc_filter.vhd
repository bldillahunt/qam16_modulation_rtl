library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
use ieee.std_logic_textio.all;
use work.common_functions.all;
use work.common_parameters.all;
library UNISIM;
use UNISIM.VComponents.all;

entity srrc_filter is
generic (
	BUS_WIDTH			: integer := 160;			-- Size of data bus
	SYMBOL_DATA_SIZE	: integer := 8;				-- Number of samples per beat
	OUTPUT_BUS_SIZE		: integer := 1280;			-- 20 x 64
	FIR_OUPUT_DATA_SIZE	: integer := 62				-- 11 integer bits, 51 fractional bits
);
port (
	reset				: in	std_logic;
	clock				: in	std_logic;
	-- AXIS data input
	-- This data is the result of decimating and rescaling the values coming from the SRRC filter
	axis_tready_out		: out	std_logic;
	axis_tvalid_in		: in	std_logic;
	axis_tdata_in		: in	std_logic_vector(BUS_WIDTH-1 downto 0);	-- Q is stored in upper bits, I is stored in lower bits, 1 sign, bit, 8 integer bits, 23 fractional bits
	axis_tkeep_in		: in	std_logic_vector(BUS_WIDTH/8-1 downto 0);
	axis_tlast_in		: in	std_logic;
	-- AXIS data output
	-- The values in the data bus consist of the constellation index for I and the constellation index of Q
	axis_tready_in		: in	std_logic;
	axis_tvalid_out		: out	std_logic;
	axis_tdata_out		: out	std_logic_vector(OUTPUT_BUS_SIZE-1 downto 0);	-- Q is stored in upper bits, I is stored in lower bits
	axis_tkeep_out		: out	std_logic_vector(OUTPUT_BUS_SIZE/8-1 downto 0);
	axis_tlast_out		: out	std_logic
);
end entity srrc_filter;

architecture struct of srrc_filter is

-- COMPONENTS

	-- Single rate FIR filter, sample rate = 5 GHz, clock = 250 MHz, input size = 8, coefficient size = 52, output size = 62
	COMPONENT srrc_5000_500_norm_coeff
	  PORT (
		aclk : IN STD_LOGIC;
		s_axis_data_tvalid : IN STD_LOGIC;
		s_axis_data_tready : OUT STD_LOGIC;
		s_axis_data_tlast : IN STD_LOGIC;
		s_axis_data_tdata : IN STD_LOGIC_VECTOR(159 DOWNTO 0);
		m_axis_data_tvalid : OUT STD_LOGIC;
		m_axis_data_tready : IN STD_LOGIC;
		m_axis_data_tlast : OUT STD_LOGIC;
		m_axis_data_tdata : OUT STD_LOGIC_VECTOR(1279 DOWNTO 0) 
	  );
	END COMPONENT;


end architecture struct;
