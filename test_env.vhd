---------Entitatea principala a proiectului
--------**********************--------------
---------******---------*******---------
-------La fiecare entitate am pus comentarii de diferentiere intre procesele importante pentru a-mi fi mai
---------usor de vazut componentele si procesele importante


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_std.ALL;


entity test_env is

Port(clk: in std_logic;
    led: out std_logic_vector(15 downto 0);
    sw:in std_logic_vector(15 downto 0);
    btn:in std_logic_vector(4 downto 0);
    an: out std_logic_vector(3 downto 0);
    cat: out std_logic_vector(6 downto 0));
end test_env;

-----------------------Arhitectura-----------------------------------------------------
-----------****************////\\\\\\\\\\\\****************----------
architecture Behavioral of test_env is

component MEM is-------Componenta memoriei de date
 Port (clk:in std_logic;
 alu_res:inout std_logic_vector(15 downto 0);
 wr_data:in std_logic_vector(15 downto 0);
 mem_wr:in std_logic;
 mem_data:out std_logic_vector(15 downto 0));
end component MEM;

signal alu_res:std_logic_vector(15 downto 0);--CE iese din EX, rezultat pentru alu
signal mem_data:std_logic_vector(15 downto 0);--Ce iese din memoria de date

component EX is--Componenta de execute
 Port (next_instr:in std_logic_vector(15 downto 0);
 rd1,rd2:in std_logic_vector(15 downto 0);
 ext_imm:in std_logic_vector(15 downto 0);
 funct:in std_logic_vector(2 downto 0);
 sa,alusrc:in std_logic;
 aluop:in std_logic_vector(2 downto 0);
branch_adr:out std_logic_vector(15 downto 0);
  alu_res:out std_logic_vector(15 downto 0);
  zero:out std_logic);
end component EX;

component ID is--Componenta de Instruction Decoder
 Port (  clk:in std_logic;
  instr:in std_logic_vector(15 downto 0);
  wd:in std_logic_vector(15 downto 0);
  regwr,regdst,extop:in std_logic;
  funct:out std_logic_vector(2 downto 0);
  rd1,rd2:out std_logic_vector(15 downto 0);
  sa:out std_logic;
  ext_imm:out std_logic_vector(15 downto 0));
end component ID;

signal rd1,rd2,wd:std_logic_vector(15 downto 0);--rs si rt, de la RF
signal functionn:std_logic_vector(2 downto 0);--Codul de functie
signal shift_amount:std_logic;--bit de shift amount

component MPG is-------MPG component
Port(en:out std_logic;
input: in std_logic;
clock:in std_logic);
end component;

component SSD is---Afisor SSD component
    Port ( clk : in STD_LOGIC;
           cif1 : in STD_LOGIC_VECTOR (3 downto 0);
           cif2 : in STD_LOGIC_VECTOR (3 downto 0);
           cif3 : in STD_LOGIC_VECTOR (3 downto 0);
           cif4 : in STD_LOGIC_VECTOR (3 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end component SSD;


component Reg_File is--Componenta blocului de registre
 Port ( clk:in std_logic;
 en:in std_logic;
 ra1,ra2,wa:in std_logic_vector(3 downto 0);
 wd:in std_logic_vector(15 downto 0);
 rd1,rd2:out std_logic_vector(15 downto 0));
end component Reg_File;

component Instruction_Fetch is--Componenta de IF
  Port (clk:in std_logic;
  branch_adr:in std_logic_vector(15 downto 0);
  jump_adr:in std_logic_vector(15 downto 0);
  jump_c:in std_logic;
  PCSrc: in std_logic;
  en_pc:in std_logic;
  rst:in std_logic;
  instr_cr:out std_logic_vector(15 downto 0);
  next_instr:out std_logic_vector(15 downto 0));
end component Instruction_Fetch;

signal rst,en_pc,sa:std_logic;--Semnalul pentru reset la numaratorul de la IF
signal br:std_logic_vector(15 downto 0):=x"0101";--Adresa de branch
signal j:std_logic_vector(15 downto 0):=x"0000";--Adresa de jump
signal rez,instr_cr,next_adr,next_inst:std_logic_vector(15 downto 0);--Instructiunea curenta, instructiunea urmatoare,
--Adresa urmatoarei instructiuni
signal regdst,extop,alusrc,branch,jump,memwrite,memtoreg,regwrite,mem_read:std_logic;
signal alu_op:std_logic_vector(2 downto 0);
signal ext_imm:std_logic_vector(15 downto 0);--Imediatul extins cu semn
signal zero:std_logic;--Semnal de 0, vad daca am zero pe iesire sau nu
signal finall:std_logic_vector(15 downto 0);--rezultatul ce iese din memoria RAM  de la MEM
signal scris:std_logic_vector(15 downto 0);--Rezultatul final multiplexat
signal pcsrc:std_logic;

begin

iff:Instruction_Fetch port map(clk=>clk,branch_adr=>br,jump_adr=>j,jump_c=>sw(0),PCSrc=>sw(1),en_pc=>en_pc,rst=>rst,instr_cr=>instr_cr,next_instr=>next_adr);

ssd_f:ssd port map(clk=>clk,cif1=>rez(3 downto 0),cif2=>rez(7 downto 4),cif3=>rez(11 downto 8),cif4=>rez(15 downto 12),an=>an,cat=>cat);

mpg_reset:MPG port map(en=>rst,input=>btn(0),clock=>clk);

mpg_pc:MPG port map(en=>en_pc,input=>btn(1),clock=>clk);

memm:MEM port map(clk=>clk,alu_res=>alu_res,wr_data=>rd2,mem_wr=>en_pc,mem_data=>mem_data);

idd:ID port map(clk=>clk,instr=>instr_cr,wd=>wd,regwr=>regwrite,regdst=>regdst,extop=>extop,funct=>functionn,rd1=>rd1,rd2=>rd2,sa=>shift_amount,ext_imm=>ext_imm);

exx:EX port map(next_instr=>next_inst,rd1=>rd1,rd2=>rd2,ext_imm=>ext_imm,funct=>functionn,sa=>sa,alusrc=>alusrc,aluop=>alu_op,branch_adr=>br,alu_res=>alu_res,zero=>zero);


--------**********************--------------
---------******---------*******---------

process(instr_cr(15 downto 13),regdst,extop,alusrc,branch,jump,alu_op,memwrite,memtoreg)--Unit Control
begin
regdst<='0';
extop<='0';
alusrc<='0';
branch<='0';
jump<='0';
memwrite<='0';
memtoreg<='0';
regwrite<='0';
alu_op<="000";
case instr_cr(15 downto 13) is

when "010"=>--lw
regwrite<='1';
alusrc<='1';
extop<='1';
memtoreg<='1';
alu_op<="010";

when "001"=>--addi
regwrite<='1';
alusrc<='1';
extop<='1';
alu_op<="001";


when "100"=>--beq
extop<='1';
branch<='1';
alu_op<="100";
alu_op<="100";

when "000"=>--intructiuni de tip R
regdst<='1';
regwrite<='1';
alu_op<="000";

when "111"=>--jump
jump<='1';
alu_op<="111";

when "011"=>--sw
alusrc<='1';
extop<='1';
memwrite<='1';
alu_op<="011";

when "110"=>--bgtz
branch<='1';
alu_op<="110";


when "101"=>--andi
regwrite<='1';
alusrc<='1';
alu_op<="101";


when others=>
regdst<='1';

end case;
end process;

--------**********************--------------
---------******---------*******---------
process(sw(7 downto 5),rd1,rd2,instr_cr,next_adr,wd)
begin
case sw(7 downto 5) is
when "000"=>rez<=instr_cr;
when "010"=>rez<=next_adr;
when "011"=>rez<=rd1;
when "100"=>rez<=rd2;
when "101"=>rez<=alu_res;
when "110"=>rez<=mem_data;
when others=>rez<=wd;
end case;
end process;

--------**********************--------------
---------******---------*******---------
PCSrc<=zero and branch;
j<=next_inst(15 downto 14) & instr_cr(13 downto 0);

--------**********************--------------
---------******---------*******---------
process(regdst,extop,alusrc,branch,jump,memwrite,memtoreg,regwrite,sw,alu_op)
begin
if sw(0)='0' then
led(7)<=regdst;
led(6)<=extop;
led(5)<=alusrc;
led(4)<=branch;
led(3)<=jump;
led(2)<=memwrite;
led(1)<=memtoreg;
led(0)<=regwrite;

else
led(2 downto 0)<=alu_op(2 downto 0);
led(7 downto 3)<="00000";
end if;
led(15)<=zero;
--------**********************--------------
---------******---------*******---------
end process;
process(finall,alu_res,memtoreg)--Componenta de Write Back
begin
case memtoreg is
when '1'=>finall<=mem_data;
when others=>finall<=alu_res;
end case;
end process;
--------**********************--------------
---------******---------*******---------

end Behavioral;
