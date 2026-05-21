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

entity interpolate_symbols is
generic (
	FIFO_INPUT_SIZE		: integer := SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*SAMPLES_PER_SYMBOL;
	OUTPUT_DATA_SIZE	: integer := FIR_SYMBOLS_PER_CLOCK*SYMBOL_DATA_SIZE
);
port (
	reset				: in	std_logic;
	clock_input			: in	std_logic;		-- Clock that controls the rate of the symbol data
	clock_output		: in	std_logic;		-- Should be 8 times the frequency of the input clock
	-- Input data consists of signed 8-bit values in groups of eight pairs of I and Q data (I in the lower eight bits, Q in the upper eight bits)
	complex_data_tready	: out	std_logic;
	complex_data_tvalid	: in	std_logic;
	complex_data_tdata	: in	std_logic_vector(SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2-1 downto 0);
	complex_data_tlast	: in	std_logic;
	complex_data_tkeep	: in	std_logic_vector((SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2)/8-1 downto 0);
	-- Interpolated output data. Bus contains eight pairs of I/Q data
	i_data_tready		: in	std_logic;
	i_data_tvalid		: out	std_logic;
	i_data_tdata		: out	std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);
	i_data_tlast		: out	std_logic;
	i_data_tkeep		: out	std_logic_vector(OUTPUT_DATA_SIZE/8-1 downto 0);
	q_data_tready		: in	std_logic;
	q_data_tvalid		: out	std_logic;
	q_data_tdata		: out	std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);
	q_data_tlast		: out	std_logic;
	q_data_tkeep		: out	std_logic_vector(OUTPUT_DATA_SIZE/8-1 downto 0)
);
end entity interpolate_symbols;

architecture struct of interpolate_symbols is
-- CONSTANTS

-- COMPONENTS

	-- Independent clock, asymmetrical FIFO, 512 bits in, 256 deep, 64 bits out
	COMPONENT fifo_512_in_64_out
	  PORT (
		rst 		: IN  STD_LOGIC;
		wr_clk 		: IN  STD_LOGIC;
		rd_clk 		: IN  STD_LOGIC;
		din 		: IN  STD_LOGIC_VECTOR(FIFO_INPUT_SIZE-1 DOWNTO 0);
		wr_en 		: IN  STD_LOGIC;
		rd_en 		: IN  STD_LOGIC;
		dout 		: OUT STD_LOGIC_VECTOR(OUTPUT_DATA_SIZE-1 DOWNTO 0);
		full 		: OUT STD_LOGIC;
		overflow 	: OUT STD_LOGIC;
		empty 		: OUT STD_LOGIC;
		valid 		: OUT STD_LOGIC;
		underflow 	: OUT STD_LOGIC;
		wr_rst_busy : OUT STD_LOGIC;
		rd_rst_busy : OUT STD_LOGIC 
	  );
	END COMPONENT;

	component fifo_to_axis is
		generic(
			DATA_SIZE 		: integer := 512;
			PIPELINE_DEPTH 	: integer := 4
		);
		port(
			reset				: in	std_logic;
			clock				: in	std_logic;
			fifo_read_enable	: out	std_logic;
			fifo_empty			: in	std_logic;
			fifo_full			: in	std_logic;
			fifo_data_out		: in	std_logic_vector(DATA_SIZE-1 downto 0);
			fifo_data_valid		: in	std_logic;
			tready_in			: in	std_logic;
			tvalid_out			: out	std_logic;
			tdata_out			: out	std_logic_vector(DATA_SIZE-1 downto 0);
			tlast_out			: out	std_logic
			);
	end component;
	
	-- FIFO signals
	signal interpolated_data_i		: std_logic_vector(SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*SAMPLES_PER_SYMBOL-1 downto 0);
	signal interpolated_data_q		: std_logic_vector(SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*SAMPLES_PER_SYMBOL-1 downto 0);
	signal fifo_read_enable_i		: std_logic;
	signal fifo_data_out_i			: std_logic_vector(output_data_size-1 downto 0);
	signal fifo_full_i				: std_logic;
	signal fifo_overflow_i			: std_logic;
	signal fifo_empty_i				: std_logic;
	signal fifo_valid_i				: std_logic;
	signal fifo_underflow_i			: std_logic;
	signal fifo_read_enable_q		: std_logic;
	signal fifo_data_out_q			: std_logic_vector(output_data_size-1 downto 0);
	signal fifo_full_q				: std_logic;
	signal fifo_overflow_q			: std_logic;
	signal fifo_empty_q				: std_logic;
	signal fifo_valid_q				: std_logic;
	signal fifo_underflow_q			: std_logic;
	
begin
	
	complex_data_tready	<= '1';
	i_data_tkeep		<= (others => '1');
	q_data_tkeep		<= (others => '1');
	
	data_reformat_fifo_i : fifo_512_in_64_out
	  PORT MAP (
		rst 		=> reset,
		wr_clk 		=> clock_input,
		rd_clk 		=> clock_output,
		din 		=> interpolated_data_i,
		wr_en 		=> complex_data_tvalid,
		rd_en 		=> fifo_read_enable_i,
		dout 		=> fifo_data_out_i,
		full 		=> fifo_full_i,
		overflow 	=> fifo_overflow_i,
		empty 		=> fifo_empty_i,
		valid 		=> fifo_valid_i,
		underflow 	=> fifo_underflow_i,
		wr_rst_busy => open,
		rd_rst_busy => open
	  );

	data_reformat_fifo_q : fifo_512_in_64_out
	  PORT MAP (
		rst 		=> reset,
		wr_clk 		=> clock_input,
		rd_clk 		=> clock_output,
		din 		=> interpolated_data_q,
		wr_en 		=> complex_data_tvalid,
		rd_en 		=> fifo_read_enable_q,
		dout 		=> fifo_data_out_q,
		full 		=> fifo_full_q,
		overflow 	=> fifo_overflow_q,
		empty 		=> fifo_empty_q,
		valid 		=> fifo_valid_q,
		underflow 	=> fifo_underflow_q,
		wr_rst_busy => open,
		rd_rst_busy => open
	  );

	-- Verilog module that is used to interface between a standard FIFO and an AXIS bus
	memory_to_axis_interface_i : fifo_to_axis
	generic map (
		DATA_SIZE 			=> OUTPUT_DATA_SIZE,		-- : integer := 512;
		PIPELINE_DEPTH 		=> 8						-- : integer := 4
	)
	port map (
		reset				=> reset,					-- : in	std_logic;
		clock				=> clock_output,			-- : in	std_logic;
		fifo_read_enable	=> fifo_read_enable_i,		-- : out	std_logic;
		fifo_empty			=> fifo_empty_i,			-- : in	std_logic;
		fifo_full			=> fifo_full_i,				-- : in	std_logic;
		fifo_data_out		=> fifo_data_out_i,			-- : in	std_logic_vector(DATA_SIZE-1 downto 0);
		fifo_data_valid		=> fifo_valid_i,			-- : in	std_logic;
		tready_in			=> i_data_tready,			-- : in	std_logic;
		tvalid_out			=> i_data_tvalid,			-- : out	std_logic;
		tdata_out			=> i_data_tdata,			-- : out	std_logic_vector(DATA_SIZE-1 downto 0);
		tlast_out			=> i_data_tlast				-- : out	std_logic
		);

	memory_to_axis_interface_q : fifo_to_axis
	generic map (
		DATA_SIZE 			=> OUTPUT_DATA_SIZE,		-- : integer := 512;
		PIPELINE_DEPTH 		=> 8						-- : integer := 4
	)
	port map (
		reset				=> reset,					-- : in	std_logic;
		clock				=> clock_output,			-- : in	std_logic;
		fifo_read_enable	=> fifo_read_enable_q,		-- : out	std_logic;
		fifo_empty			=> fifo_empty_q,			-- : in	std_logic;
		fifo_full			=> fifo_full_q,				-- : in	std_logic;
		fifo_data_out		=> fifo_data_out_q,			-- : in	std_logic_vector(DATA_SIZE-1 downto 0);
		fifo_data_valid		=> fifo_valid_q,			-- : in	std_logic;
		tready_in			=> q_data_tready,			-- : in	std_logic;
		tvalid_out			=> q_data_tvalid,			-- : out	std_logic;
		tdata_out			=> q_data_tdata,			-- : out	std_logic_vector(DATA_SIZE-1 downto 0);
		tlast_out			=> q_data_tlast				-- : out	std_logic
		);
	
	-- Pad each symbol with 0s so that there are eight samples per symbol, separate I and Q and swap the words going into the asymmetrical FIFO
	padding_registers : process (complex_data_tdata)
	begin
		for i in 0 to SYMBOLS_PER_WORD-1 loop
--			interpolated_data_i((FIFO_INPUT_SIZE-1)-i*(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD) downto (FIFO_INPUT_SIZE-(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD))-i*(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD)) <= complex_data_tdata(i*2*SYMBOL_DATA_SIZE+SYMBOL_DATA_SIZE-1 downto i*2*SYMBOL_DATA_SIZE) & std_logic_vector(to_unsigned(0, OUTPUT_DATA_SIZE - SYMBOL_DATA_SIZE));
--			interpolated_data_q((FIFO_INPUT_SIZE-1)-i*(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD) downto (FIFO_INPUT_SIZE-(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD))-i*(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD)) <= complex_data_tdata(i*2*SYMBOL_DATA_SIZE+SYMBOL_DATA_SIZE+SYMBOL_DATA_SIZE-1 downto i*2*SYMBOL_DATA_SIZE+SYMBOL_DATA_SIZE) & std_logic_vector(to_unsigned(0, OUTPUT_DATA_SIZE - SYMBOL_DATA_SIZE));
			interpolated_data_i((FIFO_INPUT_SIZE-1)-i*(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD) downto (FIFO_INPUT_SIZE-(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD))-i*(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD)) <= std_logic_vector(to_unsigned(0, OUTPUT_DATA_SIZE - SYMBOL_DATA_SIZE)) & complex_data_tdata(i*2*SYMBOL_DATA_SIZE+SYMBOL_DATA_SIZE-1 downto i*2*SYMBOL_DATA_SIZE);
			interpolated_data_q((FIFO_INPUT_SIZE-1)-i*(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD) downto (FIFO_INPUT_SIZE-(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD))-i*(SYMBOL_DATA_SIZE*SYMBOLS_PER_WORD)) <= std_logic_vector(to_unsigned(0, OUTPUT_DATA_SIZE - SYMBOL_DATA_SIZE)) & complex_data_tdata(i*2*SYMBOL_DATA_SIZE+SYMBOL_DATA_SIZE+SYMBOL_DATA_SIZE-1 downto i*2*SYMBOL_DATA_SIZE+SYMBOL_DATA_SIZE);
		end loop;
	end process;
end architecture struct;
