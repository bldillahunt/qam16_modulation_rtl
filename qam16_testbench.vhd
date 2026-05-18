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

entity qam16_testbench is
end entity qam16_testbench;

architecture behavioral of qam16_testbench is
	
	constant CLOCK_PERIOD			: time := 5.0 ns;
	
	constant BUS_WIDTH				: integer := 64;	
	constant DATA_PER_BEAT			: integer := 1;	
	constant INDEX_DATA_SIZE		: integer := 8;
	constant BEAT_COUNT				: integer := 512;
	constant DATA_FILE_SIZE			: integer := 15872;
	constant TOTAL_TRANSACTIONS		: integer := DATA_FILE_SIZE/BEAT_COUNT;

	signal clock					: std_logic := '0';
	signal reset					: std_logic := '1';
	
	signal rx_data_tready			: std_logic;
	signal rx_data_tvalid			: std_logic;
	signal rx_data_tdata			: std_logic_vector(BUS_WIDTH-1 downto 0);
	signal rx_data_tkeep			: std_logic_vector(BUS_WIDTH/8-1 downto 0);
	signal rx_data_tlast			: std_logic;
	signal rx_index_tready			: std_logic;
	signal rx_index_tvalid			: std_logic;
	signal rx_index_tdata			: std_logic_vector(INDEX_DATA_SIZE-1 downto 0);	
	signal rx_index_tkeep			: std_logic_vector(INDEX_DATA_SIZE/8-1 downto 0);
	signal rx_index_tlast			: std_logic;
	
	type rx_generator_state_machine is (IDLE, WAIT_FOR_DUT_READY, END_BUS_TRANSACTION, BUS_IDLE_TIME, WAIT_FOREVER);
	signal rx_generator_state		: rx_generator_state_machine;
	signal beat_counter				: integer;
	signal transaction_counter		: integer;

begin
	
	clock <= not clock after CLOCK_PERIOD/2;
	reset <= '0' after 1.0 us;

	dut : entity work.find_likely_coordinates
	generic map (
		BUS_WIDTH			=> BUS_WIDTH,		-- : integer := 64;			-- Size of data bus
		DATA_PER_BEAT		=> DATA_PER_BEAT,	-- : integer := 1;			-- Number of samples per beat
		INDEX_DATA_SIZE		=> INDEX_DATA_SIZE	-- : integer := 8			-- The number of bits used to store the constellation index
	)
	port map (
		reset				=> reset,				-- : in	std_logic;
		clock				=> clock,				-- : in	std_logic;
		axis_tready_out		=> rx_data_tready	,	-- : out	std_logic;
		axis_tvalid_in		=> rx_data_tvalid	,	-- : in	std_logic;
		axis_tdata_in		=> rx_data_tdata	,	-- : in	std_logic_vector(BUS_WIDTH-1 downto 0);	-- Q is stored in upper bits, I is stored in lower bits, 1 sign, bit, 8 integer bits, 23 fractional bits
		axis_tkeep_in		=> rx_data_tkeep	,	-- : in	std_logic_vector(BUS_WIDTH/8-1 downto 0);
		axis_tlast_in		=> rx_data_tlast	,	-- : in	std_logic;
		axis_tready_in		=> rx_index_tready	,	-- : in	std_logic;
		axis_tvalid_out		=> rx_index_tvalid	,	-- : out	std_logic;
		axis_tdata_out		=> rx_index_tdata	,	-- : out	std_logic_vector(INDEX_DATA_SIZE-1 downto 0);	-- Q is stored in upper bits, I is stored in lower bits
		axis_tkeep_out		=> rx_index_tkeep	,	-- : out	std_logic_vector(INDEX_DATA_SIZE/8-1 downto 0);
		axis_tlast_out		=> rx_index_tlast		-- : out	std_logic
	);

	-- State machine that will read the recovered data from a file and break it up into AXIS bus transactions
	rx_data_generation : process (clock, reset)
		file rx_data_file_i 	: text open read_mode is "rx_complex_data_i.txt";
		file rx_data_file_q 	: text open read_mode is "rx_complex_data_q.txt";
		variable rx_data_line_i	: line;
		variable rx_data_line_q	: line;
		variable hex_data_i		: std_logic_vector(31 downto 0);
		variable hex_data_q		: std_logic_vector(31 downto 0);
	begin
		if (reset = '1') then
			rx_generator_state	<= IDLE;
			rx_data_tvalid		<= '0';
			rx_data_tdata		<= (others => '0');
			rx_data_tkeep		<= (others => '0');
			rx_data_tlast		<= '0';
			rx_index_tready		<= '0';
			beat_counter		<= 0;
			transaction_counter	<= 0;
		elsif (rising_edge(clock)) then
			case (rx_generator_state) is
				when IDLE =>
					readline(rx_data_file_i, rx_data_line_i);
					hread(rx_data_line_i, hex_data_i);
					readline(rx_data_file_q, rx_data_line_q);
					hread(rx_data_line_q, hex_data_q);
										
					rx_data_tvalid		<= '1';
					rx_data_tdata		<= hex_data_q & hex_data_i;
					rx_data_tkeep		<= (others => '1');
					rx_data_tlast		<= '0';
					rx_index_tready		<= '1';
					beat_counter		<= 0;
					rx_generator_state	<= WAIT_FOR_DUT_READY;
				when WAIT_FOR_DUT_READY =>
					if (rx_data_tready = '1') then
						readline(rx_data_file_i, rx_data_line_i);
						hread(rx_data_line_i, hex_data_i);
						readline(rx_data_file_q, rx_data_line_q);
						hread(rx_data_line_q, hex_data_q);

						rx_data_tvalid		<= '1';
						rx_data_tdata		<= hex_data_q & hex_data_i;
						rx_data_tkeep		<= (others => '1');
						
						if (beat_counter < BEAT_COUNT-1) then
							rx_data_tlast		<= '0';
						else
							rx_data_tlast		<= '1';
						end if;
						
						if (beat_counter < BEAT_COUNT-1) then
							beat_counter		<= beat_counter + 1;
						else
							rx_generator_state	<= END_BUS_TRANSACTION;
						end if;
					end if;
				when END_BUS_TRANSACTION =>
					rx_data_tvalid		<= '0';
					rx_data_tdata		<= (others => '0');
					rx_data_tkeep		<= (others => '0');
					rx_data_tlast		<= '0';
--					rx_index_tready		<= '0';
					beat_counter		<= 0;
					
					if (transaction_counter < TOTAL_TRANSACTIONS-1) then
						transaction_counter	<= transaction_counter + 1;
						rx_generator_state	<= BUS_IDLE_TIME;
					else
						rx_generator_state	<= WAIT_FOREVER;
					end if;
				when BUS_IDLE_TIME =>
					rx_generator_state	<= IDLE after 128*CLOCK_PERIOD;
				when WAIT_FOREVER =>
					transaction_counter	<= 0;
					file_close(rx_data_file_i);
					file_close(rx_data_file_q);
				when others =>
					rx_generator_state	<= IDLE;
			end case;
		end if;
	end process;
	
	-- Write the data to a file
	data_output_logic : process (clock)
		file index_data_file 		: text open write_mode is "simulation_index_values.txt";
		variable index_data_line	: line;
	begin
		if (rising_edge(clock)) then
			if (rx_index_tvalid	= '1') and (rx_index_tready = '1') then
				write(index_data_line, to_integer(unsigned(rx_index_tdata)));
				writeline(index_data_file, index_data_line);
			end if;
		end if;
	end process;
end behavioral;
