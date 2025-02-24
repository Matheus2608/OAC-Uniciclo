library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ulaRV_tb IS
END ulaRV_tb;

ARCHITECTURE testbench OF ulaRV_tb IS
    CONSTANT WSIZE : natural := 32;
    SIGNAL opcode : std_logic_vector(3 DOWNTO 0);
    SIGNAL A, B, Z : std_logic_vector(WSIZE-1 DOWNTO 0);
    SIGNAL cond : std_logic;

    COMPONENT ula
        GENERIC (WSIZE : natural := 32);
        PORT (
            opcode : in std_logic_vector(3 DOWNTO 0);
            A, B : in std_logic_vector(WSIZE-1 DOWNTO 0);
            Z : out std_logic_vector(WSIZE-1 DOWNTO 0);
            cond : out std_logic
        );
    END COMPONENT;

BEGIN
    UUT: ula
        GENERIC MAP (WSIZE => 32)
        PORT MAP (
            opcode => opcode,
            A => A,
            B => B,
            Z => Z,
            cond => cond
        );

    PROCESS
    BEGIN
        -- ADD Tests
        opcode <= "0000";
        A <= std_logic_vector(to_unsigned(0, WSIZE)); B <= std_logic_vector(to_unsigned(0, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(0, WSIZE)) REPORT "ADD failed on zero case" SEVERITY ERROR;

        A <= std_logic_vector(to_signed(5, WSIZE)); B <= std_logic_vector(to_signed(10, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_signed(15, WSIZE)) REPORT "ADD failed on positive case" SEVERITY ERROR;

        A <= std_logic_vector(to_signed(-5, WSIZE)); B <= std_logic_vector(to_signed(-10, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_signed(-15, WSIZE)) REPORT "ADD failed on negative case" SEVERITY ERROR;

        A <= std_logic_vector(to_signed(2147483647, WSIZE)); B <= std_logic_vector(to_signed(1, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_signed(-2147483648, WSIZE)) REPORT "ADD failed on overflow case" SEVERITY ERROR;

        -- SUB Tests
        opcode <= "0001";
        A <= std_logic_vector(to_signed(10, WSIZE)); B <= std_logic_vector(to_signed(5, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_signed(5, WSIZE)) REPORT "SUB failed on positive case" SEVERITY ERROR;

        A <= std_logic_vector(to_signed(-10, WSIZE)); B <= std_logic_vector(to_signed(-5, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_signed(-5, WSIZE)) REPORT "SUB failed on negative case" SEVERITY ERROR;

        A <= std_logic_vector(to_signed(-2147483648, WSIZE)); B <= std_logic_vector(to_signed(1, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_signed(2147483647, WSIZE)) REPORT "SUB failed on underflow case" SEVERITY ERROR;

        -- AND Tests
        opcode <= "0010";
        A <= "00000000000000000000000000001111"; B <= "00000000000000000000000000001010"; WAIT FOR 10 ns;
        ASSERT Z = "00000000000000000000000000001010" REPORT "AND failed" SEVERITY ERROR;

        -- OR Tests
        opcode <= "0011";
        A <= "00000000000000000000000000000101"; B <= "00000000000000000000000000001010"; WAIT FOR 10 ns;
        ASSERT Z = "00000000000000000000000000001111" REPORT "OR failed" SEVERITY ERROR;

        -- XOR Tests
        opcode <= "0100";
        A <= "00000000000000000000000000001111"; B <= "00000000000000000000000000001010"; WAIT FOR 10 ns;
        ASSERT Z = "00000000000000000000000000000101" REPORT "XOR failed" SEVERITY ERROR;

        -- Shift Tests
        opcode <= "0101";
        A <= "00000000000000000000000000000001"; B <= "00000000000000000000000000000010"; WAIT FOR 10 ns;
        ASSERT Z = "00000000000000000000000000000100" REPORT "SLL failed" SEVERITY ERROR;

        opcode <= "0110";
        A <= "00000000000000000000000000001000"; B <= "00000000000000000000000000000010"; WAIT FOR 10 ns;
        ASSERT Z = "00000000000000000000000000000010" REPORT "SRL failed" SEVERITY ERROR;

        opcode <= "0111";
        A <= "10000000000000000000000000000000"; B <= "00000000000000000000000000000001"; WAIT FOR 10 ns;
        ASSERT Z = "11000000000000000000000000000000" REPORT "SRA failed" SEVERITY ERROR;

        -- SLT Tests (Set Less Than - signed)
        opcode <= "1000";
        A <= std_logic_vector(to_signed(1, WSIZE)); B <= std_logic_vector(to_signed(2, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(1, WSIZE)) REPORT "SLT failed (1 < 2)" SEVERITY ERROR;
        ASSERT cond = '1' REPORT "SLT cond failed (1 < 2)" SEVERITY ERROR;

        A <= std_logic_vector(to_signed(2, WSIZE)); B <= std_logic_vector(to_signed(1, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(0, WSIZE)) REPORT "SLT failed (2 >= 1)" SEVERITY ERROR;
        ASSERT cond = '0' REPORT "SLT cond failed (2 >= 1)" SEVERITY ERROR;

        -- SLTU Tests (Set Less Than - unsigned)
        opcode <= "1001";
        A <= std_logic_vector(to_unsigned(1, WSIZE)); B <= std_logic_vector(to_unsigned(2, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(1, WSIZE)) REPORT "SLTU failed (1 < 2)" SEVERITY ERROR;
        ASSERT cond = '1' REPORT "SLTU cond failed (1 < 2)" SEVERITY ERROR;

        A <= std_logic_vector(to_unsigned(2, WSIZE)); B <= std_logic_vector(to_unsigned(1, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(0, WSIZE)) REPORT "SLTU failed (2 >= 1)" SEVERITY ERROR;
        ASSERT cond = '0' REPORT "SLTU cond failed (2 >= 1)" SEVERITY ERROR;

        -- SGE Tests (Set Greater or Equal - signed)
        opcode <= "1010";
        A <= std_logic_vector(to_signed(2, WSIZE)); B <= std_logic_vector(to_signed(1, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(1, WSIZE)) REPORT "SGE failed (2 >= 1)" SEVERITY ERROR;
        ASSERT cond = '1' REPORT "SGE cond failed (2 >= 1)" SEVERITY ERROR;

        A <= std_logic_vector(to_signed(1, WSIZE)); B <= std_logic_vector(to_signed(2, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(0, WSIZE)) REPORT "SGE failed (1 < 2)" SEVERITY ERROR;
        ASSERT cond = '0' REPORT "SGE cond failed (1 < 2)" SEVERITY ERROR;

        -- SGEU Tests (Set Greater or Equal - unsigned)
        opcode <= "1011";
        A <= std_logic_vector(to_unsigned(2, WSIZE)); B <= std_logic_vector(to_unsigned(1, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(1, WSIZE)) REPORT "SGEU failed (2 >= 1)" SEVERITY ERROR;
        ASSERT cond = '1' REPORT "SGEU cond failed (2 >= 1)" SEVERITY ERROR;

        A <= std_logic_vector(to_unsigned(1, WSIZE)); B <= std_logic_vector(to_unsigned(2, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(0, WSIZE)) REPORT "SGEU failed (1 < 2)" SEVERITY ERROR;
        ASSERT cond = '0' REPORT "SGEU cond failed (1 < 2)" SEVERITY ERROR;

        -- SEQ Tests (Set Equal)
        opcode <= "1100";
        A <= std_logic_vector(to_signed(5, WSIZE)); B <= std_logic_vector(to_signed(5, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(1, WSIZE)) REPORT "SEQ failed (5 == 5)" SEVERITY ERROR;
        ASSERT cond = '1' REPORT "SEQ cond failed (5 == 5)" SEVERITY ERROR;

        A <= std_logic_vector(to_signed(5, WSIZE)); B <= std_logic_vector(to_signed(6, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(0, WSIZE)) REPORT "SEQ failed (5 != 6)" SEVERITY ERROR;
        ASSERT cond = '0' REPORT "SEQ cond failed (5 != 6)" SEVERITY ERROR;

        -- SNE Tests (Set Not Equal)
        opcode <= "1101";
        A <= std_logic_vector(to_signed(5, WSIZE)); B <= std_logic_vector(to_signed(6, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(1, WSIZE)) REPORT "SNE failed (5 != 6)" SEVERITY ERROR;
        ASSERT cond = '1' REPORT "SNE cond failed (5 != 6)" SEVERITY ERROR;

        A <= std_logic_vector(to_signed(5, WSIZE)); B <= std_logic_vector(to_signed(5, WSIZE)); WAIT FOR 10 ns;
        ASSERT Z = std_logic_vector(to_unsigned(0, WSIZE)) REPORT "SNE failed (5 == 5)" SEVERITY ERROR;
        ASSERT cond = '0' REPORT "SNE cond failed (5 == 5)" SEVERITY ERROR;


        -- Stop simulation
        REPORT "Testbench completed successfully!" SEVERITY NOTE;
        WAIT;
    END PROCESS;

END testbench;
