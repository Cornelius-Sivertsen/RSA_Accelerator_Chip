LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Shift_Register_With_MSF IS
    generic(
        N: positive := 256; 
    );
    PORT (
        CLK       : IN  STD_LOGIC;
        RESET     : IN  STD_LOGIC;
        DATA_IN   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        SHIFT_OUT : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);  
        MSF_OUT   : OUT STD_LOGIC                     
    );
END entity;

ARCHITECTURE behavior OF Shift_Register_With_MSF IS
    signal Reg: std_logic_vector(N-1 downto 0) := (others => '0');  -- Registre interne
BEGIN

    process (CLK, RESET)
    begin
        if RESET = '1' then
            Reg <= (others => '0');  
        elsif rising_edge(CLK) then --rajoutersignal STEP de la FSM
            LSF_OUT <= Reg(N-1);  --MSF extract
            
            Reg <= Reg(N-2 downto 0) & '0'; 
        end if;
    end process;

    SHIFT_OUT <= Reg;  -- Sortie des données après décalage

END ARCHITECTURE;
