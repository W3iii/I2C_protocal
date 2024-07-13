module tb;
parameter CYCLE  = 10;
parameter CYCLE2 = 100;
reg 	  clk1;
reg 	  clk2;
reg	      rst_n;
reg	      scl;
tri	      sda;
reg  [6:0]i_slave_addr;
reg  [7:0]i_rd_data;	
wire	  o_wr_en;
wire [7:0]o_reg_addr;
wire [7:0]o_wr_data;
wire  	  o_rd_done;
reg	  	  sda_out;

I2C_slave U_I2C(
	.o_wr_en(o_wr_en),
	.o_reg_addr(o_reg_addr),
	.o_wr_data(o_wr_data),
	.o_rd_done(o_rd_done),
	.sda_out_en(sda_out_en),
	.clk(clk1),
	.rst_n(rst_n),
	.scl(scl),
	.sda(sda),
	.i_slave_addr(i_slave_addr),
	.i_rd_data(i_rd_data)
);

initial begin
	clk1 = 0;
	forever #(CYCLE/2) clk1 = ~clk1;
end

initial begin
	clk2 = 0;
	forever #(CYCLE2/2) clk2 = ~clk2;
end

assign sda = sda_out_en ? 1'bz : sda_out;

initial begin
	i_rd_data = 8'b00010011;
	scl = 1'b1;
	sda_out = 1'b1;
	rst_n = 1'b1;
	@(posedge clk2);
	rst_n = 1'b0;
	@(posedge clk2);
	rst_n = 1'b1;
	@(posedge clk2); //start sda = 0, scl = 1;
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b0;

	@(posedge clk2); //6
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //5
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //4
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //3
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //2
	sda_out = 1'b1;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //1
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //0
	sda_out = 1'b1;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //READ
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //ACK
	sda_out = 1'b1;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //OFFSET 7 10101010
	sda_out = 1'b1;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //OFFSET 6 
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //OFFSET 5
	sda_out = 1'b1;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //OFFSET 4
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //OFFSET 3
	sda_out = 1'b1;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //OFFSET 2
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //OFFSET 1
	sda_out = 1'b1;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //OFFSET 0
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //OFFSET ACK
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(posedge clk2); //DATA 7 10101010
	sda_out = 1'b1;        
	@(posedge clk2);   
	scl = 1'b1;        
	@(posedge clk2);   
	scl = 1'b0;        
	@(posedge clk2); //DATA 6 
	sda_out = 1'b0;       
	@(posedge clk2);  
	scl = 1'b1;       
	@(posedge clk2);  
	scl = 1'b0;       
	@(posedge clk2); //DATA 5
	sda_out = 1'b1;        
	@(posedge clk2);   
	scl = 1'b1;        
	@(posedge clk2);   
	scl = 1'b0;        
	@(posedge clk2); //DATA 4
	sda_out = 1'b0;        
	@(posedge clk2);   
	scl = 1'b1;        
	@(posedge clk2);   
	scl = 1'b0;        
	@(posedge clk2); //DATA 3
	sda_out = 1'b1;        
	@(posedge clk2);   
	scl = 1'b1;        
	@(posedge clk2);   
	scl = 1'b0;        
	@(posedge clk2); //DATA 2
	sda_out = 1'b0;        
	@(posedge clk2);   
	scl = 1'b1;        
	@(posedge clk2);   
	scl = 1'b0;        
	@(posedge clk2); //DATA 1
	sda_out = 1'b1;        
	@(posedge clk2);   
	scl = 1'b1;        
	@(posedge clk2);   
	scl = 1'b0;        
	@(posedge clk2); //DATA 0
	sda_out = 1'b0;        
	@(posedge clk2);   
	scl = 1'b1;        
	@(posedge clk2);   
	scl = 1'b0;        
	@(posedge clk2); //DATA ACK
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	
	@(posedge clk2);
	scl = 1'b1;
	@(posedge clk2); //STOP
	sda_out = 1'b1;
	@(posedge clk2);
	
	sda_out = 1'b0;  //START
	@(negedge clk2);
	scl = 1'b0;
	@(posedge clk2)  //device addr 0000101 7
	sda_out = 1'b0;
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2); //6
	sda_out = 1'b0; 
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //5
	sda_out = 1'b0; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2); //4
	sda_out = 1'b0; 
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //3
	sda_out = 1'b1; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2); //2
	sda_out = 1'b0; 
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //1
	sda_out = 1'b1; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2); //r/w = 0
	sda_out = 1'b0; 
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //wait for ack
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2); //offset 11010011 7
	sda_out = 1'b1; 
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //6
	sda_out = 1'b1; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2); //5
	sda_out = 1'b0; 
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //4
	sda_out = 1'b1; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2); //3
	sda_out = 1'b0; 
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //2
	sda_out = 1'b0; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2); //1
	sda_out = 1'b1; 
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //0
	sda_out = 1'b1; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2); //wait for ack
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); 
	sda_out = 1'b1;
	scl = 1'b1;
	@(negedge clk2); //RESTART
	sda_out = 1'b0;
	@(posedge clk2);
	scl = 1'b0;
	@(negedge clk2);
	sda_out = 1'b0;  // ADDR 0000101 6
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //5
	sda_out = 1'b0; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2);
	sda_out = 1'b0;  // ADDR 0000101 4
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //3
	sda_out = 1'b0; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2);
	sda_out = 1'b1;  // ADDR 0000101 2
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //1
	sda_out = 1'b0; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2);
	sda_out = 1'b1;  //0
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); // r/w = 1
	sda_out = 1'b1; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2); //wait for ack
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(posedge clk2); //get data 7 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(negedge clk2); //6
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	scl = 1'b0;
	@(posedge clk2); //5
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(negedge clk2); //4
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	scl = 1'b0;
	@(posedge clk2); //3 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(negedge clk2); //2
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	scl = 1'b0;
	@(posedge clk2); //1
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	scl = 1'b0;
	@(negedge clk2); //0
	@(posedge clk2);
	scl = 1'b1;
	@(negedge clk2);
	scl = 1'b0;
	@(posedge clk2); // send ACK
	sda_out = 1'b1; 
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b0;
	scl = 1'b0;
	@(negedge clk2);
	scl = 1'b1;
	@(posedge clk2);
	sda_out = 1'b1;
	@(negedge clk2);
	$stop;
end
endmodule