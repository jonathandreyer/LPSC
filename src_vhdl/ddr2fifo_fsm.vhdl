----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:02:21 05/23/2017 
-- Design Name: 
-- Module Name:    ddr2fifo_fsm - rtl 
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM; 
--use UNISIM.VComponents.all; 

entity ddr2fifo_fsm is
  generic (
           BUSRT_LEN  : integer := 64
          );
  Port ( 
    clk_i             : in  STD_LOGIC;
    reset_i           :  in  STD_LOGIC;
    ddr_cmd_en_o      : out  STD_LOGIC;
    ddr_cmd_addr_o    : out  STD_LOGIC_VECTOR (29 downto 0);
    ddr_read_en_o     : out  STD_LOGIC;
    ddr_data_empty_i  : in  STD_LOGIC;
    ddr_data_i        : in  STD_LOGIC_VECTOR(31 downto 0);
    ddr_calib_done_i  : in  STD_LOGIC;
    fifo_wr_en_o      : out  STD_LOGIC;
    fifo_data_o       : out  STD_LOGIC_VECTOR (6 downto 0);
    fifo_full_i       : in  STD_LOGIC;
    fifo_ack_i        : in  STD_LOGIC);
end ddr2fifo_fsm;

architecture rtl of ddr2fifo_fsm is
  --Declare type, subtype
 subtype t_state is std_logic_vector(2 downto 0);

  --Declare constantes
  constant c_INIT       : t_state := "000";
  constant c_WAIT_CAL   : t_state := "001";
  constant c_SEND_ADDR  : t_state := "010";
  --constant c_WAIT_DATA  : t_state := "011";
  constant c_READ_DDR   : t_state := "100";
  constant c_WRITE_FIFO : t_state := "101";

  signal state          : t_state;

  signal burst_byte_count: std_logic_vector(6 downto 0);
  signal read_ptr        : std_logic_vector(29 downto 0);
  signal data            : std_logic_vector(31 downto 0);

begin

  process(clk_i, reset_i)
    begin
      if reset_i = '1' then
        state <= c_INIT;
        read_ptr <= (others => '0');
        data <= (others => '0');

      elsif rising_edge(clk_i) then
        case state is
          -- Dummy state
          when c_INIT =>
            burst_byte_count <= (others => '0');
            read_ptr <= (others => '0');
            state <= c_WAIT_CAL;
          -- Wait the DDR to be calibrated
          when c_WAIT_CAL =>
            if ddr_calib_done_i = '1' then
              state <= c_SEND_ADDR;
            end if;
          -- Send the address
          when c_SEND_ADDR =>
            state <= c_READ_DDR;
            burst_byte_count <= (others => '0');

          -- Wait for DDR to have some data and fifo to be ready
          when c_READ_DDR => 
              if ddr_data_empty_i = '0' then
                read_ptr <= std_logic_vector(unsigned(read_ptr) + BUSRT_LEN);
                burst_byte_count <= std_logic_vector(signed(burst_byte_count) + 1);
                data <= ddr_data_i;
                if  fifo_full_i = '0' then
                  state <= c_WRITE_FIFO;
                end if;
              end if;

          -- Write the FIFO
          when c_WRITE_FIFO => 
            if fifo_ack_i = '1' then
              if unsigned(burst_byte_count) = BUSRT_LEN then
                state <= c_SEND_ADDR;
              else
                state <= c_READ_DDR;
              end if; 
            end if;

			 when others => state <= c_INIT;

        end case;

      end if;
  end process;

  ddr_cmd_addr_o <= read_ptr;
  -- Manage the CMD_EN signal
  ddr_cmd_en_o <= '1' when state = c_SEND_ADDR else '0';

  -- Manage DDR read enable
  ddr_read_en_o <= '1' when state = c_READ_DDR else '0';


  -- Manage FIFO data & contoll
  fifo_data_o <= data(6 downto 0);
  fifo_wr_en_o <= '1' when state = c_WRITE_FIFO else '0';



end rtl;

