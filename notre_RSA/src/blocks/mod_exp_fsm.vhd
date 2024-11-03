library work;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;



-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity exp_fsm is
    Port ( reset : in STD_LOGIC;
           clock : in STD_LOGIC;
           trigger : in STD_LOGIC;
           msgin_valid : in STD_logic;
           write_back_resolution : out STD_LOGIC; --indicates whether to write the input message, 
 						  --or the feedback value to the main calculation register (register C).
 						  --write_back_resolution = low -> Register C should read input message
						  --write_back_resolution = high -> Register C should read feedback value.
           manual_reset : out STD_LOGIC;
           msgin_ready : out STD_LOGIC;
           msgout_valid : out STD_LOGIC
           );
           
end exp_fsm;

architecture Behavioral of exp_fsm is

  signal counter_state: integer range 0 to 254;
  signal calculation_finished : STD_LOGIC := '0';
  signal internal_reset : STD_LOGIC := '0';

begin

  counter: entity work.counter port map(
    reset => reset,
    clock => clock,
    manual_reset => internal_reset,
    trigger => trigger,
    counter_val_out => counter_state
);

  msgin_ready <= calculation_finished;
  msgout_valid <= calculation_finished;
  
  internal_reset <= calculation_finished and msgin_valid;
  
  manual_reset <= internal_reset;
  
  event_loop: process(counter_state) -- as the counter is already handling reset and synchro,
                      -- we dont need to do it here
  begin
    if counter_state = 0 then
      write_back_resolution <= '0';
      calculation_finished <= '0';
    elsif counter_state >= 254 then
      write_back_resolution <= '1';
      calculation_finished <= '1';
    else
      write_back_resolution <= '1';
      calculation_finished <= '0';
    end if;
   end process;
end Behavioral;
	
