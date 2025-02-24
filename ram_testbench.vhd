library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ram is
end entity;

architecture testbench of tb_ram is
    component ram_rv
        port (
            clck    : in  std_logic;
            we      : in  std_logic;
            byte_en : in  std_logic;
            sgn_en  : in  std_logic;
            address : in  std_logic_vector(12 downto 0);
            datain  : in  std_logic_vector(31 downto 0);
            dataout : out std_logic_vector(31 downto 0)
        );
    end component;

    signal clk      : std_logic := '0';
    signal we       : std_logic := '0';
    signal byte_en  : std_logic := '0';
    signal sgn_en   : std_logic := '0';
    signal address  : std_logic_vector(12 downto 0) := (others => '0');
    signal datain   : std_logic_vector(31 downto 0) := (others => '0');
    signal dataout  : std_logic_vector(31 downto 0);
    
    constant clk_period : time := 10 ns;

begin
    uut_ram : ram_rv
        port map (
            clck    => clk,
            we      => we,
            byte_en => byte_en,
            sgn_en  => sgn_en,
            address => address,
            datain  => datain,
            dataout => dataout
        );
    
    clk_gen: process
    begin
        for i in 0 to 100 loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;
    
    stim_proc: process
    begin
        for i in 0 to 255 loop
            address <= std_logic_vector(to_unsigned(i, 13));
            datain  <= std_logic_vector(to_unsigned(i, 30)) & "00";
            we <= '1';
            wait for 1 ns;
            we <= '0';
            wait for 1 ns;
            assert dataout = datain report "Erro na RAM" severity error;
        end loop;
        wait;
    end process;
end architecture;
