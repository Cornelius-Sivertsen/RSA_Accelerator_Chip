library work;

library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

entity vrh_tb is

end entity vrh_tb;

architecture rtl of vrh_tb is
  signal res: std_logic := '0';
  signal clock: std_logic := '0';
  constant period: time := 1 ns;
  signal data_valid: std_logic; --OUTput
  signal calc_done: std_logic := '0'; --INput
  signal out_ready: std_logic := '0'; --INput
  signal simu_done: boolean;

  type testcase_t is (test_1, test_2, test_3, test_4);
  signal active_test: testcase_t := test_1;
begin
  DUT: entity work.VRH (out_handshake_v2) port map(
    done => calc_done,
    ready => out_ready,
    reset => res,
    clk => clock,
    valid => data_valid
    );

  clock <= '0' when simu_done else not clock after Period/2;

  stimuli: process
  begin

    -- set active test here
    active_test <= test_4;

    simu_Done <= false;
    report "starting simulation";

    wait for period * 5;

    case (active_test) is
      when test_1 =>
      
        wait until rising_edge(clock);
        calc_done <= '1';
        wait for period * 1;

        calc_done <= '0';
        wait for period * 1;

        wait for period * 3;
        
        wait until rising_edge(clock);
        out_ready <= '1';
        wait for period * 1;


        out_ready <= '0';
        wait for period * 1;

      when test_2 =>
        
        wait until rising_edge(clock);
        out_ready <= '1';
        wait for period * 1;
        
        out_ready <= '0';
        wait for period * 1;

        wait for period * 3;
        
        wait until rising_edge(clock);
        out_ready <= '1';
        wait for period * 1;

        wait for period * 3;
        
        wait until rising_edge(clock);
        calc_done <= '1';
        wait for period * 1;

        --case 2/3 differ
        
        wait until rising_edge(clock);
        out_ready <= '0';
        wait for period * 1;

        calc_done <= '0';
        wait for period * 1;

      when test_3 =>
        
        wait until rising_edge(clock);
        out_ready <= '1';
        wait for period * 1;

        out_ready <= '0';
        wait for period * 1;

        wait for period * 3;
        
        wait until rising_edge(clock);
        out_ready <= '1';
        wait for period * 1;

        wait for period * 3;
        
        wait until rising_edge(clock);
        calc_done <= '1';
        wait for period * 1;

        --case 2/3 differ
        --calc_done <= '0';
        wait for period * 1;
        wait for period * 1;
        wait for period * 1;
        wait for period * 1;

        out_ready <= '0';
        wait for period * 3;
        
        out_ready <= '1';
        wait for period * 3;
        calc_done <= '0';
        wait for period * 3;
        out_ready <= '1';
        
      when test_4 =>
        
        wait for period;
        
        wait until rising_edge(clock);
        calc_done <= '1';
        
        wait for period * 1;
        wait until rising_edge(clock);
        out_ready <= '1';
        wait for period;
        
        wait until rising_edge(clock);
        out_ready <= '0';
        wait for period;
        
        wait until rising_edge(clock);
        out_ready <= '1';
        wait for period;
        
        wait until rising_edge(clock);
        out_ready <= '0';
        wait for period;
        
        wait until rising_edge(clock);
        calc_done <= '0';
        wait for period;
        
        
        wait for period * 3;
        

      when others =>

        report "no valid test selected" severity error;

    end case;

    wait for period * 5;

    simu_done <= true;
    report "ending simulation";
    finish;

  end process;
end architecture;
