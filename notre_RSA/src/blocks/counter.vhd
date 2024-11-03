--8 bit (0-255) bit counter that counts when it receives a trigger signal (rising edge).
--Currently, only up-counting is implemented, with following behaviours:
--idles when no trigger input is given
--goes into idle at 254, as the given application only does
--255 (0-254) iterations.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
  Port ( Reset : in STD_LOGIC;
         Clock : in STD_LOGIC;
         Manual_reset : in STD_LOGIC;
         Trigger : in STD_LOGIC;
         Counter_val_out : out integer range 0 to 254
         );
end counter;


architecture Behavioral of counter is
begin

  process(Clock, Reset, Manual_reset, trigger)
    variable internal_counter_val: integer range 0 to 254;
  begin

    if RESET = '1' then
      internal_counter_val := 0;
    elsif rising_edge(clock) then
      if manual_reset = '1' then
        -- NOTE: 
        -- At least in the simulator,
        -- manual reset has to already
        -- be at '1' when the clock pulse
        -- happens. If both happen at the
        -- exact same time, it does not work.
        internal_counter_val := 0;
      elsif (internal_counter_val < 254 and
             trigger = '1') then
        -- Same note as above applies for "trigger" here.
        internal_counter_val := internal_counter_val + 1;
      else
        internal_counter_val := internal_counter_val; -- do nothing
      end if;
    end if;

    -- output is updated every clock cycle
    counter_val_out <= internal_counter_val;

  end process;
end Behavioral;

