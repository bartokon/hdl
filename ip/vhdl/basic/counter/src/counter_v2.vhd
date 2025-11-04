library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

use work.my_pkg.all;

entity counter is
    generic (
        WIDTH : integer := 8
    );
    Port (
        output_binary : inout std_logic_vector(WIDTH - 1 downto 0);
        output_binary_2 : inout std_logic_vector(WIDTH - 1 downto 0);
        output_gray : inout std_logic_vector(WIDTH - 1 downto 0);
        rst : in std_logic;
        clk : in std_logic
    );
end counter;

architecture binary_gray of counter is
    signal counter : unsigned(WIDTH - 1 downto 0) := (others => '0');
begin
    process (clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                counter <= (others => '0');
            else
                counter <= counter + 1; -- It works
            end if;
        end if;
    end process;

    output_binary <= std_logic_vector(counter);
    output_gray <= bin_to_gray(output_binary);
    output_binary_2 <= gray_to_bin(output_gray);

--    output_gray <= (('0' & output_binary(WIDTH-1 downto 1)) XOR output_binary);
--    output_binary_2(WIDTH - 1) <= output_gray(WIDTH - 1);
--    labl: for i in WIDTH - 2  downto 0 generate
--        output_binary_2(i) <= output_binary_2(i + 1) XOR output_gray(i);
--    end generate labl;

end binary_gray;