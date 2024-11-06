library ieee;
use ieee.std_logic_1164.all;

entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input controll
		valid_in	: in STD_LOGIC; --msgin_valid
		ready_in	: out STD_LOGIC; -- msgin_ready

		--input data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ); --msgin_data
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ); --key_e

		--ouput controll
		ready_out	: in STD_LOGIC; --msgout_ready
		valid_out	: out STD_LOGIC; --msgout_valid

		--output data
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0); --msgout_data

		--modulus
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0); --key_n

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

    signal trigger_reg_sig          : std_logic; -- register for the trigger signal from the FSM


    -- Blakely signals
    signal Sortie_blk_1     : std_logic_vector(C_block_size-1 downto 0);
    signal Sortie_blk_2     : std_logic_vector(C_block_size-1 downto 0);
    -- input
    signal Input_blk_1_ready : std_logic;
    signal Input_blk_2_ready : std_logic;

    --output
    signal Ready_blk_1      :std_logic;
    signal Ready_blk_2      :std_logic;

    signal valid_out_sig    :std_logic;
	--register shift-left
	signal trig_first_time_only : std_logic; --to shift left the exponent
											 -- after 1st use of his MSF to initialize register C

    signal MSF_exponent     :std_logic;
    --FSM
    signal fill_E_and_C      :std_logic; --signal to first fill E and C
    --signal ready_out : std_logic;
    --signal msgin_ready : std_logic;
    --signal msgin_valid : std_logic;
    
    --signal internal_reset : std_logic;
    signal manual_reset : std_logic;

	--result <= message xor modulus;
	--ready_in <= ready_out;
	--valid_out <= valid_in;

    begin
        BLACKLEY_1 : entity work.Blackley(blackley_archi_v2)
            port map (

                RESET                       => reset_n  ,
                CLOCK                       => clk      ,
                In_Blakley_Value1           => C_r      ,
                In_Blakley_Value2           => C_r      ,
                In_Blakley_Mod              => modulus  ,
                Input_Ready                 => Input_blk_1_ready ,
                Out_Blackley                => Sortie_blk_1 ,
                Result_ready                => Ready_blk_1
            );
        BLACKLEY_2 : entity work.Blackley(blackley_archi_v2)
            port map (

                RESET                       => reset_n  ,
                CLOCK                       => clk      ,
                In_Blakley_Value1           => Sortie_blk_1 ,
                In_Blakley_Value2           => message      ,
                In_Blakley_Mod              => modulus      ,
                Input_Ready                 => Ready_blk_1 and MSF_exponent,
                Out_Blackley                => Sortie_blk_2,
                Result_ready                => Ready_blk_2 
            );

        REGISTER_E : entity work.Shift_Register_With_MSF
            port map(
                CLK       	=> clk,
                RESET     	=> reset_n or manual_reset,
                CONTROL 	=> fill_E_and_C, -- a update chaque fois qu'un message est fini
                TRIG    	=> trigger_reg_sig or trig_first_time_only,
                DATA_IN 	=> key,
                MSF_OUT  	=> MSF_exponent -- on doit commencer à lenght-2 voir algo
            );
        
        FSM : entity work.exp_fsm
            port map(
                reset => reset_n,
                clock => clk,
                trigger => trigger_reg_sig,
                msgin_valid => valid_in,
                write_back_resolution => fill_E_and_C,
                manual_reset => manual_reset,
                msgin_ready =>ready_in,
                msgout_valid =>valid_out_sig
                
            );

        
    

    process(clk, reset_n)
     variable trigger_reg : std_logic := '0';
     variable valid_out_var :std_logic :='0';
        begin
            if ((reset_n = '1') or (manual_reset = '1')) then
                C_r <= (0 => '1', others => '0');   -- Reset C_r to a known value
                trigger_reg := '0';
                Input_blk_1_ready <= '0';
                Input_blk_2_ready <= '0';
            elsif rising_edge(clk) then
                -- update of C_r for each new message
				-- done once per message
                if fill_E_and_C = '1' and valid_in ='1' then
					if MSF_exponent /= '0' then
						C_r <= message;             --update C_r with the message value
					else 
                        C_r <= (255 downto 1 => '0') & '1';     -- if the signal is out of the fsm only the 1st time or not changes everything
                       -- C_r(0) <= '1';
                    end if;
					trig_first_time_only <= '1'; 
                    Input_blk_1_ready <= '1';
				else 
					trig_first_time_only <= '0';
				end if;
                
                
                if Ready_blk_1 ='1' then            -- Check if we need to do Blackey_2
                    if MSF_exponent /='1' then      
                        C_nxt <= Sortie_blk_1;      
                        trigger_reg := '1';
                    elsif Ready_blk_2 ='1' then     -- Waiting for Blackley_2 to be finished
                        C_nxt <= Sortie_blk_2;
                        trigger_reg := '1';
                    else 
                        trigger_reg :='0';
                    end if;
                else
                    trigger_reg := '0';             -- Reset trigger if Ready_blk_1 is not 1  
                end if;
                
                trigger_reg_sig <= trigger_reg;
                valid_out_var := valid_out_sig;

				if trigger_reg = '1' then
                    C_r <= C_nxt;                    --update C_r with new calculated value
                    Input_blk_1_ready <= '1';  
                else
                    Input_blk_1_ready <= '0';       -- Not ready
                end if;
        
                -- OUT(PUTE)
                -- gérer la remise à 0 de ready_out
                -- qu'il se remette à 0 au bon moment
                if (valid_out_var = '1') then
                    result <= C_r;                  -- assign C_r to result when calculation done
                else
                    result <= (others => '0');      --output zeros if not finished
                end if;
            end if;
        end process;
end architecture ;
