library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.vga_pkg.all;

entity pixel_generator is
    Port (
        pixel_o : out pixel;
        addra : out std_logic_vector(16 downto 0);
        dout : in std_logic_vector(11 downto 0);
        rd : in std_logic;
        VS : in std_logic;
        rst : in std_logic;
        clk : in std_logic
    );
end pixel_generator;

architecture behavioral of pixel_generator is
    signal counter : unsigned(16 downto 0) := (others => '0');
begin

    LOGIC_COMB : process (counter, dout)
        variable temp_pixel : pixel := PIXEL_BLACK;
    begin
        temp_pixel.red := dout(11 downto 8);
        temp_pixel.green := dout(7 downto 4);
        temp_pixel.blue := dout(3 downto 0);
        pixel_o <= temp_pixel;
        addra <= std_logic_vector(counter);
    end process;

    LOGIC_FF: process (clk)
    begin
        if rising_edge(clk) then
            if (rst = '1' or VS = '0') then
                counter <= (others => '0');
            else
                if (rd = '1') then
                    counter <= counter + 1;
                else
                    counter <= counter;
                end if;
            end if;
        end if;
    end process;

end architecture;