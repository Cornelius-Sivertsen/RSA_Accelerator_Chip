--8 bit (0-255) bit counter that counts when it receives a trigger signal (rising edge).
--Currently, only up-counting is implemented, with following behaviours:
--idles when no trigger input is given
--goes into idle at 254, as the given application only does
--255 (0-254) iterations.
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY counter IS
		port(
					RESET: IN STD_LOGIC;
					CLOCK: IN STD_LOGIC;
					manual_reset: IN STD_LOGIC;
					Trigger: IN STD_LOGIC;
					--counter_value: OUT STD_LOGIC_VECTOR(7 downto 0) Might have to be changed back to logic_vector, but using integer simplifies things
					counter_value: OUT integer range 0 to 254

);
END entity;


ARCHITECTURE count_up OF counter IS
		signal count_reg: integer;

begin
		counter_value <= count_reg;
		process (CLOCK, RESET)
		begin
				if RESET = '1' or (rising_edge(CLOCK) and (manual_reset = '1')) then
						count_reg <= 0;
				elsif count_reg = 254 then
				        count_reg <= 254; -- idle at max counter val
				elsif rising_edge(CLOCK) and rising_edge(Trigger) then
						count_reg <= count_reg + 1;
				else
				        count_reg <= count_reg;   -- do nothing
				end if;
		end process;
end architecture;
