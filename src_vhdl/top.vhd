----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    18:13:58 05/02/2017
-- Design Name:
-- Module Name:    top - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
	port (
			RESET_I     : in    std_logic;                     -- Reset on switch button SW6
			SYSCLK_P    : in    std_logic;                     -- Differential clock @ 200 MHz
			SYSCLK_N    : in    std_logic;                     -- Differential clock @ 200 MHz
			DVI_XCLK_P  : out   std_logic;                     -- DVI differential clock
			DVI_XCLK_N  : out   std_logic;                     -- DVI differential clock
			DVI_DE      : out   std_logic;                     -- DVI data enable
			DVI_H       : out   std_logic;                     -- DVI horizontal sync
			DVI_V       : out   std_logic;                     -- DVI vertical sync
			DVI_D       : out   std_logic_vector(11 downto 0); -- DVI data
			DVI_RESET_B : out   std_logic;                     -- DVI reset
			SDA_DVI     : inout std_logic;                     -- DVI I2C
			SCL_DVI     : out   std_logic                      -- DVI I2C
		 );
end top;

architecture Behavioral of top is

	component bram
	  port (
		 clka : IN STD_LOGIC;
		 ena : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		 clkb : IN STD_LOGIC;
		 addrb : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		 doutb : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	  );
	end component;

	component dvi_ctrl
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
	end component;

	-- Generates clocks for the entire design
	component SP605_BRD_CLOCKS
		port (
			   SYSCLK_P  : in  std_logic; -- Differential clock @ 200 MHz
				SYSCLK_N  : in  std_logic; -- Differential clock @ 200 MHz
			   RST       : in  std_logic; -- Reset
				 SYSCLK    : in  std_logic; -- Clock @ 200 MHz
			   CLK125    : out std_logic; -- Clock @ 125 MHz
			   CALIB_CLK : out std_logic  -- Clock @ 50 MHz
			 );
	end component;

	-- Control the communication with the DVI screen (I2C)
	component FMCVIDEO_LPBK_CTRL
		port (
			   CLK : in    std_logic; -- Clock @ 50 MHz
			   RST : in    std_logic; -- Reset
			   SDA : inout std_logic; -- I2C
			   SCL : out   std_logic  -- I2C
 			 );
	end component;

	component PixelColor
	  generic (
           SIZE : integer := 8
	  );
	  port (
		  iteration_i     : in  std_logic_vector(SIZE-1 downto 0);
		  r_o             : out std_logic_vector(SIZE-1 downto 0);
		  g_o             : out std_logic_vector(SIZE-1 downto 0);
		  b_o             : out std_logic_vector(SIZE-1 downto 0)
	   );
	end component;

	component CoordinateXYtoMemoryADDR
     port (
        x_i             : in  std_logic_vector(8 downto 0);
        y_i             : in  std_logic_vector(8 downto 0);
        addr_o          : out std_logic_vector(17 downto 0)
     );
   end component;

	component LimiterXYtoBRAM is
	  port (
			  x_i             : in  std_logic_vector(10 downto 0);
			  y_i             : in  std_logic_vector(10 downto 0);
			  iter_i          : in  std_logic_vector(6 downto 0);
			  x_o             : out std_logic_vector(8 downto 0);
			  y_o             : out std_logic_vector(8 downto 0);
			  iter_o          : out std_logic_vector(7 downto 0)
			 );
	end component;

	component IP_MandelbrotGenerator is
	  generic (
           SIZE_COMPLEX   : integer := 18;
           FRACTIONAL     : integer := 13;
           SIZE_ITER      : integer := 7;
           MAX_ITERATION  : integer := 100;
           X_SCREEN_SIZE  : integer := 512;
           Y_SCREEN_SIZE  : integer := 512;
           SIZE_SCREEN    : integer := 9
     );
	  port (
			  clk_i       : in  std_logic;
			  rst_i       : in  std_logic;
			  x_o         : out std_logic_vector(SIZE_SCREEN-1 downto 0);
			  y_o         : out std_logic_vector(SIZE_SCREEN-1 downto 0);
			  finish_o    : out std_logic;
			  iteration_o : out std_logic_vector(SIZE_ITER-1 downto 0)
			 );
	end component;

	component Clock_Generator_Mandelbrot
	port
	 (-- Clock in ports
	  CLK_IN1           : in     std_logic;
	  -- Clock out ports
	  CLK_OUT1          : out    std_logic;
	  -- Status and control signals
	  RESET             : in     std_logic;
	  LOCKED            : out    std_logic
	 );
	end component;

	signal sysclk_buf_s : std_logic;

	-- DVI signals
	signal clk50      : std_logic;                     -- Clock @ 50 MHz
	signal clk125     : std_logic;                     -- Clock @ 125 MHz
	signal dvi_red    : std_logic_vector(7 downto 0);  -- RED color channel
	signal dvi_green  : std_logic_vector(7 downto 0);  -- GREEN color channel
	signal dvi_blue   : std_logic_vector(7 downto 0);  -- BLUE color channel
	signal dvi_xpos   : std_logic_vector(10 downto 0); -- Pixel position X
	signal dvi_ypos   : std_logic_vector(10 downto 0); -- Pixel position Y

	signal dvi_xpos_lim : std_logic_vector(8 downto 0);
	signal dvi_ypos_lim : std_logic_vector(8 downto 0);
	signal dvi_addr     : std_logic_vector(17 downto 0);
	signal dvi_data     : std_logic_vector(6 downto 0);
	signal dvi_data_lim : std_logic_vector(7 downto 0);


	-- Signals for the generation side
	signal clk_110  : std_logic;
	signal gen_locked : std_logic;
	signal gen_reset  : std_logic;
	signal gen_x    : std_logic_vector(8 downto 0);
	signal gen_y    : std_logic_vector(8 downto 0);
	signal gen_data : std_logic_vector(6 downto 0);
	signal gen_addr : std_logic_vector(17 downto 0);
	signal gen_write: std_logic;
	signal gen_write_bus: std_logic_vector(0 downto 0);

begin

	gen_110_mhz : Clock_Generator_Mandelbrot
	  port map
		(-- Clock in ports
		 CLK_IN1 => sysclk_buf_s,
		 -- Clock out ports
		 CLK_OUT1 => clk_110,
		 -- Status and control signals
		 RESET  => RESET_I,
		 LOCKED => gen_locked);

	-- This device initialize the DVI screen using the I2C interface. Black box, supplied by the teacher.
	Inst_FMCVIDEO_LPBK_CTRL: FMCVIDEO_LPBK_CTRL
	port map (
		 CLK => clk50,
		 RST => RESET_I,
		 SCL => SCL_DVI,
		 SDA => SDA_DVI
	  );

	-- This component generate the 125Mhz and 50Mhz clock out of the 200MHz system clock.
	Inst_SP605_BRD_CLOCKS: SP605_BRD_CLOCKS
		port map (
			 SYSCLK_P  => SYSCLK_P,
	         SYSCLK_N  => SYSCLK_N,
				SYSCLK => sysclk_buf_s,
			 CALIB_CLK => clk50,
			 CLK125    => clk125,
			 RST       => RESET_I
		  );

	  -- This copoment drive the DVI signals using the RGB data.
	  Inst_dvictrl: dvi_ctrl
		port map (
					 -- Top level
					 CLK        => clk125,
					 RCOL       => dvi_red,
					 GCOL       => dvi_green,
					 BCOL       => dvi_blue,
					 XPOS       => dvi_xpos,
					 YPOS       => dvi_ypos,
					 -- dvi side signal
					 DVI_XCLK_P => DVI_XCLK_P,
					 DVI_XCLK_N => DVI_XCLK_N,
					 DVI_DE     => DVI_DE,
					 DVI_H      => DVI_H,
					 DVI_V      => DVI_V,
					 DVI_D      => DVI_D
				  );

      limiter_i: LimiterXYtoBRAM
	  port map (
			  x_i             => dvi_xpos,
			  y_i             => dvi_ypos,
			  iter_i          => dvi_data,
			  x_o             => dvi_xpos_lim,
			  y_o             => dvi_ypos_lim,
			  iter_o          => dvi_data_lim
			 );

		PixelColor_i : PixelColor
			port map (
			  iteration_i => dvi_data_lim,
			  r_o         => dvi_red,
			  g_o         => dvi_green,
			  b_o         => dvi_blue
			);

	  XYtoRam_dvi_i: 	CoordinateXYtoMemoryADDR
     port map (
        x_i             => dvi_xpos_lim,
        y_i             => dvi_ypos_lim,
        addr_o          => dvi_addr
     );

	IP_MandelbrotGenerator_i: IP_MandelbrotGenerator
	  port map (
			  clk_i   			=> clk_110,
			  rst_i   			=> gen_reset,
			  x_o     			=> gen_x,
			  y_o     			=> gen_y,
			  finish_o    		=> gen_write,
			  iteration_o       => gen_data
	  );

	XYtoRam_gen_i: 	CoordinateXYtoMemoryADDR
     port map (
        x_i             => gen_x,
        y_i             => gen_y,
        addr_o          => gen_addr
     );


	bram_i : bram
	  port map (
		 clka => clk_110,
		 ena => '1',
		 wea => gen_write_bus,
		 addra => gen_addr,
		 dina => gen_data,
		 clkb => clk125,
		 addrb => dvi_addr,
		 doutb => dvi_data
	  );

	-- tricks the system
	gen_write_bus <= (others => '1') when gen_write = '1' else  (others => '0');

	-- Reset the DVI
	DVI_RESET_B <= RESET_I;

	-- Reset Mandelbrot IP
	gen_reset <= not gen_locked;

end Behavioral;
