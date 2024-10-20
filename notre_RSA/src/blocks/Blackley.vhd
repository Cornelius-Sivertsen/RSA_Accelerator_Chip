LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Blackley is
    port 
    (  
        RESET : in std_logic;
        CLOCK : in std_logic;
        In_Blakley_Value1, In_Blakley_Value2, In_Blakley_Mod : in std_logic_vector(255 downto 0);
        Manual_Reset, Input_Ready : in std_logic;

        Out_Blackley : out std_logic_vector(255 downto 0);
        Result_ready : out std_logic
    );
end entity;

architecture blackley_archi of Blackley is
    signal Reg_R : std_logic_vector(255 downto 0) := (others => '0');
    signal Reg_Value1 : std_logic_vector(255 downto 0) := (others => '0');
    signal Reg_Value2 : std_logic_vector(255 downto 0) := (others => '0');
    signal Reg_Mod : std_logic_vector(255 downto 0) := (others => '0');
begin
    process(CLOCK, RESET)
        variable shifted_R, modulo_R_1, modulo_R_2 : unsigned(255 downto 0);
        variable shifted_mod : unsigned(255 downto 0);
    begin
        if RESET = '1' then
            Reg_R <= (others => '0');
        elsif rising_edge(CLOCK) then
            -- if Manual_Reset = '1' then
            --     Reg_R <= (others => '0');
            -- else
                for i in 1 to 255 loop
                    if Input_Ready = '1' then
                        Reg_Value1 <= In_Blakley_Value1;
                        Reg_Value2 <= In_Blakley_Value2;
                        Reg_Mod <= In_Blakley_Mod;
                    else 
                        Reg_Value1 <= Reg_Value1;
                        Reg_Value2 <= Reg_Value2(254 downto 0) & '0';
                        Reg_Mod <= Reg_Mod;
                    end if;
                    shifted_R := Reg_R(254 downto 0) & '0';
                    if Reg_Value2(255) = '1' then
                        shifted_R := shifted_R + unsigned(Reg_Value1);
                    end if;

                    -- First Way to do the modulo
                    if shifted_R >= unsigned(Reg_Mod) then
                        shifted_R := shifted_R - unsigned(Reg_Mod);
                    end if;
                    if unsigned(shifted_R) >= unsigned(Reg_Mod) then
                        shifted_R := shifted_R - unsigned(Reg_Mod);
                    end if;
                    Reg_R <= std_logic_vector(shifted_R);

                    -- Second Way to do the modulo -> if not choosen remove modulo_R_1 and modulo_R_2 and shifted_mod
                    shifted_mod := unsigned(Reg_Mod(254 downto 0) & '0');
                    modulo_R_1 := shifted_R - unsigned(Reg_Mod);
                    modulo_R_2 := shifted_R - shifted_mod;
                    if modulo_R_2 >= 0 then
                        Reg_R <= std_logic_vector(modulo_R_2);
                    elsif modulo_R_1 >= 0 then
                        Reg_R <= std_logic_vector(modulo_R_1);
                    else
                        Reg_R <= std_logic_vector(shifted_R);
                    end if;
                end loop;
                Result_ready <= '1';
                Out_Blackley <= Reg_R;
            -- end if;
        end if;
    end process;
end architecture;