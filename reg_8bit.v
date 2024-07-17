module reg_8bit ( d_out, clk, rst_n, en_reg, d_in );
input 		 clk, rst_n	, en_reg;
input	[7:0]d_in;
output	[7:0]d_out;
reg 	[7:0]d_out;
reg 	[7:0]reg_data;

always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n )
		reg_data <= 8'b11111111;
    else if ( en_reg )
		reg_data <= d_in;
end

always @(*) begin
	d_out = reg_data;
end

endmodule