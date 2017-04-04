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
      END init;

      BEGIN

        init;  --appel procdure init
        ASSERT FALSE REPORT "la simulation est en cours" SEVERITY NOTE;
        --debut des tests
        sim_cycle(2);

        --Desactivation du reset
        rst_o <= '0';
        z_norm_limit_o <= "000100000000000000";
        sim_cycle(1);

        c_re_o    <= "000000000000000000";
        c_im_o    <= "000000000000000000";
        z_re_o    <= "000000000000000000";
        z_im_o    <= "000000000000000000";

        sim_cycle(2);
        enable_o <= '1';
        sim_cycle(2);

        enable_o  <= '0';
        sim_cycle(2);

        c_re_o    <= "100100000000000000";
        c_im_o    <= "010000000000000000";
        z_re_o    <= "000100000000100000";
        z_im_o    <= "101000000001100000";

        sim_cycle(2);
        enable_o <= '1';

        sim_cycle(4);
        enable_o <= '0';


        --End simu
        sim_cycle(3);

        sim_end <= TRUE;
        wait;

      END PROCESS;

end architecture behaviour;
