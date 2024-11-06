----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2024 20:40:02
-- Design Name: 
-- Module Name: register_shift_left - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY Shift_Register_With_MSF IS
    generic(
        N: positive := 256
    );
    PORT (
        CLK       : IN  STD_LOGIC;
        RESET     : IN  STD_LOGIC;
        CONTROL, TRIG   : IN  STD_LOGIC; -- control to initialize it

        DATA_IN   : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        --SHIFT_OUT : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);  
        MSF_OUT   : OUT STD_LOGIC
                             
    );
END entity;

ARCHITECTURE behavior OF Shift_Register_With_MSF IS
    signal Reg: std_logic_vector(N-1 downto 0) := (others => '0');  -- Registre interne
    --signal test      : std_logic := '0';
BEGIN

    process (CLK, RESET)
    begin
        if (RESET = '1') then
            Reg <= (others => '0');  
        elsif rising_edge(CLK) then --rajouter signal STEP de la FSM
            if (CONTROL = '1') then
                Reg <= DATA_IN;
            elsif (TRIG ='1') then
                Reg <= Reg(N-2 downto 0) & '0'; --shift left by one bite
                --test <= '1';
            else
                Reg <= Reg;
                --test <= '0';
            end if;
        end if;
    end process;
    MSF_OUT <= Reg(N-1);

END ARCHITECTURE;

