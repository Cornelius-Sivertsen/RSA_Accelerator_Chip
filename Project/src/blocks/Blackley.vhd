LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Blackley is
    port 
    (  
        RESET : in std_logic;
        CLOCK : in std_logic;
        In_Blakley_Value1, In_Blakley_Value2, In_Blakley_Mod : in std_logic_vector(255 downto 0);
        Out_Blackley : out std_logic_vector(255 downto 0);
        Result_ready : out std_logic
    );
end entity;

architecture blackley_archi of Blackley is
begin
    
end architecture;