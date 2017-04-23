library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TB_Stimuli_IP_MandelbrotGenerator is

  generic (
           SIZE_SCREEN    : integer := 11;
           SIZE_ITER      : integer := 8
          );

  port (
        clk_o       : out std_logic;
        rst_o       : out std_logic;
        x_i         : in  std_logic_vector(SIZE_SCREEN-1 downto 0);
        y_i         : in  std_logic_vector(SIZE_SCREEN-1 downto 0);
        finish_i    : in  std_logic;
        iteration_i : in  std_logic_vector(SIZE_ITER-1 downto 0)
       );

end entity TB_Stimuli_IP_MandelbrotGenerator;

architecture Behavioral of TB_Stimuli_IP_MandelbrotGenerator is

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
          clk_o   <= '1', '0' AFTER 2 ns, '1' AFTER 7 ns; --commenter si on teste une fonction combinatoire (pas de clock)
          wait for 10 ns;
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
          rst_o <= '1';
      END init;

      BEGIN

        init;  --appel procdure init
        ASSERT FALSE REPORT "la simulation est en cours" SEVERITY NOTE;
        --debut des tests
        sim_cycle(2);

        --Desactivation du reset
        rst_o <= '0';

        sim_cycle(8000000);

        --End simu
        sim_cycle(20);

        sim_end <= TRUE;
        ASSERT FALSE REPORT "la simulation est fini" SEVERITY NOTE;
        wait;

      END PROCESS;

end architecture Behavioral;
