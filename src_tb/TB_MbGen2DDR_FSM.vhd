--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:51:09 05/25/2017
-- Design Name:   
-- Module Name:   /home/antoine/master/LPSC/project/src_tb/TB_MbGen2DDR_FSM.vhd
-- Project Name:  mandelbrot
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MbGen2DDR_FSM
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_MbGen2DDR_FSM IS
END TB_MbGen2DDR_FSM;
 
ARCHITECTURE behavior OF TB_MbGen2DDR_FSM IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MbGen2DDR_FSM
    PORT(
         clk_i : IN  std_logic;
         rst_i : IN  std_logic;
         mb_gen_trigger_o : OUT  std_logic;
         mb_gen_finished_i : IN  std_logic;
         ddr_calib_done_i : IN  std_logic;
         ddr_st_wr_o : OUT  std_logic;
         ddr_fifo_empty_i : IN  std_logic;
         ddr_fifo_full_i : IN  std_logic;
         ddr_fifo_wr_en_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal rst_i : std_logic := '0';
   signal mb_gen_finished_i : std_logic := '0';
   signal ddr_calib_done_i : std_logic := '0';
   signal ddr_fifo_empty_i : std_logic := '0';
   signal ddr_fifo_full_i : std_logic := '0';

  --Outputs
   signal mb_gen_trigger_o : std_logic;
   signal ddr_st_wr_o : std_logic;
   signal ddr_fifo_wr_en_o : std_logic;

  -- internals
  signal wr_count: integer := 0;

   signal i: integer := 0;

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
  -- Instantiate the Unit Under Test (UUT)
   uut: MbGen2DDR_FSM PORT MAP (
          clk_i => clk_i,
          rst_i => rst_i,
          mb_gen_trigger_o => mb_gen_trigger_o,
          mb_gen_finished_i => mb_gen_finished_i,
          ddr_calib_done_i => ddr_calib_done_i,
          ddr_st_wr_o => ddr_st_wr_o,
          ddr_fifo_empty_i => ddr_fifo_empty_i,
          ddr_fifo_full_i => ddr_fifo_full_i,
          ddr_fifo_wr_en_o => ddr_fifo_wr_en_o
        );

   -- Clock process definitions
   clk_i_process :process
   begin
    clk_i <= '0';
    wait for clk_i_period/2;
    clk_i <= '1';
    wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process 
   begin    
      -- hold reset state for 100 ns.
      rst_i <= '1';
      wait for 100 ns;  
      rst_i <= '0';

      wait for clk_i_period*10;

      ddr_calib_done_i <= '1';

      for i in 0 to 128  loop

        wait until mb_gen_trigger_o = '1';
      
        wait for clk_i_period * 5;
      

        wait until ddr_fifo_wr_en_o = '1';

        if i = 64 then
          wait until ddr_st_wr_o = '1';

          wait for clk_i_period * 5;


          wait until ddr_fifo_wr_en_o = '1';
        end if;

      end loop;

      -- insert stimulus here 

      wait;
   end process;

  drive_empty: process(clk_i, rst_i)
	begin

    if rst_i = '1' then
      ddr_fifo_empty_i <= '1';

    elsif rising_edge(clk_i) then
      if ddr_fifo_wr_en_o = '1' then
        ddr_fifo_empty_i <= '0';
      end if;
      if ddr_st_wr_o = '1' then
        ddr_fifo_empty_i <= '1';
      end if;

    end if;
      

  end process;

  drive_full: process(clk_i, rst_i)
  begin 
    if rst_i = '1' then
      wr_count <= 0;

    elsif rising_edge(clk_i) then

      if ddr_fifo_wr_en_o = '1' then
        wr_count <= wr_count + 1;
        if wr_count = 64 then
          ddr_fifo_full_i <= '1';
        end if;
      end if;

      

      if ddr_st_wr_o = '1' then
        ddr_fifo_full_i <= '0';
        wr_count <= 0;
      end if;

    end if;


  end process;

  drive_finished: process
  begin

    mb_gen_finished_i <= '1';

    loop
		  wait until mb_gen_trigger_o = '1';
		  mb_gen_finished_i <= '0';
		  wait for clk_i_period * 3;
		  mb_gen_finished_i <= '1';   

    end loop;

  end process;

END;
