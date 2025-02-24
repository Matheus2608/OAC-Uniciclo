library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
ENTITY ula IS
    GENERIC (WSIZE : natural := 32);
    PORT (
        opcode : in std_logic_vector(3 DOWNTO 0);  
        A, B : in std_logic_vector(WSIZE-1 DOWNTO 0);
        Z : out std_logic_vector(WSIZE-1 DOWNTO 0);
        cond : out std_logic
    );
END ula;

ARCHITECTURE arch_ula OF ula IS

SIGNAL Z_internal : std_logic_vector(WSIZE-1 DOWNTO 0);

BEGIN
    PROCESS(A, B, opcode) 
    BEGIN
        CASE opcode IS
            WHEN "0000" => -- ADD
                Z_internal <= std_logic_vector(signed(A) + signed(B));
            WHEN "0001" => -- SUB
                Z_internal <= std_logic_vector(signed(A) - signed(B));
            WHEN "0010" => -- AND
                Z_internal <= A AND B;
            WHEN "0011" => -- OR
                Z_internal <= A OR B;
            WHEN "0100" => -- XOR
                Z_internal <= A XOR B;
            WHEN "0101" => -- SLL
                Z_internal <= std_logic_vector(unsigned(A) SLL to_integer(unsigned(B)));
            WHEN "0110" => -- SRL
                Z_internal <= std_logic_vector(unsigned(A) SRL to_integer(unsigned(B)));
            WHEN "0111" => -- SRA
                Z_internal <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B))));
            WHEN "1000" => -- SLT
                Z_internal <= (others => '0');
                if signed(A) < signed(B) then
                    Z_internal(0) <= '1';
                else
                    Z_internal(0) <= '0';
                end if;
            WHEN "1001" => -- SLTU
                Z_internal <= (others => '0');
                if unsigned(A) < unsigned(B) then
                    Z_internal(0) <= '1';
                else
                    Z_internal(0) <= '0';
                end if;
            WHEN "1010" => -- SGE
                Z_internal <= (others => '0');
                if signed(A) >= signed(B) then
                    Z_internal(0) <= '1';
                else
                    Z_internal(0) <= '0';
                end if;
            WHEN "1011" => -- SGEU
		Z_internal <= (others => '0');
                if unsigned(A) >= unsigned(B) then
                    Z_internal(0) <= '1';
                else
                    Z_internal(0) <= '0';
                end if;
            WHEN "1100" => -- SEQ
                Z_internal <= (others => '0');
                if A = B then
                    Z_internal(0) <= '1';
                else
                    Z_internal(0) <= '0';
                end if;
            WHEN "1101" => -- SNE
                Z_internal <= (others => '0');
                if A /= B then
                    Z_internal(0) <= '1';
                else
                    Z_internal(0) <= '0';
                end if;
            WHEN OTHERS =>
                REPORT "? ERRO: Opcode inválido detectado: " & integer'image(to_integer(unsigned(opcode))) 
                SEVERITY ERROR;
                ASSERT FALSE REPORT "A execução foi interrompida devido a um opcode inválido!" SEVERITY FAILURE;
        END CASE;
    END PROCESS;

    Z <= Z_internal; -- usado para leitura no próximo processo já que vhdl nao deixou ler a saída, somente na versão 2008
    
    -- atualiza o sinal cond
    PROCESS (Z_internal)
    BEGIN
        if unsigned(Z_internal) = 1 then
            cond <= '1'; 
        else
            cond <= '0';
        end if;
    END PROCESS;
END arch_ula;

