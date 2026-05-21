module common_header (tkeep_size_in, tkeep_size_out);
	input tkeep_size_in;
	output integer tkeep_size_out;
	
	function integer tkeep_data_size;
		input tkeep_size_in;
		real quotient;
		real product;
		
		begin		
			quotient		= tkeep_size_in/8;
			product			= $ceil(quotient);
			tkeep_data_size	= product * 8;
		end
	endfunction
	
	always @* begin
		tkeep_size_out = tkeep_data_size(tkeep_size_in);
	end
endmodule

module byte_swap #(parameter WIDTH = 8)
(
	input wire [WIDTH-1:0] data_in,
	output wire [WIDTH-1:0] data_out
);

    // The function uses the module's parameter 'WIDTH'
    function [WIDTH-1:0] parametizable_byte_swap (input [WIDTH-1:0] input_data);
    	integer i;
    	reg [WIDTH-1:0] shift_register;
    	
        begin
       		shift_register = input_data;
       		
        	for (i = 0; i < WIDTH/8; i = i + 1) begin
        		parametizable_byte_swap[i*8+:8] = shift_register[WIDTH-1:WIDTH-8];
        		shift_register = shift_register << 8;
        	end
        end
    endfunction

    // Use the function
    assign data_out = parametizable_byte_swap(data_in);
endmodule

