----------Componenta de Instruction Decode--------------
----////////////\\\\\\\\\\\\\\\\\\-------
--------**********************--------------
---------******---------*******---------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_std.ALL;

entity ID is
 Port (  clk:in std_logic;
  instr:in std_logic_vector(15 downto 0);--instructiunea curenta
  wd:in std_logic_vector(15 downto 0);--ce se scrie in rf
  regwr,regdst,extop:in std_logic;--semnale de control
  funct:out std_logic_vector(2 downto 0);--codul pentru functie
  rd1,rd2:out std_logic_vector(15 downto 0);--rd1 si rd2 din rf
  sa:out std_logic;--bit de shiftare
  ext_imm:out std_logic_vector(15 downto 0));--imediatul extins
end ID;

architecture Behavioral of ID is

signal ra1,ra2,mux_aux:std_logic_vector(2 downto 0);--ra1,ra2--folosite pentru a lua valori din rd1 si rd2, mai precis pentru adrese
--mux_aux folosesc pentru a selecta in ce registrii pun, iau codul din instructiune pentru rs sau rt

signal imm_aux:std_Logic_vector(15 downto 0);--iesirea de la imediatul extins
signal e:std_logic;--semnal de control pentru imediatul extins

component Reg_File is-----------------Blocul de registre--------
 Port ( clk:in std_logic;
 en:in std_logic;
 ra1,ra2,wa:in std_logic_vector(2 downto 0);
 wd:in std_logic_vector(15 downto 0);
 rd1,rd2:out std_logic_vector(15 downto 0));
end component Reg_File;

begin

Register_File: Reg_File port map(clk=>clk,en=>regwr,ra1=>ra1,ra2=>ra2,wa=>mux_aux,wd=>wd,rd1=>rd1,rd2=>rd2);

process(regdst,instr)
begin
if(regdst='1') then
mux_aux<=instr(6 downto 4);
else
mux_aux<=instr(9 downto 7);
end if;
end process;

--------**********************-------------- Am pus pentru a fi mai usor de vazut componentele
---------******---------*******---------

process(e,instr)--extind cu sau fara semn, adica la ext_imm(imediatul extins)
begin
----extind imm cu sau fara semn

case(e) is
when '1'=>case(instr(6)) is
when '0'=>imm_aux<="000000000" & instr(6 downto 0);
when others=>imm_aux<="111111111" & instr(6 downto 0);
end case;
when others=>imm_aux<="000000000" & instr(6 downto 0);

end case;

end process;
-----------------------------------------------------
--------**********************--------------
---------******---------*******---------
funct<=instr(2 downto 0);--iau codul de functie din instructiune
sa<=instr(3);--iau bitul de shift

ra1<=instr(12 downto 10);--iau din instructiune rs
ra2<=instr(9 downto 7);--iau din intructiune rt

ext_imm<=imm_aux;--pun imediatul extins

------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!-----------------------------
---------------------------#################-------------------

end Behavioral;
