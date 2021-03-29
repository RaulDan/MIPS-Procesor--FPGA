---------------Memoria de date-----------
--------**********************--------------
---------******---------*******---------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_std.ALL;



entity MEM is
 Port (clk:in std_logic;--semnal de clock
 alu_res:inout std_logic_vector(15 downto 0);--Semnal de intrare si iesire
 wr_data:in std_logic_vector(15 downto 0);--Data care se scrie in memorie
 mem_wr:in std_logic;--semnal validare scriere in memorie
 mem_data:out std_logic_vector(15 downto 0));--ce iese din memorie
end MEM;

architecture Behavioral of MEM is

type ram is array(0 to 100) of std_logic_vector(15 downto 0);
--Memoria de data contine:7,1,2,5,4,3,1,7,5,8
signal m_ram:ram:=(x"0111",x"0001",x"0010",x"0101",x"0100",x"0011",x"0001",x"0111",x"0101",x"1000",others=>x"1111");
signal adr:std_logic_vector(15 downto 0);

begin
adr<=alu_res;
process(clk)
begin

if rising_edge(clk) then 
if(mem_wr='1') then
m_ram(conv_integer(adr))<=wr_data;--scriere in memorie
end if;
end if;

mem_data<=m_ram(conv_integer(adr));--citire din memorie
end process;



end Behavioral;
