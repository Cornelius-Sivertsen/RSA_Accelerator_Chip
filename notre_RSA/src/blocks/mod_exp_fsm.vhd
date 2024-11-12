library work;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;


entity exp_fsm is
  Port ( 
    --INPUTS:
    reset : in STD_LOGIC;
    clock : in STD_LOGIC;
    trigger : in STD_LOGIC;
    msgin_valid : in STD_logic;
    msgout_ready : IN std_logic;
    ----------------------------------------
    --OUTPUTS:
    first_iteration: buffer std_logic;
    msgin_ready : out STD_LOGIC;
    msgout_valid : out STD_LOGIC;
    calculation_finished : buffer std_logic -- to be decided
    );

end exp_fsm;

architecture Behavioral of exp_fsm is

  signal counter_value: integer range 0 to 256;
begin

  counter: entity work.counter port map(
    reset => reset,
    clock => clock,
    trigger => trigger,
    start_counting => msgin_valid,
    counter_val_out => counter_value    
    );
    
    VR_handshake: entity work.VRH port map(
    done => calculation_finished,
    ready => msgout_ready,
    reset => reset,
    clk => clock,
    valid => msgout_valid  
    );
  

  event_loop: process(reset, clock)  -- as the counter is already handling reset,
  -- we dont need to do it here
  variable first_iter_done: std_logic := '0';
  begin

    if reset = '1' then
      msgin_ready <= '0';
      first_iteration <= '0';
      calculation_finished <= '0';
      first_iter_done := '0';
    elsif rising_edge(clock) then
      case (counter_value) is
        when 0 =>  
          first_iteration <= '0';
          calculation_finished <= '0';
          
          if msgin_valid = '1' then
            msgin_ready <= '0';
          else
            msgin_ready <= '1';
          end if;
          
        when 1 =>
          msgin_ready <= '0';
          calculation_finished <= '0';
          
          if first_iter_done = '0' then
            first_iteration <= '1';
          else
            first_iteration <= '0';  
          end if;
          first_iter_done := '1';
        when 256 =>
          msgin_ready <= '0';
          first_iteration <= '0';
          calculation_finished <= '1';
        when others =>
          msgin_ready <= '0';
          first_iteration <= '0';
          calculation_finished <= '0';
          first_iter_done := '0';
      end case;
    end if;
  end process;
end Behavioral;
