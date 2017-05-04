----------------------------------------------------------------------------------
-- Company:        Xilinx & HES//SO hepia
-- Engineer:       Xavier Paillard
-- 
-- Create Date:    08:49:58 01/29/2013 
-- Design Name:    DVI
-- Module Name:    dvi_ctrl
-- Project Name:   DVI
-- Target Devices: Xilinx SP605 - XC6SLX45T-3fpgg484
-- Tool versions:  Xilinx ISE 14.3 - Windows 7 64bits
-- Description:    DVI controller
-- Dependencies:   No
-- Revision:       Revision 0.01 - File created by Xilinx
--                 Revision 0.02 - File modified by Xavier Paillard
----------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;

entity dvi_ctrl is
	port (
			CLK        : in  std_logic;                     -- Clock @ 125 MHz
			RCOL       : in  std_logic_vector(7 downto 0);  -- RED color
			GCOL       : in  std_logic_vector(7 downto 0);  -- GREEN color
			BCOL       : in  std_logic_vector(7 downto 0);  -- BLUE color
			XPOS       : out std_logic_vector(10 downto 0); -- Pixel position X
			YPOS       : out std_logic_vector(10 downto 0); -- Pixel position Y
			DVI_XCLK_P : out std_logic;                     -- DVI differential clock
			DVI_XCLK_N : out std_logic;                     -- DVI differential clock
			DVI_DE     : out std_logic;                     -- DVI data enable
			DVI_H      : out std_logic;                     -- DVI horizontal sync
			DVI_V      : out std_logic;                     -- DVI vertical sync
			DVI_D      : out std_logic_vector(11 downto 0)  -- DVI data
	    );
end dvi_ctrl;

architecture Behavioral of dvi_ctrl is

	-- Video timing generator
	component VTG
		port (
				V_SYNC    : in  std_logic_vector(7 downto 0);  -- Vertical sync value
				V_BP      : in  std_logic_vector(7 downto 0);  -- Vertical back porch value
				V_ACT     : in  std_logic_vector(7 downto 0);  -- Vertical active line value
				V_FP      : in  std_logic_vector(7 downto 0);  -- Vertical front porch value
				H_SYNC    : in  std_logic_vector(7 downto 0);  -- Horizontal sync value
				H_BP      : in  std_logic_vector(7 downto 0);  -- Horizontal back porch value
				H_ACT     : in  std_logic_vector(7 downto 0);  -- Horizontal active line value
				H_FP      : in  std_logic_vector(7 downto 0);  -- Horizontal front porch value
				HS_POL    : in  std_logic;                     -- Horizontal sync polarity
				VS_POL    : in  std_logic;                     -- Vertical sync polarity
				PIX_CLK   : in  std_logic;                     -- Pixel clock (depend on the resolution)
				DE        : out std_logic;                     -- Data enable
				HS        : out std_logic;                     -- Horizontal sync
				VS        : out std_logic;                     -- Vertical sync
				VS_STROBE : out std_logic;                     -- Vertical sync strobe
				HS_STROBE : out std_logic;                     -- Horizontal sync strobe
				H_CNT     : out std_logic_vector(10 downto 0); -- Horizontal counter (line)
				V_CNT     : out std_logic_vector(10 downto 0)  -- Vertical counter (line)
			 );
	end component;
	
	-- Signals generation for on board DVI chip controller (Chrontel CH7301)
	component CH7301_OUT
		port (
				CLK        : in  std_logic;                    -- Clock @ 125 MHz
				CLK180     : in  std_logic;                    -- Clock @ 125 MHz inversed
				DE         : in  std_logic;                    -- Data enable
				HS         : in  std_logic;                    -- Horizontal sync
				VS         : in  std_logic;                    -- Vertical sync
				R          : in  std_logic_vector(7 downto 0); -- RED color value
				G          : in  std_logic_vector(7 downto 0); -- GREEN color value
				B          : in  std_logic_vector(7 downto 0); -- BLUE color value        
				DVI_XCLK_P : out std_logic;                    -- DVI differential clock
				DVI_XCLK_N : out std_logic;                    -- DVI differential clock
				DVI_DE     : out std_logic;                    -- DVI data enable
				DVI_HS     : out std_logic;                    -- DVI horizontal sync
				DVI_VS     : out std_logic;                    -- DVI vertical sync
				DVI_D      : out std_logic_vector(11 downto 0) -- DVI data
			 );
	end component;
	
	signal vtg_de     : std_logic; -- Video timing generation data enable
	signal vtg_hs     : std_logic; -- Video timing generation horizontal sync
	signal vtg_vs     : std_logic; -- Video timing generation vertical sync
	signal vtg_hs_stb : std_logic; -- Video timing generation horizontal sync strobe
	signal vtg_vs_stb : std_logic; -- Video timing generation vertical sync strobe
	signal CLK180_s   : std_logic; -- Clock 125 MHz at 180 degrees

begin

	CLK180_s <= not CLK; -- /!\ Inverse the main clock

	Inst_VTG: VTG 
		port map (
					 V_SYNC    => X"02",
					 V_BP      => X"25",
					 V_ACT     => X"7f",
					 V_FP      => X"00",
					 H_SYNC    => X"0d",
					 H_BP      => X"1e",
					 H_ACT     => X"9f",
					 H_FP      => X"05",
					 HS_POL    => '1',
					 VS_POL    => '1',
					 PIX_CLK   => CLK,
					 DE        => vtg_de,
					 HS        => vtg_hs,
					 VS        => vtg_vs,
					 VS_STROBE => vtg_vs_stb,
					 HS_STROBE => vtg_hs_stb,
					 H_CNT     => XPOS,
					 V_CNT     => YPOS
				  );

	Inst_CH7301_OUT: CH7301_OUT 
		port map (
					 CLK        => CLK,
					 CLK180     => CLK180_s,
					 DE         => vtg_de,
					 HS         => vtg_hs,
					 VS         => vtg_vs,
					 R          => RCOL,
					 G          => GCOL,
					 B          => BCOL,
					 DVI_XCLK_P => DVI_XCLK_P,
					 DVI_XCLK_N => DVI_XCLK_N,
					 DVI_DE     => DVI_DE,
					 DVI_HS     => DVI_H,
					 DVI_VS     => DVI_V,
					 DVI_D      => DVI_D
				  );
	
end Behavioral;