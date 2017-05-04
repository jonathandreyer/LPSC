//------------------------------------------------------------------------------------------------------
// Company:        Xilinx & HES//SO hepia
// Engineer:       Xavier Paillard
// 
// Create Date:    08:49:58 01/29/2013 
// Design Name:    DVI
// Module Name:    FMCVIDEO_LPBK_CTRL
// Project Name:   DVI
// Target Devices: Xilinx SP605 - XC6SLX45T-3fpgg484
// Tool versions:  Xilinx ISE 14.3 - Windows 7 64bits
// Description:    This module is a wrapper for a Picoblaze processor to control misc stuff (I2C, etc)
// Dependencies:   No
// Revision:       09-12-2007 Initial creation
//                 30-01-2013 File modified by Xavier Paillard, add simplification
//------------------------------------------------------------------------------------------------------

module FMCVIDEO_LPBK_CTRL
	(
	 CLK, // Clock @ 50 MHz 
	 RST, // Reset 
	 SCL, // I2C SCL
	 SDA  // I2C SDA
  );

	input  CLK; 
	input  RST; 
	output SCL; 
	inout  SDA; 

	// Picoblaze data bus 
	wire [7:0] adr, wr_dat, rd_dat;
	wire rd_strobe, wr_strobe;

	// PicoBlaze data bus stuff
	parameter [7:0] i2c_reg_adr = 8'h00;

	// I2C register
	reg SCL = 1, sda_out = 1; 
	tri SDA = !sda_out ? 1'b0 : 1'bz;
	
	always @(posedge CLK) 
	begin
		SCL     <=#1 (adr == i2c_reg_adr) && wr_dat[3] && wr_strobe ? wr_dat[2] : SCL;
		sda_out <=#1 (adr == i2c_reg_adr) && wr_dat[1] && wr_strobe ? wr_dat[0] : sda_out;
	end
	
	wire [7:0] i2c_reg_rd = {7'b0000_000, SDA};

	// generate read data
	assign rd_dat = (adr == i2c_reg_adr) ? i2c_reg_rd : 8'h00; 

	// Picoblaze Program
	wire [9:0] instruction_address;
	wire [17:0]	instruction;
	
	// ROM init programm
	PB_DVI_INIT prog 
		(
		 .CLK(CLK),                     // Clock @ 125 MHz
		 .ADDRESS(instruction_address), // Read memory address
		 .INSTRUCTION(instruction)      // Instruction datas
	  );

	// Picoblaze Processor
	reg  interrupt = 0;
	wire interrupt_ack;
	
	// Small processor (Picoblaze)
	kcpsm3 cpu
		(
		 .clk(CLK), 
		 .interrupt(interrupt), 
		 .interrupt_ack(interrupt_ack),
		 .address(instruction_address), 
		 .instruction(instruction), 
		 .port_id(adr), 
		 .in_port(rd_dat), 
		 .out_port(wr_dat), 
		 .read_strobe(rd_strobe), 
		 .write_strobe(wr_strobe), 
		 .reset(RST)
	  );

endmodule 