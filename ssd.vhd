


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity SSD is
    Port ( clk : in STD_LOGIC;
           cif1 : in STD_LOGIC_VECTOR (3 downto 0);
           cif2 : in STD_LOGIC_VECTOR (3 downto 0);
           cif3 : in STD_LOGIC_VECTOR (3 downto 0);
           cif4 : in STD_LOGIC_VECTOR (3 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end SSD;

architecture Behavioral of SSD is
signal cnt:std_logic_vector(15 downto 0);
signal sel:std_logic_vector(1 downto 0);
signal m1:std_logic_vector(3 downto 0);
signal m2:std_logic_vector(3 downto 0);
signal dcd:std_logic_vector(6 downto 0);



begin
sel<=cnt(15 downto 14);

process(clk)
begin
if rising_edge(clk) then
cnt<=cnt+1;
end if;
end process;

process(cif1,cif2,cif3,cif4)
begin
case sel is
when "00"=>m1<=cif1;
when "01"=>m1<=cif2;
when "10"=>m1<=cif3;
when others=>m1<=cif4;
end case;
end process;

process(m1) --Decoficator BCD: ce se afiseaza pe placa
begin
case m1 is
when "0000"=>dcd<="1000000";--0
when "0001"=>dcd<="1111001";--1
when "0010"=>dcd<="0100100";--2
when "0011"=>dcd<="0110000";--3
when "0100"=>dcd<="0011001";--4
when "0101"=>dcd<="0010010";--5
when "0110"=>dcd<="0000010";--6
when "0111"=>dcd<="1111000";--7
when "1000"=>dcd<="0000000";--8
when "1001"=>dcd<="0010000";--9
when "1010"=>dcd<="0001000";--A
when "1011"=>dcd<="0000011";--b
when "1100"=>dcd<="1000110";--C
when "1101"=>dcd<="0100001";--d
when "1110"=>dcd<="0000110";--E
when others=>dcd<="0001110";--F
end case;
end process;

cat<=dcd;

process(sel)
begin
case sel is
when "00"=>m2<="1110";
when "01"=>m2<="1101";
when "10"=>m2<="1011";
when others=>m2<="0111";
end case;
end process;

an<=m2;

end Behavioral;
