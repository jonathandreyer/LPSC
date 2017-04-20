library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;

entity MandelbrotFSM is

  generic (
           SIZE       : integer := 18;
           SIZE_ITER  : integer := 8
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
  signal state : t_state;

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
            if (end_counter_i = '1') or (isDivergent_i = '1') then
              state <= c_END;
            end if;

          when c_END =>
            if  start_fsm_i = '1' then
              state <= c_LOAD;
            end if;

          when others =>
            state <= c_INIT;
        end case;
      end if;
  end process;

  z_re_o <= z_re_1_i        when state = c_CALC else
            (others => '0') when state = c_INIT else
            (others => '0') when state = c_WAIT else
            (others => '0') when state = c_LOAD else
            (others => '0');

  z_im_o <= z_im_1_i        when state = c_CALC else
            (others => '0') when state = c_INIT else
            (others => '0') when state = c_WAIT else
            (others => '0') when state = c_LOAD else
            (others => '0');

  enable_complex_o <= '1' when state = c_CALC else
                      '0';

  enable_counter_o <= '1' when state = c_CALC else
                      '0';
  clear_counter_o <= '1' when state = c_LOAD else
                     '0';

  end_value_counter_o <= iteration_i when state = c_END else
                         (others => '0');

  finished_o <= '1' when state = c_END else
                '0';

end architecture Behavioral_FSM;
