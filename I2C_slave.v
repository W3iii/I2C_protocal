module I2C_slave(
	output	reg		  o_wr_en,
	output	reg	 [7:0]o_reg_addr,
	output	reg  [7:0]o_wr_data,
	output	reg  	  o_rd_done,
	input	wire	  clk,
	input	wire	  rst_n,
	input	wire	  scl,
	inout	wire	  sda,
	input	wire [6:0]i_slave_addr,
	input	wire [7:0]i_rd_data
);

//state and sycn signal
reg  [10:0]state, next_state;
reg	 [7:0]offset, in_data, out_data, temp_reg;
reg	 [6:0]device_addr;
reg		  sda_ff1, sda_ff2, sda_ff3;
reg		  scl_ff1, scl_ff2, scl_ff3;
reg		  backup_reg;

//fix temp read reg
reg  [7:0]fix_temp_data;

//condition and reg
reg  [2:0]bit_counter;
reg		  rw_signal;
reg		  is_restart;
reg 	  is_nonACK;
reg		  sda_out;
wire	  sda_in;

localparam IDLE	         = 11'b00000000001; //1
localparam ADDR	         = 11'b00000000010; //2
localparam OFFSET        = 11'b00000000100; //4
localparam IN_DATA	     = 11'b00000001000; //8
localparam OUT_DATA	     = 11'b00000010000; //16
localparam ADDR_ACK	     = 11'b00000100000; //32
localparam OFFSET_ACK 	 = 11'b00001000000; //64
localparam IN_DATA_ACK	 = 11'b00010000000; //128
localparam OUT_DATA_ACK	 = 11'b00100000000; //256
localparam STOP	         = 11'b01000000000; //512
localparam START	     = 11'b10000000000; //1024


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


assign sync_pos_sda =  sda_ff2 & ~sda_ff3;
assign sync_neg_sda = ~sda_ff2 &  sda_ff3;
assign sync_pos_scl =  scl_ff2 & ~scl_ff3;
assign sync_neg_scl = ~scl_ff2 &  scl_ff3;

assign sda_in = sda;
assign sda = sda_out ? 1'bz : 1'b0;

always @(posedge clk or negedge rst_n) begin //sync SDA
	if(!rst_n) begin
		sda_ff1 <= 1'b0;
		sda_ff2 <= 1'b0;
		sda_ff3 <= 1'b0;
	end
	else begin
	
		sda_ff1 <= sda_in;
		sda_ff2 <= sda_ff1;
		sda_ff3 <= sda_ff2;
	end
end

always @(posedge clk or negedge rst_n) begin //sync SCL
	if(!rst_n) begin
		scl_ff1 <= 1'b0;
		scl_ff2 <= 1'b0;
		scl_ff3 <= 1'b0;
	end
	else begin
		scl_ff1 <= scl;
		scl_ff2 <= scl_ff1;
		scl_ff3 <= scl_ff2;
	end
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
			if((sync_neg_sda == 1'b1) && (scl == 1'b1))
				next_state = START;	
			else
				next_state = IDLE;
		end
		START: begin
			if(sync_neg_scl)
				next_state = ADDR;	
			else
				next_state = START;
		end
		ADDR: begin
			if((bit_counter == 3'd7) && (sync_neg_scl == 1'd1))
				next_state = ADDR_ACK;
			else 
				next_state = ADDR;
		end
		ADDR_ACK: begin
			if((sync_neg_scl == 1'b1) && (rw_signal == 1'b0))
				next_state = OFFSET;
			else if((sync_neg_scl == 1'b1) && (rw_signal == 1'b1))
				next_state = OUT_DATA;
			else
				next_state = ADDR_ACK;
		end
		OFFSET: begin
			if((bit_counter == 3'd7) && (sync_neg_scl == 1'd1))
				next_state = OFFSET_ACK;
			else
				next_state = OFFSET;
		end
		OFFSET_ACK: begin
			if((sync_neg_scl == 1'b1) && (rw_signal == 1'b0))
				next_state = IN_DATA;
			else if((sync_neg_scl == 1'b1) && (rw_signal == 1'b1))
				next_state = OUT_DATA;
			else
				next_state = OFFSET_ACK;
		end
		IN_DATA: begin
			if((is_restart == 1'b1) && (sync_neg_scl == 1'd1)) 
				next_state = ADDR;
			else if((bit_counter == 3'd7) && (sync_neg_scl == 1'd1))
				next_state = IN_DATA_ACK;
			else 
				next_state = IN_DATA;
		end
		OUT_DATA: begin
			if((bit_counter == 3'd7) && (sync_neg_scl == 1'd1))
				next_state = OUT_DATA_ACK;
			else 
				next_state = OUT_DATA;
		end
		IN_DATA_ACK: begin
			if(sync_neg_scl)
				next_state = STOP;
			else
				next_state = IN_DATA_ACK;
		end
		OUT_DATA_ACK: begin
			if((sync_neg_scl ==1'b1) && (is_nonACK == 1'b1))
				next_state = STOP;
			else
				next_state = OUT_DATA_ACK;
		end
		STOP: begin
			if((sync_pos_sda == 1'b1) && (scl == 1'b1))
				next_state = IDLE;
			else
				next_state = STOP;
		end
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		is_nonACK <= 1'b0;
	else if((ST_IDLE == 1'b1) || (ST_OUT_DATA == 1'b1))
		is_nonACK <= 1'b0;
	else if((ST_OUT_DATA_ACK == 1'b1) && (sync_pos_scl == 1'b1) && (sda_in == 1'b1) )
		is_nonACK <= 1'b1;
	else
		is_nonACK <= is_nonACK;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		is_restart <= 4'd0;
	else if(ST_IDLE)
		is_restart <= 4'd0;
	else if(ST_START)
		is_restart <= 4'd0;
	else if ((sync_pos_scl == 1'b1) && (ST_ADDR == 1'd1))
		is_restart <= 1'b0;
	else if((sync_neg_sda == 1'b1) && (scl == 1'b1) && (ST_IN_DATA == 1'b1))
		is_restart <= 1'b1;
	else	
		is_restart <= is_restart;
end

always @(posedge clk or negedge rst_n) begin //counter add
	if(!rst_n)
		bit_counter <= 3'd0;
	else if(ST_IDLE)
		bit_counter <= 3'd0;
	else if((ADDR_ACK == 1'b1) || (OFFSET_ACK == 1'b1))
		bit_counter <= 3'd0;
	else if((IN_DATA_ACK == 1'b1) || (OUT_DATA_ACK == 1'b1))
		bit_counter <= 3'd0;
	else if((is_restart == 1'b1) && (sync_neg_scl == 1'b1))
		bit_counter <= 3'd0;
	else if((ST_ADDR == 1'b1) && (sync_neg_scl == 1'b1)) 
		bit_counter <= bit_counter + 3'd1;
	else if((ST_OFFSET == 1'b1) && (sync_neg_scl == 1'b1)) 
		bit_counter <= bit_counter + 3'd1;
	else if((ST_IN_DATA == 1'b1) && (sync_neg_scl == 1'b1)) 
		bit_counter <= bit_counter + 3'd1;
	else if((ST_OUT_DATA == 1'b1) && (sync_neg_scl == 1'b1)) 
		bit_counter <= bit_counter + 3'd1;
	else 
		bit_counter <= bit_counter;
end

always @(posedge clk or negedge rst_n) begin //ADDR
	if(!rst_n)
		device_addr <= 7'd0;
	else if(ST_IDLE)
		device_addr <= 7'd0;
	else if((ST_ADDR == 1'b1) && (sync_pos_scl == 1'b1) && (bit_counter < 7)) 
		device_addr <= {device_addr[5:0], sda_in};
	else 
		device_addr <= device_addr;
end

always @(posedge clk or negedge rst_n) begin //OFFSET
	if(!rst_n)
		offset <= 8'd0;
	else if(ST_IDLE)
		offset <= 8'd0;
	else if((ST_OFFSET == 1'b1) && (sync_pos_scl == 1'b1)) 
		offset <= {offset[6:0], sda_in};
	else	
		offset <= offset;
end

always @(posedge clk or negedge rst_n) begin //temp reg
	if(!rst_n)
		temp_reg <= 8'd0;
	else if(ST_OFFSET_ACK)
		temp_reg <= i_rd_data;
	else if((ST_IN_DATA == 1'b1) && (sync_pos_scl == 1'b1)) 
		temp_reg <= {temp_reg[6:0], sda_in};
	else if((ST_IN_DATA == 1'b1) && (sync_neg_scl == 1'b1) && (is_restart == 1'b1)) 
		temp_reg <= {backup_reg, temp_reg[7:1]};
	else if((ST_OUT_DATA == 1'b1) && (sync_neg_scl == 1'b1))
		temp_reg <= temp_reg << 1;
	else 
		temp_reg <= temp_reg;
end

always @(posedge clk or negedge rst_n) begin //backup reg
	if(!rst_n)
		backup_reg <= 1'b0;
	else if((ST_IN_DATA == 1'b1) && (sync_pos_scl == 1'b1)) 
		backup_reg <= temp_reg[7];
	else 
		backup_reg <= backup_reg;
end

always @(posedge clk or negedge rst_n) begin //out data
	if(!rst_n)
		o_wr_data <= 8'd0;
	else if(ST_IN_DATA_ACK)
		o_wr_data <= temp_reg;
	else 
		o_wr_data <= o_wr_data;
end

always @(posedge clk or negedge rst_n) begin //out data
	if(!rst_n)
		o_wr_en <= 1'b0;
	else if(ST_IDLE)
		o_wr_en <= 1'b0;
	else if(ST_IN_DATA_ACK)
		o_wr_en <= 1'b1;
	else if(ST_STOP)
		o_wr_en <= 1'b0;
	else 
		o_wr_data <= o_wr_data;
end

always @(posedge clk or negedge rst_n) begin //DATA OUT
	if(!rst_n)
		sda_out <= 1'b1;
	else if(ST_IDLE)
		sda_out <= 1'b1;
	else if((ST_OUT_DATA == 1'b1) && (sync_pos_scl == 1'b1))
		sda_out <= temp_reg[7];
	else if ((device_addr == i_slave_addr)&& (sync_neg_scl == 1'd1) && (ST_ADDR == 1'b1) && (bit_counter == 3'd7))
		sda_out <= 1'b0;
	else if ((device_addr != i_slave_addr)&& (sync_neg_scl == 1'd1) && (ST_ADDR == 1'b1) && (bit_counter == 3'd7))
		sda_out <= 1'b1; 
	else if ((sync_neg_scl == 1'd1) && (ST_OFFSET == 1'b1) && (bit_counter == 3'd7))
		sda_out <= 1'b0; 
	else if ((sync_neg_scl == 1'd1) && (ST_IN_DATA == 1'b1) && (bit_counter == 3'd7))
		sda_out <= 1'b0; 
	else if ((ST_ADDR_ACK == 1'b1) && (sync_pos_scl == 1'b1))
		sda_out <= 1'b1; 
	else if ((ST_OFFSET_ACK == 1'b1) && (sync_pos_scl == 1'b1))
		sda_out <= 1'b1; 
	else if ((ST_IN_DATA_ACK == 1'b1) && (sync_pos_scl == 1'b1))
		sda_out <= 1'b1;  
	else 
		sda_out <= sda_out;
end

always @(posedge clk or negedge rst_n) begin // r/w signal
	if(!rst_n) 
		rw_signal <= 1'b0;
	else if(ST_IDLE) 
		rw_signal <= 1'b0;
	else if((ST_ADDR == 1'b1) && (sync_pos_scl == 1'b1) && (bit_counter == 3'd7))
		rw_signal <= sda;
	else 
		rw_signal <= rw_signal;
end



endmodule
