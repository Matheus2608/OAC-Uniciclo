library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity adder is
    port (
        A : in std_logic_vector(31 downto 0);
        B : in std_logic_vector(31 downto 0);
        Z : out std_logic_vector(31 downto 0));
end entity adder;

architecture arch of adder is

begin
    Z <= std_logic_vector(signed(A) + signed(B));
end arch;
