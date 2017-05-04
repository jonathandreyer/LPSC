//--------------------------------------------------------------------
// CH7301_OUT.v
//--------------------------------------------------------------------
// History of Changes:
//	8-30-2007  Initial creation
//--------------------------------------------------------------------
// Very simple module - only real operation is to DDR the data bits.
//--------------------------------------------------------------------

module CH7301_OUT
	(
	 CLK,        // Clock @ 125 MHz
	 CLK180,     // Clock @ 125 MHz @ 180 degree
	 DE,         // Data enable
	 HS,         // Horizontal sync
	 VS,         // Vertical sync
	 R,          // RED
	 G,          // GREEN
	 B,          // BLUE
	 DVI_XCLK_P, // DVI differential clock
	 DVI_XCLK_N, // DVI differential clock
	 DVI_DE,     // DVI data enable
	 DVI_HS,     // DVI horizontal sync
	 DVI_VS,     // DVI vertical sync
	 DVI_D	    // DVI data
  );

	// Video input stream
	input	CLK, CLK180;
	input	DE, HS, VS;
	input	[7:0]	R, G, B; // video data

	// Video interface to CH7301
	output DVI_XCLK_P, DVI_XCLK_N;
	output DVI_DE, DVI_HS, DVI_VS;
	output [11:0] DVI_D;

	FDRSE de_outff (.C(CLK180), .D(DE), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_DE));
	FDRSE hs_outff (.C(CLK180), .D(HS), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_HS));
	FDRSE vs_outff (.C(CLK180), .D(VS), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_VS));

	// Use these for Spartan based FPGAs (ODDR => Output double data rate)
	ODDR2 xclk_p_oddr (.C0(CLK), .C1(CLK180), .D0(1'b1), .D1(1'b0), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_XCLK_P) );
	ODDR2 xclk_n_oddr (.C0(CLK), .C1(CLK180), .D0(1'b0), .D1(1'b1), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_XCLK_N) );
	
	ODDR2 d00_oddr (.C0(CLK), .C1(CLK180), .D0(G[4]), .D1(B[0]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[00]) );
	ODDR2 d01_oddr (.C0(CLK), .C1(CLK180), .D0(G[5]), .D1(B[1]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[01]) );
	ODDR2 d02_oddr (.C0(CLK), .C1(CLK180), .D0(G[6]), .D1(B[2]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[02]) );
	ODDR2 d03_oddr (.C0(CLK), .C1(CLK180), .D0(G[7]), .D1(B[3]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[03]) );
	ODDR2 d04_oddr (.C0(CLK), .C1(CLK180), .D0(R[0]), .D1(B[4]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[04]) );
	ODDR2 d05_oddr (.C0(CLK), .C1(CLK180), .D0(R[1]), .D1(B[5]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[05]) );
	ODDR2 d06_oddr (.C0(CLK), .C1(CLK180), .D0(R[2]), .D1(B[6]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[06]) );
	ODDR2 d07_oddr (.C0(CLK), .C1(CLK180), .D0(R[3]), .D1(B[7]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[07]) );
	ODDR2 d08_oddr (.C0(CLK), .C1(CLK180), .D0(R[4]), .D1(G[0]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[08]) );
	ODDR2 d09_oddr (.C0(CLK), .C1(CLK180), .D0(R[5]), .D1(G[1]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[09]) );
	ODDR2 d10_oddr (.C0(CLK), .C1(CLK180), .D0(R[6]), .D1(G[2]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[10]) );
	ODDR2 d11_oddr (.C0(CLK), .C1(CLK180), .D0(R[7]), .D1(G[3]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DVI_D[11]) );

endmodule 