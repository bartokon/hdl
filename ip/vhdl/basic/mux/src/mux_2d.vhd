library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.my_pkg.all;

entity mux_2d is
  port (
    input_data : in data_type;
    output_data : out element;
    sel : in std_logic_vector(3 downto 0);
    clk  : in std_logic
  );
end entity;

architecture simple_architecture_2d of mux_2d is
begin
    process (clk) begin
        if rising_edge(clk) then
            output_data <= input_data(to_integer(unsigned(sel)));
        end if;
    end process;
end architecture simple_architecture_2d;
