library ieee;
use ieee.std_logic_1164.all;

entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input controll
		valid_in	: in STD_LOGIC;
		ready_in	: out STD_LOGIC;

		--input data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );

		--ouput controll
		ready_out	: in STD_LOGIC;
		valid_out	: out STD_LOGIC;

		--output data
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--modulus
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC
	);
end exponentiation;


architecture expBehave of exponentiation is
    -- registers
    signal E_r              : std_logic_vector(C_block_size-1 downto 0); --register of exponent
    signal C_r              : std_logic_vector(C_block_size-1 downto 0); --register of C
    signal E_nxt            : std_logic_vector(C_block_size-1 downto 0);
    signal C_nxt            : std_logic_vector(C_block_size-1 downto 0);

    signal trigger_reg          : std_logic; -- register for the trigger signal from the FSM


    -- Blakely signals
    signal Sortie_blk_1     : std_logic_vector(C_block_size-1 downto 0);
    signal Sortie_blk_2     : std_logic_vector(C_block_size-1 downto 0);

    signal Ready_blk_1      :std_logic;
    signal Ready_blk_2      :std_logic;


    signal MSF_exponent     :std_logic;
    --FSM
    signal fill_E_and_C      :std_logic; 
    signal calculation_finished : std_logic;

    
    

	--result <= message xor modulus;
	--ready_in <= ready_out;
	--valid_out <= valid_in;

    begin
        BLACKLEY_1 : entity work.Blackley
            port map (

                RESET                       => reset_n  ;
                CLOCK                       => clk      ;
                In_Blakley_Value1           => C_r      ;
                In_Blakley_Value2           => C_r      ;
                In_Blakley_Mod              => n        ;
                --Manual_Reset                => -- FINIR
                Input_Ready                 => trigger_reg;

                Out_Blackley :              => Sortie_blk_1;
                Result_ready                => Ready_blk_1 ;
            );
        BLACKLEY_2 : entity work.Blackley
            port map (

                RESET                       => reset_n  ;
                CLOCK                       => clk      ;
                In_Blakley_Value1           => Sortie_blk_1;
                In_Blakley_Value2           => message     ;
                In_Blakley_Mod              => n        ;
                --Manual_Reset                => -- FINIR
                Input_Ready                 => Ready_blk_1 and MSF_exponent;

                Out_Blackley :              => Sortie_blk_2;
                Result_ready                => Ready_blk_2 ;
            );

        REGISTER_E : entity work.register_shift_left
            port map(
                CLK       => clk;
                RESET     => reset_n;
                CONTROL => fill_E_and_C;
                TRIG    => trigger_reg;
                DATA_IN  => key;
                MSF_OUT  => MSF_exponent;
            );
        
        FSM : entity work.FSM --CHANGE NAME
            port map(
                reset => reset_n;
                clock => clk;
                trigger => trigger_reg;
                calculation_finished =>calculation_finished;
                write_back_resolution => fill_E_and_C;
            );

            -- FINIR
            -- FSM1 : entity work. 

        -- process des registers
        process(clk, reset_n)
            begin
                if (reset_n = '0') then
                    C_r <= (0 => '1', others => '0');
		        elsif (rising_edge(clk)) then
                    if (trigger='1') then
                    C_r <= C_nxt;
                    end if;
                    
                end if;
        end process;
        


        
                
                    
end expBehave;
