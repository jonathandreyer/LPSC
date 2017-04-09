library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;

entity TB_Stimuli_IP_MandelbrotComplexCalculator is

  generic (
           SIZE  : integer := 18
           --COMMA : integer := 12
           );

  port (
        clk             : out std_logic;
        rst_o           : out std_logic;
        enable_o        : out std_logic;
        c_re_o          : out std_logic_vector(SIZE-1 downto 0);
        c_im_o          : out std_logic_vector(SIZE-1 downto 0);
        z_re_o          : out std_logic_vector(SIZE-1 downto 0);
        z_im_o          : out std_logic_vector(SIZE-1 downto 0);
        z_norm_limit_o  : out std_logic_vector(SIZE-1 downto 0);
        z_re_1_i        : in  std_logic_vector(SIZE-1 downto 0);
        z_im_1_i        : in  std_logic_vector(SIZE-1 downto 0);
        isDivergent_i   : in  std_logic
        );

end entity TB_Stimuli_IP_MandelbrotComplexCalculator;

architecture behaviour of TB_Stimuli_IP_MandelbrotComplexCalculator is

  --Declaration du composant UUT

  --Signaux pour instanciation composant UUT

  --signaux propres au testbench
  	SIGNAL sim_end      : BOOLEAN   := FALSE;
  	SIGNAL mark_error   : std_logic := '0';
  	SIGNAL error_number : INTEGER   := 0;
  	SIGNAL clk_gen      : std_logic := '0';

    constant SIZE_BUS   : integer := 18;

    signal z_re_1_attendu : std_logic_vector(SIZE-1 downto 0);
    signal z_im_1_attendu : std_logic_vector(SIZE-1 downto 0);
    signal div_attendu    : std_logic;

begin

  --Intanciation du composant UUT

    --********** PROCESS "clk_gengen" **********
    clk_gengen: PROCESS
      BEGIN
        IF sim_end = FALSE THEN
          clk_gen <= '1', '0' AFTER 1 ns;
          clk     <= '1', '0' AFTER 5 ns, '1' AFTER 17 ns; --commenter si on teste une fonction combinatoire (pas de clock)
          wait for 25 ns;
        ELSE
          wait;
        END IF;
    END PROCESS;

    --********** PROCESS "run" **********
    run: PROCESS

      PROCEDURE sim_cycle(num : IN integer) IS
        BEGIN
          FOR index IN 1 TO num LOOP
            wait until clk_gen'EVENT AND clk_gen = '1';
          END LOOP;
      END sim_cycle;

      --********** PROCEDURE "init" **********
      --fixer toutes les entrees du module à tester (DUT)
      PROCEDURE init IS
        BEGIN
          rst_o     <= '1';
          enable_o  <= '0';
          c_re_o    <= (OTHERS => '0');
          c_im_o    <= (OTHERS => '0');
          z_re_o    <= (OTHERS => '0');
          z_im_o    <= (OTHERS => '0');
          z_norm_limit_o <= (OTHERS => '0');
          z_re_1_attendu <= (OTHERS => '0');
          z_im_1_attendu <= (OTHERS => '0');
          div_attendu <= '0';
      END init;

      --********** PROCEDURE "assign_mandelbrot" **********
      PROCEDURE assign_mandelbrot(z_re, z_im, c_re, c_im: IN std_logic_vector(SIZE_BUS-1 DOWNTO 0)) IS
        BEGIN
          c_re_o    <= c_re;
          c_im_o    <= c_im;
          z_re_o    <= z_re;
          z_im_o    <= z_im;
      END assign_mandelbrot;

      --********** PROCEDURE "execute_mandebrot" **********
      PROCEDURE execute_mandebrot IS
        BEGIN
          sim_cycle(1);
          enable_o <= '1';
          sim_cycle(1);
          enable_o <= '0';
          sim_cycle(1);
      END execute_mandebrot;

      --********** PROCEDURE "check_result_mandelbrot" **********
      PROCEDURE check_result_mandelbrot(z_re_attendu, z_im_attendu: IN std_logic_vector(SIZE_BUS-1 DOWNTO 0); diverg_attendu: IN std_logic; erreur: IN integer) IS
        BEGIN
          IF z_im_attendu/=z_im_1_i THEN
            mark_error <= '1', '0' AFTER 1 ns;
            error_number <= erreur;
            z_im_1_attendu <= z_im_attendu, (OTHERS => '0') AFTER 5 ns;
            REPORT "Erreur No " & integer'image(erreur) & " - Etat du resultat (im) non correct" SEVERITY ERROR;
          END IF;
          IF z_re_attendu/=z_re_1_i THEN
            mark_error <= '1', '0' AFTER 1 ns;
            error_number <= erreur;
            z_re_1_attendu <= z_re_attendu, (OTHERS => '0') AFTER 5 ns;
            REPORT "Erreur No " & integer'image(erreur) & " - Etat du resultat (re) non correct" SEVERITY ERROR;
          END IF;
          IF diverg_attendu/=isDivergent_i THEN
            mark_error <= '1', '0' AFTER 1 ns;
            error_number <= erreur;
            div_attendu <= diverg_attendu;
            REPORT "Erreur No " & integer'image(erreur) & " - Etat du resultat (diverg) non correct" SEVERITY ERROR;
          END IF;
          sim_cycle(1);
      END check_result_mandelbrot;

      BEGIN

        init;  --appel procdure init
        ASSERT FALSE REPORT "la simulation est en cours" SEVERITY NOTE;
        --debut des tests
        sim_cycle(2);

        --Desactivation du reset
        rst_o <= '0';
        z_norm_limit_o <= "001000000000000000";
        sim_cycle(1);

        --Z_Re = 0.0, Z_Im = 0.0, C_Re = 1.0, C_Im = 0.0
        assign_mandelbrot("00" & X"0000", "00" & X"0000", "00" & X"2000", "00" & X"0000");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"2000", "00" & X"0000", '0', 100);

        --Z_Re = 0.0, Z_Im = 0.0, C_Re = 0.0, C_Im = 1.0
        assign_mandelbrot("00" & X"0000", "00" & X"0000", "00" & X"0000", "00" & X"2000");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"0000", "00" & X"2000", '0', 101);

        --Z_Re = 1.0, Z_Im = 0.0, C_Re = 0.0, C_Im = 0.0
        assign_mandelbrot("00" & X"2000", "00" & X"0000", "00" & X"0000", "00" & X"0000");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"2000", "00" & X"0000", '0', 102);

        --Z_Re = 0.0, Z_Im = 1.0, C_Re = 0.0, C_Im = 0.0
        assign_mandelbrot("00" & X"0000", "00" & X"2000", "00" & X"0000", "00" & X"0000");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"0000", "00" & X"0000", '0', 103);

        --Z_Re = 1.0, Z_Im = 1.0, C_Re = 1.0, C_Im = 1.0
        assign_mandelbrot("00" & X"2000", "00" & X"2000", "00" & X"2000", "00" & X"2000");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"2000", "00" & X"2000", '0', 104);

        --End simu
        sim_cycle(3);

        sim_end <= TRUE;
        wait;



        assign_mandelbrot("00" & X"0000", "00" & X"0000", "00" & X"0000", "00" & X"0000");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"0000", "00" & X"0000", '0', 1);

        --Zi=(0.5+0.5j)[re=0x1000, img=0x1000], Ci=(0.5+0.5j)[re=0x1000, img=0x1000] -> Zi+1=(0.5+1j)[re=0x1000, img=0x2000], Diverge=False
        assign_mandelbrot("00" & X"1000", "00" & X"1000", "00" & X"1000", "00" & X"1000");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"1000", "00" & X"2000", '0', 2);

        --Zi=(0.5+0.5j)[re=0x1000, img=0x1000], Ci=0j[re=0x0000, img=0x0000] -> Zi+1=0.5j[re=0x0000, img=0x1000], Diverge=False
        assign_mandelbrot("00" & X"1000", "00" & X"1000", "00" & X"0000", "00" & X"0000");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"0000", "00" & X"1000", '0', 3);

        --Zi=(2+1.5j)[re=0x4000, img=0x3000], Ci=0j[re=0x0000, img=0x0000] -> Zi+1=(1.75+6j)[re=0x3800, img=0xc000], Diverge=True
        assign_mandelbrot("00" & X"4000", "00" & X"3000", "00" & X"0000", "00" & X"0000");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"3800", "00" & X"C000", '1', 4);

        --Zi=(0.5+0.25j)[re=0x1000, img=0x0800], Ci=(0.5+0.3j)[re=0x1000, img=0x0999] -> Zi+1=(0.6875+0.55j)[re=0x1600, img=0x1199], Diverge=False
        assign_mandelbrot("00" & X"1000", "00" & X"8000", "00" & X"1000", "00" & X"0999");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"1600", "00" & X"1199", '0', 5);

        --Zi=(0.7+0.4j)[re=0x1666, img=0x0ccc], Ci=(-0.4+0.7j)[re=0x3f334, img=0x1666] -> Zi+1=(-0.07000000000000012+1.2599999999999998j)[re=0x3fdc3, img=0x2851], Diverge=False
        assign_mandelbrot("00" & X"1666", "00" & X"0CCC", "11" & X"F334", "00" & X"1666");
        execute_mandebrot;
        check_result_mandelbrot("11" & X"FDC3", "00" & X"2851", '0', 6);

        --Zi=(-0.6-0.8j)[re=0x3eccd, img=0x3e667], Ci=(0.8-0.7j)[re=0x1999, img=0x3e99a] -> Zi+1=(0.5199999999999999+0.26j)[re=0x10a3, img=0x0851], Diverge=False
        assign_mandelbrot("11" & X"ECCD", "11" & X"E667", "00" & X"1999", "11" & X"E99A");
        execute_mandebrot;
        check_result_mandelbrot("00" & X"10A3", "00" & X"0851", '0', 7);


        --End simu
        sim_cycle(3);

        sim_end <= TRUE;
        wait;

      END PROCESS;

end architecture behaviour;
