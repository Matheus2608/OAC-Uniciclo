library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity rom is
    port (
    	clock : in std_logic;
    	address : in std_logic_vector(10 downto 0);
    	dataout : out std_logic_vector(31 downto 0)
    );
end entity rom;

architecture RTL of rom is
    
    constant mem_depth : NATURAL := 2048;
    constant mem_width : NATURAL := 32;

    Type mem_type is array (0 to mem_depth-1) of std_logic_vector(mem_width - 1 downto 0);
    signal read_address : std_logic_vector(address'range);
    
    impure function init_mem_instr return mem_type is
        file text_file : text open read_mode is "instructions.txt";
        variable text_line : line;
        variable mem_content : mem_type;
        variable mem_content_bit_vector : bit_vector(31 downto 0) := (others => '0');
        begin
        for i in 0 to mem_depth - 1 loop
            if (not endfile(text_file)) then
                readline(text_file, text_line);
                hread(text_line, mem_content_bit_vector);  -- Correção aqui
                mem_content(i) := to_stdlogicvector(mem_content_bit_vector);
            end if;
        end loop;
        return mem_content;
    end function;


    signal mem : mem_type := init_mem_instr;

    begin
        process(clock)
        begin
            if rising_edge(clock) then
                dataout <= mem(to_integer(unsigned(address)));
            end if;
            read_address <= address;       
    end process;

    dataout <= mem(to_integer(unsigned(read_address)));
end RTL;
