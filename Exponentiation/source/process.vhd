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




signal E_r , E_nxt : std_logic_vector(255 downto 0);
signal trigger_r, trigger_nxt : std_logic;
signal Input_blk_1_ready_nxt: std_logic;

-- process des registres
process (clk, reset_n)
begin 
    if (reset_n ='0') then
        C_r <= (0 => '1', others => '0');   -- Reset C_r to a known value
        E_r <= (others => '0');
        trigger_r := '0';
    elsif rising_edge (clk) then
        trigger_r <= trigger_nxt;
        C_r <= C_nxt;
        E_r <= E_nxt;
        Input_blk_1_ready <= Input_blk_1_ready_nxt;
    end if;
end process;

process ()
variable trigger_var : std_logic := '0';
begin
    -- voir la condition du if avec Cornelius
    if write_back_resolution = '1' or  (valid_in ='1' and ready_in ='1') then
        if key(255) /= '0' then -- ou mettre la condition dans ce if
            C_nxt <= message;             --update C_r with the message value
        else 
            C_nxt <= (255 downto 1 => '0') & '1';     -- if the signal is out of the fsm only the 1st time or not changes everything
           -- C_r(0) <= '1';
        end if;
        Input_blk_1_ready_nxt <= '1';
        E_nxt <= key(254 downto 0 ) & '0'; -- stockage en shift left de l'exposant
    else -- voir la condition pour pas shift left tout le temps 
        E_nxt <= E_r(254 downto 0 ) & '0';
        C_nxt <= 
        Input_blk_1_ready_nxt  <= 
    end if;

    if Ready_blk_1 ='1' then            -- Check if we need to do Blackey_2
        if E_r(255) /='1' then      
            C_nxt <= Sortie_blk_1;      
            trigger_var := '1';
        elsif Ready_blk_2 ='1' then     -- Waiting for Blackley_2 to be finished
            C_nxt <= Sortie_blk_2;
            trigger_var := '1';
        else 
            C_nxt <= C_r;
            trigger_var :='0';
        end if;
    else
        C_nxt <= C_r;
        trigger_var := '0';             -- Reset trigger if Ready_blk_1 is not 1  
    end if;
    
    trigger_nxt <= trigger_var;
    

    if trigger_var = '1' then
        Input_blk_1_ready_nxt <= '1';  
    else
        Input_blk_1_ready_nxt <= '0'; -- Not ready
    end if;


    if (valid_out_sig = '1') then
        result <= C_r;  -- assign C_r to result when calculation done
    else
        result <= (others => '1');      --output zeros if not finished
    end if;

end process;





