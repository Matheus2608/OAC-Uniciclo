library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity XREGS_TB is
end XREGS_TB;

architecture testbench of XREGS_TB is
    -- Sinais do DUT (Device Under Test)
    signal clk, wren : STD_LOGIC := '0';
    signal rs1, rs2, rd : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
    signal data : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal ro1, ro2 : STD_LOGIC_VECTOR (31 downto 0);

    constant clk_period : time := 10 ns;

begin
    uut: entity work.XREGS
        port map ( 
		clk => clk, 
		wren => wren, 
                rs1 => rs1, 
		rs2 => rs2, 
	        rd => rd, 
                data => data, 
		ro1 => ro1, 
		ro2 => ro2 
	);

    process
    begin
        while now < 1000 ns loop 
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Processo de testes
    process
    begin
        report "Iniciando Testbench..." severity Note;

        -- Teste 1: Escrever valores nos registradores (exceto no 0)
        for i in 1 to 31 loop
            wren <= '1';
            rd <= std_logic_vector(to_unsigned(i, 5));
            data <= std_logic_vector(to_unsigned(i * 8, 32));
            wait for clk_period;
        end loop;
        
        -- Desativar escrita
        wren <= '0';

        -- Teste 2: Ler valores e verificar se foram escritos corretamente
        for i in 1 to 31 loop
            rs1 <= std_logic_vector(to_unsigned(i, 5));
            wait for clk_period;
            assert ro1 = std_logic_vector(to_unsigned(i * 8, 32))
                report "Erro na leitura do registrador " & integer'image(i)
                severity Error;
        end loop;

        -- Teste 3: Verificar que o registrador 0 continua zero
        wren <= '1';
        rd <= "00000";  -- Registrador 0
        data <= X"FFFFFFFF";
        wait for clk_period;
        wren <= '0';

        rs1 <= "00000";
        wait for clk_period;
        assert ro1 = X"00000000"
            report "Erro: registrador zero foi alterado!" severity Error;

        report "Testbench finalizado com sucesso!" severity Note;
        wait;
    end process;
end testbench;

