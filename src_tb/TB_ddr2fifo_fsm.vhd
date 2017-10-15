--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:35:11 05/23/2017
-- Design Name:   
-- Module Name:   /home/antoine/master/LPSC/project/src_tb/TB_ddr2fifo_fsm.vhd
-- Project Name:  mandelbrot
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ddr2fifo_fsm
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_ddr2fifo_fsm IS
END TB_ddr2fifo_fsm;
 
ARCHITECTURE behavior OF TB_ddr2fifo_fsm IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ddr2fifo_fsm
    PORT(
         clk_i : IN  std_logic;
         reset_i : IN  std_logic;
         ddr_cmd_en_o : OUT  std_logic;
         ddr_cmd_addr_o : OUT  std_logic_vector(29 downto 0);
         ddr_read_en_o : OUT  std_logic;
         ddr_data_empty_i : IN  std_logic;
         ddr_data_i : IN  std_logic_vector(31 downto 0);
         ddr_calib_done_i : IN  std_logic;
         fifo_wr_en_o : OUT  std_logic;
         fifo_data_o : OUT  std_logic_vector(6 downto 0);
         fifo_full_i : IN  std_logic;
         fifo_ack_i : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal reset_i : std_logic := '0';
   signal ddr_data_empty_i : std_logic := '0';
   signal ddr_data_i : std_logic_vector(31 downto 0);
   signal ddr_calib_done_i : std_logic := '0';
   signal fifo_full_i : std_logic := '0';
   signal fifo_ack_i : std_logic := '0';

 	--Outputs
   signal ddr_cmd_en_o : std_logic;
   signal ddr_cmd_addr_o : std_logic_vector(29 downto 0);
   signal ddr_read_en_o : std_logic;
   signal fifo_wr_en_o : std_logic;
   signal fifo_data_o : std_logic_vector(6 downto 0);

   -- internals
   signal ddr_data: std_logic_vector(31 downto 0) := (others => '0');
   signal fifo_ack: std_logic := '0';


   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ddr2fifo_fsm PORT MAP (
          clk_i => clk_i,
          reset_i => reset_i,
          ddr_cmd_en_o => ddr_cmd_en_o,
          ddr_cmd_addr_o => ddr_cmd_addr_o,
          ddr_read_en_o => ddr_read_en_o,
          ddr_data_empty_i => ddr_data_empty_i,
          ddr_data_i => ddr_data_i,
          ddr_calib_done_i => ddr_calib_done_i,
          fifo_wr_en_o => fifo_wr_en_o,
          fifo_data_o => fifo_data_o,
          fifo_full_i => fifo_full_i,
          fifo_ack_i => fifo_ack_i
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;

   ddr_data_change: process(reset_i, clk_i)
   begin
      if reset_i = '1' then
        ddr_data <= (others => '0');
      elsif rising_edge(clk_i) then
        if ddr_read_en_o = '1' and ddr_data_empty_i = '0'then
          ddr_data <= ddr_data + "1";
        end if;
      end if;
   end process;
   ddr_data_i <= ddr_data;

   fifo_ack_process: process(clk_i)
   begin
    if rising_edge(clk_i) then
      if fifo_wr_en_o = '1' then
        fifo_ack <= '1';
      else
        fifo_ack <= '0';
      end if;
    end if;
   end process;
   fifo_ack_i <= fifo_ack;
 

   -- Stimulus process
   stim_proc: process
   begin	
		ddr_calib_done_i <= '0';	
		ddr_data_empty_i <= '1';
		fifo_full_i <= '0';
    reset_i <= '1';
		
      -- hold reset state for 100 ns.
      wait for 100 ns;

		reset_i <= '0';


      wait for clk_i_period*10;

	
		 
		 -- DDR is now calibrated, FSM should send address!
		 ddr_calib_done_i <= '1';
		 
		 wait for clk_i_period * 10;
		 
		 -- DDR has now data in the fifo
		 
		 ddr_data_empty_i <= '0';
		 
		 wait for clk_i_period*32;
		 
		 fifo_full_i <= '1';
		 
		 wait for clk_i_period * 10;
		 
		 fifo_full_i <= '0';
		 
		 
		 
		 
		 
		 

      wait;
   end process;

END;
