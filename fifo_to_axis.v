`include "common_header.v"

module fifo_to_axis (reset, clock, fifo_read_enable, fifo_empty, fifo_full, fifo_data_out, fifo_data_valid, tready_in, tvalid_out, tdata_out, tlast_out);
	
	parameter DATA_SIZE = 512;
	parameter PIPELINE_DEPTH = 4;
//	parameter EVEN_DATA_TYPE = 1'b1;
	
//	localparam TKEEP_SIZE = (EVEN_DATA_TYPE ? DATA_SIZE/8 : 32);
	localparam HIGH_WATER_MARK = PIPELINE_DEPTH/2;
	
	input reset;
	input clock;
	output reg fifo_read_enable;
	input fifo_empty;
	input fifo_full;
	input [DATA_SIZE-1:0] fifo_data_out;
	input fifo_data_valid;
	input tready_in;
	output reg tvalid_out;
	output reg [DATA_SIZE-1:0] tdata_out;
	output reg tlast_out;
//	output reg [TKEEP_SIZE-1:0] tkeep_out;
	integer i;
	
	// Input side state machine registers
	localparam [7:0] IDLE = 8'h01;
	localparam [7:0] FILL_TO_WATERMARK = 8'h02;
	localparam [7:0] WAIT_FOR_END_OF_DATA = 8'h04;
	
	reg [7:0] fifo_access_state;
	reg [PIPELINE_DEPTH-1:0] eof_shift_register;
	reg [DATA_SIZE-1:0] shift_register[0:PIPELINE_DEPTH-1];
	integer input_counter;		
	integer input_index;			
	reg enable_data_output;	
	reg flush_pipeline;		
	
	// Output side state machine register
//	localparam [7:0] IDLE = 8'h01;
	localparam [7:0] TRANSMIT_DATA_STREAM = 8'h02;
	localparam [7:0] EMPTY_PIPELINE_DATA = 8'h04;
	localparam [7:0] CLEAR_BUS_TRANSACTION = 8'h08;
	
	reg [7:0] axis_access_state;
	integer output_counter;		
	integer output_index;		
	integer current_count;
	
	// Input side state machine
	always @(posedge clock or reset) begin
		if (reset) begin
			fifo_access_state	<= IDLE;
			eof_shift_register	<= {PIPELINE_DEPTH{1'b0}};
			
			for (i = 0; i < PIPELINE_DEPTH; i = i + 1) begin
				shift_register[i]	<= 0;
			end
			
			input_counter		<= 0;
			input_index			<= 0;
			fifo_read_enable	<= 1'b0;
			enable_data_output	<= 1'b0;
			flush_pipeline		<= 1'b0;
		end
		else begin
			case (fifo_access_state)
				IDLE:
				begin
					input_counter		<= 0;
					input_index			<= 0;
					enable_data_output	<= 1'b0;
					
					if (!fifo_empty) begin
						fifo_read_enable	<= 1'b1;
						fifo_access_state	<= FILL_TO_WATERMARK;
					end
				end
				FILL_TO_WATERMARK:
				begin
					if (fifo_data_valid) begin
						shift_register[0]		<= fifo_data_out;
						eof_shift_register[0]	<= fifo_empty;
						
						for (i = 1; i < PIPELINE_DEPTH; i = i + 1) begin
							shift_register[i]		<= shift_register[i-1];
							eof_shift_register[i]	<= eof_shift_register[i-1];
						end
						
						input_counter	<= input_counter + 1;
						
						
						if (input_counter < PIPELINE_DEPTH) begin
							input_index		<= input_counter;
						end
						else begin
							input_index		<= PIPELINE_DEPTH - 1;
						end
						
						if (input_counter >= HIGH_WATER_MARK) begin
							enable_data_output	<= 1'b1;
							flush_pipeline		<= 1'b0;
						end
						else if (fifo_empty) begin
							enable_data_output	<= 1'b0;
							flush_pipeline		<= 1'b1;
							fifo_read_enable	<= 1'b0;
							fifo_access_state	<= WAIT_FOR_END_OF_DATA;
						end
					end
					else if (fifo_empty) begin
						eof_shift_register[0]	<= 1'b1;
						
						for (i = 1; i < PIPELINE_DEPTH; i = i + 1) begin
							eof_shift_register[i]	<= eof_shift_register[i-1];
						end

						enable_data_output	<= 1'b0;
						flush_pipeline		<= 1'b1;
						fifo_read_enable	<= 1'b0;
						fifo_access_state	<= WAIT_FOR_END_OF_DATA;
					end
				end
				WAIT_FOR_END_OF_DATA:
				begin
					if ((tready_in) && (eof_shift_register[output_index] == 1'b1)) begin
						flush_pipeline		<= 1'b0;
						fifo_access_state	<= IDLE;
					end
				end
				default: fifo_access_state	<= IDLE;
			endcase
		end
	end
	
	always @(posedge clock or reset) begin
		if (reset) begin
			axis_access_state	<= IDLE;
			tvalid_out			<= 1'b0;
			tdata_out			<= 0;
//			tkeep_out			<= 0;
			tlast_out			<= 1'b0;
			output_counter		<= 0;
			output_index		<= 0;
			current_count		<= 0;
		end
		else begin
			case (axis_access_state)
				IDLE:
				begin
					output_counter		<= 0;
					output_index		<= 0;
					
					if (enable_data_output) begin	// Expecting more data
						current_count	<= input_counter;
						tvalid_out		<= 1'b1;
						tdata_out		<= shift_register[input_index];
//						tkeep_out		<= {TKEEP_SIZE{1'b1}};
						tlast_out		<= eof_shift_register[input_index];
						
						if (fifo_empty) begin
							output_index		<= input_index - 1;
						end
						else begin
							output_index		<= input_index;
						end
						
						if (tready_in) begin
							output_counter		<= output_counter + 1;
						end
						
						if (eof_shift_register[0]) begin
							axis_access_state	<= EMPTY_PIPELINE_DATA;
						end
						else begin
							axis_access_state	<= TRANSMIT_DATA_STREAM;
						end
					end
					else if (flush_pipeline) begin	// No more data going into shift register
						current_count		<= input_counter;
						tvalid_out			<= 1'b1;
						tdata_out			<= shift_register[input_index];
//						tkeep_out			<= {TKEEP_SIZE{1'b1}};
						tlast_out			<= eof_shift_register[input_index];
						output_counter		<= output_counter + 1;

						if (input_index > 0) begin
							output_index		<= input_index - 1;
						end
						else begin
							output_index		<= 0;
						end
						
						axis_access_state	<= EMPTY_PIPELINE_DATA;
					end
				end
				TRANSMIT_DATA_STREAM:
				begin
					if (tready_in) begin
						tvalid_out		<= 1'b1;
						tdata_out		<= shift_register[output_index];
						tlast_out		<= eof_shift_register[output_index];
						output_counter	<= output_counter + 1;
						current_count	<= input_counter;

						if (fifo_empty) begin	// (eof_shift_register[0]) begin
							if (output_index > 0) begin
								output_index		<= output_index - 1;
							end

							axis_access_state	<= EMPTY_PIPELINE_DATA;
						end
					end
					else begin
						if (fifo_data_valid) begin
							output_index	<= input_index;
						end
					end
				end
				EMPTY_PIPELINE_DATA:
				begin
					if (tready_in) begin
						if (!eof_shift_register[0]) begin
							tvalid_out		<= 1'b1;
							tdata_out		<= shift_register[output_index];
//							tkeep_out		<= {TKEEP_SIZE{1'b1}};
							tlast_out		<= eof_shift_register[output_index];
							output_counter	<= output_counter + 1;

							if (output_index > 0) begin
								output_index		<= output_index - 1;
							end
							else begin
								axis_access_state	<= CLEAR_BUS_TRANSACTION;
							end
						end
						else begin
							if (output_counter == current_count) begin
								tvalid_out			<= 1'b0;
								tdata_out			<= 0;
//								tkeep_out			<= 0;
								tlast_out			<= 1'b0;
								axis_access_state	<= IDLE;
							end
							else begin
								tvalid_out			<= 1'b1;
								tdata_out			<= shift_register[output_index];
//								tkeep_out			<= {TKEEP_SIZE{1'b1}};
								tlast_out			<= eof_shift_register[output_index];
								output_counter		<= output_counter + 1;
								
								if (output_index > 0) begin
									output_index		<= output_index - 1;
								end
								else begin
									axis_access_state	<= CLEAR_BUS_TRANSACTION;
								end
							end
						end
					end
				end
				CLEAR_BUS_TRANSACTION:
				begin
					tvalid_out			<= 1'b0;
					tdata_out			<= 0;
//					tkeep_out			<= 0;
					tlast_out			<= 1'b0;
					axis_access_state	<= IDLE;
				end
				default: axis_access_state	<= IDLE;
			endcase
		end
	end
endmodule