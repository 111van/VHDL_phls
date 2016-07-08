library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc128s_logic is
    generic(
        DIV_MAX  : natural range 1 to 255 := 2;
        CONV_MAX : natural                := 7
    );

    port(
        clk  : in  std_ulogic;
        rst  : in  std_ulogic;
        soc  : in  std_ulogic;
        en   : in  std_ulogic;
        din  : in  std_ulogic;
        sclk : out std_ulogic;
        cs_n : out std_ulogic;
        dout : out std_ulogic;
        done : out std_ulogic
    );
end entity adc128s_logic;

architecture RTL of adc128s_logic is
    type state_type is (s_reset, s_idle, s_conv, s_done);

    subtype chn is std_ulogic_vector(2 downto 0);
    type chn_list is array (CONV_MAX + 1 downto 0) of chn;

    subtype rlt is std_ulogic_vector(11 downto 0);
    type rlt_list is array (CONV_MAX + 1 downto 0) of rlt;

    signal state    : state_type;
    
    -- Lists
    signal chn_conv : chn_list;
    signal rlt_conv : rlt_list;
    
    -- Counters
    signal div_cnt  : natural range 0 to DIV_MAX;
    signal sclk_cnt : natural range 0 to 31;
    signal conv_cnt : natural range 0 to CONV_MAX + 2;
    signal sclk_r   : natural range 0 to 16;
    signal sclk_f   : natural range 0 to 15;
    
    -- Flags
    signal run      : std_ulogic;
    signal rw_al    : std_ulogic;

begin
    -- For debug: channel list initialization
    CHN_INIT:for i in 0 to CONV_MAX + 1 generate
    begin
        chn_conv(i) <= "101";
    end generate CHN_INIT;
    
    -- Next state logic
    NSL : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= s_reset;
            else
                case state is
                    when s_reset =>
                        state <= s_idle;
                    when s_idle =>
                        if (en = '1') and (soc = '1') then
                            state <= s_conv;
                        else
                            state <= s_idle;
                        end if;
                    when s_conv =>
                        if (conv_cnt = CONV_MAX + 1) and (div_cnt = 0) and (sclk_cnt = 31) then
                            state <= s_done;
                        else
                            state <= s_conv;
                        end if;
                    when s_done =>
                        state <= s_idle;
                end case;
            end if;
        end if;
    end process NSL;

    -- State machine output
    SMO : process(state)
    begin
        case state is
            when s_reset =>
                run <= '0';
                rw_al <= '0';
                done <= '0';
            when s_idle =>
                run <= '0';
                rw_al <= '1';
                done <= '0';
            when s_conv =>
                run <= '1';
                rw_al <= '0';
                done <= '0';
            when s_done =>
                run <= '0';
                rw_al <= '0';
                done <= '1';
        end case;
    end process SMO;

    -- Clock divider
    CDI : process(clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                div_cnt <= 0;
            elsif (en = '1') and (run = '1') then
                if div_cnt = DIV_MAX then
                    div_cnt <= 0;
                else
                    div_cnt <= div_cnt + 1;
                end if;
            end if;
        end if;
    end process CDI;

    -- SCLK generation
    SCL : process(clk)
        variable sclk_var : std_ulogic := '1';
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cs_n     <= '1';
                sclk_var := '1';
                sclk_cnt <= 0;
                sclk_r <= 0;
                sclk_f <= 0;
            elsif (run = '1') then
                cs_n <= '0';
                if div_cnt = 0 then
                    sclk_var := not sclk_var;
                    if sclk_var = '1' then
                        sclk_r <= 0 when sclk_r = 15 else sclk_r + 1;
                    end if;
                    if sclk_var = '0' then
                        sclk_f <= 0 when sclk_f = 15 else sclk_f + 1;
                    end if;
                    if sclk_cnt = 31 then
                        sclk_cnt <= 0;
                        conv_cnt <= conv_cnt + 1;
                    else
                        sclk_cnt <= sclk_cnt + 1;
                    end if;
                end if;
            else
                cs_n <= '1';
                conv_cnt <= 0;
            end if;
        end if;
        sclk <= sclk_var;
    end process SCL;
    
    -- ADC IO
    AIO : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                dout <= '0';
            else
                if true then
                    case sclk_f is
                    when 3 =>
                        dout <= chn_conv(conv_cnt)(2);
                    when 4 =>
                        dout <= chn_conv(conv_cnt)(1);
                    when 5 =>
                        dout <= chn_conv(conv_cnt)(0);
                    when others =>
                        dout <= '0';
                    end case;
                    if (div_cnt = 0) and (sclk_f = sclk_r) then
                        rlt_conv(conv_cnt)(15 - sclk_f) <= din when sclk_f > 3;
                    end if;
                else
                    dout<= '0';
                end if;
            end if;
        end if;
    end process AIO;
    

end architecture RTL;
