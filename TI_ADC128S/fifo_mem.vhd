-- altera vhdl_input_version vhdl_2008

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_mem is
    generic (
        STG_LEN : natural := 8;
        VEC_LEN : natural := 16
    );
    port (
        clk : in std_ulogic;
        rst : in std_ulogic;
        
        wr_en : in std_ulogic;
        rd_en : in std_ulogic;
        full : out std_ulogic;
        empty : out std_ulogic;
        
        fin : in std_ulogic_vector(VEC_LEN - 1 downto 0);
        fout : out std_ulogic_vector(VEC_LEN - 1 downto 0)
    );
end entity fifo_mem;

architecture RTL of fifo_mem is
    
    signal ptr_wr : integer range 0 to STG_LEN - 1 := 0;
    signal ptr_rd : integer range 0 to STG_LEN - 1 := 0;
    signal stop_fl : std_ulogic;
    
    type mem_t is array (STG_LEN - 1 downto 0) of std_ulogic_vector(VEC_LEN - 1 downto 0);
    
    function init_fifo
        return mem_t is 
        variable tmp : mem_t := (others => (others => '0'));
    begin 
        for ptr in 0 to STG_LEN - 1 loop 
            tmp(ptr) := std_ulogic_vector(to_unsigned(ptr, VEC_LEN));
        end loop;
        return tmp;
    end init_fifo;
    
--    signal mem : mem_t := (others => (others => '0'));
    signal mem : mem_t := init_fifo;
    
begin
    
    process (all)
    begin
        full <= '1' when (ptr_wr = ptr_rd) and (stop_fl = '1') else '0';
        empty <= '1' when (ptr_wr = ptr_rd) and (stop_fl = '0') else '0';
    end process;
    
    RWL : process (clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                fout <= (others => '0');
                ptr_wr <= 0;
                ptr_rd <= 0;
                stop_fl <= '0';
            else
                if (wr_en = '1') and (full = '0') then
                    mem(ptr_wr) <= fin;
                    ptr_wr <= 0 when ptr_wr = (STG_LEN - 1) else (ptr_wr + 1);
                    stop_fl <= '1';
                end if;
                if (rd_en = '1') and (empty = '0') then
                    fout <= mem(ptr_rd);
                    ptr_rd <= 0 when ptr_rd = (STG_LEN - 1) else (ptr_rd + 1);
                    stop_fl <= '0';
                end if;
            end if;
        end if;
    end process RWL;

end architecture RTL;
