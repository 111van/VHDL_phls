-- altera vhdl_input_version vhdl_2008

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adc_int is
    port(
        avs_s0_address     : in  std_logic_vector(7 downto 0)  := (others => '0'); --   avs_s0.address
        avs_s0_read        : in  std_logic                     := '0'; --         .read
        avs_s0_readdata    : out std_logic_vector(31 downto 0); --         .readdata
        avs_s0_write       : in  std_logic                     := '0'; --         .write
        avs_s0_writedata   : in  std_logic_vector(31 downto 0) := (others => '0'); --         .writedata
        avs_s0_waitrequest : out std_logic; --         .waitrequest
        clock_clk          : in  std_logic                     := '0'; --    clock.clk
        reset_reset        : in  std_logic                     := '0'; --    reset.reset
        ins_irq0_irq       : out std_logic; -- ins_irq0.irq

        sclk               : out std_ulogic;
        dout               : out std_ulogic;
        cs_n               : out std_ulogic;
        din                : in std_ulogic
    );
end entity adc_int;

architecture rtl of adc_int is
    signal adc_soc  : std_ulogic;
    signal en, done : std_ulogic;
    signal echo     : std_logic_vector(31 downto 0):= (others => '0');
    
    signal fifo_rd  : std_ulogic;
    signal fifo_out : std_ulogic_vector(11 downto 0);

    constant DIV_MAX  : natural := 15;
    constant CONV_MAX : natural := 3;

begin
    adc128s_logic_inst : entity work.adc128s_logic
        generic map(
            DIV_MAX  => DIV_MAX,
            CONV_MAX => CONV_MAX
        )
        port map(
            clk  => clock_clk,
            rst  => reset_reset,
            soc  => adc_soc,
            en   => en,
            din  => din,
            sclk => sclk,
            cs_n => cs_n,
            dout => dout,
            done => done,
            
            fifo_rd  => fifo_rd,
            fifo_out => fifo_out
        );

    avs_s0_waitrequest <= '0';
    ins_irq0_irq       <= done;

    en      <= '1';
    adc_soc <= '1' when ((avs_s0_address(3 downto 0) = "0000") and (avs_s0_write = '1')) else '0';

    process(clock_clk) is
    begin
        if rising_edge(clock_clk) then
            if reset_reset = '1' then
                null;
            else
                if adc_soc = '1' then
                    echo <= avs_s0_writedata;
                end if;
            end if;
        end if;
    end process;
    
    process(all)
    begin
        if avs_s0_read = '1' then
            avs_s0_readdata <= echo;
        else
            avs_s0_readdata <= (others => '0');
        end if;
--        avs_s0_readdata <= echo when avs_s0_read = '1' else (others => '0');
    end process;

end architecture rtl;