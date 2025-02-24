library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity genImm32 is
    port (
        instr : in std_logic_vector(31 downto 0); -- Instrução RISC-V de 32 bits
        imm32 : out signed(31 downto 0)          -- Valor imediato gerado (32 bits)
    );
end genImm32;

architecture arch of genImm32 is
    signal opcode : std_logic_vector(6 downto 0); -- Campo opcode da instrução
    signal funct3 : std_logic_vector(2 downto 0); -- Campo funct3, usado para instruções específicas
    signal imm : signed(31 downto 0);            -- Sinal interno para geração do imediato
    signal extended_zeros : std_logic_vector(11 downto 0); -- Padding de zeros para extensões
begin
    -- Processo principal para geração do imediato
    process(instr)
    begin
        opcode <= instr(6 downto 0); -- Captura o opcode (bits 6 a 0)
        funct3 <= instr(14 downto 12); -- Captura o funct3 (bits 14 a 12)
        extended_zeros <= (others => '0'); -- Inicializa padding com zeros
        
        case opcode is
            -- R-type: Sem imediato
            when "0110011" =>
                imm <= to_signed(0, 32); -- Imediato inexistente

            -- I-type: Imediato de 12 bits, extensão de sinal
            when "0000011" | "0010011" | "1100111" =>
                if opcode = "0010011" and funct3 = "101" and instr(30) = '1' then
                    -- I-type*: Campo shamt (5 bits)
                    imm <= resize(signed("00000000000000000000" & instr(24 downto 20)), 32);
                else
                    -- I-type: Extensão de sinal direta
                    imm <= resize(signed(instr(31 downto 20)), 32);
                end if;

            -- S-type: Imediato de 12 bits com bits embaralhados
            when "0100011" =>
                imm <= resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32);

            -- SB-type: Imediato de 12 bits para branches
            when "1100011" =>
                imm <= resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), 32);

            -- U-type: Imediato de 20 bits
            when "0110111" | "0010111" =>
                imm <= resize(signed(instr(31 downto 12) & extended_zeros), 32);

            -- UJ-type: Imediato de 20 bits para jumps
            when "1101111" =>
                imm <= resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32);

            -- Caso padrão: Imediato inexistente
            when others =>
                imm <= to_signed(0, 32);
        end case;

        imm32 <= imm; -- Atribuição do imediato à saída
    end process;
end architecture arch;

