library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use std.env.finish;

library work;
use work.vga_pkg.all;

entity tb_memory is
end tb_memory;

architecture testbench of tb_memory is
    signal pixel_o: pixel := PIXEL_BLACK;
    signal HS_i : std_logic := '1';
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
begin

    u0_pixel_generator : entity work.pixel_generator
    port map (
        pixel_o => pixel_o,
        HS_i => HS_i,
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

    HS_i_gen: process begin
        wait for 200ns;
        HS_i <= not HS_i;
    end process;

    stimulus : process begin
        wait until (AND_REDUCE(pixel_o.red) = '1') and (AND_REDUCE(pixel_o.green) = '1') and (AND_REDUCE(pixel_o.blue) = '1');
        wait until rising_edge(clk);
        report ("Test finished.");
        finish;
    end process;

end architecture;