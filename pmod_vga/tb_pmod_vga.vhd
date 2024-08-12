library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use std.env.finish;

library work;
use work.vga_pkg.all;

entity tb_pmod_vga is
end tb_pmod_vga;

architecture testbench of tb_pmod_vga is
    signal start : std_logic := '0';
    signal pixel_in : pixel := PIXEL_BLACK;
    signal R : red;
    signal G : green;
    signal B : blue;
    signal VS : std_logic;
    signal HS : std_logic;
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
begin

    u0_pmod_vga : entity work.pmod_vga
    port map (
        start => start,
        pixel_in => pixel_in,
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
        wait for 5ns;
    end process clk_gen;

    rst_gen : process begin
        wait for 50ns;
        rst <= '0';
    end process;

    increase_pixel : process begin
        wait until rising_edge(clk);
        if (VS = '1' and HS = '1') then
            pixel_in.red <= pixel_in.red + '1';
            if (AND_REDUCE(pixel_in.red) = '1') then
                pixel_in.green <= pixel_in.green + '1';
            end if;
            if (AND_REDUCE(pixel_in.green) = '1') then
                pixel_in.blue <= pixel_in.blue + '1';
            end if;
        end if;
    end process;

    stimulus : process begin
        wait for 100ns;
        start <= '1';
        wait until (AND_REDUCE(R) = '1') and (AND_REDUCE(G) = '1') and (AND_REDUCE(B) = '1');
        report ("Test finished.");
        finish;
    end process;

end architecture;