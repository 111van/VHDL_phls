-- Arith_test.vhd

-- This file was auto-generated as a prototype implementation of a module
-- created in component editor.  It ties off all outputs to ground and
-- ignores all inputs.  It needs to be edited to make it do something
-- useful.
-- 
-- This file will not be automatically regenerated.  You should check it in
-- to your version control system if you want to keep it.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Arith_test is
    port(
        avs_s0_address     : in  std_logic_vector(7 downto 0)  := (others => '0'); -- avs_s0.address
        avs_s0_read        : in  std_logic                     := '0'; --       .read
        avs_s0_readdata    : out std_logic_vector(31 downto 0); --       .readdata
        avs_s0_write       : in  std_logic                     := '0'; --       .write
        avs_s0_writedata   : in  std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
        avs_s0_waitrequest : out std_logic; --       .waitrequest
        clock_clk          : in  std_logic                     := '0'; --  clock.clk
        reset_reset        : in  std_logic                     := '0' --  reset.reset
    );
end entity Arith_test;

architecture rtl of Arith_test is
    signal op_a, op_b         : signed(15 downto 0);
    signal result_s, result_p : signed(31 downto 0);
    signal wr_op_a, wr_op_b   : boolean;

begin
    unit : entity work.arith
        port map(clk => clock_clk, rst => reset_reset,
                 i_a => op_a, i_b => op_b, o_s => result_s, o_p => result_p);

    avs_s0_waitrequest <= '0';
    wr_op_a            <= (avs_s0_address(3 downto 0) = "0000") and (avs_s0_write = '1');
    wr_op_b            <= (avs_s0_address(3 downto 0) = "0001") and (avs_s0_write = '1');

    process(clock_clk, reset_reset)
    begin
        if reset_reset = '1' then
            op_a <= (others => '0');
            op_b <= (others => '0');
        elsif rising_edge(clock_clk) then
            if wr_op_a then
                op_a <= resize(signed(avs_s0_writedata), op_a'length);
            end if;
            if wr_op_b then
                op_b <= resize(signed(avs_s0_writedata), op_b'length);
            end if;
        end if;
    end process;

    process(all)
    begin
        if avs_s0_read = '1' then
            case avs_s0_address(3 downto 0) is
                when "0010" => avs_s0_readdata <= std_logic_vector(result_s);
                when "0011" => avs_s0_readdata <= std_logic_vector(result_p);
                when others => avs_s0_readdata <= (others => '0');
            end case;
        else
            avs_s0_readdata <= (others => '0');
        end if;
    end process;

end architecture rtl;
