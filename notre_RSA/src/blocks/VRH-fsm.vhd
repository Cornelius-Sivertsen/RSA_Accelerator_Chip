library ieee;
use ieee.std_logic_1164.all;

entity VRH is
  port(
    done : in std_logic;
    ready: in std_logic;
    reset: in std_logic;
    clk: in std_logic;
    valid: out std_logic
    );

end entity VRH;

architecture output_handshake of VRH is
  type state is (s_idle, s_B_done, s_C_ready, s_D_ready_off);
  signal curr_state, next_state : state;
begin

  Combinatorial_component : process (done, ready, curr_state)
  begin
    case (curr_state) is
      when s_idle =>
        valid <= '0';

        if done = '0' then
          next_state <= s_idle;
        elsif ready = '0' then
          next_state <= s_B_done;
        elsif ready = '1' then
          next_state <= s_C_ready;
        end if;

      when s_B_done =>
        valid <= '1';

        if ready = '0' then
          next_state <= s_B_done;
        else
          next_state <= s_C_ready;
        end if;
      when s_C_ready =>
        valid <= '1';

        if ready = '1' then
          next_state <= s_C_ready;
        elsif done = '0' then
          next_state <= s_idle;
        else
          next_state <= s_D_ready_off;
        end if;
        
        when s_D_ready_off =>
            if done = '0' then
                next_state <= s_idle;
            else
                next_state <= s_D_ready_off;
            end if;
      when others =>
        valid <= '0';

        next_state <= s_idle;
    end case;
  end process Combinatorial_component;

  Seq_component : process (reset, next_state, clk)
  begin
    if (reset = '1') then
      curr_state <= s_idle;
    elsif rising_edge(clk) then
      curr_state <= next_state;
    end if;
  end process Seq_component;

end architecture output_handshake;
