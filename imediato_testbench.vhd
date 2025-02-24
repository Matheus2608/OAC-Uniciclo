library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_genImm32 is
end tb_genImm32;

architecture test of tb_genImm32 is
    -- Sinais para a DUT (Dispositivo em Teste)
    signal instr : std_logic_vector(31 downto 0);
    signal imm32 : signed(31 downto 0);

    -- Declara��o do componente DUT
    component genImm32
        Port (
            instr : in  std_logic_vector(31 downto 0);
            imm32 : out signed(31 downto 0)
        );
    end component;

begin
    -- Instancia��o da DUT
    uut: genImm32
        port map (
            instr => instr,
            imm32 => imm32
        );

    -- Processo de teste
    process
    begin
        -- Teste 1: Formato R-type (sa�da deve ser 0)
        instr <= x"000002B3";  -- add t0, zero, zero
        wait for 10 ns;

        assert imm32 = to_signed(0, 32) report "Teste 1 Falhou" severity error;

        -- Teste 2: Formato I-type0 (lw t0, 16(zero))
        instr <= x"01002283";  -- lw t0, 16(zero)
        wait for 10 ns;
        assert imm32 = to_signed(16, 32) report "Teste 2 Falhou" severity error;

        -- Teste 3: Formato I-type1 (addi t1, zero, -100)
        instr <= x"f9c00313";  -- addi t1, zero, -100
        wait for 10 ns;
        assert imm32 = to_signed(-100, 32) report "Teste 3 Falhou" severity error;

        -- Teste 4: Formato I-type1 (xori t0, t0, -1)
        instr <= x"fff2c293";  -- xori t0, t0, -1
        wait for 10 ns;
        assert imm32 = to_signed(-1, 32) report "Teste 4 Falhou" severity error;

        -- Teste 5: Formato I-type1 (addi t1, zero, 354)
        instr <= x"16200313";  -- addi t1, zero, 354
        wait for 10 ns;
        assert imm32 = to_signed(354, 32) report "Teste 5 Falhou" severity error;

        -- Teste 6: Formato I-type2 (jalr zero, zero, 0x18)
        instr <= x"01800067";  -- jalr zero, zero, 0x18
        wait for 10 ns;
        assert imm32 = to_signed(24, 32) report "Teste 6 Falhou" severity error;

        -- Teste 7: Formato I-type* (srai t1, t2, 10)
        instr <= x"40a3d313";  -- srai t1, t2, 10
        wait for 10 ns;
        assert imm32 = to_signed(10, 32) report "Teste 7 Falhou" severity error;

        -- Teste 8: Formato U-type (lui s0, 2)
        instr <= x"00002437";  -- lui s0, 2
        wait for 10 ns;
        assert imm32 = to_signed(8192, 32) report "Teste 8 Falhou" severity error;

        -- Teste 9: Formato S-type (sw t0, 60(s0))
        instr <= x"02542e23";  -- sw t0, 60(s0)
        wait for 10 ns;
        assert imm32 = to_signed(60, 32) report "Teste 9 Falhou" severity error;

        -- Teste 10: Formato SB-type (bne t0, t0, main)
        instr <= x"fe5290e3";  -- bne t0, t0, main
        wait for 10 ns;
        assert imm32 = to_signed(-32, 32) report "Teste 10 Falhou" severity error;

        -- Teste 11: Formato UJ-type (jal rot)
        instr <= x"00c000ef";  -- jal rot
        wait for 10 ns;
        assert imm32 = to_signed(12, 32) report "Teste 11 Falhou" severity error;

        wait;
    end process;

end test;


