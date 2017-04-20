library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TB_Stimuli_IP_MandelbrotCalculator is

  generic (
           SIZE       : integer := 18;
           SIZE_ITER  : integer := 8
          );

  port (
        clk_o           : out std_logic;
        rst_o           : out std_logic;
        start_o         : out std_logic;
        c_re_o          : out std_logic_vector(SIZE-1 downto 0);
        c_im_o          : out std_logic_vector(SIZE-1 downto 0);
        z_re_i          : in  std_logic_vector(SIZE-1 downto 0);
        z_im_i          : in  std_logic_vector(SIZE-1 downto 0);
        iteration_i     : in  std_logic_vector(SIZE_ITER-1 downto 0);
        finish_i        : in  std_logic
       );

end entity TB_Stimuli_IP_MandelbrotCalculator;

architecture Behavioral of TB_Stimuli_IP_MandelbrotCalculator is

  --Declaration du composant UUT

  --Signaux pour instanciation composant UUT

  --signaux propres au testbench
  	SIGNAL sim_end      : BOOLEAN   := FALSE;
  	SIGNAL mark_error   : std_logic := '0';
  	SIGNAL error_number : INTEGER   := 0;
  	SIGNAL clk_gen      : std_logic := '0';

    signal iter_ref     : std_logic_vector(SIZE_ITER-1 downto 0);
    signal z_re_1_ref   : std_logic_vector(SIZE-1 downto 0);
    signal z_im_1_ref   : std_logic_vector(SIZE-1 downto 0);

begin

  --Intanciation du composant UUT

    --********** PROCESS "clk_gengen" **********
    clk_gengen: PROCESS
      BEGIN
        IF sim_end = FALSE THEN
          clk_gen <= '1', '0' AFTER 1 ns;
          clk_o   <= '1', '0' AFTER 5 ns, '1' AFTER 17 ns; --commenter si on teste une fonction combinatoire (pas de clock)
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
          start_o   <= '0';
          c_re_o    <= (OTHERS => '0');
          c_im_o    <= (OTHERS => '0');
          iter_ref  <= (OTHERS => '0');
          z_re_1_ref <= (OTHERS => '0');
          z_im_1_ref <= (OTHERS => '0');
      END init;

      --********** PROCEDURE "assign_mandelbrot" **********
      PROCEDURE assign_mandelbrot(c_re, c_im: IN std_logic_vector(SIZE-1 DOWNTO 0)) IS
        BEGIN
          c_re_o    <= c_re;
          c_im_o    <= c_im;
      END assign_mandelbrot;

      --********** PROCEDURE "assign_ref_mandelbrot" **********
      PROCEDURE assign_ref_mandelbrot(iteration_ref: IN std_logic_vector(SIZE_ITER-1 DOWNTO 0); z_re_ref, z_im_ref: IN std_logic_vector(SIZE-1 DOWNTO 0)) IS
        BEGIN
          iter_ref <= iteration_ref;
          z_re_1_ref <= z_re_ref;
          z_im_1_ref <= z_im_ref;
      END assign_ref_mandelbrot;

      --********** PROCEDURE "execute_mandebrot" **********
      PROCEDURE execute_mandebrot IS
        BEGIN
          sim_cycle(1);
          start_o <= '1';
          sim_cycle(1);
          start_o <= '0';
          sim_cycle(150);
      END execute_mandebrot;

      --********** PROCEDURE "check_result_mandelbrot_light" **********
      PROCEDURE check_result_mandelbrot_light(erreur: IN integer) IS
        BEGIN
          IF iter_ref/=iteration_i THEN
            mark_error <= '1', '0' AFTER 1 ns;
            error_number <= erreur;
            REPORT "Erreur No " & integer'image(erreur) & " - Etat du resultat (iteration) non correct" SEVERITY ERROR;
          END IF;

          sim_cycle(1);
      END check_result_mandelbrot_light;

      --********** PROCEDURE "check_result_mandelbrot_full" **********
      PROCEDURE check_result_mandelbrot_full(erreur: IN integer) IS
        BEGIN
          IF iter_ref/=iteration_i THEN
            mark_error <= '1', '0' AFTER 1 ns;
            error_number <= erreur;
            REPORT "Erreur No " & integer'image(erreur) & " - Etat du resultat (iteration) non correct" SEVERITY ERROR;
          END IF;
          IF z_re_1_ref/=z_re_i THEN
            mark_error <= '1', '0' AFTER 1 ns;
            error_number <= erreur;
            REPORT "Erreur No " & integer'image(erreur) & " - Etat du resultat (re) non correct" SEVERITY ERROR;
          END IF;
          IF z_im_1_ref/=z_im_i THEN
            mark_error <= '1', '0' AFTER 1 ns;
            error_number <= erreur;
            REPORT "Erreur No " & integer'image(erreur) & " - Etat du resultat (im) non correct" SEVERITY ERROR;
          END IF;

          sim_cycle(1);
      END check_result_mandelbrot_full;

      BEGIN

        init;  --appel procdure init
        ASSERT FALSE REPORT "la simulation est en cours" SEVERITY NOTE;
        --debut des tests
        sim_cycle(2);

        --Desactivation du reset
        rst_o <= '0';
        sim_cycle(1);

        --C_Re = 0.0, C_Im = 0.0 -> Iteration = 100
        assign_mandelbrot("00" & X"0000", "00" & X"0000");
        assign_ref_mandelbrot(X"64", "00" & X"2000", "00" & X"0000");
        execute_mandebrot;
        check_result_mandelbrot_light(1);

        --C_Re = 2.0, C_Im = 2.0 -> Iteration = 2
        assign_mandelbrot("00" & X"4000", "00" & X"4000");
        assign_ref_mandelbrot(X"02", "00" & X"0000", "00" & X"2000");
        execute_mandebrot;
        check_result_mandelbrot_light(2);


        --End simu
        sim_cycle(20);

        sim_end <= TRUE;
        wait;

      END PROCESS;

end architecture Behavioral;
