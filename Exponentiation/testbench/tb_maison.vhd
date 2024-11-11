library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_expBehave_2 is
end tb_expBehave_2;

architecture behavior of tb_expBehave_2 is

    -- Déclaration des signaux
    signal clk                 : std_logic := '0';
    signal reset_n             : std_logic;
    --signal condition_magique   : std_logic := '0';
    --signal trigger_r           : std_logic := '0';
    signal key                 : std_logic_vector(255 downto 0) := (others => '0');
    signal message             : std_logic_vector(255 downto 0) := (others => '0');
    signal modulus             : std_logic_vector(255 downto 0) := (others => '0');
    signal valid_in            : std_logic;
    signal ready_in            : std_logic;
    signal ready_out           : std_logic := '1';
    signal valid_out           : std_logic;
    signal result              : std_logic_vector(255 downto 0);
    signal trigger_count       : integer := 0;

    -- -- Instanciation du composant à tester
    -- component exponentiation
    --     generic (
    --         C_block_size : integer := 256
    --     );
    --     port(
    --         valid_in       : in std_logic;
    --         ready_in       : out std_logic;
    --         message        : in std_logic_vector(255 downto 0);
    --         key            : in std_logic_vector(255 downto 0);
    --         ready_out      : in std_logic;
    --         valid_out      : out std_logic;
    --         result         : out std_logic_vector(255 downto 0);
    --         modulus        : in std_logic_vector(255 downto 0);
    --         clk            : in std_logic;
    --         reset_n        : in std_logic
    --     );
    -- end component;

begin
    -- Instanciation de l'architecture expBehave_2
    UUT: entity work.exponentiation
        port map (
            clk             => clk,
            reset_n         => reset_n,
            --condition_magique => condition_magique,
            --trigger_r       => trigger_r,
            key             => key,
            message         => message,
            modulus         => modulus,
            valid_in        => valid_in,
            ready_in        => ready_in,
            ready_out       => ready_out,
            valid_out       => valid_out,
            result          => result
        );

    -- Génération de l'horloge
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Stimuli et vérification
    stim_proc: process
    begin
        -- Réinitialisation du système
        reset_n <= '0';
        wait for 120 ns;
        reset_n <= '1';

        -- Cas de test : Activer condition_magique
        condition_magique <= '1';
        key <=     X"F000000000000000000000000000000000000000000000000000000000110101";
        message <= X"0000000000000000000000000000000000000000000000000000000000000111";
        modulus <= X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

        wait for 20 ns;
        condition_magique <= '0';
        
        wait for 120 ns;
        
        reset_n <= '0';
        wait for 120 ns;
        reset_n <= '1';
        
        -- Cas de test : Activer condition_magique
        condition_magique <= '1';
        key <=     X"0000000000000000000000000000000000000000000000000000000000110101";
        message <= X"0000000000000000000000000000000000000000000000000000000000110000";
        modulus <= X"CCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCC";
        
        wait for 20 ns;
        condition_magique <= '0';


        -- Boucle pour surveiller le trigger et augmenter le compteur
        while trigger_count < 254 loop
            wait until rising_edge(clk);
            
            -- Vérifier si trigger est activé
            if trigger_r = '1' then
                trigger_count <= trigger_count + 1;
            end if;
        end loop;

        -- Définir valid_out à '1' lorsque le compteur atteint 254
        valid_out <= '1';
        wait for 20 ns;
        valid_out <= '0';

        -- Observation des signaux de sortie
        wait for 100 ns;
        wait;
    end process;

end behavior;
