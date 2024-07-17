module I2C_master(
	output	reg  [7:0]o_reg_data,
	output	reg	 	  o_rd_done,
	output	reg		  o_wr_done,
	output	reg		  o_i2c_done,
	output	reg	  	  scl,
	input	wire	  clk,
	input	wire	  rst_n,
	inout	wire	  sda,
	input	wire	  i_i2c_go,
	input	wire	  i_rw,
	input	wire [7:0]i_reg_addr,
	input	wire [7:0]i_wr_data,
	input	wire [7:0]i_cycle,
	input	wire [6:0]i_i2c_slave_addr
);

reg  [11:0]state, next_state;
reg  [3:0]bit_counter;
reg  [4:0]div_counter;
reg  	  clk_div;
reg   	  sda_out;
reg		  is_ack;
wire	  sda_in;


reg	 [6:0]slave_addr;
reg	 [6:0]slave_addr_backup;
reg	 [7:0]reg_offset;
reg	 [7:0]out_data;
reg	 [7:0]in_data;
reg		  rw_signal;
reg		  is_restart;

assign sda_in = sda;
assign sda = sda_out ? 1'bz : 1'b0;

localparam IDLE	         = 12'b000000000001; //1
localparam ADDR	         = 12'b000000000010; //2
localparam OFFSET        = 12'b000000000100; //4
localparam IN_DATA	     = 12'b000000001000; //8
localparam OUT_DATA	     = 12'b000000010000; //16
localparam ADDR_ACK	     = 12'b000000100000; //32
localparam OFFSET_ACK 	 = 12'b000001000000; //64
localparam IN_DATA_ACK	 = 12'b000010000000; //128
localparam OUT_DATA_ACK	 = 12'b000100000000; //256
localparam STOP	         = 12'b001000000000; //512
localparam START	     = 12'b010000000000; //1024
localparam RESTART		 = 12'B100000000000; //2048


assign ST_IDLE	       = state[0];	
assign ST_ADDR	       = state[1];
assign ST_OFFSET       = state[2];
assign ST_IN_DATA	   = state[3];
assign ST_OUT_DATA	   = state[4];
assign ST_ADDR_ACK	   = state[5];
assign ST_OFFSET_ACK   = state[6];
assign ST_IN_DATA_ACK  = state[7];
assign ST_OUT_DATA_ACK = state[8];
assign ST_STOP	       = state[9];
assign ST_START	       = state[10];
assign ST_RESTART	   = state[11];

//count cycle
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        div_counter <= 5'd0;
	else if (div_counter == 5'd15)
		div_counter <= 5'd0;
    else 
        div_counter <= div_counter + 5'd1;
end

//count bit
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        bit_counter <= 4'd0;
	else if ((bit_counter == 5'd7) &&(div_counter == 5'd15))
		bit_counter <= 4'd0;
    else if ((ST_ADDR == 1'b1) && (div_counter == 4'd15))
        bit_counter <= bit_counter + 4'd1;
	else if ((ST_OFFSET == 1'b1) && (div_counter == 4'd15))
        bit_counter <= bit_counter + 4'd1;
	else if ((ST_IN_DATA == 1'b1) && (div_counter == 4'd15))
        bit_counter <= bit_counter + 4'd1;
	else if ((ST_OUT_DATA == 1'b1) && (div_counter == 4'd15))
        bit_counter <= bit_counter + 4'd1;
	else 
		bit_counter <= bit_counter;
end

always @(posedge clk or negedge rst_n) begin //change state
	if(!rst_n)
		state <= IDLE;
	else
		state <= next_state;
end

always @(*) begin
	case(state)
		IDLE: begin
			if(i_i2c_go)
				next_state = START;	
			else
				next_state = IDLE;
		end
		START: begin
			if((div_counter == 4'd15))
				next_state = ADDR;	
			else
				next_state = START;
		end
		ADDR: begin
			if((bit_counter == 3'd7) && (div_counter == 4'd15))
				next_state = ADDR_ACK;
			else 
				next_state = ADDR;
		end
		ADDR_ACK: begin
			if((div_counter == 4'd15) && (is_restart == 1'b0) && (is_ack == 1'b0))
				next_state = OFFSET;
			else if((div_counter == 4'd15) && (is_restart == 1'b1) && (is_ack == 1'b0))
				next_state = IN_DATA;
			else
				next_state = ADDR_ACK;
		end
		OFFSET: begin
			if((bit_counter == 3'd7) && (div_counter == 4'd15))
				next_state = OFFSET_ACK;
			else
				next_state = OFFSET;
		end
		OFFSET_ACK: begin
			if((div_counter == 4'd15) && (rw_signal == 1'b1) && (is_ack == 1'b0))
				next_state = RESTART;
			else if((div_counter == 4'd15) && (rw_signal == 1'b0) && (is_ack == 1'b0))
				next_state = OUT_DATA;
			else
				next_state = OFFSET_ACK;
		end
		IN_DATA: begin
			if((bit_counter == 3'd7) && (div_counter == 4'd15))
				next_state = IN_DATA_ACK;
			else 
				next_state = IN_DATA;
		end
		IN_DATA_ACK: begin
			if((div_counter == 4'd15))    // write nonACK
				next_state = STOP;
			else
				next_state = IN_DATA_ACK;
		end
		RESTART: begin 							
			if((div_counter == 4'd15))
				next_state = ADDR;	
			else
				next_state = RESTART;
		end
		OUT_DATA: begin
			if((bit_counter == 3'd7) && (div_counter == 4'd15))
				next_state = OUT_DATA_ACK;
			else 
				next_state = OUT_DATA;
		end
		OUT_DATA_ACK: begin
			if((div_counter == 4'd15)  && (is_ack == 1'b0))
				next_state = STOP;
			else
				next_state = OUT_DATA_ACK;
		end
		STOP: begin
			if((div_counter == 4'd15))
				next_state = IDLE;
			else
				next_state = STOP;
		end
	endcase
end

//write scl
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		scl <= 1'b1;
	else if(ST_IDLE)
		scl <= 1'b1;
	else if(ST_START)
		scl <= 1'b1;
	else if((ST_STOP == 1'b1)  && (div_counter == 4'd2))
		scl <= 1'b0;
	else if((ST_STOP == 1'b1)  && (div_counter == 4'd3))
		scl <= 1'b1;
	else if((ST_RESTART == 1'b1) && (div_counter == 4'd3))
		scl <= 1'b1;
	else if((div_counter == 4'd2))
		scl <= 1'b0;
	else if((div_counter == 4'd8))
		scl <= 1'b1;
	else
		scl <= scl;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		sda_out <= 1'b1;
	else if(ST_IDLE)
		sda_out <= 1'b1;
	else if((ST_START == 1'b1) && (div_counter == 4'd7))
		sda_out <= 1'b0;
	else if((ST_ADDR ==1'b1) && (div_counter == 4'd2) && (bit_counter < 3'd7))
		sda_out <= slave_addr[6];
	else if((ST_ADDR ==1'b1) && (div_counter == 4'd2) && (bit_counter == 3'd7) && (rw_signal ==1'b1)) begin
		if(is_restart)
			sda_out <= rw_signal;
		else
			sda_out <= 1'b0;
	end
	else if((ST_OFFSET ==1'b1) && (div_counter == 4'd2))
		sda_out <= reg_offset[7];
	else if((ST_OUT_DATA ==1'b1) && (div_counter == 4'd2))
		sda_out <= out_data[7];
	else if((ST_IN_DATA_ACK == 1'd1) && (bit_counter == 3'd2))
		sda_out <= 1'b0;
	else if((ST_OFFSET_ACK == 1'd1) && (bit_counter == 3'd2))
		sda_out <= 1'b1;
	else if((ST_ADDR_ACK == 1'd1) && (bit_counter == 3'd2))
		sda_out <= 1'b1;
	else if((ST_OUT_DATA_ACK == 1'd1) && (bit_counter == 3'd2))
		sda_out <= 1'b1;
	else if((ST_RESTART ==1'b1) && (div_counter == 4'd5))
		sda_out <= 1'b0;
	else if((ST_STOP ==1'b1) && (div_counter == 4'd0))
		sda_out <= 1'b0;
	else if((ST_STOP ==1'b1) && (div_counter == 4'd5))
		sda_out <= 1'b1;
	else
		sda_out <= sda_out;
end

//read ack from slave
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		is_ack <= 1'b1;
	else if((ST_ADDR_ACK == 1'b1) && (div_counter == 4'd8))
		is_ack <= sda_in;
	else if((ST_OFFSET_ACK == 1'b1) && (div_counter == 4'd8))
		is_ack <= sda_in;
	else if((ST_OUT_DATA_ACK == 1'b1) && (div_counter == 4'd8))
		is_ack <= sda_in;
	else if((ST_ADDR == 1'b1) || (ST_OFFSET == 1'b1) || (ST_OUT_DATA == 1'b1))
		is_ack <= 1'b1;
	else
		is_ack <= is_ack;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		in_data <= 8'd0;
	else if((ST_IN_DATA == 1'b1) && (div_counter == 4'd12))
		in_data <= {in_data[6:0], sda_in};
	else
		in_data <= in_data;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		is_restart <= 1'b0;
	else if(ST_OFFSET_ACK)
		is_restart <= 1'b1;
	else if(ST_STOP)
		is_restart <= 1'b0;
	else
		is_restart <= is_restart;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		rw_signal <= 1'b0;
	else if(ST_START)
		rw_signal <= i_rw;
	else 
		rw_signal <= rw_signal;
end

always @(posedge clk or negedge rst_n) begin //slave addr
	if(!rst_n)
		slave_addr <= 7'd0;
	else if((ST_ADDR == 1'b1) && (div_counter == 4'd0) && (bit_counter == 4'd0))
		slave_addr <= i_i2c_slave_addr;
	else if((ST_ADDR == 1'b1) && (div_counter == 4'd15))
		slave_addr <= slave_addr << 1'b1;
	else 
		slave_addr <= slave_addr;
end

always @(posedge clk or negedge rst_n) begin //offset
	if(!rst_n)
		reg_offset <= 8'd0;
	else if(ST_START)
		reg_offset <= i_reg_addr;
	else if((ST_OFFSET == 1'b1) && (div_counter == 4'd15))
		reg_offset <= reg_offset << 1'b1;
	else 
		reg_offset <= reg_offset;
end

always @(posedge clk or negedge rst_n) begin //out_data
	if(!rst_n)
		out_data <= 8'd0;
	else if(ST_START)
		out_data <= i_wr_data;
	else if((ST_OUT_DATA == 1'b1) && (div_counter == 4'd15))
		out_data <= out_data << 1'b1;
	else 
		out_data <= out_data;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		o_i2c_done <= 1'b0;
	else if(ST_IDLE)
		o_i2c_done <= 1'b0;
	else if((ST_STOP == 1'b1) && (div_counter == 4'd15))
		o_i2c_done <= 1'b1;
	else 
		o_i2c_done <= o_i2c_done;
end

endmodule