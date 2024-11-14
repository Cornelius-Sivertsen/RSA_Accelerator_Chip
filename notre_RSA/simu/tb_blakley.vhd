library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity test_tb_blakley is
end entity test_tb_blakley;

architecture TEST of test_tb_blakley is
    constant Period : time := 1 ns;
    signal Done : boolean;

    signal T_CLK                        :  std_logic := '0';
    signal T_RST                        :  std_logic;
    signal T_Blakley_Value1, T_Blakley_Value2, T_Blakley_Mod :  std_logic_vector(255 downto 0);
    signal T_InReady : std_logic;

    signal T_OutBlackley : std_logic_vector(255 downto 0);
    signal T_Outready : std_logic;    

    signal OK, OK_general : boolean := true;

    signal expected_result : unsigned(255 downto 0);

begin

    T_CLK <= '0' when Done else not T_CLK after Period;
    --T_RST <= '0';

    UUT: entity work.Blackley(blackley_archi_v3) port map (
        CLOCK => T_CLK,
        RESET => T_RST,
        In_Blakley_Value1 => T_Blakley_Value1,
        In_Blakley_Value2 => T_Blakley_Value2,
        In_Blakley_Mod => T_Blakley_Mod,
        Input_Ready => T_InReady,
        Out_Blackley => T_OutBlackley,
        Result_ready => T_Outready
    );

    process
        variable result : integer;
        variable ok_v : boolean := false;
    begin
        Done <= false;

        T_RST <= '1';
        wait for 200 ns;
        T_RST <= '0';
        
        -- Test Case 1 a: Simple case
        T_Blakley_Value1 <= X"0000000000000000000000000000000000000000000000000000000000000000";
        T_Blakley_Value2 <= X"0000000000000000000000000000000000000000000000000000000000000000";
        T_Blakley_Mod <= (others => '1');
        T_InReady <= '1';
        wait for 2 ns;
        T_InReady <= '0';
        wait until T_Outready = '1';
        assert T_OutBlackley = X"0000000000000000000000000000000000000000000000000000000000000000" report "Test Case 1a Failed" severity warning;
        OK <= T_OutBlackley = X"0000000000000000000000000000000000000000000000000000000000000000";
        ok_v := T_OutBlackley = X"0000000000000000000000000000000000000000000000000000000000000000";
        expected_result <= X"0000000000000000000000000000000000000000000000000000000000000000";
        OK_general <= OK_general and ok_v;
        wait for 4000 ns;
        
        assert T_Outready = '0' report "Signal Blakley OutReady suppose to be up only 1 cycle" severity warning;
        ok_v := T_Outready = '0';
        OK <= ok_v;
        OK_general <= OK_general and ok_v;
        
        T_RST <= '1';
        wait for 2 ns;
        T_RST <= '0';
        wait for 200 ns;

-- Test Case 1 b: Simple case
        T_Blakley_Value1 <= X"0000000000000000000000000000000000000000000000000000000000000001";
        T_Blakley_Value2 <= X"0000000000000000000000000000000000000000000000000000000000000001";
        T_Blakley_Mod <= (others => '1');
        T_InReady <= '1';
        wait for 2 ns;
        T_InReady <= '0';
        wait until T_Outready = '1';
        assert T_OutBlackley = X"0000000000000000000000000000000000000000000000000000000000000001" report "Test Case 1b Failed" severity warning;
        expected_result <= X"0000000000000000000000000000000000000000000000000000000000000001";
        OK <= T_OutBlackley = X"0000000000000000000000000000000000000000000000000000000000000001";
        ok_v := T_OutBlackley = X"0000000000000000000000000000000000000000000000000000000000000001";
        OK_general <= OK_general and ok_v;
        wait for 4 ns;

        -- Test Case 2: Edge case with maximum values
        T_Blakley_Value1 <= '0' & (254 downto 0 => '1');
        T_Blakley_Value2 <= '0' & (254 downto 0 => '1');
        T_Blakley_Mod <= (others => '1');
        T_InReady <= '1';
        wait for 2 ns;
        T_InReady <= '0';
        wait until T_Outready = '1';
        assert unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod) report "Test Case 2 Failed" severity warning;
        expected_result <= (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK <= unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK_v := unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK_general <= OK_general and ok_v;
        wait for 4 ns;

        -- Test Case 3: Random values
        T_Blakley_Value1 <= X"0000000000000000000000000000000000000000000000000000000000000001";
        T_Blakley_Value2 <= X"0000000000000000000000000000000000000000000000000000000000000002";
        T_Blakley_Mod <= X"0000000000000000000000000000000000000000000000000000000000000003";
        T_InReady <= '1';
        wait for 2 ns;
        T_InReady <= '0';
        wait until T_Outready = '1';
        assert unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod) report "Test Case 3 Failed" severity error;
        expected_result <= (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK <= unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK_v := unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK_general <= OK_general and ok_v;
        -- assert T_OutBlackley = X"0000000000000000000000000000000000000000000000000000000000000002" report "Test Case 3 Failed" severity warning;
        wait for 4 ns;

        -- Test Case 4: Large values with different mod
        T_Blakley_Value1 <= X"0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9";
        T_Blakley_Value2 <= X"0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9";
        T_Blakley_Mod    <= X"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
        T_InReady <= '1';
        wait for 2 ns;
        T_InReady <= '0';
        wait until T_Outready = '1';
        assert unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod) report "Test Case 4 Failed" severity error;
        expected_result <= (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK <= unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK_v := unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK_general <= OK_general and ok_v;
        -- assert T_OutBlackley = X"0000000000000000000000000000000000000000000000000000000000000000" report "Test Case 4 Failed" severity error;
        wait for 4 ns;

        -- Test Case 5: Large values with prime mod
        T_Blakley_Value1 <= X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA"; -- Value1 < Mod
        T_Blakley_Value2 <= X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9"; -- Value2 < Mod
        T_Blakley_Mod <= X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB";
        T_InReady <= '1';
        wait for 2 ns;
        T_InReady <= '0';
        wait until T_Outready = '1';
        assert unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod) report "Test Case 5 Failed" severity error;
        expected_result <= (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK <= unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK_v := unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK_general <= OK_general and ok_v;
        wait for 4 ns;

        -- Test Case 6: Large values with non-trivial mod
        T_Blakley_Value1 <= X"123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEEF"; -- Value1 < Mod
        T_Blakley_Value2 <= X"FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA987654320F"; -- Value2 < Mod
        T_Blakley_Mod <= X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0"; -- Mod > Values
        T_InReady <= '1';
        wait for 2 ns;
        T_InReady <= '0';
        wait until T_Outready = '1';
        assert unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod) report "Test Case 6 Failed" severity error;
        expected_result <= (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK <= unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK_v := unsigned(T_OutBlackley) = (unsigned(T_Blakley_Value1) * unsigned(T_Blakley_Value2)) mod unsigned(T_Blakley_Mod);
        OK_general <= OK_general and ok_v;
        -- wait for 4 ns;

        -- End of tests
        wait for 2 ns;
        Done <= true;
        wait;
    end process;

end architecture TEST;