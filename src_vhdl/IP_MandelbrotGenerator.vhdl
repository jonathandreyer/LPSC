library ieee;
use ieee.std_logic_1164.all;

entity IP_MandelbrotGenerator is

  generic (
           SIZE_COMPLEX   : integer := 18;
           FRACTIONAL     : integer := 13;
           SIZE_ITER      : integer := 8;
           MAX_ITERATION  : integer := 100;
           X_SCREEN_SIZE  : integer := 1024;
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

end entity IP_MandelbrotGenerator;

architecture Behavioral of IP_MandelbrotGenerator is

  signal next_value_s   : std_logic;
  signal next_value_1_s : std_logic;

  signal c_re_s         : std_logic_vector(SIZE_COMPLEX-1 downto 0);
  signal c_im_s         : std_logic_vector(SIZE_COMPLEX-1 downto 0);
  signal z_re_1_s       : std_logic_vector(SIZE_COMPLEX-1 downto 0);
  signal z_im_1_s       : std_logic_vector(SIZE_COMPLEX-1 downto 0);

  component MandelbrotManageGenerator
    port (
      clk_i          : in  std_logic;
      rst_i          : in  std_logic;
      finish_i       : in  std_logic;
      next_value_o   : out std_logic;
      next_value_1_o : out std_logic
    );
  end component MandelbrotManageGenerator;

  component ComplexValueGenerator
    generic (
      SIZE       : integer;
      COMMA      : integer;
      X_SIZE     : integer;
      Y_SIZE     : integer;
      SCREEN_RES : integer
    );
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      next_value  : in  std_logic;
      c_real      : out std_logic_vector (SIZE_COMPLEX-1 downto 0);
      c_imaginary : out std_logic_vector (SIZE_COMPLEX-1 downto 0);
      X_screen    : out std_logic_vector (SIZE_SCREEN-1 downto 0);
      Y_screen    : out std_logic_vector (SIZE_SCREEN-1 downto 0)
    );
  end component ComplexValueGenerator;

  component MandelbrotCalculator
    generic (
      SIZE          : integer;
      FRACTIONAL    : integer;
      SIZE_ITER     : integer;
      MAX_ITERATION : integer
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      start_i     : in  std_logic;
      c_re_i      : in  std_logic_vector(SIZE_COMPLEX-1 downto 0);
      c_im_i      : in  std_logic_vector(SIZE_COMPLEX-1 downto 0);
      z_re_o      : out std_logic_vector(SIZE_COMPLEX-1 downto 0);
      z_im_o      : out std_logic_vector(SIZE_COMPLEX-1 downto 0);
      iteration_o : out std_logic_vector(SIZE_ITER-1 downto 0);
      finish_o    : out std_logic
    );
  end component MandelbrotCalculator;

begin

  MandelbrotManageGenerator_i : MandelbrotManageGenerator
    port map (
      clk_i          => clk_i,
      rst_i          => rst_i,
      finish_i       => trigger_i,
      next_value_o   => next_value_s,
      next_value_1_o => next_value_1_s
    );

  ComplexValueGenerator_i : ComplexValueGenerator
    generic map (
      SIZE       => SIZE_COMPLEX,
      COMMA      => FRACTIONAL,
      X_SIZE     => X_SCREEN_SIZE,
      Y_SIZE     => Y_SCREEN_SIZE,
      SCREEN_RES => SIZE_SCREEN
    )
    port map (
      clk         => clk_i,
      reset       => rst_i,
      next_value  => next_value_s,
      c_real      => c_re_s,
      c_imaginary => c_im_s,
      X_screen    => x_o,
      Y_screen    => y_o
    );

  MandelbrotCalculator_i : MandelbrotCalculator
    generic map (
      SIZE          => SIZE_COMPLEX,
      FRACTIONAL    => FRACTIONAL,
      SIZE_ITER     => SIZE_ITER,
      MAX_ITERATION => MAX_ITERATION
    )
    port map (
      clk_i       => clk_i,
      rst_i       => rst_i,
      start_i     => next_value_1_s,
      c_re_i      => c_re_s,
      c_im_i      => c_im_s,
      z_re_o      => z_re_1_s,
      z_im_o      => z_im_1_s,
      iteration_o => iteration_o,
      finish_o    => finish_o
    );


end architecture Behavioral;
