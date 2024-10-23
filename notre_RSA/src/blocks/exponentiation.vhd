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
    -- input
    signal Input_blk_1_ready : std_logic;
    --output
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
                In_Blakley_Mod              => mudulus  ;
                --Manual_Reset                => -- FINIR
                Input_Ready                 => Input_blk_1_ready;

                Out_Blackley :              => Sortie_blk_1;
                Result_ready                => Ready_blk_1 ;
            );
        BLACKLEY_2 : entity work.Blackley
            port map (

                RESET                       => reset_n  ;
                CLOCK                       => clk      ;
                In_Blakley_Value1           => Sortie_blk_1;
                In_Blakley_Value2           => message     ;
                In_Blakley_Mod              => modulus       ;
                --Manual_Reset                => -- FINIR
                Input_Ready                 => Ready_blk_1 and MSF_exponent;

                Out_Blackley :              => Sortie_blk_2;
                Result_ready                => Ready_blk_2 ;
            );

        REGISTER_E : entity work.register_shift_left
            port map(
                CLK       => clk;
                RESET     => reset_n;
                CONTROL => fill_E_and_C; -- a update chaque fois qu'un message est fini
                TRIG    => trigger_reg;
                DATA_IN  => key;
                MSF_OUT  => MSF_exponent; -- on doit commencer à lenght-2 voir algo
            );
        
        -- FSM : entity work.FSM --CHANGE NAME
        --     port map(
        --         reset => reset_n;
        --         clock => clk;
        --         trigger => trigger_reg;
        --         calculation_finished =>calculation_finished;
        --         write_back_resolution => fill_E_and_C;
        --     );

            -- FINIR
            -- FSM1 : entity work. 

        -- process des registers
    process(clk, reset_n)
        begin
            if (reset_n = '0') then
                C_r <= (0 => '1', others => '0');  -- Reset C_r to a known value
                trigger_reg <= '0';
                Input_blk_1_ready <= '0';
            elsif rising_edge(clk) then
                if Ready_blk_1 ='1' then
                    if MSF_exponent /='1' then
                        C_nxt <= Sortie_blk_1;
                        trigger_reg <= 1;
                    elsif Ready_blk_2 ='1' then -- vraiment ez, t as pas besoin de lire les commentaires
                        C_nxt <= Sortie_blk_2;
                        trigger_reg <= 1;
                    end if;
                else
                -- Reset trigger if Ready_blk_1 is not 1
                    trigger_reg <= '0';  
                end if;
                
                -- update of C_r
                if fill_E_and_C = '1' and MSF_exponent = '1' then
                    C_r <= message;  --update C_r with the message value
                elsif trigger_reg = '1' then
                    C_r <= C_nxt;  --update C_r with new calculated value
                    Input_blk_1_ready <= '1';  
                else
                    Input_blk_1_ready <= '0';  -- Not ready
                end if;
        
                -- OUT(PUTEEE)
                if calculation_finished = '1' then
                    result <= C_r;  -- assign C_r to result when calculation done
                else
                    result <= (others => '0');  --output soooooo much zeros if not finished
                end if;
            end if;
        end process;
