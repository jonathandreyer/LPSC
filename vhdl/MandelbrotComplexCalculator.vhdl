library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MandelbrotComplexCalculator is

  generic (
           SIZE  : integer := 18;
           COMMA : integer := 12
           --X_BUS_WIDTH   : integer := 16; -- [16 15]
           --F_BUS_WIDTH   : integer := 48; -- [48 42]
           --F_RIGHT_WIDTH : integer := 42
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
  --constant LIMIT_DIVERG : std_logic_vector(SIZE_POW2-1 downto 0) := "000100000000000000000000000000000000";
  constant POS_DECIMAL_MULT : integer := (COMMA * 2);
  --constant RESIZE_R     : integer := SIZE_POW2 - SIZE_DECIMAL;
  --constant SIZEL : integer := (F_BUS_WIDTH-(W_RIGHT_WIDTH+SIZER))-(W_BUS_WIDTH-W_RIGHT_WIDTH);

  --constant ZEROS : std_logic_vector(F_RIGHT_WIDTH-1 downto 0) := (others => '0');
  --constant  ONES : std_logic_vector(F_RIGHT_WIDTH-1 downto 0) := (others => '1');
  --constant SIZER : integer := F_RIGHT_WIDTH - W_RIGHT_WIDTH;
  --constant SIZEL : integer := (F_BUS_WIDTH-(W_RIGHT_WIDTH+SIZER))-(W_BUS_WIDTH-W_RIGHT_WIDTH);--(48 - (32+10))- (34-32)

  signal zr_pow2_s             : std_logic_vector(SIZE_POW2-1 downto 0);
  signal zi_pow2_s             : std_logic_vector(SIZE_POW2-1 downto 0);
  signal zr_mult_zi_s          : std_logic_vector(SIZE_POW2-1 downto 0);
  signal zr_mult_zi_mult2_s    : std_logic_vector(SIZE_POW2-1 downto 0);

  signal zr_calc_s             : std_logic_vector(SIZE_POW2-1 downto 0);
  signal zi_calc_s             : std_logic_vector(SIZE_POW2-1 downto 0);
  signal isDivergent_s         : std_logic;

begin

  zr_pow2_s    <= std_logic_vector(signed(z_re_i) * signed(z_re_i));
  zi_pow2_s    <= std_logic_vector(signed(z_im_i) * signed(z_im_i));
  zr_mult_zi_s <= std_logic_vector(signed(z_re_i) * signed(z_im_i));
  zr_mult_zi_mult2_s <= ('1' & zr_mult_zi_s(SIZE_POW2-3 downto 0) & '0')  when zr_mult_zi_s(zr_mult_zi_s'left) = '1' else
                        ('0' & zr_mult_zi_s(SIZE_POW2-3 downto 0) & '0');

  process (clk_i, rst_i)
    begin
      if rst_i = '1' then
        zr_calc_s    <= (others => '0');
        zi_calc_s    <= (others => '0');
        isDivergent_s <= '0';
      elsif rising_edge(clk_i) then
        if enable_i = '1' then
          zr_calc_s <= std_logic_vector((signed(zr_pow2_s) - signed(zr_pow2_s)) + signed(c_re_i));
          zi_calc_s <= std_logic_vector(signed(zr_mult_zi_mult2_s) + signed(c_im_i));

          if signed(signed(zr_pow2_s) + signed(zi_pow2_s)) > signed(z_norm_limit_i) then
            isDivergent_s <= '1';
          else
            isDivergent_s <= '0';
          end if;

        end if;
      end if;
    end process;

--TODO finish (size right / left)
  z_re_1_o <= ('1' & zr_calc_s(SIZE-2 downto 0)) when zr_calc_s(zr_mult_zi_s'left) = '1' else
              ('0' & zr_calc_s(SIZE-2 downto 0));
  z_im_1_o <= ('1' & zi_calc_s(SIZE-2 downto 0)) when zi_calc_s(zr_mult_zi_s'left) = '1' else
              ('0' & zi_calc_s(SIZE-2 downto 0));

  isDivergent_o <= isDivergent_s;

end architecture MandelbrotComplexCalculator;
