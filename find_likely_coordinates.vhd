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

entity find_likely_coordinates is
generic (
	BUS_WIDTH			: integer := 64;			-- Size of data bus
	DATA_PER_BEAT		: integer := 1;				-- Number of samples per beat
	INDEX_DATA_SIZE		: integer := 8				-- The number of bits used to store the constellation index
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
	axis_tdata_out		: out	std_logic_vector(INDEX_DATA_SIZE-1 downto 0);	-- Q is stored in upper bits, I is stored in lower bits
	axis_tkeep_out		: out	std_logic_vector(INDEX_DATA_SIZE/8-1 downto 0);
	axis_tlast_out		: out	std_logic
);
end entity find_likely_coordinates;

architecture struct of find_likely_coordinates is

	-- From Python code:
	-- constellation_data = [(-1-1j), (-1-3j), (-1+1j), (-1+3j), (-3-1j), (-3-3j), (-3+1j), (-3+3j), (1-1j), (1-3j), (1+1j), (1+3j), (3-1j),	(3-3j),	(3+1j),	(3+3j)]
	type constellation_array is array (0 to 1, 0 to 15) of signed(31 downto 0);
	type tdata_shift_register_array is array (0 to BACKPRESSURE_DEPTH-1) of std_logic_vector(INDEX_DATA_SIZE-1 downto 0);
	type tkeep_shift_register_array is array (0 to BACKPRESSURE_DEPTH-1) of std_logic_vector(INDEX_DATA_SIZE/8-1 downto 0);
	type error_vector_array is array (natural range <>) of signed(31 downto 0);
	type minimum_error_array is array (natural range <>) of signed(31 downto 0); 
	type minimum_index_array is array (natural range <>) of integer;
	type controller_state_machine is (IDLE, MANAGE_BACK_PRESSURE, WAIT_FOR_END_OF_DATA, END_OF_BUS_TRANSACTION, WAIT_FOR_BUS_CLEAR);
	type tkeep_pipeline_array is array (natural range <>) of std_logic_vector(BUS_WIDTH/8-1 downto 0);
	type sum_of_squares_array is array (0 to 15) of unsigned(63 downto 0);
	type sum_of_squares_reduced_array is array (0 to 15) of std_logic_vector(47 downto 0);
	type error_magnitude_array is array (0 to 15) of std_logic_vector(31 downto 0);
	type minimum_error_magnitude_array is array (natural range <>) of unsigned(24 downto 0);
	type minimum_error_index_array is array (natural range <>) of integer;
	type square_diff_array is array (0 to 15) of std_logic_vector(31 downto 0);
	type square_diff_product_array is array (0 to 15) of std_logic_vector(63 downto 0);
	
	constant FRACTIONAL_BITS			: integer := 23;
	constant INTEGER_BITS				: integer := 9;		-- 1 sign bit, 8 integer bits
	constant DATA_BIT_SIZE				: integer := INTEGER_BITS + FRACTIONAL_BITS;
	constant CONSTELLATION_DATA			: constellation_array := ((
																   to_signed(-1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+3*2**FRACTIONAL_BITS, DATA_BIT_SIZE)								   
																  ),
																  (
																   to_signed(-1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(-3*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+1*2**FRACTIONAL_BITS, DATA_BIT_SIZE),
																   to_signed(+3*2**FRACTIONAL_BITS, DATA_BIT_SIZE)								   
																  ));

	constant STAGE_1_PIPELINE_SIZE	: integer := 6;
	constant STAGE_3_PIPELINE_SIZE	: integer := 26;
	
-- COMPONENTS

	-- Pipeline depth = 6, type = DSP
	COMPONENT multiplier_32x32_signed
	  PORT (
		CLK : IN STD_LOGIC;
		A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		P : OUT STD_LOGIC_VECTOR(63 DOWNTO 0) 
	  );
	END COMPONENT;

	-- Latency = 26, unsigned integer inputs, valid output bits: (24:0)
	COMPONENT square_root_48_48_integer
	  PORT (
		aclk : IN STD_LOGIC;
		s_axis_cartesian_tvalid : IN STD_LOGIC;
		s_axis_cartesian_tlast : IN STD_LOGIC;
		s_axis_cartesian_tdata : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
		m_axis_dout_tvalid : OUT STD_LOGIC;
		m_axis_dout_tlast : OUT STD_LOGIC;
		m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
	  );
	END COMPONENT;

	-- Input side registers
	signal axis_tready					: std_logic;
	
	-- Stage 0
	signal error_vector_i				: error_vector_array(0 to 15);	-- 1 sign bit, 8 integer bits, 23 fractional bits
	signal error_vector_q				: error_vector_array(0 to 15);	-- 1 sign bit, 8 integer bits, 23 fractional bits
	signal tvalid_in_pipe0				: std_logic;
	signal tkeep_in_pipe0				: std_logic_vector(BUS_WIDTH/8-1 downto 0);
	signal tlast_in_pipe0				: std_logic;
	
	-- Stage 1
	signal square_diff_input_a_i		: square_diff_array;			-- 1 sign bit, 8 integer bits, 23 fractional bits
	signal square_diff_input_b_i		: square_diff_array;			-- 1 sign bit, 8 integer bits, 23 fractional bits
	signal square_difference_p_i		: square_diff_product_array;	-- 18 integer bits, 46 fractional bits
	signal square_diff_input_a_q		: square_diff_array;			-- 1 sign bit, 8 integer bits, 23 fractional bits
	signal square_diff_input_b_q		: square_diff_array;			-- 1 sign bit, 8 integer bits, 23 fractional bits
	signal square_difference_p_q		: square_diff_product_array;	-- 18 integer bits, 46 fractional bits
	signal tvalid_in_pipe1				: std_logic_vector(0 to STAGE_1_PIPELINE_SIZE-1);
	signal tkeep_in_pipe1				: tkeep_pipeline_array(0 to STAGE_1_PIPELINE_SIZE-1);
	signal tlast_in_pipe1				: std_logic_vector(0 to STAGE_1_PIPELINE_SIZE-1);
	
	-- Stage 2
	signal sum_of_squares				: sum_of_squares_array;				-- 18 integer bits, 46 fractional bits
	signal tvalid_in_pipe2				: std_logic;
	signal tkeep_in_pipe2				: std_logic_vector(BUS_WIDTH/8-1 downto 0);
	signal tlast_in_pipe2				: std_logic;
	
	-- Stage 3
	signal sum_of_square_slv_reduced	: sum_of_squares_reduced_array;		-- 18 integer bits, 30 fractional bits
	signal tvalid_in_pipe3				: std_logic_vector(0 to 15);
	signal tlast_in_pipe3				: std_logic_vector(0 to 15);
	signal error_magnitude				: error_magnitude_array;			-- 8 extra bits, 9 integer bits, 15 fractional bits
	
	-- Stage 4
	signal tlast_in_pipe4				: std_logic;
	signal tvalid_in_pipe4				: std_logic;
	signal minimum_error_magnitude_0	: minimum_error_magnitude_array(0 to 7);
	signal minimum_error_index_0		: minimum_error_index_array(0 to 7);
	signal tvalid_in_pipe5				: std_logic;
	signal tlast_in_pipe5				: std_logic;
	signal minimum_error_magnitude_1	: minimum_error_magnitude_array(0 to 3);
	signal minimum_error_index_1		: minimum_error_index_array(0 to 3);
	signal tvalid_in_pipe6				: std_logic;
	signal tlast_in_pipe6				: std_logic;
	signal minimum_error_magnitude_2	: minimum_error_magnitude_array(0 to 1);
	signal minimum_error_index_2		: minimum_error_index_array(0 to 1);
	signal tvalid_in_pipe7				: std_logic;
	signal tlast_in_pipe7				: std_logic;
	signal minimum_error_magnitude		: unsigned(24 downto 0);
	signal minimum_error_index			: integer;

	-- Output side state machine
	signal controller_state				: controller_state_machine;
	signal tvalid_shift_register		: std_logic_vector(0 to BACKPRESSURE_DEPTH-1);
	signal tdata_shift_register			: tdata_shift_register_array;
	signal tkeep_shift_register			: tkeep_shift_register_array;
	signal tlast_shift_register			: std_logic_vector(0 to BACKPRESSURE_DEPTH-1);
	signal shift_register_index			: integer;
	signal current_index				: integer;
	
begin

	axis_tready_out	<= axis_tready;

-- Python code:
-- error_magnitude.append(math.sqrt((i_modulated_data[i]-constellation_data[j].real)**2 + (q_modulated_data[i]-constellation_data[j].imag)**2))
	
----------<<<<<<<<<< STAGE 0 >>>>>>>>>>----------
-- Perform the subtractions
	stage_0_registers : process (clock)
	begin
		if (rising_edge(clock)) then
			if (axis_tvalid_in = '1') then
				axis_tready		<= '1';
			else
				axis_tready		<= '0';
			end if;
		
			-- First clock cycle, obtain the differences
			if (axis_tvalid_in = '1') and (axis_tready = '1') then
				for i in 0 to 15 loop
					error_vector_i(i)	<= signed(axis_tdata_in(31 downto 0)) - CONSTELLATION_DATA(0, i);
					error_vector_q(i)	<= signed(axis_tdata_in(63 downto 32)) - CONSTELLATION_DATA(1, i);
				end loop;

				-- Pipelines
				tvalid_in_pipe0	<= '1';	
				tkeep_in_pipe0	<= (others => '1');	
				tlast_in_pipe0	<= axis_tlast_in;
			else
				error_vector_i	<= (others => (others => '0'));
				error_vector_q	<= (others => (others => '0'));
				tvalid_in_pipe0	<= '0';	
				tkeep_in_pipe0	<= (others => '0');	
				tlast_in_pipe0	<= '0';
			end if;
		end if;
	end process;

----------<<<<<<<<<< STAGE 1 >>>>>>>>>>----------
-- Square the differences

stage_1_multipliers : for i in 0 to 15 generate
	square_diff_input_a_i(i)	<= std_logic_vector(error_vector_i(i));
	square_diff_input_b_i(i)	<= std_logic_vector(error_vector_i(i));
	
	square_difference_i : multiplier_32x32_signed
	  PORT MAP (
		CLK 	=> clock,
		A 		=> square_diff_input_a_i(i),
		B 		=> square_diff_input_b_i(i),
		P 		=> square_difference_p_i(i)
	  );

	square_diff_input_a_q(i)	<= std_logic_vector(error_vector_q(i));
	square_diff_input_b_q(i)	<= std_logic_vector(error_vector_q(i));
	
	square_difference_q : multiplier_32x32_signed
	  PORT MAP (
		CLK 	=> clock,
		A 		=> square_diff_input_a_q(i),
		B 		=> square_diff_input_b_q(i),
		P 		=> square_difference_p_q(i)
	  );
end generate stage_1_multipliers;

	stage_1_registers : process (clock)
	begin
		if (rising_edge(clock)) then
			-- Pipelines
			tvalid_in_pipe1(STAGE_1_PIPELINE_SIZE-1)	<= tvalid_in_pipe0;
			tkeep_in_pipe1(STAGE_1_PIPELINE_SIZE-1)		<= tkeep_in_pipe0;	
			tlast_in_pipe1(STAGE_1_PIPELINE_SIZE-1)		<= tlast_in_pipe0;	
			
			for i in STAGE_1_PIPELINE_SIZE-2 downto 0 loop
				tvalid_in_pipe1(i)	<= tvalid_in_pipe1(i+1);
				tkeep_in_pipe1(i)	<= tkeep_in_pipe1(i+1);
				tlast_in_pipe1(i)	<= tlast_in_pipe1(i+1);
			end loop;
		end if;
	end process;

----------<<<<<<<<<< STAGE 2 >>>>>>>>>>----------
-- Add the square of the differences

	stage_2_adders : process (clock)
	begin
		if (rising_edge(clock)) then
			if (tvalid_in_pipe1(0) = '1') then
				for i in 0 to 15 loop
					sum_of_squares(i)	<= unsigned(square_difference_p_i(i)) + unsigned(square_difference_p_q(i));
				end loop;
			else
				sum_of_squares	<= (others => (others => '0'));
			end if;
			
			-- Pipelines
			tvalid_in_pipe2		<= tvalid_in_pipe1(0);	
			tkeep_in_pipe2		<= tkeep_in_pipe1(0);	
			tlast_in_pipe2		<= tlast_in_pipe1(0);	
		end if;
	end process;

----------<<<<<<<<<< STAGE 3 >>>>>>>>>>----------
-- Take the square root of the sum of the squares

stage_3_square_roots : for i in 0 to 15 generate
	sum_of_square_slv_reduced(i)	<= std_logic_vector(sum_of_squares(i)(63 downto 16));

	error_magnitude_calculation : square_root_48_48_integer
	  PORT MAP (
		aclk 					=> clock,
		s_axis_cartesian_tvalid => tvalid_in_pipe2,
		s_axis_cartesian_tlast 	=> tlast_in_pipe2,
		s_axis_cartesian_tdata 	=> sum_of_square_slv_reduced(i),
		m_axis_dout_tvalid 		=> tvalid_in_pipe3(i),
		m_axis_dout_tlast 		=> tlast_in_pipe3(i),
		m_axis_dout_tdata 		=> error_magnitude(i)
	  );
end generate stage_3_square_roots;

----------<<<<<<<<<< STAGE 4 >>>>>>>>>>----------
-- Multi-clock cycle stage used to find the minimum error

	find_minimum_error : process (clock)
		type error_mag_mod_array is array (0 to 15) of unsigned(24 downto 0);
		variable error_magnitude_mod_a	: error_mag_mod_array;
		variable error_magnitude_mod_b	: error_mag_mod_array;
	begin
		if (rising_edge(clock)) then
			if (tlast_in_pipe3 = (tlast_in_pipe3'high downto 0 => '0')) then
				tlast_in_pipe4	<= '0';
			else
				tlast_in_pipe4	<= '1';
			end if;
				
			-- First stage of comparators
			if (tvalid_in_pipe3 = (tvalid_in_pipe3'high downto 0 => '1')) then
				tvalid_in_pipe4		<= '1';
				
				for i in 0 to 7 loop
					error_magnitude_mod_a(i)	:= unsigned(error_magnitude(i*2)(24 downto 0));
					error_magnitude_mod_b(i)	:= unsigned(error_magnitude(i*2+1)(24 downto 0));
		
					if (error_magnitude_mod_a(i) < error_magnitude_mod_b(i)) then
						minimum_error_magnitude_0(i)	<= error_magnitude_mod_a(i);
						minimum_error_index_0(i)		<= i*2;
					else
						minimum_error_magnitude_0(i)	<= error_magnitude_mod_b(i);
						minimum_error_index_0(i)		<= i*2+1;
					end if;
				end loop;
			else
				tvalid_in_pipe4		<= '0';
			end if;
			
			-- Second stage of comparators
			for i in 0 to 3 loop
				if (minimum_error_magnitude_0(i*2) < minimum_error_magnitude_0(i*2+1)) then
					minimum_error_magnitude_1(i)	<= minimum_error_magnitude_0(i*2);
					minimum_error_index_1(i)		<= minimum_error_index_0(i*2);
				else
					minimum_error_magnitude_1(i)	<= minimum_error_magnitude_0(i*2+1);
					minimum_error_index_1(i)		<= minimum_error_index_0(i*2+1);
				end if;
			end loop;
			
			tvalid_in_pipe5	<= tvalid_in_pipe4;
			tlast_in_pipe5	<= tlast_in_pipe4;
			
			-- Third stage of comparators
			for i in 0 to 1 loop
				if (minimum_error_magnitude_1(i*2) < minimum_error_magnitude_1(i*2+1)) then
					minimum_error_magnitude_2(i)	<= minimum_error_magnitude_1(i*2);
					minimum_error_index_2(i)		<= minimum_error_index_1(i*2);
				else
					minimum_error_magnitude_2(i)	<= minimum_error_magnitude_1(i*2+1);
					minimum_error_index_2(i)		<= minimum_error_index_1(i*2+1);
				end if;
			end loop;

			tvalid_in_pipe6	<= tvalid_in_pipe5;
			tlast_in_pipe6	<= tlast_in_pipe5;
			
			-- Fourth stage of comparators
			if (minimum_error_magnitude_2(0) < minimum_error_magnitude_2(1)) then
				minimum_error_magnitude	<= minimum_error_magnitude_2(0);
				minimum_error_index		<= minimum_error_index_2(0);	
			else
				minimum_error_magnitude	<= minimum_error_magnitude_2(1);
				minimum_error_index		<= minimum_error_index_2(1);	
			end if;

			tvalid_in_pipe7	<= tvalid_in_pipe6;
			tlast_in_pipe7	<= tlast_in_pipe6;			
		end if;
	end process;

	output_controller : process (reset, clock)
	begin
		if (reset = '1') then
			controller_state		<= IDLE;
			axis_tvalid_out			<= '0';
			axis_tdata_out			<= (others => '0');
			axis_tkeep_out			<= (others => '0');
			axis_tlast_out			<= '0';
			tvalid_shift_register	<= (others => '0');
			tdata_shift_register	<= (others => (others => '0'));
			tkeep_shift_register	<= (others => (others => '0'));
			tlast_shift_register	<= (others => '0');
			shift_register_index	<= 0;
			current_index			<= 0;
		elsif (rising_edge(clock)) then
			case (controller_state) is
				when IDLE =>
					if (tvalid_in_pipe7 = '1') then
						if (axis_tready_in = '1') then	-- tready is already set to '1'
							axis_tvalid_out		<= '1';
							axis_tdata_out		<= std_logic_vector(to_unsigned(minimum_error_index, INDEX_DATA_SIZE));
							axis_tkeep_out		<= (others => '1');
							axis_tlast_out		<= tlast_in_pipe7;
							
							if (tlast_in_pipe7 = '1') then
								controller_state	<= END_OF_BUS_TRANSACTION;
							else
								controller_state	<= WAIT_FOR_END_OF_DATA;
							end if;
						else
							axis_tvalid_out				<= tvalid_in_pipe7;
							axis_tdata_out				<= std_logic_vector(to_unsigned(minimum_error_index, INDEX_DATA_SIZE));
							axis_tkeep_out				<= (others => '1');
							axis_tlast_out				<= tlast_in_pipe7;
							tvalid_shift_register(0)	<= tvalid_in_pipe7;
							tdata_shift_register(0)		<= std_logic_vector(to_unsigned(minimum_error_index, INDEX_DATA_SIZE));
							tkeep_shift_register(0)		<= (others => '1');
							tlast_shift_register(0)		<= tlast_in_pipe7;
							current_index				<= 0;
							shift_register_index		<= 1;
							controller_state			<= MANAGE_BACK_PRESSURE;
						end if;
					else
						axis_tvalid_out		<= '0';
						axis_tdata_out		<= (others => '0');
						axis_tkeep_out		<= (others => '0');
						axis_tlast_out		<= '0';
					end if;
				when MANAGE_BACK_PRESSURE =>
					if (axis_tready_in = '1') and (tvalid_shift_register(current_index) = '1') then
						axis_tvalid_out		<= tvalid_shift_register(current_index);
						axis_tdata_out		<= tdata_shift_register(current_index);	
						axis_tkeep_out		<= tkeep_shift_register(current_index);	
						axis_tlast_out		<= tlast_shift_register(current_index);	
						
						if (tlast_shift_register(current_index) = '1') then
							controller_state	<= END_OF_BUS_TRANSACTION;
						end if;
					else	-- Place data bus into shift registers
						tvalid_shift_register(0)	<= tvalid_in_pipe7;
						tdata_shift_register(0)		<= std_logic_vector(to_unsigned(minimum_error_index, INDEX_DATA_SIZE));
						tkeep_shift_register(0)		<= (others => '1');
						tlast_shift_register(0)		<= tlast_in_pipe7;
					
						for i in 1 to BACKPRESSURE_DEPTH-1 loop
							tvalid_shift_register(i)	<= tvalid_shift_register(i-1);
							tdata_shift_register(i)		<= tdata_shift_register(i-1);	
							tkeep_shift_register(i)		<= tkeep_shift_register(i-1);	
							tlast_shift_register(i)		<= tlast_shift_register(i-1);	
						end loop;
						
						current_index	<= shift_register_index;
						
						if (shift_register_index < BACKPRESSURE_DEPTH-1) then
							shift_register_index	<= shift_register_index + 1;
						end if;
					end if;
				when WAIT_FOR_END_OF_DATA =>
					if (axis_tready_in = '1') then
						axis_tvalid_out		<= tvalid_in_pipe7;
						axis_tdata_out		<= std_logic_vector(to_unsigned(minimum_error_index, INDEX_DATA_SIZE));
						axis_tkeep_out		<= (others => '1');
						axis_tlast_out		<= tlast_in_pipe7;
						
						if (tlast_in_pipe7 = '1') then
							controller_state	<= END_OF_BUS_TRANSACTION;
						end if;
					else
						axis_tvalid_out				<= tvalid_in_pipe7;
						axis_tdata_out				<= std_logic_vector(to_unsigned(minimum_error_index, INDEX_DATA_SIZE));
						axis_tkeep_out				<= (others => '1');
						axis_tlast_out				<= tlast_in_pipe7;
						tvalid_shift_register(0)	<= tvalid_in_pipe7;
						tdata_shift_register(0)		<= std_logic_vector(to_unsigned(minimum_error_index, INDEX_DATA_SIZE));
						tkeep_shift_register(0)		<= (others => '1');
						tlast_shift_register(0)		<= tlast_in_pipe7;
						current_index				<= 0;
						shift_register_index		<= 1;
						controller_state			<= MANAGE_BACK_PRESSURE;
					end if;
				when END_OF_BUS_TRANSACTION =>
					axis_tvalid_out		<= '0';
					axis_tdata_out		<= (others => '0');
					axis_tkeep_out		<= (others => '0');
					axis_tlast_out		<= '0';
					controller_state	<= WAIT_FOR_BUS_CLEAR;
				when WAIT_FOR_BUS_CLEAR =>
					if (tvalid_in_pipe7 = '0') and (tlast_in_pipe7 = '0') then
						controller_state	<= IDLE;
					end if;
				when others =>
					controller_state	<= IDLE;
			end case;
		end if;
	end process;
end architecture struct;
