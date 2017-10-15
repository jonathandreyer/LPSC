library ieee;
use ieee.std_logic_1164.all;

entity PixelColor is

  generic (
           SIZE : integer := 8
          );

  port (
        iteration_i     : in  std_logic_vector(SIZE-1 downto 0);
        r_o             : out std_logic_vector(SIZE-1 downto 0);
        g_o             : out std_logic_vector(SIZE-1 downto 0);
        b_o             : out std_logic_vector(SIZE-1 downto 0)
       );

end entity PixelColor;

architecture Behavioral_Color of PixelColor is

  signal rgb_s  : std_logic_vector(SIZE-1 downto 0);

begin

  rgb_s <= iteration_i(SIZE-2 downto 0) & '0';

  --r_o <= rgb_s(SIZE-1 downto 5) & "00000";
  --g_o <= rgb_s(5 downto 3) & "00000";
  --b_o <= rgb_s(2 downto 0) & "00000";
  r_o <= rgb_s;
  g_o <= rgb_s;
  b_o <= rgb_s;

end architecture Behavioral_Color;
