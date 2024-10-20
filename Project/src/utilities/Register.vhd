LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all

ENTITY Register is
    generic(
        N: positive := 256;
        VALUE: positive := 0
    );
	PORT
	(			
		RESET   	    		     :  IN  STD_LOGIC;
		CLOCK   	    			 :  IN  STD_LOGIC;
		Register_In                  :  IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		Register_Out                 :  OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
	);
END entity;

ARCHITECTURE Register_archi OF Register IS
    signal Reg: std_logic_vector(N-1 downto 0) := (others => '0');
BEGIN

    process (CLOCK, RESET)

    begin

        if RESET = '1' then
            Reg <= std_logic_vector(to_unsigned(VALUE, N));
        elsif rising_edge(CLOCK) then
            Reg <= Register_In;
        end if;

    end process;

    Register_Out <= Reg;

END architecture;