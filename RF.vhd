-------------Blocul de registre-------------
--------**********************--------------
---------******---------*******---------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_std.ALL;



entity Reg_File is
 Port ( clk:in std_logic;
 en:in std_logic;
 ra1,ra2,wa:in std_logic_vector(2 downto 0);
 wd:in std_logic_vector(15 downto 0);
 rd1,rd2:out std_logic_vector(15 downto 0));
end Reg_File;

architecture Behavioral of Reg_File is
type mem is array (0 to 15) of std_logic_vector(15 downto 0);
signal rf:mem:=("0000000000001010","0000000000001111",others=>x"0001");

begin

process(clk,en)
begin
  if(rising_edge(clk)  ) then
  if en='1' then
       rf(conv_integer(wa))<=wd;
     end if;
end if;
end process;

rd1<=rf(conv_integer(ra1));
rd2<=rf(conv_integer(ra2));

end Behavioral;
