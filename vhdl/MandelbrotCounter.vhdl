library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;

entity MandelbrotCounter is

  generic (
    SIZE : integer := 16);

  port (
    clk           : in  std_logic;
    reset_as      : in  std_logic;
    enable        : in  std_logic;
    valuecounter  : out std_logic_vector(SIZE-1 downto 0));

end entity MandelbrotCounter;

architecture MandelbrotCounter of MandelbrotCounter is

	signal counter : std_logic_vector(SIZE-1 downto 0);

begin

  process (clk, reset_as)
  	begin
  		if reset_as = '0' then
  			counter <= (OTHERS => '0');
  		elsif rising_edge(clk) then
  			IF enable = '1' then
  				counter <= unsigned(counter) + 1;
        end if;
      end if;
    end process;

  valuecounter <= counter;

end architecture MandelbrotCounter;
