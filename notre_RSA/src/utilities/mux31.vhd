LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity mux31 is
	generic( N: positive := 256 );
	port (  SEL_1 : in std_logic;
            SEL_2 : in std_logic;
			A, B, C : in std_logic_vector(N-1 downto 0);
			S_MUX : out std_logic_vector(N-1 downto 0));
end entity;

architecture dataflow of mux21 is
begin
	S_MUX <= A when (SEL_1 = '0' and SEL_2 = '0') else
             B when (SEL_1 = '0' and SEL_2 = '1') else 
             C; 
end architecture;
