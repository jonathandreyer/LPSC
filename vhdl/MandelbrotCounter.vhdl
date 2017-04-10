library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;

entity MandelbrotCounter is

  generic (
           SIZE : integer := 8
          );

  port (
        clk_i           : in  std_logic;
        rst_i           : in  std_logic;
        enable_i        : in  std_logic;
        clear_i         : in  std_logic;
        valuecounter_o  : out std_logic_vector(SIZE-1 downto 0)
       );

end entity MandelbrotCounter;

architecture Behavioral_Counter of MandelbrotCounter is

	signal counter_s : std_logic_vector(SIZE-1 downto 0);

begin

  process (clk_i, rst_i)
    begin
      if rst_i = '1' then
        counter_s <= (others => '0');
      elsif rising_edge(clk_i) then
        if clear_i = '1' then
          counter_s <= (others => '0');
        elsif enable_i = '1' then
          counter_s <= unsigned(counter_s) + 1;
        end if;
      end if;
    end process;

  valuecounter_o <= counter_s;

end architecture Behavioral_Counter;
