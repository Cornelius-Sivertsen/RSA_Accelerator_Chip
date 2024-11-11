library work;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

entity fsm_testbench is
--  Port ( );
end fsm_testbench;

architecture Behavioral of fsm_testbench is
  signal res: std_logic;
  signal clock: std_logic := '0';
  constant period: time := 1 ns;
  signal simu_Done: boolean;
  signal ext_trigger: std_logic := '0';
  
  
  signal msgin_valid: std_logic := '0';
  signal msgin_ready: std_logic := '0';
  
  signal msgout_valid:  std_logic := '0';
  signal msgout_ready: std_logic := '0';
  
  signal first_iteration: std_logic;
  signal calculation_finished: std_logic;

-- Procedure to pulse on, then off, an std_logic signal.
-- Does not wait for a clock edge before pulsing. (asynchronous)
-- Signal stays on for a very short while (100ps)
  procedure pulse_signal_asynch (signal sig: inout std_logic) is
  begin
    sig <= '1';
    wait for 100 ps;
    sig <= '0';
  end procedure;

-- Procedure to pulse on, then of, an std_logic signal.
-- Ensures that the signal is (already) on when a clock rising edge arrives.
  procedure pulse_signal_synch (signal sig: inout std_logic;
                                signal clock: in std_logic) is
  begin      
    sig <= '1';
    wait until rising_edge(clock);
    wait for period * 3;
    sig <= '0';
    wait for period * 6;
  end procedure;
  
  procedure blakley_iteration(signal sig: inout std_logic; signal clock: in std_logic) is
  begin
    wait for 345ps; --simulate the signal mis-aligning slightly from the clock
    wait for period * 15; --simulate one iteration
    
    wait until rising_edge(clock);
    sig <= '1';
    wait for period * 2;
    sig <= '0';
    wait for period * 1;
  end procedure;
    


begin

  DUT: entity work.exp_fsm port map(
    Reset => res,
    Clock => clock,
    trigger => ext_trigger,
    msgin_valid => msgin_valid,
    msgout_ready => msgout_ready,
    msgout_valid => msgout_valid,
    msgin_ready => msgin_ready,
    
    first_iteration => first_iteration,
    calculation_finished => calculation_finished
    );

  clock <= '0' when simu_Done else not clock after Period/2; --try dividing by two.

  stimuli: process
  begin

    simu_Done <= false;
    res <= '1';
    wait for 10ps;
    res <= '0';
    
    report "Starting simulation" ;
    
    wait for period * 20;

    msgin_valid <= '1';
    
    wait on msgin_ready; msgin_valid <= '0';
    
    wait for period * 10;
    wait for 432ps;
    
    for i in 0 to 500 loop
    blakley_iteration(ext_trigger, clock);
    end loop;
    
    msgin_valid <= '1';
    
    for i in 0 to 500 loop
    blakley_iteration(ext_trigger, clock);
    end loop;
    
    pulse_signal_asynch(res);
    
    for i in 0 to 500 loop
    blakley_iteration(ext_trigger, clock);
    end loop;

    simu_Done <= true;
    report "ending simulation";
    finish;
    
    
    
  end process;

end Behavioral;
