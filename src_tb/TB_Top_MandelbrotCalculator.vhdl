library ieee;
use ieee.std_logic_1164.all;

entity TB_Top_MandelbrotCalculator is

  generic (
           SIZE           : integer := 18;
           FRACTIONAL     : integer := 13;
           SIZE_ITER      : integer := 8;
           MAX_ITERATION  : integer := 100
          );

end entity TB_Top_MandelbrotCalculator;

architecture Behavioral of TB_Top_MandelbrotCalculator is

  signal clk_s          : std_logic;
  signal rst_s          : std_logic;
  signal start_s        : std_logic;
  signal c_re_s         : std_logic_vector(SIZE-1 downto 0);
  signal c_im_s         : std_logic_vector(SIZE-1 downto 0);
  signal z_re_s         : std_logic_vector(SIZE-1 downto 0);
  signal z_im_s         : std_logic_vector(SIZE-1 downto 0);
  signal iteration_s    : std_logic_vector(SIZE_ITER-1 downto 0);
  signal finished_s     : std_logic;

  component MandelbrotCalculator
    generic (
             SIZE           : integer;
             FRACTIONAL     : integer;
             SIZE_ITER      : integer;
             MAX_ITERATION  : integer
            );
    port (
          clk_i       : in  std_logic;
          rst_i       : in  std_logic;
          start_i     : in  std_logic;
          c_re_i      : in  std_logic_vector(SIZE-1 downto 0);
          c_im_i      : in  std_logic_vector(SIZE-1 downto 0);
          z_re_o      : out std_logic_vector(SIZE-1 downto 0);
          z_im_o      : out std_logic_vector(SIZE-1 downto 0);
          iteration_o : out std_logic_vector(SIZE_ITER-1 downto 0);
          finish_o    : out std_logic
         );
  end component MandelbrotCalculator;

  component TB_Stimuli_MandelbrotCalculator
    generic (
             SIZE      : integer;
             SIZE_ITER : integer
            );
    port (
          clk_o       : out std_logic;
          rst_o       : out std_logic;
          start_o     : out std_logic;
          c_re_o      : out std_logic_vector(SIZE-1 downto 0);
          c_im_o      : out std_logic_vector(SIZE-1 downto 0);
          z_re_i      : in  std_logic_vector(SIZE-1 downto 0);
          z_im_i      : in  std_logic_vector(SIZE-1 downto 0);
          iteration_i : in  std_logic_vector(SIZE_ITER-1 downto 0);
          finish_i    : in  std_logic
         );
  end component TB_Stimuli_MandelbrotCalculator;

begin

  DUT: MandelbrotCalculator
    generic map (
                 SIZE           => SIZE,
                 FRACTIONAL     => FRACTIONAL,
                 SIZE_ITER      => SIZE_ITER,
                 MAX_ITERATION  => MAX_ITERATION
                )
    port map(
             clk_i          => clk_s,
             rst_i          => rst_s,
             start_i        => start_s,
             c_re_i         => c_re_s,
             c_im_i         => c_im_s,
             z_re_o         => z_re_s,
             z_im_o         => z_im_s,
             iteration_o    => iteration_s,
             finish_o       => finished_s
             );

  TB_Stimuli: TB_Stimuli_MandelbrotCalculator
    generic map (
                 SIZE      => SIZE,
                 SIZE_ITER => SIZE_ITER
                )
    port map (
              clk_o       => clk_s,
              rst_o       => rst_s,
              start_o     => start_s,
              c_re_o      => c_re_s,
              c_im_o      => c_im_s,
              z_re_i      => z_re_s,
              z_im_i      => z_im_s,
              iteration_i => iteration_s,
              finish_i    => finished_s
             );

end architecture Behavioral;
