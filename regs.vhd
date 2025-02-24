library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity XREGS is
    port ( clk, wren   : in  STD_LOGIC;
           rs1, rs2, rd   : in  STD_LOGIC_VECTOR (4 downto 0);
           data  : in  STD_LOGIC_VECTOR (31 downto 0);
           ro1, ro2   : out STD_LOGIC_VECTOR (31 downto 0)
         );

end XREGS;

architecture xreg_arch of XREGS is

    type regs_array is array (0 to 31) of STD_LOGIC_VECTOR (31 downto 0);
    signal regs : regs_array := (others => (others => '0'));

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if wren = '1' and to_integer(unsigned(rd)) /= 0 then
                regs(to_integer(unsigned(rd))) <= data;
            end if;

            ro1 <= regs(to_integer(unsigned(rs1)));
            ro2 <= regs(to_integer(unsigned(rs2)));
        end if;
    end process;

end xreg_arch;
