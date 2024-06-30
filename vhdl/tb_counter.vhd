library ieee;
use ieee.std_logic_1164.all;
library work;

entity tb_counter is 
    generic (
        WIDTH : integer := 4
    );
end tb_counter;

architecture testbench of tb_counter is 
    signal output_binary : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
    signal output_gray : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
begin

    u0_binary_counter: entity work.counter(binary)
    generic map (
        WIDTH => WIDTH
    )
    port map (
        output => output_binary,
        clk => clk,
        rst => rst
    );
    
    u0_gray_counter: entity work.counter(gray)
    generic map (
        WIDTH => WIDTH
    )
    port map (
        output => output_gray,
        clk => clk,
        rst => rst
    );
    
    clk_gen : process begin
--        clk <= not clk after 5ns; -- It gives warning about missing time control statement.
        clk <= not clk;
        wait for 5ns;
    end process clk_gen;
    
    rst_gen: process begin 
        wait for 50ns;
        rst <= '0';
    end process;
    
end architecture;