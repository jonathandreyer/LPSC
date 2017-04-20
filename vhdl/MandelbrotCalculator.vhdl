library ieee;
use ieee.std_logic_1164.all;

entity MandelbrotCalculator is

  generic (
           SIZE           : integer := 18;
           FRACTIONAL     : integer := 13;
           SIZE_ITER      : integer := 8;
           MAX_ITERATION  : integer := 100
          );

  port (
        clk_i           : in  std_logic;
        rst_i           : in  std_logic;
        start_i         : in  std_logic;
        c_re_i          : in  std_logic_vector(SIZE-1 downto 0);
        c_im_i          : in  std_logic_vector(SIZE-1 downto 0);
        z_re_o          : out std_logic_vector(SIZE-1 downto 0);
        z_im_o          : out std_logic_vector(SIZE-1 downto 0);
        iteration_o     : out std_logic_vector(SIZE_ITER-1 downto 0);
        finish_o        : out std_logic
       );

end entity MandelbrotCalculator;

architecture Behavioral_Calculator of MandelbrotCalculator is

  constant Z_NORM_LIMIT : std_logic_vector(SIZE-1 downto 0) := "001000000000000000";

  signal enable_complex_s : std_logic;
  signal isDivergent_s : std_logic;
  signal z_re_s : std_logic_vector(SIZE-1 downto 0);
  signal z_im_s : std_logic_vector(SIZE-1 downto 0);
  signal z_re_1_s : std_logic_vector(SIZE-1 downto 0);
  signal z_im_1_s : std_logic_vector(SIZE-1 downto 0);

  signal enable_counter_s : std_logic;
  signal clear_counter_s : std_logic;
  signal end_counter_s : std_logic;
  signal counter_s : std_logic_vector(SIZE_ITER-1 downto 0);

  component MandelbrotFSM
    generic (
             SIZE       : integer;
             SIZE_ITER  : integer
            );
    port (
          clk_i               : in  std_logic;
          rst_i               : in  std_logic;
          start_fsm_i         : in  std_logic;
          isDivergent_i       : in  std_logic;
          z_re_1_i            : in  std_logic_vector(SIZE-1 downto 0);
          z_im_1_i            : in  std_logic_vector(SIZE-1 downto 0);
          end_counter_i       : in  std_logic;
          iteration_i         : in  std_logic_vector(SIZE_ITER-1 downto 0);
          enable_complex_o    : out std_logic;
          z_re_o              : out std_logic_vector(SIZE-1 downto 0);
          z_im_o              : out std_logic_vector(SIZE-1 downto 0);
          enable_counter_o    : out std_logic;
          clear_counter_o     : out std_logic;
          end_value_counter_o : out std_logic_vector(SIZE_ITER-1 downto 0);
          finished_o          : out std_logic
         );
  end component MandelbrotFSM;

  component MandelbrotCounter
    generic (
             SIZE       : integer := 8;
             MAXCOUNTER : integer := 100
            );
    port (
          clk_i           : in  std_logic;
          rst_i           : in  std_logic;
          enable_i        : in  std_logic;
          clear_i         : in  std_logic;
          endvalue_o      : out std_logic;
          valuecounter_o  : out std_logic_vector(SIZE-1 downto 0)
         );
  end component MandelbrotCounter;

  component MandelbrotComplexCalculator
    generic (
             SIZE       : integer;
             FRACTIONAL : integer
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

begin

  FSM: MandelbrotFSM
    generic map (
                 SIZE      => SIZE,
                 SIZE_ITER => SIZE_ITER
                )
    port map (
              clk_i               => clk_i,
              rst_i               => rst_i,
              start_fsm_i         => start_i,
              enable_complex_o    => enable_complex_s,
              isDivergent_i       => isDivergent_s,
              z_re_1_i            => z_re_1_s,
              z_im_1_i            => z_im_1_s,
              end_counter_i       => end_counter_s,
              iteration_i         => counter_s,
              z_re_o              => z_re_s,
              z_im_o              => z_im_s,
              enable_counter_o    => enable_counter_s,
              clear_counter_o     => clear_counter_s,
              end_value_counter_o => iteration_o,
              finished_o          => finish_o
             );

  Counter: MandelbrotCounter
    generic map (
                 SIZE       => SIZE_ITER,
                 MAXCOUNTER => MAX_ITERATION
                )
    port map (
              clk_i          => clk_i,
              rst_i          => rst_i,
              enable_i       => enable_counter_s,
              clear_i        => clear_counter_s,
              endvalue_o     => end_counter_s,
              valuecounter_o => counter_s
             );

  ComplexCalculator: MandelbrotComplexCalculator
    generic map (
                 SIZE       => SIZE,
                 FRACTIONAL => FRACTIONAL
                )
    port map (
              clk_i          => clk_i,
              rst_i          => rst_i,
              enable_i       => enable_complex_s,
              c_re_i         => c_re_i,
              c_im_i         => c_im_i,
              z_re_i         => z_re_s,
              z_im_i         => z_im_s,
              z_norm_limit_i => Z_NORM_LIMIT,
              z_re_1_o       => z_re_1_s,
              z_im_1_o       => z_im_1_s,
              isDivergent_o  => isDivergent_s
             );

  z_re_o <= z_re_1_s;
  z_im_o <= z_im_1_s;

end architecture Behavioral_Calculator;
