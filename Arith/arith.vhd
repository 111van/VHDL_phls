library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
 
entity arith is
  port (
    rst     : in std_logic;
    clk     : in std_logic;
    i_a     : in signed(15 downto 0);
    i_b     : in signed(15 downto 0);
	
	o_s     : out signed(31 downto 0);
	o_p     : out signed(31 downto 0)
    );
end arith;
 
architecture arch of arith is
         
begin

  process (clk, rst)
  begin
    if rst = '1' then
      o_s <= (others => '0');
      o_p <= (others => '0');
    elsif rising_edge(clk) then
      o_s <= resize((i_a + i_b), o_s'length);
      o_p <= i_a * i_b;
    end if;
  end process;
 
end arch;