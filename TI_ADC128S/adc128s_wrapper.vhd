library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adc_int is
    port(
        avs_s0_address     : in  std_logic_vector(7 downto 0)  := (others => '0'); --   avs_s0.address
        avs_s0_read        : in  std_logic                     := '0';             --         .read
        avs_s0_readdata    : out std_logic_vector(31 downto 0);                    --         .readdata
        avs_s0_write       : in  std_logic                     := '0';             --         .write
        avs_s0_writedata   : in  std_logic_vector(31 downto 0) := (others => '0'); --         .writedata
        avs_s0_waitrequest : out std_logic;                                        --         .waitrequest
        clock_clk          : in  std_logic                     := '0';             --    clock.clk
        reset_reset        : in  std_logic                     := '0';             --    reset.reset
        ins_irq0_irq       : out std_logic -- ins_irq0.irq
    );
end entity adc_int;

architecture rtl of adc_int is
begin

    -- TODO: Auto-generated HDL template

    avs_s0_readdata <= "00000000000000000000000000000000";

    avs_s0_waitrequest <= '0';

    ins_irq0_irq <= '0';

end architecture rtl;