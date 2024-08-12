library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vga_pkg is

    subtype red   is std_logic_vector(3 downto 0);
    subtype green is std_logic_vector(3 downto 0);
    subtype blue  is std_logic_vector(3 downto 0);

    type pixel is record
        red   : red;
        green : green;
        blue  : blue;
    end record pixel;

    constant PIXEL_BLACK : pixel := (
        red   => (others => '0'),
        green => (others => '0'),
        blue  => (others => '0')
    );

    constant PIXEL_RED : pixel := (
        red   => (others => '1'),
        green => (others => '0'),
        blue  => (others => '0')
    );

    constant PIXEL_GREEN : pixel := (
        red   => (others => '0'),
        green => (others => '1'),
        blue  => (others => '0')
    );

    constant PIXEL_BLUE : pixel := (
        red   => (others => '0'),
        green => (others => '0'),
        blue  => (others => '1')
    );

    constant PIXEL_YELLOW : pixel := (
        red   => (others => '1'),
        green => (others => '1'),
        blue  => (others => '0')
    );

    constant PIXEL_VIOLET : pixel := (
        red   => (others => '1'),
        green => (others => '0'),
        blue  => (others => '1')
    );

    constant PIXEL_TURQUOISE : pixel := (
        red   => (others => '0'),
        green => (others => '1'),
        blue  => (others => '1')
    );

    pure function increase_red (
        in_pixel : pixel
    ) return pixel;

    pure function increase_green (
        in_pixel : pixel
    ) return pixel;

    pure function increase_blue (
        in_pixel : pixel
    ) return pixel;

end package vga_pkg;

package body vga_pkg is

    pure function increase_red (
        in_pixel : pixel
    ) return pixel is
        variable temp : pixel;
    begin
        temp := in_pixel;
        temp.red := std_logic_vector(unsigned(in_pixel.red) + 1);
    return temp;
    end function;

    pure function increase_green (
        in_pixel : pixel
    ) return pixel is
        variable temp : pixel;
    begin
        temp := in_pixel;
        temp.red := std_logic_vector(unsigned(in_pixel.green) + 1);
    return temp;
    end function;

    pure function increase_blue (
        in_pixel : pixel
    ) return pixel is
        variable temp : pixel;
    begin
        temp := in_pixel;
        temp.red := std_logic_vector(unsigned(in_pixel.blue) + 1);
    return temp;
    end function;

end vga_pkg;