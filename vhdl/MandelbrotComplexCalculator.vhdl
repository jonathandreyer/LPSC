library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MandelbrotComplexCalculator is

  generic (
           SIZE       : integer := 18;
           FRACTIONAL : integer := 13
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

architecture Behavioral_ComplexCalculator of MandelbrotComplexCalculator is

  constant SIZE_POW2    : integer := SIZE * 2;

  signal zr_pow2_s             : std_logic_vector(SIZE_POW2-1 downto 0);
  signal zi_pow2_s             : std_logic_vector(SIZE_POW2-1 downto 0);
  signal zr_mult_zi_s          : std_logic_vector(SIZE_POW2-1 downto 0);
  signal zr_mult_zi_time2_s    : std_logic_vector(SIZE_POW2-1 downto 0);
  signal z_norm_limit_s        : std_logic_vector(SIZE_POW2-1 downto 0);

  signal zr_pow2_scd_s         : std_logic_vector(SIZE-1 downto 0);
  signal zi_pow2_scd_s         : std_logic_vector(SIZE-1 downto 0);
  signal zr_mult_zi_time2_scd_s : std_logic_vector(SIZE-1 downto 0);

  signal zr_calc_s             : std_logic_vector(SIZE-1 downto 0);
  signal zi_calc_s             : std_logic_vector(SIZE-1 downto 0);
  signal isDivergent_s         : std_logic;


  constant MULT_WIDTH           : integer := SIZE * 2;                            -- (18*2)    = 36
  constant MULT_PRECISION_WITDH : integer := (FRACTIONAL * 2) - 1;                -- (13*2)-1  = 25
  constant Z_1_RIGHT_WIDTH      : integer := (MULT_PRECISION_WITDH - FRACTIONAL); -- (25-13)   = 12
  constant Z_1_LEFT_WIDTH       : integer := (Z_1_RIGHT_WIDTH + SIZE - 2);        -- (12+18-2) = 28

  constant ZEROS                : std_logic_vector(SIZE_POW2-1 downto 0) := (others => '0');
  constant ONES                 : std_logic_vector(SIZE_POW2-1 downto 0) := (others => '1');


begin

  zr_pow2_s    <= std_logic_vector(signed(z_re_i) * signed(z_re_i));
  zi_pow2_s    <= std_logic_vector(signed(z_im_i) * signed(z_im_i));
  zr_mult_zi_s <= std_logic_vector(signed(z_re_i) * signed(z_im_i));
  zr_mult_zi_time2_s <= std_logic_vector(shift_left(signed(zr_mult_zi_s), 1));

  z_norm_limit_s <= ('1' & ONES(MULT_WIDTH-2 downto Z_1_LEFT_WIDTH+3) & z_norm_limit_i(SIZE-1 downto 0) & ZEROS(Z_1_RIGHT_WIDTH downto 0))
                            when z_norm_limit_i(z_norm_limit_i'left) = '1' else
                    ('0' & ZEROS(MULT_WIDTH-2 downto Z_1_LEFT_WIDTH+3) & z_norm_limit_i(SIZE-1 downto 0) & ZEROS(Z_1_RIGHT_WIDTH downto 0));

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

          if signed(signed(zr_pow2_s) + signed(zi_pow2_s)) > signed(z_norm_limit_s) then
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

end architecture Behavioral_ComplexCalculator;
