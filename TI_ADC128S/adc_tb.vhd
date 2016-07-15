library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_tb is
end entity adc_tb;

architecture RTL of adc_tb is
    signal clk  : std_ulogic;
    signal rst  : std_ulogic;
    signal soc  : std_ulogic;
    signal en   : std_ulogic;
    signal din  : std_ulogic;
    signal sclk : std_ulogic;
    signal cs_n : std_ulogic;
    signal dout : std_ulogic;
    signal done : std_ulogic;
    
    signal fifo_rd  : std_ulogic;
    signal fifo_out : std_ulogic_vector(11 downto 0);
    
    signal addr_wr : std_ulogic;
    signal addr_in : std_ulogic_vector(2 downto 0);
    signal addr_rst : std_ulogic;
    

    constant CLK_PRD  : time    := 20 ns;
    constant DIV_MAX  : natural := 7;
    constant CONV_MAX : natural := 1;

begin
    UUT : entity work.adc128s_logic
        generic map(
            DIV_MAX  => DIV_MAX,
            CONV_MAX => CONV_MAX
        )
        port map(
            clk  => clk,
            rst  => rst,
            soc  => soc,
            en   => en,
            din  => din,
            sclk => sclk,
            cs_n => cs_n,
            dout => dout,
            done => done,
            
            fifo_rd  => fifo_rd,
            fifo_out => fifo_out,
            
            addr_wr => addr_wr,
            addr_in => addr_in,
            addr_rst => addr_rst
        );

    process
    begin
        clk <= '0' after CLK_PRD / 2, '1' after CLK_PRD;
        wait for CLK_PRD;
    end process;

    process(sclk)
        variable dat : std_ulogic_vector(11 downto 0) := "100000000001";
        variable cnt : natural          := 16;
    begin
        if falling_edge(sclk) then
            if cnt = 0 then
                cnt := 15;
                dat := dat xor "010000000010";
            else
                cnt := cnt - 1;
            end if;
            if cnt < 12 then
                din <= dat(cnt);
            else
                din <= '0';
            end if;
        end if;

    end process;

    process
    begin
        rst <= '1';
        en  <= '0';
        soc <= '0';
        fifo_rd <= '0';
        wait for CLK_PRD;
        rst <= '0';
        en  <= '1';
        wait for 2 * CLK_PRD;
        soc <= '1';
        wait for CLK_PRD;
        soc <= '0';
--        wait until cs_n = '1';
        wait until rising_edge(done);
        for i in 0 to 2 loop
            fifo_rd <= '1';
            wait for CLK_PRD;
            fifo_rd <= '0';
            wait for CLK_PRD;
        end loop;
        
        wait for 5 * CLK_PRD;
        
        soc <= '1';
        wait for CLK_PRD;
        soc <= '0';
        wait until cs_n = '1';
        wait for 5 * CLK_PRD;
        
        assert false
            report "Simulation Completed"
        severity failure;
    end process;

end architecture RTL;
