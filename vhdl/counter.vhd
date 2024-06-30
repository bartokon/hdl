library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

entity counter is
    generic (
        WIDTH : integer := 4
    );
    Port ( 
        output : out std_logic_vector(WIDTH - 1 downto 0);
        rst : in std_logic; 
        clk : in std_logic
    );
end counter;

architecture binary of counter is
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
    output <= std_logic_vector(counter);
end binary;

architecture gray of counter is
    signal counter : unsigned(WIDTH - 1 downto 0) := (others => '0');
    signal output_binary : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
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
    output <= (('0' & output_binary(WIDTH-1 downto 1)) XOR output_binary);
end gray;