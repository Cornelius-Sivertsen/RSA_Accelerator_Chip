library work;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

entity counter_tb is

end counter_tb;

architecture Behavioral of counter_tb is
  signal res: std_logic;
  signal clock: std_logic := '0';
  constant period: time := 1 ns;
  signal simu_Done: boolean;
  signal ext_trigger: std_logic := '0';
  
  signal counter_value: integer range 0 to 255;
  
  signal enable_counter: STD_logic := '0';

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
    wait for period * 1;
    sig <= '0';
    wait for period * 2;
  end procedure;


begin

  DUT: entity work.counter port map(
    Reset => res,
    Clock => clock,
    trigger => ext_trigger,
    counter_val_out => counter_value,
    start_counting => enable_counter
    );

  clock <= '0' when simu_Done else not clock after Period;

  stimuli: process
  begin

    simu_Done <= false;
    res <= '1';
    wait for 10ps;
    res <= '0';
    
    wait for 100ps;
    
    report "Starting simulation" ;
    
    wait for period * 12;
    
    enable_counter <= '1';
    
    wait for period * 12;
    
    assert ( counter_value = 1)
      report "Counting without triggers"
      severity Failure;

    wait for 325 ps;

    for i in 1 to 100 loop
      pulse_signal_synch(ext_trigger, clock);
      wait for 300 ps;
      
      if i = 42 then
        assert ( counter_value > 10)
            report "Counter not counting"
            severity Failure;
      end if;           
    end loop;
    
    wait for 100 ps;

    
    pulse_signal_asynch(res);
    
    wait for period * 1;
    
    assert ( counter_value = 1)
            report "counter not resetting from global reset signal"
            severity Failure;
            
    for i in 1 to 100 loop
      pulse_signal_synch(ext_trigger, clock);
      wait for 300 ps;
    end loop;
 
    ext_trigger <= '0';
    wait for period * 50;
    
    ext_trigger <= '1';
    
    wait for period * 50;
    
    ext_trigger <= '0';
    
    wait for 200 ps;
    
    pulse_signal_asynch(res);
    
    wait until rising_edge(clock);
    wait for period * 5;
    
    for i in 1 to 1000 loop
      pulse_signal_synch(ext_trigger, clock);
      wait for 300 ps;
    end loop;
    
    enable_counter <= '0';
    
    for i in 1 to 50 loop
      pulse_signal_synch(ext_trigger, clock);
      wait for 300 ps;
    end loop;
    
    enable_counter <= '1';
    wait for period * 1;
    enable_counter <= '0';
    
    for i in 1 to 50 loop
      pulse_signal_synch(ext_trigger, clock);
      wait for 300 ps;
    end loop;
    
 
    simu_Done <= true;
    report "ending simulation";
    finish;
    
    
    
  end process;

end Behavioral;
