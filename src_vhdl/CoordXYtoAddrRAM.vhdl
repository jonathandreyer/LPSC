library ieee;
use ieee.std_logic_1164.all;

entity CoordinateXYtoMemoryADDR is

  port (
        x_i             : in  std_logic_vector(10 downto 0);
        y_i             : in  std_logic_vector(10 downto 0);
        addr_o          : out std_logic_vector(21 downto 0)
       );

end entity CoordinateXYtoMemoryADDR;

architecture Behavioral_converter of CoordinateXYtoMemoryADDR is

begin

  addr_o <= y_i & x_i;

end architecture Behavioral_converter;
