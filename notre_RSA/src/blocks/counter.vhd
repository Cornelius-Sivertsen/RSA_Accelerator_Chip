--Counts rising edges on "trigger".
--Counts from 0-255.
--Idles at 0.
--While at 255, goes back to 0 at next clock cycle.

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
         Trigger : in STD_LOGIC;
         start_counting : in STD_Logic;
         Counter_val_out : out integer range 0 to 255
         );
end counter;


architecture Behavioral of counter is
begin

  process(Clock, Reset)
    variable prev_trigger: std_logic := '0';  -- Used for rising edge detection
    variable trigger_edge: std_logic;  -- Used for rising edge detection
    variable internal_counter_val: integer range 0 to 255;
  begin
  
    

    if RESET = '1' then
      internal_counter_val := 0;
      prev_trigger := '0';
    elsif rising_edge(clock) then
      trigger_edge := trigger and not prev_trigger;
      prev_trigger := trigger; --update stored value of trigger for edge detection
      if (internal_counter_val = 0) then
       if start_counting = '1' then
        internal_counter_val := internal_counter_val + 1;
       else
           internal_counter_val := internal_counter_val; -- do nothing 
       end if;     
      elsif (internal_counter_val < 255 and
             trigger_edge = '1') then
        internal_counter_val := internal_counter_val + 1;
      elsif internal_counter_val = 255 then
        internal_counter_val := 0;
      else
        internal_counter_val := internal_counter_val; -- do nothing
      end if;
      
    end if;

    -- output is updated every clock cycle
    counter_val_out <= internal_counter_val;
    
  end process;
end Behavioral;
