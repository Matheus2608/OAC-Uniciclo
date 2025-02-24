library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram_rv is
    port (
        clck    : in  std_logic;
        we      : in  std_logic;
        byte_en : in  std_logic;
        sgn_en  : in  std_logic;
        address : in  std_logic_vector(12 downto 0);
        datain  : in  std_logic_vector(31 downto 0);
        dataout : out std_logic_vector(31 downto 0)
    );
end entity ram_rv;

architecture RTL of ram_rv is
    type ram_type is array (0 to (2**13)-1) of std_logic_vector(7 downto 0);
    signal mem : ram_type := (others => (others => '0'));

begin
    process(clck)
    begin
        if rising_edge(clck) then
            if we = '1' then -- Escrita
                if byte_en = '1' then -- Acesso a byte
                    mem(to_integer(unsigned(address))) <= datain(7 downto 0);
                elsif to_integer(unsigned(address)) mod 4 = 0 then -- Acesso a word, apenas se o endereço for múltiplo de 4
                    mem(to_integer(unsigned(address)))     <= datain(7 downto 0);
                    mem(to_integer(unsigned(address))+1) <= datain(15 downto 8);
                    mem(to_integer(unsigned(address))+2) <= datain(23 downto 16);
                    mem(to_integer(unsigned(address))+3) <= datain(31 downto 24);
                end if;
            else -- Leitura
                if byte_en = '1' then -- Leitura de byte
                    if sgn_en = '1' then -- Leitura com sinal
                        dataout <= std_logic_vector(resize(signed(mem(to_integer(unsigned(address)))), 32));
                    else -- Leitura sem sinal
                        dataout <= std_logic_vector(resize(unsigned(mem(to_integer(unsigned(address)))), 32));
                    end if;
                elsif to_integer(unsigned(address)) mod 4 = 0 then -- Leitura de word apenas se o endereço for múltiplo de 4
                    dataout <= mem(to_integer(unsigned(address))+3) &
                               mem(to_integer(unsigned(address))+2) &
                               mem(to_integer(unsigned(address))+1) &
                               mem(to_integer(unsigned(address)));
                end if; 
            end if;
        end if;
    end process;
end RTL;

