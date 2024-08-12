library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.vga_pkg.all;

entity pixel_reader is
    Port (
        pixel_o : out pixel;
        rd : in std_logic;
        rst : in std_logic;
        clk : in std_logic
    );
end pixel_reader;

architecture behavioral of pixel_reader is
    signal counter : unsigned(31 downto 0) := (others => '0');
    type pixel_memory is array(0 to 307200) of pixel;
    signal mem : pixel_memory;
begin

    FILL_MEMORY: process begin 
        for i in 0 to 307200 loop
            mem(i) <= PIXEL_BLACK;
        end loop;
    end process;
    
    LOGIC_FF: process (clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                pixel_o <= PIXEL_BLACK;
                counter <= (others => '0');
            else
                pixel_o <= mem(to_integer(counter));
                if (rd = '1') then
                    if (counter = 307200 - 1) then
                        counter <= (others => '0');
                    else
                        counter <= counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture;