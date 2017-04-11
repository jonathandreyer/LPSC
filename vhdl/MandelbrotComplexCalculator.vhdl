library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MandelbrotComplexCalculator is

  generic (
           SIZE       : integer := 16;
           FRACTIONAL : integer := 12;
			  INT_PART   : integer := 4
           );

  port (
        clk_i           : in  std_logic;
        rst_i           : in  std_logic;
		  enable_i        : in  std_logic;
        c_re_i          : in  std_logic_vector(SIZE-1 downto 0);
        c_im_i          : in  std_logic_vector(SIZE-1 downto 0);
        z_re_i          : in  std_logic_vector(SIZE-1 downto 0);
        z_im_i          : in  std_logic_vector(SIZE-1 downto 0);
        z_norm_limit_i  : in  std_logic_vector(SIZE-1 downto 0);
        z_re_1_o        : out std_logic_vector(SIZE-1 downto 0);
        z_im_1_o        : out std_logic_vector(SIZE-1 downto 0);
        isDivergent_o   : out std_logic
        );

end entity MandelbrotComplexCalculator;

architecture MandelbrotComplexCalculator of MandelbrotComplexCalculator is

  constant SIZE_POW2    : integer := SIZE * 2;

  signal zr_pow2_s             : std_logic_vector(SIZE_POW2-1 downto 0);
  signal zi_pow2_s             : std_logic_vector(SIZE_POW2-1 downto 0);
  signal zr_mult_zi_s          : std_logic_vector(SIZE_POW2-1 downto 0);
  signal zr_mult_zi_time2_s    : std_logic_vector(SIZE_POW2-1 downto 0);
  
  signal zr_pow2_scd_s         : std_logic_vector(SIZE-1 downto 0);
  signal zi_pow2_scd_s         : std_logic_vector(SIZE-1 downto 0);
  signal zr_mult_zi_time2_scd_s : std_logic_vector(SIZE-1 downto 0);
  
  signal zr_calc_s             : std_logic_vector(SIZE-1 downto 0);
  signal zi_calc_s             : std_logic_vector(SIZE-1 downto 0);
  signal isDivergent_s         : std_logic;
 

begin

  zr_pow2_s    <= std_logic_vector(signed(z_re_i) * signed(z_re_i));
  zi_pow2_s    <= std_logic_vector(signed(z_im_i) * signed(z_im_i));
  zr_mult_zi_s <= std_logic_vector(signed(z_re_i) * signed(z_im_i));
  zr_mult_zi_time2_s <= std_logic_vector(shift_left(signed(zr_mult_zi_s), 1));
  
  zr_pow2_scd_s <= zr_pow2_s(SIZE + FRACTIONAL-1 downto FRACTIONAL);
  zi_pow2_scd_s <= zi_pow2_s(SIZE + FRACTIONAL-1 downto FRACTIONAL);
  zr_mult_zi_time2_scd_s <= zr_mult_zi_time2_s(SIZE + FRACTIONAL-1 downto FRACTIONAL);
 



	
	process (clk_i, rst_i)
    begin
      if rst_i = '1' then
        zr_calc_s    <= (others => '0');
        zi_calc_s    <= (others => '0');
        isDivergent_s <= '0';
      elsif rising_edge(clk_i) then
        if enable_i = '1' then
          zr_calc_s <= std_logic_vector((signed(zr_pow2_scd_s) - signed(zi_pow2_scd_s)) + signed(c_re_i));
			 zi_calc_s <= std_logic_vector( signed(zr_mult_zi_time2_scd_s) + signed(c_im_i));
          if signed(signed(zr_pow2_s) + signed(zi_pow2_s)) > signed(z_norm_limit_i) then
            isDivergent_s <= '1';
          else
            isDivergent_s <= '0';
          end if;

        end if;
      end if;
    end process;

  z_re_1_o <= zr_calc_s;
  z_im_1_o <= zi_calc_s;

  isDivergent_o <= isDivergent_s;

end architecture MandelbrotComplexCalculator;
