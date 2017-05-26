----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:46:04 05/26/2017 
-- Design Name: 
-- Module Name:    dvi_start_fsm - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
 
entity dvi_start_fsm is
  Port ( 
    reset_i : in  STD_LOGIC;
    cli_i : in  STD_LOGIC;
    xpos_i : in  STD_LOGIC_VECTOR (10 downto 0);
    ypos_i : in  STD_LOGIC_VECTOR (10 downto 0);
    enable_o : out  STD_LOGIC
 );
end dvi_start_fsm;

architecture Behavioral of dvi_start_fsm is

  subtype t_state is integer;
  constant c_WAIT       : t_state := 0;
  constant c_RUN        : t_state := 1;

  signal state          : t_state;

begin

  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state <= c_WAIT;
    elsif rising_edge(clk_i) then 
      case state is

        when c_WAIT =>
          if xpos_i = "0" and ypos_i = "0" then
            state <= c_RUN;
          end if;
        when c_RUN => 
          -- Nothing to do anymore

      end case;
    end if;
  end process;

  enable_o <= '1' when state = c_RUN else '0';

end Behavioral;

