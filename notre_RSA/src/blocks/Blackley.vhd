LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Blackley is
    port 
    (  
        RESET : in std_logic;
        CLOCK : in std_logic;
        In_Blakley_Value1, In_Blakley_Value2, In_Blakley_Mod : in std_logic_vector(255 downto 0);
        Input_Ready : in std_logic;

        Out_Blackley : out std_logic_vector(255 downto 0);
        Result_ready : out std_logic
    );
end entity;

architecture blackley_archi_v2 of Blackley is
    signal Reg_R : std_logic_vector(255 downto 0) := (others => '0');
    signal Reg_Value1 : std_logic_vector(255 downto 0) := (others => '0');
    signal Reg_Value2 : std_logic_vector(255 downto 0) := (others => '0');
    signal Reg_Mod : std_logic_vector(255 downto 0) := (others => '0');
    signal i : integer := 1;  -- signal i to replace the for loop
begin
    process(CLOCK, RESET)
        variable shifted_R : unsigned(257 downto 0); -- 257 and not 255 because we need to add one bit for the carry
        variable modulo_R_1, modulo_R_2, shifted_mod : signed(258 downto 0); -- 258 and not 255 because we need to add one bit for the carry and one bit for the sign
    begin
        if RESET = '1' then
            Reg_R <= (others => '0');
            i <= 0;  -- Reset i when RESET is active
            Result_ready <= '0';
        elsif rising_edge(CLOCK) then
            if Input_Ready = '1' then
                Reg_Value1 <= In_Blakley_Value1;
                Reg_Value2 <= In_Blakley_Value2;
                Reg_Mod <= In_Blakley_Mod;
                i <= 0; 
                Reg_R <= (others => '0');
                Result_ready <= '0';
            elsif i <= 255 then
                Result_ready <= '0';
                
                Reg_Value2 <= Reg_Value2(254 downto 0) & '0';

                shifted_R := unsigned('0' & Reg_R(255 downto 0) & '0');
                if Reg_Value2(255) = '1' then
                    shifted_R := shifted_R + unsigned(Reg_Value1);
                end if;

                -- First Way to do the modulo
                
                    -- if shifted_R >= unsigned(Reg_Mod) then
                    --     shifted_R := shifted_R - unsigned(Reg_Mod);
                    -- end if;
                    -- if unsigned(shifted_R) >= unsigned(Reg_Mod) then
                    --     shifted_R := shifted_R - unsigned(Reg_Mod);
                    -- end if;
                    -- Reg_R <= std_logic_vector(shifted_R);

                -- Second Way to do the modulo 
                -- -> if not chosen remove modulo_R_1 and modulo_R_2 and shifted_mod
                shifted_mod := signed("00" & Reg_Mod(255 downto 0) & '0');
                modulo_R_1 := signed('0' & shifted_R) - signed("00" & Reg_Mod);
                modulo_R_2 := signed('0' & shifted_R) - shifted_mod;
                if modulo_R_2 >= 0 then
                    Reg_R <= std_logic_vector(modulo_R_2(255 downto 0));
                elsif modulo_R_1 >= 0 then
                    Reg_R <= std_logic_vector(modulo_R_1(255 downto 0));
                else
                    Reg_R <= std_logic_vector(shifted_R(255 downto 0));
                end if;

                i <= i + 1;
            else
                Result_ready <= '1';
                Out_Blackley <= Reg_R;
            end if;
        end if;
    end process;
end architecture;

architecture blackley_archi_v1 of Blackley is
    signal Reg_R : std_logic_vector(255 downto 0) := (others => '0');
    signal Reg_Value1 : std_logic_vector(255 downto 0) := (others => '0');
    signal Reg_Value2 : std_logic_vector(255 downto 0) := (others => '0');
    signal Reg_Mod : std_logic_vector(255 downto 0) := (others => '0');
    signal i : integer := 1;  -- signal i to replace the for loop
begin
    process(CLOCK, RESET)
        variable shifted_R : unsigned(257 downto 0); -- 257 and not 255 because we need to add one bit for the carry
    begin
        if RESET = '1' then
            Reg_R <= (others => '0');
            i <= 0;  -- Reset i when RESET is active
            Result_ready <= '0';
        elsif rising_edge(CLOCK) then
            if Input_Ready = '1' then
                Reg_Value1 <= In_Blakley_Value1;
                Reg_Value2 <= In_Blakley_Value2;
                Reg_Mod <= In_Blakley_Mod;
                i <= 0; 
                Reg_R <= (others => '0');
                Result_ready <= '0';
            elsif i <= 255 then
                Result_ready <= '0';
                
                Reg_Value2 <= Reg_Value2(254 downto 0) & '0';

                shifted_R := unsigned('0' & Reg_R(255 downto 0) & '0');
                if Reg_Value2(255) = '1' then
                    shifted_R := shifted_R + unsigned(Reg_Value1);
                end if;

                -- First Way to do the modulo
                
                if shifted_R >= unsigned(Reg_Mod) then
                    shifted_R := shifted_R - unsigned(Reg_Mod);
                end if;
                if shifted_R >= unsigned(Reg_Mod) then
                    shifted_R := shifted_R - unsigned(Reg_Mod);
                end if;
                Reg_R <= std_logic_vector(shifted_R(255 downto 0));

                i <= i + 1;
            else
                Result_ready <= '1';
                Out_Blackley <= Reg_R;
            end if;
        end if;
    end process;
end architecture;