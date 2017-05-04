//------------------------------------------------------------------------------------------------------
// Company:        Xilinx & HES//SO hepia
// Engineer:       Xavier Paillard
//
// Create Date:    08:49:58 01/29/2013
// Design Name:    DVI
// Module Name:    SP601_BRD_CLOCKS
// Project Name:   DVI
// Target Devices: Xilinx SP605 - XC6SLX45T-3fpgg484
// Tool versions:  Xilinx ISE 14.3 - Windows 7 64bits
// Description:    Clock management
// Dependencies:   No
// Revision:       05-05-2009 Initial creation
//                 06-15-2009 Added PLL to generate MCB clocks, also used PLL to generate some others.
//                 29-01-2013 File modified by Xavier Paillard, add simplification
//------------------------------------------------------------------------------------------------------

module SP605_BRD_CLOCKS
	(
	 input  wire SYSCLK_P,SYSCLK_N, // RAW clock differtiential
	 input  wire RST,               // System reset
	 output wire SYSCLK,            // 200 Mhz
	 output wire CLK125,            // 125 Mhz
	 output wire CALIB_CLK          // 50 MHz
  );

	wire calib_clk_bufg_in;    // RAW PLL outputs
	wire clkfbout_clkfbin;     // Clock from PLLFBOUT to PLLFBIN
	wire clkfbout_clkfbin_125; // Clock from PLLFBOUT to PLLFBIN
	wire xclk125_tx;           // Clock 125 MHz signal

	BUFG calib_clk_bufg // Clock buffer
		(
		 .I(calib_clk_bufg_in),
		 .O(CALIB_CLK)
	  );

	BUFG bufg125_tx // Clock buffer
		(
		 .I(xclk125_tx),
		 .O(CLK125)
	  );

	IBUFGDS // Differential clock buffer
		#(
		  .DIFF_TERM("FALSE"),    // Differential Termination (Virtex-4/5, Spartan-3E/3A)
	     .IBUF_DELAY_VALUE("0"), // Specify the amount of added input delay for
									     // The buffer, "0"-"16" (Spartan-3E/3A only)
	     .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
		) inibufg
	   (
	    .O(SYSCLK), // Clock buffer output
	    .I(SYSCLK_P),      // Diff_p clock buffer input
	    .IB(SYSCLK_N)      // Diff_n clock buffer input
	  );

	PLL_ADV // Main PLL to generate all clocks
		#(
		  .BANDWIDTH          ("OPTIMIZED"),
		  .CLKIN1_PERIOD      (5),  // 200 MHz = 5 ns
		  .CLKIN2_PERIOD      (1),
		  .DIVCLK_DIVIDE      (1),
		  .CLKFBOUT_MULT      (5),  // 200 * 5 = 1000 MHz
		  .CLKFBOUT_PHASE     (0.0),
		  .CLKOUT0_DIVIDE     (8),  // 125 MHz
		  .CLKOUT1_DIVIDE     (),
		  .CLKOUT2_DIVIDE     (),
		  .CLKOUT3_DIVIDE     (20), // 50 MHz
		  .CLKOUT4_DIVIDE     (),
		  .CLKOUT5_DIVIDE     (),
		  .CLKOUT0_PHASE      (0.000),
		  .CLKOUT1_PHASE      (180.000),
		  .CLKOUT2_PHASE      (0.000),
		  .CLKOUT3_PHASE      (0.000),
		  .CLKOUT4_PHASE      (0.000),
		  .CLKOUT5_PHASE      (0.000),
		  .CLKOUT0_DUTY_CYCLE (0.500),
		  .CLKOUT1_DUTY_CYCLE (0.500),
		  .CLKOUT2_DUTY_CYCLE (0.500),
		  .CLKOUT3_DUTY_CYCLE (0.500),
		  .CLKOUT4_DUTY_CYCLE (0.500),
		  .CLKOUT5_DUTY_CYCLE (0.500),
		  .COMPENSATION       ("SYSTEM_SYNCHRONOUS"),
		  .REF_JITTER         (0.005000)
		 ) u_pll_adv_125
		 (
		  .CLKFBIN    (clkfbout_clkfbin_125),
		  .CLKINSEL   (1'b1),
		  .CLKIN1     (SYSCLK),
		  .CLKIN2     (1'b0),
		  .DADDR      (5'b0),
		  .DCLK       (1'b0),
		  .DEN        (1'b0),
		  .DI         (16'b0),
		  .DWE        (1'b0),
		  .REL        (1'b0),
		  .RST        (RST),
		  .CLKFBDCM   (),
		  .CLKFBOUT   (clkfbout_clkfbin_125), // PLL feedback
		  .CLKOUTDCM0 (),
		  .CLKOUTDCM1 (),
		  .CLKOUTDCM2 (),
		  .CLKOUTDCM3 (),
		  .CLKOUTDCM4 (),
		  .CLKOUTDCM5 (),
		  .CLKOUT0    (xclk125_tx),           // 125 MHz
		  .CLKOUT1    (),
		  .CLKOUT2    (),
		  .CLKOUT3    (calib_clk_bufg_in),    // 50 MHz
		  .CLKOUT4    (),
		  .CLKOUT5    (),
		  .DO         (),
		  .DRDY       (),
		  .LOCKED     ()
	    );

endmodule
