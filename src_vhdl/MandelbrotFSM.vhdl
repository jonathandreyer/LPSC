library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MandelbrotFSM is

  generic (
           SIZE       : integer := 18;
           SIZE_ITER  : integer := 8;
           MAX_ITER   : integer := 100
          );

  port (
        clk_i               : in  std_logic;
        rst_i               : in  std_logic;
        start_fsm_i         : in  std_logic;
        isDivergent_i       : in  std_logic;
        c_re_i              : in  std_logic_vector(SIZE-1 downto 0);
        c_im_i              : in  std_logic_vector(SIZE-1 downto 0);
        z_re_1_i            : in  std_logic_vector(SIZE-1 downto 0);
        z_im_1_i            : in  std_logic_vector(SIZE-1 downto 0);
        iteration_i         : in  std_logic_vector(SIZE_ITER-1 downto 0);
        enable_complex_o    : out std_logic;
        c_re_o              : out std_logic_vector(SIZE-1 downto 0);
        c_im_o              : out std_logic_vector(SIZE-1 downto 0);
        z_re_o              : out std_logic_vector(SIZE-1 downto 0);
        z_im_o              : out std_logic_vector(SIZE-1 downto 0);
        enable_counter_o    : out std_logic;
        clear_counter_o     : out std_logic;
        end_value_counter_o : out std_logic_vector(SIZE_ITER-1 downto 0);
        finished_o          : out std_logic
       );

end entity MandelbrotFSM;

architecture Behavioral_FSM of MandelbrotFSM is

  --Declare type, subtype
 subtype t_state is std_logic_vector(2 downto 0);

  --Declare constantes
  constant c_INIT : t_state := "000";
  constant c_WAIT : t_state := "001";
  constant c_LOAD : t_state := "010";
  constant c_CALC : t_state := "011";
  constant c_END  : t_state := "100";

  --Declare signals
  signal state  : t_state;
  signal c_re_s : std_logic_vector(SIZE-1 downto 0);
  signal c_im_s : std_logic_vector(SIZE-1 downto 0);

begin

  process(clk_i, rst_i)
    begin
      if rst_i = '1' then
        state <= c_INIT;
      elsif rising_edge(clk_i) then
        case state is
          when c_INIT =>
            state <= c_WAIT;

          when c_WAIT =>
            if start_fsm_i = '1' then
              state <= c_LOAD;
            end if;

          when c_LOAD =>
            state <= c_CALC;

          when c_CALC =>
            if (unsigned(iteration_i) >= MAX_ITER) or (isDivergent_i = '1') then
              state <= c_END;
            end if;

          when c_END =>
            if start_fsm_i = '1' then
              state <= c_LOAD;
            end if;

          when others =>
            state <= c_INIT;
        end case;
      end if;
  end process;

  process(state, rst_i)
    begin
      if rst_i = '1' then
        c_re_s <= (others => '0');
        c_im_s <= (others => '0');
      elsif state = c_LOAD then
          c_re_s <= c_re_i;
          c_im_s <= c_im_i;
      end if;
  end process;

  z_re_o <= z_re_1_i  when state = c_CALC else
            (others => '0');

  z_im_o <= z_im_1_i  when state = c_CALC else
            (others => '0');

  enable_complex_o <= '1' when state = c_CALC else
                      '1' when state = c_LOAD else
                      '0';

  enable_counter_o <= '1' when state = c_CALC else
                      '0';
  clear_counter_o <= '1' when state = c_LOAD else
                     '0';

  end_value_counter_o <= std_logic_vector(unsigned(iteration_i) - 1) when state = c_END else
                         (others => '0');

  finished_o <= '1' when state = c_END else
                '0';

  c_re_o <= c_re_s;
  c_im_o <= c_im_s;

end architecture Behavioral_FSM;
