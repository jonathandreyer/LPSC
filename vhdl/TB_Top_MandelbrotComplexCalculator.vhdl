library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;

entity TB_Top_IP_MandelbrotComplexCalculator is

  generic (
           SIZE       : integer := 18;
           FRACTIONAL : integer := 13
          );

end entity TB_Top_IP_MandelbrotComplexCalculator;

architecture Behavioral of TB_Top_IP_MandelbrotComplexCalculator is

  signal clk          : std_logic;
  signal rst          : std_logic;
  signal enable       : std_logic;
  signal c_re         : std_logic_vector(SIZE-1 downto 0);
  signal c_im         : std_logic_vector(SIZE-1 downto 0);
  signal z_re         : std_logic_vector(SIZE-1 downto 0);
  signal z_im         : std_logic_vector(SIZE-1 downto 0);
  signal z_norm_limit : std_logic_vector(SIZE-1 downto 0);
  signal z_re_1       : std_logic_vector(SIZE-1 downto 0);
  signal z_im_1       : std_logic_vector(SIZE-1 downto 0);
  signal isDivergent  : std_logic;

  component MandelbrotComplexCalculator
    generic (
             SIZE       : integer := SIZE;
             FRACTIONAL : integer := FRACTIONAL
            );
    port (
          clk_i           : in  std_logic;
          rst_i           : in  std_logic;
          enable_i        : in  std_logic;
          c_re_i          : in  std_logic_vector(SIZE-1 downto 0);
          c_im_i          : in  std_logic_vector(SIZE-1 downto 0);
          z_re_i          : in  std_logic_vector(SIZE-1 downto 0);
          z_im_i          : in  std_logic_vector(SIZE-1 downto 0);
          z_norm_limit_i  : in  std_logic_vector(SIZE-1 downto 0);
          z_re_1_o        : out std_logic_vector(SIZE-1 downto 0);
          z_im_1_o        : out std_logic_vector(SIZE-1 downto 0);
          isDivergent_o   : out std_logic
         );
  end component MandelbrotComplexCalculator;

  component TB_Stimuli_IP_MandelbrotComplexCalculator
    port (
          clk             : out std_logic;
          rst_o           : out std_logic;
          enable_o        : out std_logic;
          c_re_o          : out std_logic_vector(SIZE-1 downto 0);
          c_im_o          : out std_logic_vector(SIZE-1 downto 0);
          z_re_o          : out std_logic_vector(SIZE-1 downto 0);
          z_im_o          : out std_logic_vector(SIZE-1 downto 0);
          z_norm_limit_o  : out std_logic_vector(SIZE-1 downto 0);
          z_re_1_i        : in  std_logic_vector(SIZE-1 downto 0);
          z_im_1_i        : in  std_logic_vector(SIZE-1 downto 0);
          isDivergent_i   : in  std_logic
         );
  end component TB_Stimuli_IP_MandelbrotComplexCalculator;

begin

  DUT: MandelbrotComplexCalculator
    port map (
              clk_i          => clk,
              rst_i          => rst,
              enable_i       => enable,
              c_re_i         => c_re,
              c_im_i         => c_im,
              z_re_i         => z_re,
              z_im_i         => z_im,
              z_norm_limit_i => z_norm_limit,
              z_re_1_o       => z_re_1,
              z_im_1_o       => z_im_1,
              isDivergent_o  => isDivergent
             );

  TB_Stimuli: TB_Stimuli_IP_MandelbrotComplexCalculator
    port map (
              clk            => clk,
              rst_o          => rst,
              enable_o       => enable,
              c_re_o         => c_re,
              c_im_o         => c_im,
              z_re_o         => z_re,
              z_im_o         => z_im,
              z_norm_limit_o => z_norm_limit,
              z_re_1_i       => z_re_1,
              z_im_1_i       => z_im_1,
              isDivergent_i  => isDivergent
             );

end architecture Behavioral;
