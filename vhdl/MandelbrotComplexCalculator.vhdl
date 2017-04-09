library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MandelbrotComplexCalculator is

  generic (
           Q_WIDTH      : integer := 18; --Q4.13
           P_WITDH      : integer := 13
          );

  port (
        clk_i           : in  std_logic;
        rst_i           : in  std_logic;
        enable_i        : in  std_logic;
        c_re_i          : in  std_logic_vector(Q_WIDTH-1 downto 0);
        c_im_i          : in  std_logic_vector(Q_WIDTH-1 downto 0);
        z_re_i          : in  std_logic_vector(Q_WIDTH-1 downto 0);
        z_im_i          : in  std_logic_vector(Q_WIDTH-1 downto 0);
        z_norm_limit_i  : in  std_logic_vector(Q_WIDTH-1 downto 0);
        z_re_1_o        : out std_logic_vector(Q_WIDTH-1 downto 0);
        z_im_1_o        : out std_logic_vector(Q_WIDTH-1 downto 0);
        isDivergent_o   : out std_logic
       );

end entity MandelbrotComplexCalculator;

architecture Behavioral of MandelbrotComplexCalculator is

  constant MULT_WIDTH           : integer := Q_WIDTH * 2;                       -- (18*2)    = 36
  constant MULT_PRECISION_WITDH : integer := (P_WITDH * 2) - 1;                 -- (13*2)-1  = 25
  constant Z_1_RIGHT_WIDTH      : integer := (MULT_PRECISION_WITDH - P_WITDH);  -- (25-13)   = 12
  constant Z_1_LEFT_WIDTH       : integer := (Z_1_RIGHT_WIDTH + Q_WIDTH - 2);   -- (12+18-2) = 28

  constant ZEROS                : std_logic_vector(MULT_WIDTH-1 downto 0) := (others => '0');
  constant ONES                 : std_logic_vector(MULT_WIDTH-1 downto 0) := (others => '1');

  signal cr_s                   : std_logic_vector(MULT_WIDTH-1 downto 0);
  --signal cr_s_f                   : std_logic_vector(MULT_WIDTH-1 downto 0);
  signal ci_s                   : std_logic_vector(MULT_WIDTH-1 downto 0);
  --signal ci_s_f                   : std_logic_vector(MULT_WIDTH-1 downto 0);
  signal z_norm_limit_s         : std_logic_vector(MULT_WIDTH-1 downto 0);

  signal zr_pow2_s              : std_logic_vector(MULT_WIDTH-1 downto 0);
  signal zi_pow2_s              : std_logic_vector(MULT_WIDTH-1 downto 0);
  signal zr_mult_zi_s           : std_logic_vector(MULT_WIDTH-1 downto 0);
  signal zr_mult_zi_mult2_s     : std_logic_vector(MULT_WIDTH-1 downto 0);

  signal zr_calc_s              : std_logic_vector(MULT_WIDTH-1 downto 0);
  signal zi_calc_s              : std_logic_vector(MULT_WIDTH-1 downto 0);
  signal isDivergent_s          : std_logic;

begin

  --TODO better way???
  --cr_s <= std_logic_vector(resize(signed(c_re_i), cr_s'length));
  cr_s <= ('1' & ONES(MULT_WIDTH-2 downto Z_1_LEFT_WIDTH+1) & c_re_i(Q_WIDTH-2 downto 0) & ZEROS(Z_1_RIGHT_WIDTH-1 downto 0)) when c_re_i(c_re_i'left) = '1' else
          ('0' & ZEROS(MULT_WIDTH-2 downto Z_1_LEFT_WIDTH+1) & c_re_i(Q_WIDTH-2 downto 0) & ZEROS(Z_1_RIGHT_WIDTH-1 downto 0));
  --ci_s <= std_logic_vector(resize(signed(c_im_i), ci_s'length));
  ci_s <= ('1' & ONES(MULT_WIDTH-2 downto Z_1_LEFT_WIDTH+1) & c_im_i(Q_WIDTH-2 downto 0) & ZEROS(Z_1_RIGHT_WIDTH-1 downto 0)) when c_im_i(c_im_i'left) = '1' else
          ('0' & ZEROS(MULT_WIDTH-2 downto Z_1_LEFT_WIDTH+1) & c_im_i(Q_WIDTH-2 downto 0) & ZEROS(Z_1_RIGHT_WIDTH-1 downto 0));

  z_norm_limit_s <= ('1' & ONES(MULT_WIDTH-2 downto Z_1_LEFT_WIDTH+1) & z_norm_limit_i(Q_WIDTH-2 downto 0) & ZEROS(Z_1_RIGHT_WIDTH-1 downto 0)) when z_norm_limit_i(z_norm_limit_i'left) = '1' else
                    ('0' & ZEROS(MULT_WIDTH-2 downto Z_1_LEFT_WIDTH+1) & z_norm_limit_i(Q_WIDTH-2 downto 0) & ZEROS(Z_1_RIGHT_WIDTH-1 downto 0));

  zr_pow2_s    <= std_logic_vector(signed(z_re_i) * signed(z_re_i));
  zi_pow2_s    <= std_logic_vector(signed(z_im_i) * signed(z_im_i));
  zr_mult_zi_s <= std_logic_vector(signed(z_re_i) * signed(z_im_i));
  zr_mult_zi_mult2_s <= ('1' & zr_mult_zi_s(MULT_WIDTH-3 downto 0) & '0')  when zr_mult_zi_s(zr_mult_zi_s'left) = '1' else
                        ('0' & zr_mult_zi_s(MULT_WIDTH-3 downto 0) & '0');

  process (clk_i, rst_i)
    begin
      if rst_i = '1' then
        zr_calc_s    <= (others => '0');
        zi_calc_s    <= (others => '0');
        isDivergent_s <= '0';
      elsif rising_edge(clk_i) then
        if enable_i = '1' then
          zr_calc_s <= std_logic_vector(signed(zr_pow2_s) - signed(zr_pow2_s) + signed(cr_s));
          zi_calc_s <= std_logic_vector(signed(zr_mult_zi_mult2_s) + signed(ci_s));

          if signed(signed(zr_pow2_s) + signed(zi_pow2_s)) > signed(z_norm_limit_s) then
            isDivergent_s <= '1';
          else
            isDivergent_s <= '0';
          end if;

        end if;
      end if;
    end process;

  -- TODO a revoir (sans bidouille du signe)
  z_re_1_o <= ('1' & zr_calc_s(Z_1_LEFT_WIDTH downto Z_1_RIGHT_WIDTH)) when zr_calc_s(zr_mult_zi_s'left) = '1' else
              ('0' & zr_calc_s(Z_1_LEFT_WIDTH downto Z_1_RIGHT_WIDTH));
  z_im_1_o <= ('1' & zi_calc_s(Z_1_LEFT_WIDTH downto Z_1_RIGHT_WIDTH)) when zi_calc_s(zr_mult_zi_s'left) = '1' else
              ('0' & zi_calc_s(Z_1_LEFT_WIDTH downto Z_1_RIGHT_WIDTH));

  isDivergent_o <= isDivergent_s;

end architecture Behavioral;
