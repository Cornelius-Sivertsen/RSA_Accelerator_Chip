LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
library work;


entity fsm is
		port(
		--clock and reset inputs:
					reset: in std_logic;
					clock: in std_logic;
					manual_reset: in std_logic;
		--input:
					trigger: in std_logic; --rising edge on trigger increments the loop
		--outputs:
					calculation_finished: out std_logic; --indicates that the system has completed 256 iterations
														 --can probably be directly mapped to msgin_ready, as well as msgout_valid.
														 --can also be used to generate manual reset signal.

					write_back_resolution: out std_logic --indicates whether to write the input message, 
														  --or the feedback value to the main calculation register (register C).
														  --write_back_resolution = low -> Register C should read input message
														  --write_back_resolution = high -> Register C should read feedback value.
);
end entity;

architecture primary of fsm is
		--signal counter_state: std_logic_vector(7 downto 0); Might have to be changed back to logic_vector, but using integer simplifies things
		signal counter_state: integer range 0 to 254;

begin
		counter: entity work.counter port map
		             (reset => reset,
					 clock => clock,  
					 manual_reset => manual_reset,
					 trigger => trigger,
					 counter_value => counter_state
		             );

		process (clock, reset)
		begin
		--resetting is already handled by the counter
				if counter_state = 0 then
						write_back_resolution <= '0';
						calculation_finished <= '0';
				elsif counter_state = 254 then
						write_back_resolution <= '1'; -- might be changed to 0
						calculation_finished <= '1';
				else
						write_back_resolution <= '1';
						calculation_finished <= '0';
				end if;
		end process;
end architecture;


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
	
