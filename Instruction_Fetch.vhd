
    
    
    
    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_ARITH.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;
    use IEEE.NUMERIC_std.ALL;
    
    
    entity Instruction_Fetch is
      Port (clk:in std_logic;
      branch_adr:in std_logic_vector(15 downto 0);--Adresa de branch
      jump_adr:in std_logic_vector(15 downto 0);--Adresa de jump
      jump_c:in std_logic;--Semnal de control pentru Jump
      PCSrc: in std_logic;--Semnal de control pentru branch
      en_pc:in std_logic;--Semnal de write_enable pentru pc
      rst:in std_logic;--Semnal de validare pentru reset
      instr_cr:out std_logic_vector(15 downto 0);--Instructiunea curenta care se executa
      next_instr:out std_logic_vector(15 downto 0));--Pc=next_instr
    end Instruction_Fetch;
    
    architecture Behavioral of Instruction_Fetch is
    
    
    type rom is array (0 to 255) of std_logic_vector(15 downto 0);
    signal mrom:rom:=(B"000_000_000_001_0_000", --add $1,$0,$0
                      B"000_000_000_010_000",   --add $2,$0,$0 
                      B"001_000_011_0000001",--addi $3,$0,1
                      B"000_000_000_100_0_000",--add $4,$0,$0
                      B"001_000_101_0000000",--addi $5,$0,0
                      B"001_000_110_0001001",--addi $6,$0,9 Revin la 99
                      B"100_101_110_0100010",--beq 5,6,34(exit adress)
                      B"010_111_110_0000000",--iau din memorie                      
                      B"000_111_101_111_0_000",--add 7,7,5
                      B"010_111_110_0000000",--lw 6,0(7)
                      B"011_111_110_0000000",--sw 6,0(7)
                      B"010_111_110_0000000",--lw 6,0(7)
                      B"100_101_001_0010000",--beq 5,1,16
                      B"001_101_101_0000001",--addi r5,r5,1
                      B"001_000_110_0001010",--addi r6,r0,10
                      B"111_0000000000110",--j adesa 6, inceput for
                      B"001_000_111_0000001",--addi r7,r0,1
                      B"101_110_111_0000001",--andi r7,r6,1
                      B"001_000_110_0000001",--addi r6,r0,1
                      B"100_110_111_0011001",--beq r6,r7,impar
                      B"010_111_110_0000000",--iau din memorie
                      B"000_111_101_111_0_000",--add r7,r57,r5
                      B"010_111_110_0000000",--lw r6,0(r7)
                      B"000_100_110_100_0_000",--add r4,r6,r4-- adun la suma daca e numar par
                      B"111_0011101",--jmp 29(calculez urm index si urm fib)
                      B"010_111_110_0000000",--iau din memorie
                      B"000_111_101_111_0_000",--add r7,r7,r5
                      B"010_111_110_0000000",--lw r6,0(r7)
                      B"000_100_110_100_0_001",--sub r4,r4,r6
                      B"001_101_101_0000001",--addi r5,r5,1, cresc indicele din vector
                      B"000_010_011_001_0_000",--add r1,r2,r4,calculez urmatorul numar din fibonacci
                      B"000_000_011_010_0_000",--add r3,r0,r1
                      B"000_000_001_011_0_000",--add r3,r0,r1  
                      B"001_000_110_0001001",--addi r6,r0,9
                      B"111_0000000000110",--jump et(6) inceput for                   
                      B"110_0000000110111",--bgtz 39
                      B"001_000_101_0000001",--addi r5,r0,1
                      B"000_000_101_101_0_001",--sub r5,r0,r5, punn -1 in r5
                      B"000_100_101_100_0_110",--xor r4,r4,r5
                      B"001_100_100_0000001",--addi r4,r4,1
                      others => X"0000");                                                                                                                                                                                                                
    signal aux,pc_aux,d,nextt:std_logic_vector(15 downto 0);
    
    begin
    
   process(jump_c,aux,jump_adr)
   begin
   case jump_c is
   when '0'=>nextt<=aux;
   when '1'=>nextt<=jump_adr;
   end case;
   end process;
   
   process(PCSrc,pc_aux,branch_adr)
   begin
    
    case(PCSrc) is
    when '0'=>aux<=pc_aux;
    when '1'=>aux<=branch_adr;
    end case;
 
   end process;
   
   process(clk,rst,en_pc)
   begin
   if rst='1' then
   d<=x"0000";
   elsif rising_edge(clk)  and en_pc='1' 
   then d<=nextt;
   end if; 
   end process;
   
   instr_cr<=mrom(conv_integer(d));
   
   pc_aux<=d+'1';
   
   next_instr<=pc_aux;
   
   end Behavioral;
