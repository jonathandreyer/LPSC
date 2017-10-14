----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:31:45 05/25/2017 
-- Design Name: 
-- Module Name:    MbGen2DDR_FSM - Behavioral 
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

entity MbGen2DDR_FSM is
    Port ( clk_i : in  STD_LOGIC;
           rst_i : in  STD_LOGIC;
           mb_gen_trigger_o : out  STD_LOGIC;
           mb_gen_finished_i : in  STD_LOGIC;
           ddr_calib_done_i : in  STD_LOGIC;
           ddr_st_wr_o : out  STD_LOGIC;
           ddr_fifo_empty_i : in  STD_LOGIC;
           ddr_fifo_full_i : in  STD_LOGIC;
           ddr_fifo_wr_en_o : out  STD_LOGIC);
end MbGen2DDR_FSM;

architecture Behavioral of MbGen2DDR_FSM is

    subtype t_state is integer;

  --Declare constantes
  constant c_WAIT_CAL       : t_state := 0;
  constant c_START_GEN      : t_state := 1;
  constant c_WAIT_GEN       : t_state := 2;
  constant c_WRITE_DDR      : t_state := 3;
  constant c_LOOK_FIFO_FULL : t_state := 4;
  constant c_SEND_WRITE_CMD : t_state := 5;
  constant c_WAIT_FIFO_E    : t_state := 6;

  signal state          : t_state;

begin

  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state <= c_WAIT_CAL;
    elsif rising_edge(clk_i) then 
      case state is

        when c_WAIT_CAL =>
          -- Wait for the DDR to be calibrated
          if ddr_calib_done_i = '1' then
            state <= c_START_GEN;
          end if;

        when c_START_GEN =>
          -- Just pulse mg_trigger_o, done outside of this process
          state <= c_WAIT_GEN;

        when c_WAIT_GEN =>
          -- wait for the mandelbrot generator to be completed
          if mb_gen_finished_i = '1' then
            state <= c_WRITE_DDR;
          end if;

        when c_WRITE_DDR =>
          -- pluse ddr_wr_en_o, done outside of this process
          state <= c_LOOK_FIFO_FULL;

        when c_LOOK_FIFO_FULL =>
          if ddr_fifo_full_i = '1' then
            state <= c_SEND_WRITE_CMD;
          else
            state <= c_START_GEN;
          end if;

        when c_SEND_WRITE_CMD =>
          -- pluse ddr_st_wr_o, done outside of this process
          state <= c_WAIT_FIFO_E;

        when c_WAIT_FIFO_E =>
          if ddr_fifo_empty_i = '1' then
            state <= c_START_GEN;
          end if;      

      when others => state <= c_WAIT_CAL;
      end case;

    end if;
  end process;

  mb_gen_trigger_o <= '1' when state = c_START_GEN else '0'; 
  ddr_fifo_wr_en_o <= '1' when state = c_WRITE_DDR else '0';
  ddr_st_wr_o <= '1' when state = c_SEND_WRITE_CMD else '0';



end Behavioral;

