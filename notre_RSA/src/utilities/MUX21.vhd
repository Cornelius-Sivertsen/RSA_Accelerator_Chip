LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


entity mux21 is
	generic( N: positive := 256 );
	port (  SEL : in std_logic;
			A, B : in std_logic_vector(N-1 downto 0);
			S_MUX : out std_logic_vector(N-1 downto 0));
end entity;

architecture dataflow of mux21 is
begin
	S_MUX <= A when not SEL = '1' else B;
end architecture;
