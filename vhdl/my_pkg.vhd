library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package my_pkg is
  subtype element is std_logic_vector(7 downto 0);
  type data_type is array (0 to 7) of std_logic_vector(7 downto 0);

  pure function gray_to_bin (
    gray : std_logic_vector(7 downto 0)
  ) return std_logic_vector;

  pure function bin_to_gray (
    bin : std_logic_vector(7 downto 0)
  ) return std_logic_vector;

end package my_pkg;

package body my_pkg is

  pure function gray_to_bin (
    gray : std_logic_vector(7 downto 0)
  ) return std_logic_vector is
    variable bin : std_logic_vector(7 downto 0);
  begin
    bin(8 - 1) := gray(8 - 1);
    labl: for i in 8 - 2  downto 0 loop
        bin(i) := bin(i + 1) XOR gray(i);
    end loop labl;
  return bin;
  end function;

  pure function bin_to_gray (
   bin : std_logic_vector(7 downto 0)
  ) return std_logic_vector is
    variable gray : std_logic_vector(7 downto 0);
  begin
    gray := (('0' & bin(8-1 downto 1)) XOR bin);
  return gray;
  end function;

end my_pkg;