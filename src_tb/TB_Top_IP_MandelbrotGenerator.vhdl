library ieee;
use ieee.std_logic_1164.all;

entity TB_Top_IP_MandelbrotGenerator is

  generic (
    SIZE_COMPLEX  : integer := 18;
    FRACTIONAL    : integer := 13;
    SIZE_ITER     : integer := 8;
    MAX_ITERATION : integer := 100;
    X_SCREEN_SIZE : integer := 1280;
    Y_SCREEN_SIZE : integer := 1024;
    SIZE_SCREEN   : integer := 11
  );

end entity TB_Top_IP_MandelbrotGenerator;

architecture Behavioral of TB_Top_IP_MandelbrotGenerator is

  signal clk_s          : std_logic;
  signal rst_s          : std_logic;
  signal x_s            : std_logic_vector(SIZE_SCREEN-1 downto 0);
  signal y_s            : std_logic_vector(SIZE_SCREEN-1 downto 0);
  signal finished_s     : std_logic;
  signal iteration_s    : std_logic_vector(SIZE_ITER-1 downto 0);

  component IP_MandelbrotGenerator
    generic (
      SIZE_COMPLEX  : integer;
      FRACTIONAL    : integer;
      SIZE_ITER     : integer;
      MAX_ITERATION : integer;
      X_SCREEN_SIZE : integer;
      Y_SCREEN_SIZE : integer;
      SIZE_SCREEN   : integer
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      x_o         : out std_logic_vector(SIZE_SCREEN-1 downto 0);
      y_o         : out std_logic_vector(SIZE_SCREEN-1 downto 0);
      finish_o    : out std_logic;
      iteration_o : out std_logic_vector(SIZE_ITER-1 downto 0)
    );
    end component IP_MandelbrotGenerator;

  component TB_Stimuli_IP_MandelbrotGenerator
    generic (
             SIZE_SCREEN  : integer;
             SIZE_ITER    : integer
            );
    port (
          clk_o       : out std_logic;
          rst_o       : out std_logic;
          x_i         : in  std_logic_vector(SIZE_SCREEN-1 downto 0);
          y_i         : in  std_logic_vector(SIZE_SCREEN-1 downto 0);
          finish_i    : in  std_logic;
          iteration_i : in  std_logic_vector(SIZE_ITER-1 downto 0)
         );
  end component TB_Stimuli_IP_MandelbrotGenerator;

begin

  IP_MandelbrotGenerator_i : IP_MandelbrotGenerator
    generic map (
      SIZE_COMPLEX  => SIZE_COMPLEX,
      FRACTIONAL    => FRACTIONAL,
      SIZE_ITER     => SIZE_ITER,
      MAX_ITERATION => MAX_ITERATION,
      X_SCREEN_SIZE => X_SCREEN_SIZE,
      Y_SCREEN_SIZE => Y_SCREEN_SIZE,
      SIZE_SCREEN   => SIZE_SCREEN
    )
    port map (
      clk_i       => clk_s,
      rst_i       => rst_s,
      x_o         => x_s,
      y_o         => y_s,
      finish_o    => finished_s,
      iteration_o => iteration_s
    );

  TB_Stimuli: TB_Stimuli_IP_MandelbrotGenerator
    generic map (
                 SIZE_SCREEN  => SIZE_SCREEN,
                 SIZE_ITER    => SIZE_ITER
                )
    port map (
              clk_o       => clk_s,
              rst_o       => rst_s,
              x_i         => x_s,
              y_i         => y_s,
              finish_i    => finished_s,
              iteration_i => iteration_s
             );

end architecture Behavioral;
