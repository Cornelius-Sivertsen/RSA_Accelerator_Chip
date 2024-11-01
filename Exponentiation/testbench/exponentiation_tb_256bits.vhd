library ieee;
use ieee.std_logic_1164.all;


entity exponentiation_tb is
	generic (
		C_block_size : integer := 256
	);
end exponentiation_tb;


architecture expBehave of exponentiation_tb is
	-- given by the teacher
	signal message 		: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal key 			: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal valid_in 	: STD_LOGIC;
	signal ready_in 	: STD_LOGIC;
	signal ready_out 	: STD_LOGIC;
	signal valid_out 	: STD_LOGIC;
	signal result 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal modulus 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal clk 			: STD_LOGIC;
	signal restart 		: STD_LOGIC;
	signal reset_n 		: STD_LOGIC;

	--created
	-- constant
	constant CLK_PERIOD    : time := 10 ns;
	constant CLK_PERIOD    : time := 9 ns; -- or 10ns ?
	--signal
	signal expected 	: STD_LOGIC_VECTOR(C_block_size-1 downto 0);

begin
	i_exponentiation : entity work.exponentiation
		port map (
			message   => message  ,
			key       => key      ,
			valid_in  => valid_in ,
			ready_in  => ready_in ,
			ready_out => ready_out,
			valid_out => valid_out,
			result    => result   ,
			modulus   => modulus  ,
			clk       => clk      ,
			reset_n   => reset_n
		);

	--clock generation : 
	clk <= not clk after CLK_PERIOD/2;

	-- Reset generation
	reset_process: process
	begin
		wait for RESET_TIME;
		reset_n <= '1';
		wait;
	end process;


	simulation : process
	begin
		message <= x'message';
		key <=
		modulus <=
		expected <= 
		wait for 4*CLK_PERIOD;
		

		wait until calculation_finished ='1';
		
		assert expected = result
			report "Output message differs from the expected result"
			severity Failure;
		


end expBehave;
