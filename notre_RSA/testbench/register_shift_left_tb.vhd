----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2024 20:42:34
-- Design Name: 
-- Module Name: register_shift_left_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Shift_Register_With_MSF_tb IS
END Shift_Register_With_MSF_tb;

ARCHITECTURE behavior OF Shift_Register_With_MSF_tb IS
    -- Parameters
    constant N: integer := 256;
    
    -- DUT (Device Under Test) signals
    signal CLK       : std_logic := '0';
    signal RESET     : std_logic := '0';
    signal CONTROL   : std_logic := '0';
    signal TRIG      : std_logic := '0';
    signal DATA_IN   : std_logic_vector(N-1 downto 0) := (others => '0');
    signal MSF_OUT   : std_logic;

    -- Clock period for the simulation
    constant clk_period : time := 10 ns;

BEGIN
    SRWMSF : entity work.Shift_Register_With_MSF
        generic map (
            N => N
        )
        port map (
            CLK       => CLK,
            RESET     => RESET,
            CONTROL   => CONTROL,
            TRIG      => TRIG,
            DATA_IN   => DATA_IN,
            MSF_OUT   => MSF_OUT
        );

    -- Clock process definition
    clk_process : process
    begin
        CLK <= '1';
        wait for clk_period / 2;
        CLK <= '0';
        wait for clk_period / 2;
    end process;

    -- simulation process
    simulation: process
    begin
        -- Initial reset
        RESET <= '1';
        wait for clk_period;
        RESET <= '0';
        wait for clk_period;

        -- Test Case 1: Load `DATA_IN` into the shift register
        CONTROL <= '1';
        DATA_IN <= (others => '1');  -- Load all 1s for a clear test
        wait for clk_period;
        CONTROL <= '0';

        -- Test Case 2: Perform multiple shifts
        TRIG <= '1';
        wait for clk_period * 5;  -- Apply shifts for several clock cycles
        TRIG <= '0';

        -- Test Case 3: Reinitialize the register with a new pattern
        CONTROL <= '1';
        DATA_IN <= std_logic_vector(to_unsigned(3, N));  -- Set DATA_IN with a pattern
        wait for clk_period;
        CONTROL <= '0';
        
        -- Test Case 4: Shift again
        TRIG <= '1';
        wait for clk_period * 4;
        TRIG <= '0';

        -- Test Case 5 : 10110010 pattern and shift left this pattern
        
        DATA_IN <= (others => '0');
        for i in 0 to N/8 - 1 loop
            DATA_IN(i*8+7 downto i*8) <= "10110010";
        end loop;
            -- put data in the register with control
        CONTROL <= '1';
        wait for clk_period;
        CONTROL <= '0';
        
            -- continuous shift left
        wait for clk_period;
         
        while true loop
            TRIG <= '1';
            wait for clk_period;
            TRIG <= '0';
            wait for clk_period;
        end loop;
        -- Finish simulation
        wait for clk_period * 10;
        wait;
    end process;

END ARCHITECTURE;

