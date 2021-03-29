----Componenta de executie(Execution)
------Am pus comentarii pentru a fi mai usor de vazut----------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_std.ALL;



entity EX is
 Port (next_instr:in std_logic_vector(15 downto 0);--adresa urmatoarei instructiuni de executat
 
 rd1,rd2:in std_logic_vector(15 downto 0);--rs si rt
 
 ext_imm:in std_logic_vector(15 downto 0);--*** imediatul extins
 funct:in std_logic_vector(2 downto 0);--codul de functie
 sa,alusrc:in std_logic;--bit de shift
 --comanda pentru alusrc
 aluop:in std_logic_vector(2 downto 0);--codul de  la aluop
branch_adr:out std_logic_vector(15 downto 0);--adresa de brach
  alu_res:out std_logic_vector(15 downto 0);--rezultatul de la adresa de brach
  zero:out std_logic);--vad daca am sau nu 0 la final
end EX;

---------!!!!!!!!!##########*******---------De aici incepe arhitectura

architecture Behavioral of EX is
signal in1,in2:std_logic_vector(15 downto 0);
--cu in1 si in2 iau rs si rt

signal alu_control:std_logic_vector(3 downto 0);--semal pentru alu_control

signal aluu:std_logic_vector(15 downto 0);--iesirea din alu
signal z_aux:std_logic;--vad sau nu daca am 0
signal br:std_logic_vector(15 downto 0);--adresa de brach

--------**********************--------------
---------******---------*******---------

begin
in1<=rd1;
process(alusrc)
begin
if(alusrc='1') then in2<=ext_imm;
else in2<=rd2;
end if;

end process;

--------**********************--------------
---------******---------*******---------

process(aluop,funct)
begin

case (aluop) is
when "000"=>
case (funct) is
when "000"=>alu_control<="0000";--add
when "001"=>alu_control<="0001";--sub
when "010"=>alu_control<="0010";--sll
when "011"=>alu_control<="0011";--slr
when "100"=>alu_control<="0100";--and
when "101"=>alu_control<="0101";--or
when "110"=>alu_control<="0110";--xor
when others=>alu_control<="0111";--slt
end case;

when "001"=>alu_control<="1000";--addi
when "010"=>alu_control<="1001";--lw
when "011"=>alu_control<="1010";--sw
when "100"=>alu_control<="1011";--beq
when "101"=>alu_control<="1100";--andi
when "110"=>alu_control<="1101";--bgtz
when others=>alu_control<="1111";--jump

end case;
end process;

--------**********************--------------
---------******---------*******---------

process(alu_control,in1,in2,sa)
begin
case (alu_control) is
when "0000"=>aluu<=in1+in2;--add
when "0001"=>aluu<=in1-in2;--sub
when "0010"=>case (sa) is when '1'=>aluu<=in1(14 downto 0) & '0';
when others=>aluu<=in1;--sll
end case;
when "0011"=>case (sa) is when '1'=> aluu<="0" & in1(15 downto 1) ;
when others=>aluu<=in1;--slr
end case;

when "0100"=>aluu<=in1 and in2;--and
when "0101"=>aluu<=in1 or in2;--or
when "0110"=>aluu<=in1 xor in2;--xor
when "0111"=> if(in1<in2) then aluu<=x"0001";
else aluu<=x"0000";
end if;--slt
when "1000"=>aluu<=in1+ext_imm;--addi
when "1001"=>aluu<=x"0000";--lw
when "1010"=>aluu<=x"0001";--sw
when "1011"=>--beq
if in1=in2 then
br<=next_instr+ext_imm(13 downto 0)+1;
end if;
when "1100"=>aluu<=in1 and ext_imm;--andi
when "1101"=>--bgtz
if in1>0 then
br<=next_instr+1+ext_imm(13 downto 0);
end if;
when "1110"=>aluu<=ext_imm;
when others=>aluu<=x"0000";

end case;

case aluu is 
when x"0000"=>z_aux<='1';
when others=>z_aux<='0';
end case;

end process;

--------**********************--------------
---------******---------*******---------
alu_res<=aluu;
zero<=z_aux;
end Behavioral;
