--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:02:59 04/09/2017
-- Design Name:   
-- Module Name:   /home/antoine/master/LPSC/project/vhdl/test_zi_calc/MBCompCalcTB.vhd
-- Project Name:  test_zi_calc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MandelbrotComplexCalculator
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
 
ENTITY MBCompCalcTB IS
END MBCompCalcTB;
 
ARCHITECTURE behavior OF MBCompCalcTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MandelbrotComplexCalculator
    PORT(
	      clk_i  : in  std_logic;
         rst_i  : in  std_logic;
			enable_i : in std_logic;
         c_re_i : IN  std_logic_vector(15 downto 0);
         c_im_i : IN  std_logic_vector(15 downto 0);
         z_re_i : IN  std_logic_vector(15 downto 0);
         z_im_i : IN  std_logic_vector(15 downto 0);
         z_norm_limit_i : IN  std_logic_vector(15 downto 0);
         z_re_1_o : OUT  std_logic_vector(15 downto 0);
         z_im_1_o : OUT  std_logic_vector(15 downto 0);
         isDivergent_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal c_re_i : std_logic_vector(15 downto 0) := (others => '0');
   signal c_im_i : std_logic_vector(15 downto 0) := (others => '0');
   signal z_re_i : std_logic_vector(15 downto 0) := (others => '0');
   signal z_im_i : std_logic_vector(15 downto 0) := (others => '0');
   signal z_norm_limit_i : std_logic_vector(15 downto 0) := (others => '0');
	signal clk : std_logic;
	signal rst : std_logic;
	signal enable : std_logic;

 	--Outputs
   signal z_re_1_o : std_logic_vector(15 downto 0);
   signal z_im_1_o : std_logic_vector(15 downto 0);
   signal isDivergent_o : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MandelbrotComplexCalculator PORT MAP (
	       rst_i => rst,
	       clk_i => clk,
			 enable_i => enable,
          c_re_i => c_re_i,
          c_im_i => c_im_i,
          z_re_i => z_re_i,
          z_im_i => z_im_i,
          z_norm_limit_i => z_norm_limit_i,
          z_re_1_o => z_re_1_o,
          z_im_1_o => z_im_1_o,
          isDivergent_o => isDivergent_o
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		enable <= '0';
		rst <= '1';
      wait for 10 ns;	
		rst <= '0';
		enable <= '1';
		
		

      wait for clk_period*2;

    -- Case 1
		
		z_re_i <= X"0800";
		z_im_i <= X"0800";
		c_re_i <= X"0800";
		c_im_i <= X"0800";
		z_norm_limit_i <= X"4000";
		
		wait for clk_period*2;

    assert z_re_1_o = X"0800" report "z_re_1 is wrong";
    assert z_im_1_o = X"1000" report "z_im_1 is wrong";

    -- Case 2 
		
		z_re_i <= X"0800";
		z_im_i <= X"0800";
		c_re_i <= X"0000";
		c_im_i <= X"0000";

    wait for clk_period*2;

    assert z_re_1_o = X"0000" report "z_re_1 is wrong";
    assert z_im_1_o = X"0800" report "z_im_1 is wrong";


    -- Case 3 
    
    z_re_i <= X"2000";
    z_im_i <= X"1800";
    c_re_i <= X"0000";
    c_im_i <= X"0000";

    wait for clk_period*2;

    assert z_re_1_o = X"1c00" report "z_re_1 is wrong";
    assert z_im_1_o = X"6000" report "z_im_1 is wrong";

    -- Case 4
    
    z_re_i <= X"0800";
    z_im_i <= X"0400";
    c_re_i <= X"0800";
    c_im_i <= X"04cc";

    wait for clk_period*2;

    assert z_re_1_o = X"0b00" report "z_re_1 is wrong";
    assert z_im_1_o = X"08cc" report "z_im_1 is wrong";

    -- Case 5
    
    z_re_i <= X"0b33";
    z_im_i <= X"0666";
    c_re_i <= X"f99a";
    c_im_i <= X"0b33";

    wait for clk_period*2;

    assert z_re_1_o = X"fee1" report "z_re_1 is wrong";
    assert z_im_1_o = X"1428" report "z_im_1 is wrong";

    -- Case 6
    
    z_re_i <= X"f667";
    z_im_i <= X"f334";
    c_re_i <= X"0ccc";
    c_im_i <= X"f4cd";

    wait for clk_period*2;

    assert z_re_1_o = X"0851" report "z_re_1 is wrong";
    assert z_im_1_o = X"0427" report "z_im_1 is wrong";

      wait;
   end process;

END;
