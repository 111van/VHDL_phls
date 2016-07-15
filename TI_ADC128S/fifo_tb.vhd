library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_tb is
end entity fifo_tb;

architecture RTL of fifo_tb is
    constant CLK_PRD : time    := 20 ns;
    constant STG_LEN : integer := 4;
    constant VEC_LEN : integer := 6;

    signal clk, rst : std_ulogic;
    signal wr_en    : std_ulogic;
    signal rd_en    : std_ulogic;
    signal full     : std_ulogic;
    signal empty    : std_ulogic;
    signal data_out : std_ulogic_vector(VEC_LEN - 1 downto 0);
    signal data_in  : std_ulogic_vector(VEC_LEN - 1 downto 0);
    
    procedure rw(variable dat, del, cnt : inout integer;
                 signal   wr_en, rd_en : out std_ulogic;
                 signal   data_out : out std_ulogic_vector) is
    begin
        dat      := dat - del * cnt;
        data_out <= std_ulogic_vector(to_unsigned(dat, VEC_LEN));
        wait for CLK_PRD;
        wr_en <= '1';
        rd_en <= '1';
        wait for CLK_PRD;
        wr_en <= '0';
        rd_en <= '0';
    end rw;
    
    procedure read(signal   rd_en : out std_ulogic) is
    begin
        wait for CLK_PRD;
        rd_en <= '1';
        wait for CLK_PRD;
        rd_en <= '0';
    end read;
        
    procedure write(variable dat, del, cnt : inout integer;
                    signal   wr_en : out std_ulogic;
                    signal   data_out : out std_ulogic_vector) is
    begin
        dat      := dat - del * cnt;
        data_out <= std_ulogic_vector(to_unsigned(dat, VEC_LEN));
        wait for CLK_PRD;
        wr_en <= '1';
        wait for CLK_PRD;
        wr_en <= '0';
    end write;

begin
    UUT : entity work.fifo_mem
        generic map(
            STG_LEN => STG_LEN,
            VEC_LEN => VEC_LEN
        )
        port map(
            clk   => clk,
            rst   => rst,
            wr_en => wr_en,
            rd_en => rd_en,
            full  => full,
            empty => empty,
            fin   => data_out,
            fout  => data_in
        );
    process
    begin
        clk <= '0' after CLK_PRD / 2, '1' after CLK_PRD;
        wait for CLK_PRD;
    end process;

    process
        variable dat : natural := 63;
        variable cnt : natural := 1;
        variable del : natural := 2;
    begin
        rst   <= '1';
        wr_en <= '0';
        rd_en <= '0';
        wait for CLK_PRD;
        rst <= '0';
        wait for 1.5 * CLK_PRD;

        for i in 0 to 1 loop
            read(rd_en);
        end loop;

        for i in 0 to 5 loop
            write(dat, del, cnt, wr_en, data_out);
        end loop;
        
        rw(dat, del, cnt, wr_en, rd_en, data_out);

        for i in 0 to 5 loop
            read(rd_en);
        end loop;

        for i in 0 to 2 loop
            write(dat, del, cnt, wr_en, data_out);
        end loop;
        
        rw(dat, del, cnt, wr_en, rd_en, data_out);

        for i in 0 to 1 loop
            read(rd_en);
        end loop;
        
        rw(dat, del, cnt, wr_en, rd_en, data_out);

        for i in 0 to 4 loop
            write(dat, del, cnt, wr_en, data_out);
        end loop;

        for i in 0 to 4 loop
            read(rd_en);
        end loop;

        assert false
            report "Simulation Completed"
        severity failure;

    end process;

end architecture RTL;
