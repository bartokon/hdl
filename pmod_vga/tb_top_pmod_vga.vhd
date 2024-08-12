library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use std.env.finish;

library work;
use work.vga_pkg.all;

entity tb_top_pmod_vga is
end tb_top_pmod_vga;

architecture testbench of tb_top_pmod_vga is
    signal start : std_logic := '0';
    signal R : red;
    signal G : green;
    signal B : blue;
    signal VS : std_logic;
    signal HS : std_logic;
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
begin

    u0_top_pmod_vga : entity work.top_pmod_vga
    port map (
        start => start,
        R => R,
        G => G,
        B => B,
        VS => VS,
        HS => HS,
        clk => clk,
        rst => rst
    );

    clk_gen : process begin
        clk <= not clk;
        wait for 19.8609ns;
    end process clk_gen;

    rst_gen : process begin
        wait for 500ns;
        rst <= '0';
    end process;

    stimulus : process begin
        wait for 1000ns;
        start <= '1';
        wait until (AND_REDUCE(R) = '1') and (AND_REDUCE(G) = '1') and (AND_REDUCE(B) = '1');
        report ("Test finished.");
--        finish;
    end process;

end architecture;