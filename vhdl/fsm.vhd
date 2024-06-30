--TODO: FIX ME (check tb)
-- p0 <= p1(15 downto 8);

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

entity fsm is
    port (
        div : out std_logic := '0';
        sel : in std_logic_vector(1 downto 0) := (others => '0');
        clk : in std_logic := '0';
        rst : in std_logic := '0'
    );
end fsm;

architecture Behavioral of fsm is
    signal counter_d, counter_q : unsigned(15 downto 0) := (others => '0');
    signal divider_d, divider_q : unsigned(15 downto 0) := (others => '0');
    signal div_d, div_q : std_logic := '0';
    type StState is (IDLE, DIV2, DIV3, DIV4);
    signal state_d, state_q : StState;
begin

    logic_clk: process (clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                counter_q <= (others => '0');
                divider_q <= (others => '0');
                div_q <= '0';
            else
                counter_q <= counter_d;
                divider_q <= divider_d;
                div_q <= div_d;
                div <= div_d;
                --div_q <= div_d when (counter_d > divider_d) else not div_d;
            end if;
        end if;
    end process;

    logic_comb : process (counter_q, divider_q, state_q, div_q) --all
        variable tmp : std_logic := '1' when (state_q /= IDLE) else '0'; --Not used
    begin

        if (state_q = IDLE) then
            div_d <= '0';
            counter_d <= (others => '0');
        else
            counter_d <= counter_d + "1";
            if (counter_q = divider_q) then
                div_d <= not div_q;
                counter_d <= (others => '0');
            end if;
        end if;
        --counter_d <= counter_q + 1 when (state_q /= IDLE) else (others => '0') when (counter_q > divider_q) else counter_q;

        case state_q is
            when IDLE => divider_d <= (others => '0');
            when DIV2 => divider_d <= to_unsigned(0, 16);
            when DIV3 => divider_d <= to_unsigned(1, 16);
            when DIV4 => divider_d <= to_unsigned(2, 16);
            when others => divider_d <= (others => '0');
        end case;
    end process;

    state_clk : process (clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                state_q <= IDLE;
            else
                state_q <= state_d;
            end if;
        end if;
    end process;

    state_comb : process (sel) begin --all
        case sel is
            when "00" => state_d <= IDLE;
            when "01" => state_d <= DIV2;
            when "10" => state_d <= DIV3;
            when "11" => state_d <= DIV4;
            when others => state_d <= IDLE;
        end case;
    end process;

end Behavioral;
