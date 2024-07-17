module testbed;

parameter CYCLE  = 10;

wire	[7:0]o_reg_data;
wire		 o_rd_done;
wire		 o_wr_done;
wire		 o_i2c_done;
wire		 scl;
reg			 clk;
reg			 rst_n;	
tri1	     sda;
reg			 i_i2c_go;
reg			 i_rw;
reg		[7:0]i_reg_addr;
reg		[7:0]i_wr_data;
reg		[7:0]i_cycle;
reg		[6:0]i_i2c_slave_addr;
reg  	[6:0]i_slave_addr;
wire  	[7:0]i_rd_data;	
wire	  	 o_wr_en;
wire 	[7:0]o_reg_addr;
wire 	[7:0]o_wr_data;

I2C_master U_MASTER(
	.o_reg_data(o_reg_data),
	.o_rd_done(o_rd_done),
	.o_wr_done(o_wr_done),
	.o_i2c_done(o_i2c_done),
	.scl(scl),
	.clk(clk),
	.rst_n(rst_n),
	.sda(sda),
	.i_i2c_go(i_i2c_go),
	.i_rw(i_rw),
	.i_reg_addr(i_reg_addr),
	.i_wr_data(i_wr_data),
	.i_cycle(i_cycle),
	.i_i2c_slave_addr(i_i2c_slave_addr)
);

I2C_slave U_I2C(
	.o_wr_en(o_wr_en),
	.o_reg_addr(o_reg_addr),
	.o_wr_data(o_wr_data),
	.o_rd_done(o_rd_done),
	.clk(clk),
	.rst_n(rst_n),
	.scl(scl),
	.sda(sda),
	.i_slave_addr(i_slave_addr),
	.i_rd_data(i_rd_data)
);

reg_8bit U_REG(
	.d_out(i_rd_data),
	.clk(clk),
	.rst_n(rst_n),
	.d_in(o_wr_data),
	.en_reg(o_wr_en)
);
		
initial begin
	clk = 0;
	forever #(CYCLE/2) clk = ~clk;
end

initial begin
	clk = 1'b0;
	rst_n = 1'b1;
	repeat(2) @(posedge clk);
	rst_n = 1'b0;
	repeat(2) @(posedge clk);
	rst_n = 1'b1;
	@(posedge clk);
	i_i2c_go = 1'b1;
	i_rw = 1'b0;
	i_i2c_slave_addr = 7'b0100110;
	i_slave_addr = 7'b0100110;
	i_reg_addr = 8'b01010101;
	i_wr_data = 8'b11000011;
	wait(o_i2c_done == 1'b1)
	i_i2c_go = 1'b0;
	repeat(2) @(posedge clk);
	i_i2c_go = 1'b1;
	i_rw = 1'b1;
	wait(o_i2c_done == 1'b1)
	$stop;
end

endmodule
