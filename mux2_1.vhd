library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2_1 is
    port (
    	sel : in std_logic;
	A, B : in std_logic_vector(31 downto 0);
    	Z : out std_logic_vector(31 downto 0)
    );
end entity mux2_1;

architecture arch of mux2_1 is
    begin
	process (sel,a,b)
	begin
            if sel = '0' then
	        Z <= A;
	    else
	        Z <= B;
	    end if;     
        end process;
end arch;
