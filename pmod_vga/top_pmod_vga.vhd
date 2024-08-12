library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

library work;
use work.vga_pkg.all;

entity top_pmod_vga is
    Port (
        start : in std_logic;
        R : out std_logic_vector(3 downto 0);
        G : out std_logic_vector(3 downto 0);
        B : out std_logic_vector(3 downto 0);
        HS : out std_logic;
        VS : out std_logic;
        rst : in std_logic;
        clk : in std_logic
    );
end top_pmod_vga;

architecture behavioral of top_pmod_vga is
    signal pixel_internal : pixel;
    signal HS_internal : std_logic;
    signal VS_internal : std_logic;
    signal addra : std_logic_vector(16 downto 0);
    signal douta : std_logic_vector(11 downto 0);
    signal rd : std_logic;
begin

    u0_blk_mem_gen : entity work.blk_mem_gen_0
    port map (
        addra => addra,
        clka => clk,
        douta => douta
    );

    u0_pixel_generator : entity work.pixel_generator
    port map (
        pixel_o => pixel_internal,
        addra => addra,
        dout => douta,
        rd => rd,
        VS => VS_internal,
        clk => clk,
        rst => rst
    );

    u0_pmod_vga : entity work.pmod_vga
    port map (
        start => start,
        pixel_in => pixel_internal,
        rd => rd,
        R => R,
        G => G,
        B => B,
        VS => VS_internal,
        HS => HS_internal,
        clk => clk,
        rst => rst
    );

    VS <= VS_internal;
    HS <= HS_internal;

end architecture;