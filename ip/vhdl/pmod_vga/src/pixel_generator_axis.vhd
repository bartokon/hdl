library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.vga_pkg.all;

entity pixel_generator_axis is
    Port (
        s_axis_tdata : in std_logic_vector(31 downto 0);
        s_axis_tvalid : in std_logic;
        s_axis_tlast : in std_logic;
        s_axis_tready : out std_logic;

        m_axis_tdata : out std_logic_vector(15 downto 0);
        m_axis_tvalid : out std_logic;
        m_axis_tlast : out std_logic;
        m_axis_tready : in std_logic;

        rstn : in std_logic;
        clk : in std_logic
    );
end pixel_generator_axis;

architecture behavioral of pixel_generator_axis is
    type STATE is (
        IDLE, -- Wait for data
        FIRST, -- GET data
        SECOND
    );
    signal state_d, state_q : STATE := IDLE;
    signal s_axis_tready_d, s_axis_tready_q : std_logic := '0';
    signal m_axis_tdata_d, m_axis_tdata_q : std_logic_vector(15 downto 0) := (others => '0');
    signal m_axis_tvalid_d, m_axis_tvalid_q : std_logic := '0';
    signal m_axis_tlast_d, m_axis_tlast_q : std_logic := '0';
begin

    STATE_COMB : process (state_q)
    begin
        state_d <= state_q;
        case (state_q) is
            when IDLE =>
                if (s_axis_tvalid = '1') then
                    state_d <= FIRST;
                end if;
            WHEN FIRST =>
                if (m_axis_tready = '1') then
                    state_d <= SECOND;
                end if;
            WHEN SECOND =>
                if (m_axis_tready = '1') then
                    if (s_axis_tvalid = '1') then
                        state_d <= FIRST;
                    else
                        state_d <= IDLE;
                    end if;
                end if;
            when others =>
                state_d <= IDLE;
        end case;
    end process;

    STATE_FF: process (clk)
    begin
        if rising_edge(clk) then
            if (rstn = '0') then
                state_q <= IDLE;
            else
                state_q <= state_d;
            end if;
        end if;
    end process;

    LOGIC_COMB : process (s_axis_tready_q, m_axis_tdata_q, m_axis_tvalid_q, m_axis_tlast_q)
    begin
        s_axis_tready_d <= s_axis_tready_q;
        m_axis_tdata_d <= m_axis_tdata_q;
        m_axis_tvalid_d <= m_axis_tvalid_q;
        m_axis_tlast_d <= m_axis_tlast_q;
        case (state_q) is
            when IDLE =>
                s_axis_tready_d <= '0';
                m_axis_tdata_d <= (others => '0');
                m_axis_tvalid_d <= '0';
                m_axis_tlast_d <= '0';
            when FIRST =>
                s_axis_tready_d <= '0';
                m_axis_tdata_d <= s_axis_tdata(15 downto 0);
                m_axis_tvalid_d <= '1';
                m_axis_tlast_d <= '0';
            when SECOND =>
                s_axis_tready_d <= m_axis_tready;
                m_axis_tdata_d <= s_axis_tdata(31 downto 16);
                m_axis_tvalid_d <= '1';
                m_axis_tlast_d <= s_axis_tlast;
            when others =>
                s_axis_tready_d <= s_axis_tready_q;
                m_axis_tdata_d <= m_axis_tdata_q;
                m_axis_tvalid_d <= m_axis_tvalid_q;
                m_axis_tlast_d <= m_axis_tlast_q;
        end case;
    end process;

    LOGIC_FF: process (clk)
    begin
        if rising_edge(clk) then
            if (rstn = '0') then
                s_axis_tready_q <= '0';
                m_axis_tdata_q <= (others => '0');
                m_axis_tvalid_q <= '0';
                m_axis_tlast_q <= '0';
            else
                s_axis_tready_q <= s_axis_tready_d;
                m_axis_tdata_q <= m_axis_tdata_d;
                m_axis_tvalid_q <= m_axis_tvalid_d;
                m_axis_tlast_q <= m_axis_tlast_d;
            end if;
        end if;
    end process;

end architecture;