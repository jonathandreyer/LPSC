library ieee;
use ieee.std_logic_1164.all;

entity ManageGenerator is

  port (
        clk_i               : in  std_logic;
        rst_i               : in  std_logic;
        finish_i            : in  std_logic;
        next_value_o        : out std_logic;
        next_value_1_o      : out std_logic
       );

end entity ManageGenerator;

architecture Behavioral_FSM of ManageGenerator is

  --Declare type, subtype
 subtype t_state is std_logic_vector(1 downto 0);

  --Declare constantes
  constant c_INIT  : t_state := "00";
  constant c_START : t_state := "01";
  constant c_WAIT  : t_state := "10";

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
            state <= c_START;

          when c_START =>
            state <= c_WAIT;

          when c_WAIT =>
            if finish_i = '1' then
              state <= c_START;
            end if;

          when others =>
            state <= c_INIT;
        end case;
      end if;
  end process;

  next_value_o <= '1' when state = c_START else
                  '0';

  process(clk_i, rst_i)
    begin
      if rst_i = '1' then
        next_value_1_o <= '0';
      elsif rising_edge(clk_i) then
        next_value_1_o <= next_value_o;
      end if;
  end process;

end architecture Behavioral_FSM;
