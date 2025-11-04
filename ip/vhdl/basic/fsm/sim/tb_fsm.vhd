library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
use std.env.finish;

library work;

entity tb_fsm is end tb_fsm;

architecture tb of tb_fsm is
    signal div : std_logic := '0';
    signal sel : std_logic_vector(1 downto 0) := (others => '0');
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
begin

    u0_dut: entity work.fsm(Behavioral)
    port map (
        div => div,
        sel => sel,
        clk => clk,
        rst => rst
    );
    
    clk_gen : process begin
        clk <= not clk;
        wait for 5ns;
    end process clk_gen;
    
    rst_gen: process begin 
        wait for 50ns;
        rst <= '0';
    end process;
    
    stimulus : process begin 
        wait for 100ns;
        report "Starting div2 test";
        sel <= "01";
        wait for 1000ns;
        report "Starting div3 test";
        sel <= "10";
        wait for 1000ns;
        report "starting div4 test";
        sel <= "11";
        wait for 1000ns;
        report ("Test finished.");
        finish;
    end process;
end tb;
