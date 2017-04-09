library ieee;
use ieee.std_logic_1164.all;

entity MandelbrotFSM is

  generic (
           SIZE       : integer := 18;
           SIZE_ITER  : integer := 8
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

end entity MandelbrotFSM;

architecture Behavioral_FSM of MandelbrotFSM is

begin

  z_re_s <= (others => '0');
  z_im_s <= (others => '0');
  enable_counter_s <= '0';
  finished_s <= '0';

end architecture Behavioral_FSM;
