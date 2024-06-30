library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--when others => report "unreachable" severity failure;

entity mux is
    port (
        input_data : in std_logic_vector(15 downto 0);
        output_data : out std_logic;
        sel : in std_logic_vector(3 downto 0);
        clk   : in std_logic
    );
end entity;

architecture if_else_architecture of mux is
begin
process (clk) begin
    if rising_edge(clk) then
        if (sel = "0000") then
            output_data <= input_data(0);
        elsif (sel = "0001") then
            output_data <= input_data(1);
        elsif (sel = "0010") then
            output_data <= input_data(2);
        elsif (sel = "0011") then
            output_data <= input_data(3);
        elsif (sel = "0100") then
            output_data <= input_data(4);
        elsif (sel = "0101") then
            output_data <= input_data(5);
        elsif (sel = "0110") then
            output_data <= input_data(6);
        elsif (sel = "0111") then
            output_data <= input_data(7);
        elsif (sel = "1000") then
            output_data <= input_data(8);
        elsif (sel = "1001") then
            output_data <= input_data(9);
        elsif (sel = "1010") then
            output_data <= input_data(10);
        elsif (sel = "1011") then
            output_data <= input_data(11);
        elsif (sel = "1100") then
            output_data <= input_data(12);
        elsif (sel = "1101") then
            output_data <= input_data(13);
        elsif (sel = "1110") then
            output_data <= input_data(14);
        elsif (sel = "1111") then
            output_data <= input_data(15);
        else
            output_data <= 'X';
        end if;
    end if;
end process;
end architecture if_else_architecture;

architecture simple_architecture of mux is
begin
process (clk) begin
    if rising_edge(clk) then
        output_data <= input_data(to_integer(unsigned(sel)));
    end if;
end process;
end architecture simple_architecture;

architecture case_architecture of mux is
begin
process (clk) begin
    if rising_edge(clk) then
        case sel is
            when "0000" => output_data <= input_data(0);
            when "0001" => output_data <= input_data(1);
            when "0010" => output_data <= input_data(2);
            when "0011" => output_data <= input_data(3);
            when "0100" => output_data <= input_data(4);
            when "0101" => output_data <= input_data(5);
            when "0110" => output_data <= input_data(6);
            when "0111" => output_data <= input_data(7);
            when "1000" => output_data <= input_data(8);
            when "1001" => output_data <= input_data(9);
            when "1010" => output_data <= input_data(10);
            when "1011" => output_data <= input_data(11);
            when "1100" => output_data <= input_data(12);
            when "1101" => output_data <= input_data(13);
            when "1110" => output_data <= input_data(14);
            when "1111" => output_data <= input_data(15);
            when others => output_data <= 'X';
        end case;
    end if;
end process;
end architecture case_architecture;

--architecture with_architecture of mux is
--begin
--process (clk) begin
--    if rising_edge(clk) then
--        with sel select output_data <=
--            input_data(0) when "0000",
--            input_data(1) when "0001",
--            input_data(2) when "0010",
--            input_data(3) when "0011",
--            input_data(4) when "0100",
--            input_data(5) when "0101",
--            input_data(6) when "0110",
--            input_data(7) when "0111",
--            input_data(8) when "1000",
--            input_data(9) when "1001",
--            input_data(10) when "1010",
--            input_data(11) when "1011",
--            input_data(12) when "1100",
--            input_data(13) when "1101",
--            input_data(14) when "1110",
--            input_data(15) when "1111",
--            'X' when others;
--    end if;
--end process;
--end architecture with_architecture;

