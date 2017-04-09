library ieee;
use ieee.std_logic_1164.all;

entity MandelbrotCalculator is

  generic (
           SIZE       : integer := 18;
           SIZE_ITER  : integer := 8
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

  constant Q_WIDTH : integer := SIZE;
  constant P_WITDH : integer := SIZE-5;
  constant Z_NORM_LIMIT : std_logic_vector(SIZE-1 downto 0) := "001000000000000000";

  signal enable_complex_s : std_logic;
  signal isDivergent_s : std_logic;
  signal z_re_s : std_logic_vector(SIZE-1 downto 0);
  signal z_im_s : std_logic_vector(SIZE-1 downto 0);
  signal z_re_1_s : std_logic_vector(SIZE-1 downto 0);
  signal z_im_1_s : std_logic_vector(SIZE-1 downto 0);

  signal enable_counter_s : std_logic;
  signal counter_s : std_logic_vector(SIZE_ITER-1 downto 0);

  component MandelbrotFSM
    generic (
             SIZE       : integer;
             SIZE_ITER  : integer
            );
    port (
          clk_i             : in  std_logic;
          rst_i             : in  std_logic;
          start_fsm_i       : in  std_logic;
          enable_complex_i  : in  std_logic;
          isDivergent_i     : in  std_logic;
          z_re_1_i          : in  std_logic_vector(SIZE-1 downto 0);
          z_im_1_i          : in  std_logic_vector(SIZE-1 downto 0);
          iteration_i       : in  std_logic_vector(SIZE_ITER-1 downto 0);
          z_re_o            : out std_logic_vector(SIZE-1 downto 0);
          z_im_o            : out std_logic_vector(SIZE-1 downto 0);
          enable_counter_o  : out std_logic;
          finished_o        : out std_logic
         );
  end component MandelbrotFSM;

  component MandelbrotCounter
    generic (
             SIZE : integer
            );
    port (
          clk_i           : in  std_logic;
          rst_i           : in  std_logic;
          enable_i        : in  std_logic;
          valuecounter_o  : out std_logic_vector(SIZE-1 downto 0)
         );
  end component MandelbrotCounter;

  component MandelbrotComplexCalculator
    generic (
             Q_WIDTH      : integer;
             P_WITDH      : integer
            );
    port (
          clk_i           : in  std_logic;
          rst_i           : in  std_logic;
          enable_i        : in  std_logic;
          c_re_i          : in  std_logic_vector(Q_WIDTH-1 downto 0);
          c_im_i          : in  std_logic_vector(Q_WIDTH-1 downto 0);
          z_re_i          : in  std_logic_vector(Q_WIDTH-1 downto 0);
          z_im_i          : in  std_logic_vector(Q_WIDTH-1 downto 0);
          z_norm_limit_i  : in  std_logic_vector(Q_WIDTH-1 downto 0);
          z_re_1_o        : out std_logic_vector(Q_WIDTH-1 downto 0);
          z_im_1_o        : out std_logic_vector(Q_WIDTH-1 downto 0);
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
              clk_i            => clk_i,
              rst_i            => rst_i,
              start_fsm_i      => start_i,
              enable_complex_i => enable_complex_s,
              isDivergent_i    => isDivergent_s,
              z_re_1_i         => z_re_1_s,
              z_im_1_i         => z_im_1_s,
              iteration_i      => counter_s,
              z_re_o           => z_re_s,
              z_im_o           => z_im_s,
              enable_counter_o => enable_counter_s,
              finished_o       => finish_o
             );

  Counter: MandelbrotCounter
    generic map (
                 SIZE => SIZE_ITER
                )
    port map (
              clk_i          => clk_i,
              rst_i          => rst_i,
              enable_i       => enable_counter_s,
              valuecounter_o => counter_s
             );

  ComplexCalculator: MandelbrotComplexCalculator
    generic map (
                 Q_WIDTH => Q_WIDTH,
                 P_WITDH => P_WITDH
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
