//------------------------------------------------------------------------------------------------------
// Company:        Xilinx & HES//SO hepia
// Engineer:       Xavier Paillard
// 
// Create Date:    08:49:58 01/29/2013 
// Design Name:    DVI
// Module Name:    VTG
// Project Name:   DVI
// Target Devices: Xilinx SP605 - XC6SLX45T-3fpgg484
// Tool versions:  Xilinx ISE 14.3 - Windows 7 64bits
// Description:    VS & HS timing relationship :
//                 Measured on REAL video:  VS edges coincide with HS leading edges.
// Dependencies:   No
// Revision:       05-13-2009 Initial creation
//                 05-14-2009 Simulated using attached test fixture
//                 29-01-2013 Add simplification Xavier Paillard05
//------------------------------------------------------------------------------------------------------

module VTG 
	(
	 V_SYNC,    // Vertical sync value 
	 V_BP,      // Vertical back porch value
	 V_ACT,     // Vertical active line value
	 V_FP,      // Vertical front porch value
	 H_SYNC,    // Horizontal sync value
	 H_BP,      // Horizontal back porch value
	 H_ACT,     // Horizontal active line value
	 H_FP,      // Horizontal front porch value
	 HS_POL,    // Horizontal sync polarity
	 VS_POL,    // Vertical sync polarity
	 PIX_CLK,   // Pixel clock (depend on the resolution)
	 DE,        // Data enable
	 HS,        // Horizontal sync
	 VS,        // Vertical sync
	 VS_STROBE, // Vertical sync strobe
	 HS_STROBE, // Horizontal sync strobe
	 H_CNT,     // Horizontal counter (line)
	 V_CNT      // Vertical counter (line)
  );

	// Vertical timings
	input	[7:0]	V_SYNC; // Lines in VSYNC, -1
	input	[7:0]	V_BP;   // Lines in vertical Back Porch, -1
	input	[7:0]	V_ACT;  // Active Line Count, /8 -1
	input	[7:0]	V_FP;   // Vertical Front Porch, in lines -1
	
	// Horizontal timings
	input	[7:0]	H_SYNC; // Hsync length, pixels /8 -1
	input	[7:0]	H_BP;   // Horizontal back porch, pixels /8 -1
	input	[7:0]	H_ACT;  // Active pixel count, pixels /8 -1
	input	[7:0]	H_FP;   // Horizontal front porch, pixels /8 -1
	
	// Sync polarity control
	input	HS_POL, VS_POL; // 0 for active low, 1 for active high
	
	// Clock
	input	PIX_CLK;
	
	// Generated timing signals
	output DE, HS, VS; 
	
	// Other useful signals
	output VS_STROBE, HS_STROBE;
	output [10:0] H_CNT, V_CNT; // line and pixel counts

	// Calculate base numbers for waveform generation
	reg [11:0] h_total_minus_one = 0;
	reg [10:0] v_total_minus_one = 0;
	reg [11:0] hs_start, hs_stop;
	reg [10:0] vs_start, vs_stop;

	always @(posedge PIX_CLK)
		begin
			h_total_minus_one <=#1 (H_ACT + H_FP + H_SYNC + H_BP + 4) * 8 - 1;
			v_total_minus_one <=#1 (V_ACT+1)*8 + V_FP + V_SYNC + V_BP + 3 - 1;
			hs_start          <=#1 (H_ACT + H_FP + 2) * 8;
			hs_stop           <=#1 (H_ACT + H_FP + H_SYNC + 3) * 8;
			vs_start          <=#1 ((V_ACT + 1) * 8 + V_FP          + 1);
			vs_stop           <=#1 ((V_ACT + 1) * 8 + V_FP + V_SYNC + 2);
		end

	// Counters to make video timings:
	reg [11:0] h_count = 0, h_count_next = 0;
	
	always @(posedge PIX_CLK) 
		begin
			h_count_next <=#1 (h_count_next == h_total_minus_one) ? 0 : h_count_next + 1;
			h_count      <=#1 h_count_next; // Pipeline delay makes h_count_next available for logic
		end
		
	reg [10:0] v_count = 0;
	
	always @(posedge PIX_CLK) 
		if (h_count_next == hs_start) // EOF
			v_count <=#1 (v_count == v_total_minus_one) ? 0 : v_count + 1;

	// Make the video timings
	reg vde_gen = 0, hde_gen = 0, hs_gen = 0, vs_gen = 0;
	
	always @(posedge PIX_CLK)
		begin
			hde_gen <=#1 h_count <= {H_ACT[7:0], 3'b111};
			vde_gen <=#1 v_count <= {V_ACT[7:0], 3'b111};
			hs_gen  <=#1 (h_count >= hs_start) && (h_count < hs_stop);
			vs_gen  <=#1 (v_count >= vs_start) && (v_count < vs_stop);
		end

	// Outputs
	reg DE = 0, HS = 0, VS = 0;
	reg VS_STROBE = 0, HS_STROBE = 0;
	reg [10:0]	H_CNT, V_CNT; // Line and pixel counts
	
	always @(posedge PIX_CLK)
		begin
			DE        <=#1 hde_gen && vde_gen;
			HS        <=#1 hs_gen ^ !HS_POL;
			VS        <=#1 vs_gen ^ !VS_POL;
			VS_STROBE <=#1 vs_gen && !(VS ^ !VS_POL);
			HS_STROBE <=#1 hs_gen && !(HS ^ !HS_POL);
			H_CNT     <=#1 hde_gen && vde_gen ? h_count-1 : 0;
			V_CNT     <=#1 hde_gen && vde_gen ? v_count : 0;
		end

endmodule 