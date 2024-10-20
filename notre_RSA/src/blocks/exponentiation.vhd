library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation is 
    generic (N:positive := 256);
    port (
            clk : in std_logic;
            reset : in std_logic;

            msgin_valid : in std_logic;
            msgin_ready : out std_logic;
            msgin_last : in std_logic;

            msgout_valid: out std_logic;
            msgout_ready: in std_logic;
            msgout_last: out std_logic;

            -- data
            message_input : in std_logic(N-1 downto 0);
            exponent : in std_logic (N-1 downto 0);
            n : in std_logic(N-1 downto 0);

            --output
            message_output : out std_logic(N-1 downto 0);

    );
    end exponentiation;