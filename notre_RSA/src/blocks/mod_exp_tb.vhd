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
  signal man_res_top_level: std_logic;
  signal clock: std_logic := '0';
  constant period: time := 1 ns;
  signal Done: boolean;
  signal ext_trigger: std_logic := '0';
  signal wb_resolution: std_logic;
  
  signal msgin_valid: std_logic := '1';
  
  signal msgin_ready: std_logic;
  signal msgout_valid: std_logic;

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
    wait for 100 ps;
    sig <= '0';
  end procedure;


begin

  DUT: entity work.exp_fsm port map(
    Reset => res,
    manual_reset => man_res_top_level,
    Clock => clock,
    trigger => ext_trigger,
    write_back_resolution => wb_resolution,
    msgin_valid => msgin_valid,
    msgout_valid => msgout_valid,
    msgin_ready => msgin_ready
    );

  clock <= '0' when Done else not clock after Period;

  stimuli: process
  begin

    Done <= false;
    res <= '1';
    wait for 10ps;
    res <= '0';
    
    report "Starting simulation" ;
    
    wait for period * 20;
    
    assert ( (wb_resolution = '0') and (msgin_ready = '0'))
      report "Start of calculation signals failing"
      severity Failure;

    wait for 325 ps;

    for i in 1 to 254 loop
      pulse_signal_synch(ext_trigger, clock);
      wait for 300 ps;
      
      if i = 42 then
        assert ( wb_resolution = '1')
            report "write back resolution not updating"
            severity Failure;
        assert ( msgin_ready = '0')
            report "Calc done updating too son"
            severity Failure;
            end if;
      
    end loop;
    
    wait for 100 ps;

    assert ( msgin_ready = '1' )
      report "fsm not detecting end of calc"
      severity Failure;

    for i in 1 to 605 loop
      pulse_signal_synch(ext_trigger, clock);
      wait for 300 ps;
    end loop;
    
    wait for 671 ps;
    
    pulse_signal_asynch(res);
    
    for i in 1 to 200 loop
      pulse_signal_synch(ext_trigger, clock);
      wait for 300 ps;
    end loop;
    
    wait for 123 ps;
    
    pulse_signal_asynch(res);
    
    wait for 560 ps;
    
    pulse_signal_asynch(res);
    
    for i in 1 to 200 loop
      pulse_signal_synch(ext_trigger, clock);
      wait for 300 ps;
    end loop;
    
    
    
    Done <= true;
    report "ending simulation";
    finish;
    
    
    
  end process;

end Behavioral;
