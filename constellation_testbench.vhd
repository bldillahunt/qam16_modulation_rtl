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

entity constellation_testbench is
end entity constellation_testbench;

architecture behavioral of constellation_testbench is
	
	constant CLOCK_PERIOD			: time := 25.0 ns;
	constant HIGH_SPEED_CLOCK_PERIOD: time := 3.125 ns;
	constant BEATS_PER_BURST		: integer := 256;
	constant BITS_PER_BEAT			: integer := 32;
	constant INTERPACKET_GAP		: time := 32*CLOCK_PERIOD;
	constant OUTPUT_DATA_SIZE		: integer := (SYMBOL_DATA_SIZE*SAMPLES_PER_SYMBOL*SYMBOLS_PER_WORD)/FIR_SYMBOLS_PER_CLOCK;

	signal clock					: std_logic := '0';
	signal reset					: std_logic := '1';
	signal clock_high_speed			: std_logic := '0';
	
	signal binary_data_tready		: std_logic;
	signal binary_data_tvalid		: std_logic;
	signal binary_data_tdata		: std_logic_vector(BITS_PER_BEAT-1 downto 0);
	signal binary_data_tlast		: std_logic;
	signal binary_data_tkeep		: std_logic_vector(BITS_PER_BEAT/8-1 downto 0);
	signal complex_data_tready		: std_logic;
	signal complex_data_tvalid		: std_logic;
	signal complex_data_tdata		: std_logic_vector(SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2-1 downto 0);
	signal complex_data_tlast		: std_logic;
	signal complex_data_tkeep		: std_logic_vector((SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2)/8-1 downto 0);
	
	type data_gen_state_machine is (IDLE, TRANSMIT_PREAMBLE, TRANSMIT_TRAINING_PATTERN, WAIT_FOR_PREAMBLE_TREADY, START_TRANSMITTING_DATA, WAIT_FOR_TREADY, WAIT_FOR_END_OF_BURST, CLEAR_BUS_TRANSACTION);
	signal data_gen_state			: data_gen_state_machine;
	
	signal i_data_tready			: std_logic := '1';
	signal i_data_tvalid			: std_logic;
	signal i_data_tdata				: std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);
	signal i_data_tlast				: std_logic;
	signal i_data_tkeep				: std_logic_vector(OUTPUT_DATA_SIZE/8-1 downto 0);
	signal q_data_tready			: std_logic := '1';
	signal q_data_tvalid			: std_logic;
	signal q_data_tdata				: std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);
	signal q_data_tlast				: std_logic;
	signal q_data_tkeep				: std_logic_vector(OUTPUT_DATA_SIZE/8-1 downto 0);

begin

	clock <= not clock after CLOCK_PERIOD/2;
	reset <= '0' after 1.0 us;
	clock_high_speed <= not clock_high_speed after HIGH_SPEED_CLOCK_PERIOD/2;

	dut_symbols : entity work.convert_data_to_symbols
	generic map (
		INPUT_BUS_SIZE		=> 32						-- : integer := 32
	)
	port map (
		reset				=> reset,					-- : in	std_logic;
		clock				=> clock,					-- : in	std_logic;
		binary_data_tready	=> binary_data_tready	,	-- : out	std_logic;
		binary_data_tvalid	=> binary_data_tvalid	,	-- : in	std_logic;
		binary_data_tdata	=> binary_data_tdata	,	-- : in	std_logic_vector(INPUT_BUS_SIZE-1 downto 0);
		binary_data_tlast	=> binary_data_tlast	,	-- : in	std_logic;
		binary_data_tkeep	=> binary_data_tkeep	,	-- : in	std_logic_vector(INPUT_BUS_SIZE/8-1 downto 0);
		complex_data_tready	=> complex_data_tready	,	-- : in	std_logic;
		complex_data_tvalid	=> complex_data_tvalid	,	-- : out	std_logic;
		complex_data_tdata	=> complex_data_tdata	,	-- : out	std_logic_vector(SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2-1 downto 0);
		complex_data_tlast	=> complex_data_tlast	,	-- : out	std_logic;
		complex_data_tkeep	=> complex_data_tkeep		-- : out	std_logic_vector((SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2)/8-1 downto 0)
	);

	dut_interpolate : entity work.interpolate_symbols
	generic map (
		FIFO_INPUT_SIZE		=> SYMBOL_DATA_SIZE*SAMPLES_PER_SYMBOL*SYMBOLS_PER_WORD,	-- : integer := SYMBOL_DATA_SIZE*SAMPLES_PER_SYMBOL*SYMBOLS_PER_WORD;
		OUTPUT_DATA_SIZE	=> (SYMBOL_DATA_SIZE*SAMPLES_PER_SYMBOL*SYMBOLS_PER_WORD)/FIR_SYMBOLS_PER_CLOCK	-- : integer := (SYMBOL_DATA_SIZE*SAMPLES_PER_SYMBOL*SYMBOLS_PER_WORD)/FIR_SYMBOLS_PER_CLOCK
	)
	port map (
		reset				=> reset,					-- : in	std_logic;
		clock_input			=> clock,					-- : in	std_logic;
		clock_output		=> clock_high_speed,		-- : in	std_logic;
		complex_data_tready	=> complex_data_tready	,	-- : out	std_logic;
		complex_data_tvalid	=> complex_data_tvalid	,	-- : in	std_logic;
		complex_data_tdata	=> complex_data_tdata	,	-- : in	std_logic_vector(SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2-1 downto 0);
		complex_data_tlast	=> complex_data_tlast	,	-- : in	std_logic;
		complex_data_tkeep	=> complex_data_tkeep	,	-- : in	std_logic_vector((SYMBOLS_PER_WORD*SYMBOL_DATA_SIZE*2)/8-1 downto 0);
		i_data_tready		=> i_data_tready,	-- : in	std_logic;
		i_data_tvalid		=> i_data_tvalid,	-- : out	std_logic;
		i_data_tdata		=> i_data_tdata	,	-- : out	std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);
		i_data_tlast		=> i_data_tlast	,	-- : out	std_logic;
		i_data_tkeep		=> i_data_tkeep	,	-- : out	std_logic_vector(OUTPUT_DATA_SIZE/8-1 downto 0);
		q_data_tready		=> q_data_tready,	-- : in	std_logic;
		q_data_tvalid		=> q_data_tvalid,	-- : out	std_logic;
		q_data_tdata		=> q_data_tdata	,	-- : out	std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);
		q_data_tlast		=> q_data_tlast	,	-- : out	std_logic;
		q_data_tkeep		=> q_data_tkeep		-- : out	std_logic_vector(OUTPUT_DATA_SIZE/8-1 downto 0)
	);

	-- Create the data using a PRBS generator
	data_generation : process (reset, clock)
		variable beat_counter			: integer;
		variable current_prbs_pattern	: std_logic_vector(31 downto 0);
	begin
		if (reset = '1') then
			data_gen_state		<= IDLE;
			current_prbs_pattern:= x"FFFFFFFF";
			binary_data_tvalid	<= '0';
			binary_data_tdata	<= (others => '0');
			binary_data_tlast	<= '0';
			binary_data_tkeep	<= (others => '0');
			complex_data_tready	<= '1';
			beat_counter		:= 0;
		elsif (rising_edge(clock)) then
			case (data_gen_state) is
				when IDLE =>
					data_gen_state			<= TRANSMIT_PREAMBLE after 16*CLOCK_PERIOD;
				when TRANSMIT_PREAMBLE =>
					binary_data_tvalid		<= '1';
					binary_data_tdata		<= PREAMBLE;
					binary_data_tlast		<= '0';
					binary_data_tkeep		<= (others => '1');
					
					if (binary_data_tready = '1') then
						beat_counter		:= beat_counter + 1;
						data_gen_state		<= TRANSMIT_TRAINING_PATTERN;
					else
						data_gen_state		<= WAIT_FOR_PREAMBLE_TREADY;
					end if;
				when TRANSMIT_TRAINING_PATTERN =>
					binary_data_tvalid		<= '1';
					binary_data_tdata		<= TRAINING_PATTERN;
					binary_data_tlast		<= '0';
					binary_data_tkeep		<= (others => '1');
					beat_counter			:= beat_counter + 1;
					data_gen_state			<= START_TRANSMITTING_DATA;
				when WAIT_FOR_PREAMBLE_TREADY =>
					if (binary_data_tready = '1') then
						binary_data_tvalid		<= '1';
						binary_data_tdata		<= TRAINING_PATTERN;
						binary_data_tlast		<= '0';
						binary_data_tkeep		<= (others => '1');
						beat_counter			:= beat_counter + 1;
						data_gen_state			<= START_TRANSMITTING_DATA;
					end if;
				when START_TRANSMITTING_DATA =>
					current_prbs_pattern	:= prbs_32bit(current_prbs_pattern);
					binary_data_tvalid		<= '1';
					binary_data_tdata		<= current_prbs_pattern;
					binary_data_tlast		<= '0';
					binary_data_tkeep		<= (others => '1');
					
					if (binary_data_tready = '1') then
						beat_counter		:= beat_counter + 1;
						data_gen_state		<= WAIT_FOR_END_OF_BURST;
					else
						data_gen_state		<= WAIT_FOR_TREADY;
					end if;
				when WAIT_FOR_TREADY =>
					if (binary_data_tready = '1') then
						beat_counter			:= beat_counter + 1;
						current_prbs_pattern	:= prbs_32bit(current_prbs_pattern);
						binary_data_tvalid		<= '1';
						binary_data_tdata		<= current_prbs_pattern;
						binary_data_tlast		<= '0';
						binary_data_tkeep		<= (others => '1');
						data_gen_state			<= WAIT_FOR_END_OF_BURST;
					end if;
				when WAIT_FOR_END_OF_BURST =>
					if (binary_data_tready = '1') then
						if (beat_counter < BEATS_PER_BURST-1) then
							beat_counter		:= beat_counter + 1;
						else
							data_gen_state		<= CLEAR_BUS_TRANSACTION;
						end if;
						
						current_prbs_pattern	:= prbs_32bit(current_prbs_pattern);
						binary_data_tvalid		<= '1';
						binary_data_tdata		<= current_prbs_pattern;
						
						if (beat_counter = BEATS_PER_BURST-1) then
							binary_data_tlast		<= '1';
						else
							binary_data_tlast		<= '0';
						end if;
						
						binary_data_tkeep		<= (others => '1');
					end if;
				when CLEAR_BUS_TRANSACTION =>
					binary_data_tvalid	<= '0';
					binary_data_tdata	<= (others => '0');
					binary_data_tlast	<= '0';
					binary_data_tkeep	<= (others => '0');
					beat_counter		:= 0;
					data_gen_state		<= START_TRANSMITTING_DATA after INTERPACKET_GAP;
				when others =>
					data_gen_state		<= IDLE;
			end case;
		end if;
	end process;
	
	-- Print output data to a file
	file_output : process (clock)
		file constellation_file	: text open write_mode is "constellation_data.txt";
		variable constellation_line : line;
	begin
		if (rising_edge(clock)) then
			if (complex_data_tready = '1') and (complex_data_tvalid = '1') then
				write(constellation_line, string'("["));
				for i in 0 to SYMBOLS_PER_WORD-1 loop
					write(constellation_line, string'("("));
--					if (to_integer(signed(complex_data_tdata(i*16+7 downto i*16))) > 0) then
--						write(constellation_line, string'("+"));
--					end if;
					write(constellation_line, to_integer(signed(complex_data_tdata(i*16+7 downto i*16))));
--					write(constellation_line, ' ');
					if (to_integer(signed(complex_data_tdata(i*16+15 downto i*16+8))) > 0) then
						write(constellation_line, string'("+"));
					end if;
					write(constellation_line, to_integer(signed(complex_data_tdata(i*16+15 downto i*16+8))));
					write(constellation_line, string'("j"));
					
					if (i < SYMBOLS_PER_WORD-1) then
						write(constellation_line, string'("),"));
						write(constellation_line, ' ');
					else
						write(constellation_line, string'(")"));
					end if;
				end loop;
				write(constellation_line, string'("]"));
				
				writeline(constellation_file, constellation_line);
			end if;
		end if;
	end process;
end behavioral;
