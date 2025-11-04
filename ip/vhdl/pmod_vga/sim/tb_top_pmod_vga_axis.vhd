library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use std.env.finish;

library work;
use work.vga_pkg.all;

entity tb_top_pmod_vga_axis is
end tb_top_pmod_vga_axis;

architecture testbench of tb_top_pmod_vga_axis is
    signal s_axis_tdata : std_logic_vector(31 downto 0);
    signal s_axis_tvalid : std_logic;
    signal s_axis_tlast : std_logic;
    signal s_axis_tready : std_logic;

    signal pixel_tdata : std_logic_vector(15 downto 0);
    signal pixel_tlast : std_logic;
    signal pixel_tvalid : std_logic;
    signal pixel_tready : std_logic;

    signal R : red;
    signal G : green;
    signal B : blue;
    signal VS : std_logic;
    signal HS : std_logic;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
begin

    u0_pixel_generator_axis : entity work.pixel_generator_axis
    port map (
        s_axis_tdata => s_axis_tdata,
        s_axis_tvalid => s_axis_tvalid,
        s_axis_tlast => s_axis_tlast,
        s_axis_tready => s_axis_tready,

        m_axis_tdata => pixel_tdata,
        m_axis_tvalid => pixel_tvalid,
        m_axis_tlast => pixel_tlast,
        m_axis_tready => pixel_tready,

        rstn => rstn,
        clk => clk
    );

    u0_pmod_vga_axis : entity work.pmod_vga_axis
    port map (
        pixel_tdata => pixel_tdata,
        pixel_tlast => pixel_tlast,
        pixel_tvalid => pixel_tvalid,
        pixel_tready => pixel_tready,

        R => R,
        G => G,
        B => B,
        HS => HS,
        VS => VS,

        rstn => rstn,
        clk => clk
    );

    clk_gen : process begin
        clk <= not clk;
        wait for 19.8609ns;
    end process clk_gen;

    rst_gen : process begin
        wait for 500ns;
        rstn <= '0';
    end process;

    stimulus : process begin
        wait for rstn = '1';


        wait for 1000ns;
        report ("Test finished.");
        finish;
    end process;

end architecture;