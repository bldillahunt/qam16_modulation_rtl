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

entity convert_data_to_symbols is
generic (
	INPUT_BUS_SIZE		: integer := 32
);
port (
	reset				: in	std_logic;
	clock				: in	std_logic;
	-- Input data bus contains one sample of 32 bit data
	binary_data_tready	: out	std_logic;
	binary_data_tvalid	: in	std_logic;
	binary_data_tdata	: in	std_logic_vector(INPUT_BUS_SIZE-1 downto 0);
	binary_data_tlast	: in	std_logic;
	binary_data_tkeep	: in	std_logic_vector(INPUT_BUS_SIZE/8-1 downto 0);
	-- Output data consists of signed 8-bit values in groups of eight pairs of I and Q data (I in the lower eight bits, Q in the upper eight bits)
	complex_data_tready	: in	std_logic;
	complex_data_tvalid	: out	std_logic;
	complex_data_tdata	: out	std_logic_vector(SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2-1 downto 0);
	complex_data_tlast	: out	std_logic;
	complex_data_tkeep	: out	std_logic_vector((SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2)/8-1 downto 0)
);
end entity convert_data_to_symbols;

architecture struct of convert_data_to_symbols is
-- CONSTANTS
	constant OUTPUT_DATA_SIZE	: integer := SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2;

-- TYPES

	type complex_data_array is array (0 to SYMBOLS_PER_WORD-1) of complex_iq_data;

-- COMPONENTS
	-- Built-in FIFO, 128 bits, depth = 512
	COMPONENT fifo_128bitsx512
	  PORT (
		s_aclk : IN STD_LOGIC;
		s_aresetn : IN STD_LOGIC;
		s_axis_tvalid : IN STD_LOGIC;
		s_axis_tready : OUT STD_LOGIC;
		s_axis_tdata : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
		s_axis_tkeep : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		s_axis_tlast : IN STD_LOGIC;
		m_axis_tvalid : OUT STD_LOGIC;
		m_axis_tready : IN STD_LOGIC;
		m_axis_tdata : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
		m_axis_tkeep : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		m_axis_tlast : OUT STD_LOGIC 
	  );
	END COMPONENT;

-- SIGNALS
	signal complex_data					: complex_data_array;
	signal binary_data_tvalid_pipe0		: std_logic;
	signal binary_data_tdata_pipe0		: std_logic_vector(INPUT_BUS_SIZE-1 downto 0);
	signal binary_data_tlast_pipe0		: std_logic;
	signal binary_data_tkeep_pipe0		: std_logic_vector(INPUT_BUS_SIZE/8-1 downto 0);
	signal constellation_data			: std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);
	signal binary_data_tvalid_pipe1		: std_logic;
	signal binary_data_tdata_pipe1		: std_logic_vector(INPUT_BUS_SIZE-1 downto 0);
	signal binary_data_tlast_pipe1		: std_logic;
	signal binary_data_tkeep_pipe1		: std_logic_vector(15 downto 0);
	signal s_aresetn					: std_logic;
	signal fifo_input_tready			: std_logic;
	
begin

	symbol_conversion : process (clock)
	begin
		if (rising_edge(clock)) then
			binary_data_tready	<= fifo_input_tready;
			
			if (binary_data_tvalid = '1') then
				for i in 0 to (SYMBOLS_PER_WORD-1) loop
					complex_data(i)	<= qam16_converter(binary_data_tdata(i*4+3 downto i*4));
				end loop;
			else
				for i in 0 to (SYMBOLS_PER_WORD-1) loop
					complex_data(i).i	<= (others => '0');
					complex_data(i).q	<= (others => '0');
				end loop;
			end if;
			
			-- Pipelines
			binary_data_tvalid_pipe0	<= binary_data_tvalid;	
			binary_data_tdata_pipe0		<= binary_data_tdata;	
			binary_data_tlast_pipe0		<= binary_data_tlast;	
			binary_data_tkeep_pipe0		<= binary_data_tkeep;	

			-- Reformat the output data
			if (binary_data_tvalid_pipe0 = '1') then
				for i in 0 to (SYMBOLS_PER_WORD-1) loop
					constellation_data(i*16+15 downto i*16)	<= std_logic_vector(complex_data(i).q) & std_logic_vector(complex_data(i).i);
				end loop;
			else
				constellation_data	<= (others => '0');
			end if;
			
			-- Pipelines
			binary_data_tvalid_pipe1	<= binary_data_tvalid_pipe0;
			binary_data_tdata_pipe1		<= binary_data_tdata_pipe0;	
			binary_data_tlast_pipe1		<= binary_data_tlast_pipe0;	
			binary_data_tkeep_pipe1		<= (others => '1');	
		end if;
	end process;

	s_aresetn	<= not reset;
	
	output_fifo : fifo_128bitsx512
	  PORT MAP (
		s_aclk 			=> clock,
		s_aresetn 		=> s_aresetn,
		s_axis_tvalid 	=> binary_data_tvalid_pipe1,
		s_axis_tready 	=> fifo_input_tready,
		s_axis_tdata 	=> constellation_data,
		s_axis_tkeep 	=> binary_data_tkeep_pipe1,
		s_axis_tlast 	=> binary_data_tlast_pipe1,
		m_axis_tvalid 	=> complex_data_tvalid,	
		m_axis_tready 	=> complex_data_tready,
		m_axis_tdata 	=> complex_data_tdata,	
		m_axis_tkeep 	=> complex_data_tkeep,	
		m_axis_tlast 	=> complex_data_tlast	
	  );

end architecture struct;
