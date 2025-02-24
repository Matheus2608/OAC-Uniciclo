library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv is
    port (
    	clock : in std_logic
    );
end entity riscv;

architecture arch of riscv is
    -- signals
    signal pc_out, mux_pc_out, branch_pc, pc_plus_four, pc_jalr, immediate_vector : std_logic_vector(31 downto 0);
    signal instruction, data_mem_or_pc_plus_four_out, mux_pc_out_after_jalr_mux : std_logic_vector(31 downto 0);
    signal read_data1, read_data2, mux_ula_outB, mux_ula_outA1, mux_ula_outA2, ula_out, mem_data_out, mux_data_mem_out : std_logic_vector(31 downto 0);
    signal immediate : signed(31 downto 0);
    signal mem_write, alu_src, reg_write, mem_to_reg, branch_out : std_logic;
    signal alu_op_out : std_logic_vector(1 downto 0);
    signal ula_control_out : std_logic_vector(3 downto 0);
    signal ula_cond_out : std_logic;
    signal byte_en, sgn_en : std_logic;
    signal sel_pc, is_byte_en, is_read_signed, sel_mux_pc_plus_four : std_logic;
    signal is_lui, is_auipc, is_jal, is_jalr : std_logic;

    -- components
    component ula
        generic (wsize : natural := 32);
        port (
            opcode : in std_logic_vector(3 downto 0);
            a, b   : in std_logic_vector(wsize-1 downto 0);
            z      : out std_logic_vector(wsize-1 downto 0);
            cond   : out std_logic
        );
    end component;


    component rom 
        port (
    	    clock : in std_logic;
    	    address : in std_logic_vector(10 downto 0);
    	    dataout : out std_logic_vector(31 downto 0)
        );
    end component;

    component XREGS 
        port ( 
            clk, wren   : in  STD_LOGIC;
            rs1, rs2, rd   : in  STD_LOGIC_VECTOR (4 downto 0);
            data  : in  STD_LOGIC_VECTOR (31 downto 0);
            ro1, ro2   : out STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;

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
    
    component pc
        port (
            addr_in  : in  std_logic_vector(31 downto 0);
            clk      : in  std_logic;
            addr_out : out std_logic_vector(31 downto 0) := x"00000000"
        );
    end component;

    component mux2_1
        port (
    	    sel : in std_logic;
	    A, B : in std_logic_vector(31 downto 0);
    	    Z : out std_logic_vector(31 downto 0)
        );
    end component;


    component genImm32
        port (
            instr : in  std_logic_vector(31 downto 0);
            imm32 : out signed(31 downto 0)
        );
    end component;

    component adder 
        port (
            A : in std_logic_vector(31 downto 0);
            B : in std_logic_vector(31 downto 0);
            Z : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component control
        PORT (
            op : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
            branch : OUT STD_LOGIC;
            memToReg : OUT STD_LOGIC;
            auipc : OUT STD_LOGIC;
            jal : OUT STD_LOGIC;
	    jalr : OUT STD_LOGIC; 
	    lui : OUT STD_LOGIC; 
            aluOp : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
            memWrite : OUT STD_LOGIC;
            aluSrc : OUT STD_LOGIC;
            regWrite : OUT STD_LOGIC
        );
    END component;

    begin
    ulaRV : ula
        port map (
            opcode =>  ula_control_out,
            a      =>   mux_ula_outA2,
	    b      =>   mux_ula_outB,
            z      =>   ula_out,
            cond   =>   ula_cond_out
        );

    mux_ula_entryb : mux2_1 
        port map (
    	    sel => alu_src,
	    A   => read_data2,
	    B   => immediate_vector,
	    Z   => mux_ula_outB
        );
    
    mux_ula_entrya1 : mux2_1 
        port map (
    	    sel => is_auipc,
	    A   => read_data1,
	    B   => pc_out,
	    Z   => mux_ula_outA1
        );

    mux_ula_entrya2 : mux2_1 
        port map (
    	    sel => is_lui,
	    A   => mux_ula_outA1,
	    B   => (others => '0'),
	    Z   => mux_ula_outA2
        );

    instruction_mem : rom
        port map (
    	    clock   => clock,
    	    address => pc_out(12 downto 2),
    	    dataout => instruction
        );

    registers : XREGS
        port map ( 
            clk    => clock,
	    wren   => reg_write,
            rs1   => instruction(19 downto 15),
	    rs2    => instruction(24 downto 20),
	    rd     => instruction(11 downto 7),
            data   => data_mem_or_pc_plus_four_out,
	    ro1    => read_data1,
	    ro2    => read_data2
        );

    mux_data_mem : mux2_1 
        port map (
    	    sel => mem_to_reg,
	    A   => ula_out,
	    B   => mem_data_out,
	    Z   => mux_data_mem_out
        );

    mux_pc_plus_four : mux2_1 
        port map (
    	    sel => sel_mux_pc_plus_four,
	    A   => mux_data_mem_out,
	    B   => mem_data_out,
	    Z   => data_mem_or_pc_plus_four_out
        ); 

    data_mem : ram_rv
        port map (
            clck    => clock,
            we      => mem_write,
            byte_en => is_byte_en,
            sgn_en  => is_read_signed,
            address => ula_out(14 downto 2),
            datain  => read_data2,
            dataout => mem_data_out
        );

    pv_rv : pc
        port map (
            addr_in  => mux_pc_out_after_jalr_mux,
            clk      => clock,
            addr_out => pc_out
        );

    mux_pc : mux2_1
        port map (
    	    sel => sel_pc,
	    A   => pc_plus_four,
	    B   => branch_pc,
    	    Z   => mux_pc_out
        );


    imm : genImm32
        port map (
            instr => instruction,
            imm32 => immediate
        );

    adder_branch : adder 
        port map (
            A => pc_out,
            B => immediate_vector,
            Z => branch_pc
        );

    adder_plus_four : adder
        port map (
            A => pc_out,
            B => std_logic_vector(to_unsigned(4, 32)),
            Z => pc_plus_four
        );   

    control_rv : control
        port map (
            op       => instruction(6 downto 0),
            branch   => branch_out,
            memToReg => mem_to_reg,
            auipc    => is_auipc,
            jal      => is_jal,
            aluOp    => alu_op_out,
            memWrite => mem_write,
            aluSrc   => alu_src,
            regWrite => reg_write
        );

    mux_jalr : mux2_1 
        port map (
    	    sel => is_jalr,
	    A   => mux_pc_out,
	    B   => pc_jalr,
	    Z   => mux_pc_out_after_jalr_mux
        );
    
    immediate_vector <= std_logic_vector(resize(immediate, 32));
    sel_pc <= (is_jal or is_jalr) or (branch_out and ula_cond_out);
    is_byte_en <= '1' when instruction(6 downto 0) = "0000011" or instruction(6 downto 0) = "0100011" else '0';
    is_read_signed <= '1' when instruction(6 downto 0) = "0000011" and instruction(14 downto 12) = "100" else '0';
    
    pc_jalr <= mux_pc_out(31 downto 1) & '0';
    sel_mux_pc_plus_four <= is_auipc or is_lui;

end arch;
