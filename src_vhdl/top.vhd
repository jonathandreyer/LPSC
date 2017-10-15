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
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_1164.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.to_unsigned;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity top is
  port (
      RESET_I      : in    std_logic;                     -- Reset on switch button SW6
      SYSCLK_P     : in    std_logic;                     -- Differential clock @ 200 MHz
      SYSCLK_N     : in    std_logic;                     -- Differential clock @ 200 MHz
      DVI_XCLK_P   : out   std_logic;                     -- DVI differential clock
      DVI_XCLK_N   : out   std_logic;                     -- DVI differential clock
      DVI_DE       : out   std_logic;                     -- DVI data enable
      DVI_H        : out   std_logic;                     -- DVI horizontal sync
      DVI_V        : out   std_logic;                     -- DVI vertical sync
      DVI_D        : out   std_logic_vector(11 downto 0); -- DVI data
      DVI_RESET_B  : out   std_logic;                     -- DVI reset
      SDA_DVI      : inout std_logic;                     -- DVI I2C
      SCL_DVI      : out   std_logic;                     -- DVI I2C
      RESET_IP_o   : out   std_logic;
      BLINK_o      : out   std_logic;
      -- DDR 3 Memory signals
      MEM1_A       : out std_logic_vector(14 downto 0); 
      MEM1_BA      : out std_logic_vector(2 downto 0) ; 
      MEM1_CAS_B   : out std_logic;
      MEM1_CKE     : out std_logic; 
      MEM1_CLK_N   : out std_logic;
      MEM1_CLK_P   : out std_logic; 
      MEM1_DQ      : inout std_logic_vector(15 downto 0);  
      MEM1_LDM     : out std_logic;   
      MEM1_LDQS_N  : inout std_logic; 
      MEM1_LDQS_P  : inout std_logic;
      MEM1_ODT     : out std_logic;
      MEM1_RAS_B   : out std_logic;
      MEM1_RESET_B : out std_logic;
      MEM1_UDM     : out std_logic;
      MEM1_UDQS_N  : inout std_logic;
      MEM1_UDQS_P  : inout std_logic;
      MEM1_WE_B    : out std_logic;
      RZQ          : inout std_logic;
      ZIO          : inout std_logic
     );
end top;

architecture Behavioral of top is

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
      SYSCLK    : out std_logic; -- Clock @ 200 MHz
      CLK125    : out std_logic; -- Clock @ 125 MHz
      CALIB_CLK : out std_logic  -- Clock @ 50 MHz
    );
  end component;

  component gen_125Mhz_50Mhz
  port
   (-- Clock in ports
    CLK_IN1           : in     std_logic;
    -- Clock out ports
    CLK_OUT1          : out    std_logic;
    CLK_OUT2          : out    std_logic;
    -- Status and control signals
    RESET             : in     std_logic;
    LOCKED            : out    std_logic
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
        x_i             : in  std_logic_vector(10 downto 0);
        y_i             : in  std_logic_vector(10 downto 0);
        addr_o          : out std_logic_vector(21 downto 0)
      );
  end component;

  component IP_MandelbrotGenerator
    generic (
           SIZE_COMPLEX   : integer := 18;
           FRACTIONAL     : integer := 13;
           SIZE_ITER      : integer := 7;
           MAX_ITERATION  : integer := 100;
           X_SCREEN_SIZE  : integer := 1280;
           Y_SCREEN_SIZE  : integer := 1024;
           SIZE_SCREEN    : integer := 11
     );
    port (
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;
        x_o         : out std_logic_vector(SIZE_SCREEN-1 downto 0);
        y_o         : out std_logic_vector(SIZE_SCREEN-1 downto 0);
        trigger_i   : in  std_logic;
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
      CLK_OUT2          : out    std_logic;
      CLK_OUT3          : out    std_logic;
      -- Status and control signals
      RESET             : in     std_logic;
      LOCKED            : out    std_logic
     );
  end component;
  
  component ddr_control
   generic(
     C3_P0_MASK_SIZE           : integer := 4; 
     C3_P0_DATA_PORT_SIZE      : integer := 32;
     C3_P1_MASK_SIZE           : integer := 4;
     C3_P1_DATA_PORT_SIZE      : integer := 32;
     C3_MEMCLK_PERIOD          : integer := 3000;
     C3_RST_ACT_LOW            : integer := 0;
     C3_INPUT_CLK_TYPE         : string := "DIFFERENTIAL";
     C3_CALIB_SOFT_IP          : string := "TRUE";
     C3_SIMULATION             : string := "FALSE";
     DEBUG_EN                  : integer := 1;
     C3_MEM_ADDR_ORDER         : string := "ROW_BANK_COLUMN";
     C3_NUM_DQ_PINS            : integer := 16;
     C3_MEM_ADDR_WIDTH         : integer := 13;
     C3_MEM_BANKADDR_WIDTH     : integer := 3
  );
  port (
    mcb3_dram_dq                            : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
    mcb3_dram_a                             : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
    mcb3_dram_ba                            : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
    mcb3_dram_ras_n                         : out std_logic;
    mcb3_dram_cas_n                         : out std_logic;
    mcb3_dram_we_n                          : out std_logic;
    mcb3_dram_odt                           : out std_logic;
    mcb3_dram_reset_n                       : out std_logic;
    mcb3_dram_cke                           : out std_logic;
    mcb3_dram_dm                            : out std_logic;
    mcb3_dram_udqs                          : inout  std_logic;
    mcb3_dram_udqs_n                        : inout  std_logic;
    mcb3_rzq                                : inout  std_logic;
    mcb3_zio                                : inout  std_logic;
    mcb3_dram_udm                           : out std_logic;
    c3_sys_clk_p                            : in  std_logic;
    c3_sys_clk_n                            : in  std_logic;
    c3_sys_rst_i                            : in  std_logic;
    c3_calib_done                           : out std_logic;
    c3_clk0                                 : out std_logic;
    c3_rst0                                 : out std_logic;
    mcb3_dram_dqs                           : inout  std_logic;
    mcb3_dram_dqs_n                         : inout  std_logic;
    mcb3_dram_ck                            : out std_logic;
    mcb3_dram_ck_n                          : out std_logic;
    c3_p2_cmd_clk                           : in std_logic;
    c3_p2_cmd_en                            : in std_logic;
    c3_p2_cmd_instr                         : in std_logic_vector(2 downto 0);
    c3_p2_cmd_bl                            : in std_logic_vector(5 downto 0);
    c3_p2_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
    c3_p2_cmd_empty                         : out std_logic;
    c3_p2_cmd_full                          : out std_logic;
    c3_p2_rd_clk                            : in std_logic;
    c3_p2_rd_en                             : in std_logic;
    c3_p2_rd_data                           : out std_logic_vector(31 downto 0);
    c3_p2_rd_full                           : out std_logic;
    c3_p2_rd_empty                          : out std_logic;
    c3_p2_rd_count                          : out std_logic_vector(6 downto 0);
    c3_p2_rd_overflow                       : out std_logic;
    c3_p2_rd_error                          : out std_logic;
    c3_p3_cmd_clk                           : in std_logic;
    c3_p3_cmd_en                            : in std_logic;
    c3_p3_cmd_instr                         : in std_logic_vector(2 downto 0);
    c3_p3_cmd_bl                            : in std_logic_vector(5 downto 0);
    c3_p3_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
    c3_p3_cmd_empty                         : out std_logic;
    c3_p3_cmd_full                          : out std_logic;
    c3_p3_wr_clk                            : in std_logic;
    c3_p3_wr_en                             : in std_logic;
    c3_p3_wr_mask                           : in std_logic_vector(3 downto 0);
    c3_p3_wr_data                           : in std_logic_vector(31 downto 0);
    c3_p3_wr_full                           : out std_logic;
    c3_p3_wr_empty                          : out std_logic;
    c3_p3_wr_count                          : out std_logic_vector(6 downto 0);
    c3_p3_wr_underrun                       : out std_logic;
    c3_p3_wr_error                          : out std_logic
  );
  end component;

COMPONENT fifo
  PORT (
    rst       : IN  STD_LOGIC;
    wr_clk    : IN  STD_LOGIC;
    rd_clk    : IN  STD_LOGIC;
    din       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en     : IN  STD_LOGIC;
    rd_en     : IN  STD_LOGIC;
    dout      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full      : OUT STD_LOGIC;
    wr_ack    : OUT STD_LOGIC;
    empty     : OUT STD_LOGIC;
    valid     : OUT STD_LOGIC;
    underflow : OUT STD_LOGIC
  );
END COMPONENT;

component dvi_start_fsm 
  Port ( 
    reset_i  : in   STD_LOGIC;
    clk_i    : in   STD_LOGIC;
    xpos_i   : in   STD_LOGIC_VECTOR (10 downto 0);
    ypos_i   : in   STD_LOGIC_VECTOR (10 downto 0);
    enable_o : out  STD_LOGIC
 );
end component;

component ddr2fifo_fsm
  generic (
    BUSRT_LEN  : integer := 64
  );
  Port ( 
    clk_i             : in   STD_LOGIC;
    reset_i           : in   STD_LOGIC;
    ddr_cmd_en_o      : out  STD_LOGIC;
    ddr_cmd_addr_o    : out  STD_LOGIC_VECTOR (29 downto 0);
    ddr_read_en_o     : out  STD_LOGIC;
    ddr_data_empty_i  : in   STD_LOGIC;
    ddr_data_i        : in   STD_LOGIC_VECTOR(31 downto 0);
    ddr_calib_done_i  : in   STD_LOGIC;
    fifo_wr_en_o      : out  STD_LOGIC;
    fifo_data_o       : out  STD_LOGIC_VECTOR (7 downto 0);
    fifo_full_i       : in   STD_LOGIC;
    fifo_ack_i        : in   STD_LOGIC
  );
end component;

component MbGen2DDR_FSM 
  Port (
    clk_i             : in  STD_LOGIC;
    rst_i             : in  STD_LOGIC;
    mb_gen_trigger_o  : out  STD_LOGIC;
    mb_gen_finished_i : in  STD_LOGIC;
    ddr_calib_done_i  : in  STD_LOGIC;
    ddr_st_wr_o       : out  STD_LOGIC;
    ddr_fifo_empty_i  : in  STD_LOGIC;
    ddr_fifo_full_i   : in  STD_LOGIC;
    ddr_fifo_wr_en_o  : out  STD_LOGIC
  );
end component;

  signal sysclk_s    :std_logic;
  signal sysclk_buf_s : std_logic;

  -- DVI signals
  signal clk50          : std_logic;                     -- Clock @ 50 MHz
  signal clk125         : std_logic;                     -- Clock @ 125 MHz
  signal dvi_red        : std_logic_vector(7 downto 0);  -- RED color channel
  signal dvi_green      : std_logic_vector(7 downto 0);  -- GREEN color channel
  signal dvi_blue       : std_logic_vector(7 downto 0);  -- BLUE color channel
  signal dvi_xpos       : std_logic_vector(10 downto 0); -- Pixel position X
  signal dvi_ypos       : std_logic_vector(10 downto 0); -- Pixel position Y

  -- Fifo signals
  signal fifo_dout      : std_logic_vector(7 downto 0);
  signal fifo_rd_en     : std_logic;
  signal fifo_wr_en     : std_logic;
  signal fifo_din       : std_logic_vector(7 downto 0);
  signal fifo_full      : std_logic;
  signal fifo_ack       : std_logic;

  -- DDR read path signals
  signal ddr_rd_cmd_en  : std_logic;
  signal ddr_rd_addr    : std_logic_vector(29 downto 0);
  signal ddr_rd_en      : std_logic;
  signal ddr_rd_empty   : std_logic;
  signal ddr_rd_data    : std_logic_vector(31 downto 0);

  -- DDR Write path signals
  signal ddr_wr_cmd_en  : std_logic;
  signal ddr_wr_empty   : std_logic;
  signal ddr_wr_full    : std_logic;
  signal ddr_wr_en      : std_logic;

  -- Signals for the generation side
  signal clk_110        : std_logic;
  signal gen_locked     : std_logic;
  signal gen_reset      : std_logic;
  signal gen_x          : std_logic_vector(10 downto 0);
  signal gen_y          : std_logic_vector(10 downto 0);
  signal gen_data       : std_logic_vector(6 downto 0);
  signal gen_data_32    : std_logic_vector(31 downto 0);
  signal gen_addr       : std_logic_vector(21 downto 0);
  signal gen_addr_30    : std_logic_vector(29 downto 0);
  signal gen_trigger    : std_logic;
  signal gen_finished   : std_logic;

  -- Test signals (used to blink a led)
  SIGNAL counter_s      : std_logic_vector(31 DOWNTO 0);
  SIGNAL bascule_s      : std_logic;

  -- Signal for the D

  -- DDR3 sys clock
  signal clk_330        : std_logic;
  signal ddr_calib_done : std_logic;

  -- DDR to DVI signals
  signal clk_150        : std_logic;

begin

  gen_pll : Clock_Generator_Mandelbrot
    port map
    (-- Clock in ports
     CLK_IN1 => sysclk_buf_s,
     -- Clock out ports
     CLK_OUT1 => clk_110,
     CLK_OUT2 => clk_150,
     CLK_OUT3 => clk_330,
     -- Status and control signals
     RESET  => RESET_I,
     LOCKED => gen_locked);
    
    
   gen_data_32 <= X"000000" & '0' & gen_data;
  gen_addr_30 <= "00000000" & gen_addr;

  u_ddr_control : ddr_control
  generic map (
    C3_P0_MASK_SIZE           =>  4,
    C3_P0_DATA_PORT_SIZE      =>  32,
    C3_P1_MASK_SIZE           =>  4,
    C3_P1_DATA_PORT_SIZE      =>  32,
    C3_MEMCLK_PERIOD          =>  3000,
    C3_RST_ACT_LOW            =>  0,
    C3_INPUT_CLK_TYPE         => "DIFFERENTIAL",
    C3_CALIB_SOFT_IP          => "TRUE",
    C3_SIMULATION             => "FALSE",
    DEBUG_EN                  =>  1,
    C3_MEM_ADDR_ORDER         => "ROW_BANK_COLUMN",
    C3_NUM_DQ_PINS            =>  16,
    C3_MEM_ADDR_WIDTH         =>  13,
    C3_MEM_BANKADDR_WIDTH     =>  3
  )
  port map (

    c3_sys_clk_p          =>  SYSCLK_P,
    c3_sys_clk_n        => SYSCLK_N,
    c3_sys_rst_i        =>  RESET_I,                        

    -- DDR side signals
    mcb3_dram_dq        =>  MEM1_DQ,  
    mcb3_dram_a         =>  MEM1_A(12 downto 0),  
    mcb3_dram_ba        =>  MEM1_BA,
    mcb3_dram_ras_n     =>  MEM1_RAS_B,                        
    mcb3_dram_cas_n     =>  MEM1_CAS_B,                        
    mcb3_dram_we_n      =>  MEM1_WE_B,                          
    mcb3_dram_odt       =>  MEM1_ODT,
    mcb3_dram_cke       =>  MEM1_CKE,                          
    mcb3_dram_ck        =>  MEM1_CLK_P,                          
    mcb3_dram_ck_n      =>  MEM1_CLK_N,       
    mcb3_dram_dqs       =>  MEM1_LDQS_P,                          
    mcb3_dram_dqs_n     =>  MEM1_LDQS_N,
    mcb3_dram_reset_n   =>  MEM1_RESET_B,
    mcb3_dram_udqs      =>  MEM1_UDQS_P,    -- for X16 parts           
    mcb3_dram_udqs_n    =>  MEM1_UDQS_N,    -- for X16 parts
    mcb3_dram_udm       =>  MEM1_UDM,     -- for X16 parts
    mcb3_dram_dm        =>  MEM1_LDM,
    mcb3_rzq            =>  RZQ,      
    mcb3_zio            =>  ZIO,

    c3_clk0             =>  sysclk_buf_s,
    c3_rst0             =>  open,
    
   


    c3_calib_done       =>  ddr_calib_done,

    -- Read port
    c3_p2_cmd_clk       =>  clk_150, 
    c3_p2_cmd_en        =>  ddr_rd_cmd_en,
    c3_p2_cmd_instr     =>  "001",
    c3_p2_cmd_bl        =>  std_logic_vector(to_unsigned(63,6)),
    c3_p2_cmd_byte_addr =>  ddr_rd_addr,
    c3_p2_cmd_empty     =>  open,
    c3_p2_cmd_full      =>  open,
    c3_p2_rd_clk        =>  clk_150,
    c3_p2_rd_en         =>  ddr_rd_en,
    c3_p2_rd_data       =>  ddr_rd_data,
    c3_p2_rd_full       =>  open,
    c3_p2_rd_empty      =>  ddr_rd_empty,
    c3_p2_rd_count      =>  open,
    c3_p2_rd_overflow   =>  open,
    c3_p2_rd_error      =>  open,

    -- Write port
 
    c3_p3_cmd_clk       =>  clk_110,
    c3_p3_cmd_en        =>  ddr_wr_cmd_en,
    c3_p3_cmd_instr     =>  "000",
    c3_p3_cmd_bl        =>  std_logic_vector(to_unsigned(63,6)),
    c3_p3_cmd_byte_addr =>  gen_addr_30,
    c3_p3_cmd_empty     =>  open,
    c3_p3_cmd_full      =>  open,
    c3_p3_wr_clk        =>  clk_110,
    c3_p3_wr_en         =>  ddr_wr_en,
    c3_p3_wr_mask       =>  "0000",
    c3_p3_wr_data       =>  gen_data_32, -- we work with 8 bits used only
    c3_p3_wr_full       =>  ddr_wr_full,
    c3_p3_wr_empty      =>  ddr_wr_empty,
    c3_p3_wr_count      =>  open,
    c3_p3_wr_underrun   =>  open,
    c3_p3_wr_error      =>  open
  );
  
  MEM1_A(13) <= '0';
  MEM1_A(14) <= '0';


  -- This device initialize the DVI screen using the I2C interface. Black box, supplied by the teacher.
  Inst_FMCVIDEO_LPBK_CTRL: FMCVIDEO_LPBK_CTRL
  port map (
    CLK => clk50,
    RST => RESET_I,
    SCL => SCL_DVI,
    SDA => SDA_DVI
  );

  -- This component generate the 125Mhz and 50Mhz clock out of the 200MHz system clock.
  gen_125Mhz_50Mhz_i : gen_125Mhz_50Mhz
  port map
   (-- Clock in portsk
    CLK_IN1 => sysclk_buf_s,
    -- Clock out ports
    CLK_OUT1 => clk125,
    CLK_OUT2 => clk50,
    -- Status and control signals
    RESET  => RESET_I,
    LOCKED => open
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

  dvi_fifo : fifo
  PORT MAP (
    rst       => RESET_I,
    wr_clk    => clk_150,
    rd_clk    => clk125,
    din       => fifo_din,
    wr_en     => fifo_wr_en,
    rd_en     => fifo_rd_en,
    dout      => fifo_dout,
    full      => fifo_full,
    wr_ack    => fifo_ack,
    empty     => open,
    valid     => open,
    underflow => open
  );


  dvi_start_fsm_i: dvi_start_fsm 
  port map ( 
    reset_i    => RESET_I,
    clk_i      => clk125,
    xpos_i     => dvi_ypos,
    ypos_i     => dvi_xpos,
    enable_o   => fifo_rd_en
  );

ddr2_fifo_fsm_i: ddr2fifo_fsm
  generic map (
    BUSRT_LEN => 64
  )
  port map ( 
    clk_i             => clk_150,
    reset_i           => RESET_I,
    ddr_cmd_en_o      => ddr_rd_cmd_en,
    ddr_cmd_addr_o    => ddr_rd_addr,
    ddr_read_en_o     => ddr_rd_en,
    ddr_data_empty_i  => ddr_rd_empty,
    ddr_data_i        => ddr_rd_data,
    ddr_calib_done_i  => ddr_calib_done,
    fifo_wr_en_o      => fifo_wr_en,
    fifo_data_o       => fifo_din,
    fifo_full_i       => fifo_full,
    fifo_ack_i        => fifo_ack
  );


  PixelColor_i : PixelColor
  port map (
    iteration_i => fifo_dout,
    r_o         => dvi_red,
    g_o         => dvi_green,
    b_o         => dvi_blue
  );


  IP_MandelbrotGenerator_i: IP_MandelbrotGenerator
  port map (
      clk_i         => clk_110,
      rst_i         => gen_reset,
      x_o           => gen_x,
      y_o           => gen_y,
      trigger_i     => gen_trigger,
      finish_o      => gen_finished,
      iteration_o   => gen_data
  );

  XYtoRam_gen_i:  CoordinateXYtoMemoryADDR
  port map (
    x_i             => gen_x,
    y_i             => gen_y,
    addr_o          => gen_addr
  );

  MbGen2DDR_FMS_i: MbGen2DDR_FSM 
  port map (
    clk_i             => clk_110,
    rst_i             => gen_reset,
    mb_gen_trigger_o  => gen_trigger,
    mb_gen_finished_i => gen_finished,
    ddr_calib_done_i  => ddr_calib_done,
    ddr_st_wr_o       => ddr_wr_cmd_en,
    ddr_fifo_empty_i  => ddr_wr_empty,
    ddr_fifo_full_i   => ddr_wr_full,
    ddr_fifo_wr_en_o  => ddr_wr_en
  );



  PROCESS (clk_110, gen_reset)
    BEGIN
      IF gen_reset = '1' THEN
        counter_s <= (OTHERS => '0');
        bascule_s <= '0';
      ELSIF rising_edge(clk_110) THEN
        IF counter_s = X"014FB180" then
          counter_s <= (OTHERS => '0');
          IF bascule_s = '0' THEN
            bascule_s <= '1';
          ELSE
            bascule_s <= '0';
          END IF;
        ELSE
          counter_s <=  unsigned(counter_s) + 1;
        END IF;
      END IF;
    END PROCESS;

  -- Reset the DVI
  DVI_RESET_B <= '1';

  -- Reset Mandelbrot IP
  gen_reset <= not gen_locked;
  RESET_IP_o <= gen_reset;
  BLINK_o <= bascule_s;

end Behavioral;
