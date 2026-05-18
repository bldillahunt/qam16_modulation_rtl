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
	
end package common_parameters;

package body common_parameters is
end package body common_parameters;
