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
  signal msg_ready_nxt: std_logic := '1';
  signal at_idle: std_logic;
begin

  counter: entity work.counter port map(
    reset => reset,
    clock => clock,
    trigger => trigger,
    start_counting => msgin_valid,
    counter_val_out => counter_value    
    );
    
    VR_handshake_out: entity work.VRH(out_handshake_v2) port map(
    done => calculation_finished,
    ready => msgout_ready,
    reset => reset,
    clk => clock,
    valid => msgout_valid  
    );
    
    VR_handshake_in: entity work.VRH(out_handshake_v2) port map(
    done => at_idle,
    ready => msgin_valid,
    reset => reset,
    clk => clock,
    valid => msgin_ready  
    );
  

  event_loop: process(reset, clock)  -- as the counter is already handling reset,
  -- we dont need to do it here
  variable first_iter_done: std_logic := '0';
  begin

    if reset = '1' then
      --msgin_ready <= '0';
      first_iteration <= '0';
      calculation_finished <= '0';
      first_iter_done := '0';
      at_idle <= '1';
    elsif rising_edge(clock) then
                at_idle <= '0';

      case (counter_value) is
        when 0 =>  
          first_iteration <= '0';
          calculation_finished <= '0';
          at_idle <= '1';
          
--          if msgin_valid = '1' then
--            msgin_ready <= '0';
--          else
--            msgin_ready <= msg_ready_nxt;
--          end if;
--          msg_ready_nxt <= '0';
          
          
        when 1 =>
          --msgin_ready <= '0';
          calculation_finished <= '0';
          
          if first_iter_done = '0' then
            first_iteration <= '1';
          else
            first_iteration <= '0';  
          end if;
          first_iter_done := '1';
          msg_ready_nxt <= '0';
        when 256 =>
          
          first_iteration <= '0';
          calculation_finished <= '1';
        when others =>
          
          first_iteration <= '0';
          calculation_finished <= '0';
          first_iter_done := '0';
          --msg_ready_nxt <= '0';
      end case;
    end if;
  end process;
end Behavioral;
