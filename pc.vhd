library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity pc is
  port (
    addr_in  : in  std_logic_vector(31 downto 0);
    clk      : in  std_logic;
    addr_out : out std_logic_vector(31 downto 0) := x"00000000"
  );
end entity pc;

architecture arch of pc is
begin
  process(clk) 
  begin
    if rising_edge(clk) then
      addr_out <= addr_in;
    end if;
  end process;
end architecture arch;

