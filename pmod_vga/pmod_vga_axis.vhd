library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

library work;
use work.vga_pkg.all;

entity pmod_vga_axis is
    generic (
        WIDTH : integer := 640;
        HEIGHT : integer := 480
    );
    Port (
        pixel_tdata : in std_logic_vector(15 downto 0);
        pixel_tlast : in std_logic;
        pixel_tvalid : in std_logic;
        pixel_tready : out std_logic;
        R : out std_logic_vector(3 downto 0);
        G : out std_logic_vector(3 downto 0);
        B : out std_logic_vector(3 downto 0);
        HS : out std_logic;
        VS : out std_logic;
        rstn : in std_logic;
        clk : in std_logic
    );
end pmod_vga_axis;

architecture behavioral of pmod_vga_axis is
    --HORIZONTAL CONSTANTS
    CONSTANT H_BACK_PORCH : integer := 128;
    CONSTANT H_SYNC_PULSE : integer := 40;
    CONSTANT H_FRONT_PORCH : integer := 24;
    CONSTANT HORIZONTAL_SCAN_LINES : integer := H_BACK_PORCH + WIDTH + H_FRONT_PORCH + H_SYNC_PULSE;

    --VERTICAL CONSTANTS
    CONSTANT V_BACK_PORCH : integer := 29;
    CONSTANT V_SYNC_PULSE : integer := 2;
    CONSTANT V_FRONT_PORCH : integer := 9;
    CONSTANT VERTICAL_SCAN_LINES : integer := V_BACK_PORCH + HEIGHT + V_FRONT_PORCH + V_SYNC_PULSE;

    --COUNTERS
    CONSTANT COUNTER_SIZE : integer := 10;
    signal width_counter_d, width_counter_q : unsigned(COUNTER_SIZE - 1 downto 0) := (others => '0');
    signal height_counter_d, height_counter_q : unsigned(COUNTER_SIZE - 1 downto 0) := (others => '0');

    --FSM
    type VGA_STATE is (
        IDLE,
        WORKING
    );
    signal state_d, state_q : VGA_STATE := IDLE;
    signal HS_d, HS_q : std_logic := '0';
    signal VS_d, VS_q : std_logic := '0';
    signal internal_pixel_d, internal_pixel_q : pixel := PIXEL_BLACK;
    signal rd_d, rd_q : std_logic := '0';
begin

    LOGIC_COMB: process (rd_q, HS_q, VS_q, internal_pixel_q, width_counter_q, height_counter_q)
        variable HS_on : std_logic := '0';
        variable VS_on : std_logic := '0';
        variable rd_on : std_logic := '0';
        variable sink : std_logic_vector(3 downto 0);
        variable pixel_next : pixel := PIXEL_BLACK;
    begin
        rd_d <= rd_q;
        HS_d <= HS_q;
        VS_d <= VS_q;
        internal_pixel_d <= internal_pixel_q;
        width_counter_d <= width_counter_q;
        height_counter_d <= height_counter_q;
        case (state_q) is
            when IDLE =>
                rd_d <= '0';
                HS_d <= '0';
                VS_d <= '0';
                width_counter_d <= (others => '0');
                height_counter_d <= (others => '0');
                internal_pixel_d <= PIXEL_BLACK;

            when WORKING =>
                --COUNTER LOGIC
                if (width_counter_q < HORIZONTAL_SCAN_LINES) then
                    width_counter_d <= unsigned(width_counter_q) + 1;
                else
                    width_counter_d <= (others => '0');
                end if;

                if (width_counter_q >= HORIZONTAL_SCAN_LINES) then
                    if (height_counter_q < VERTICAL_SCAN_LINES) then
                        height_counter_d <= unsigned(height_counter_q) + 1;
                    else
                        height_counter_d <= (others => '0');
                    end if;
                end if;

                --SYNC LOGIC
                --pixel_tdata 15 downto 12 NOT USED
                sink := pixel_tdata(15 downto 12);
                pixel_next.red   := pixel_tdata(11 downto 8);
                pixel_next.green := pixel_tdata(7 downto  4);
                pixel_next.blue  := pixel_tdata(3 downto  0);

                HS_on := '1';
                if (width_counter_q < H_BACK_PORCH) then
                    pixel_next := PIXEL_BLACK;
                end if;
                if (width_counter_q >= WIDTH and width_counter_q < (WIDTH + H_FRONT_PORCH)) then
                    pixel_next := PIXEL_BLACK;
                end if;
                if (width_counter_q >= (WIDTH + H_FRONT_PORCH) and width_counter_q < (WIDTH + H_FRONT_PORCH + H_SYNC_PULSE)) then
                    pixel_next := PIXEL_BLACK;
                    HS_on := '0';
                end if;

                VS_on := '1';
                if (height_counter_q < V_BACK_PORCH) then
                    pixel_next := PIXEL_BLACK;
                end if;
                if (height_counter_q >= HEIGHT and height_counter_q < (HEIGHT + V_FRONT_PORCH)) then
                    pixel_next := PIXEL_BLACK;
                end if;
                if (height_counter_q >= (HEIGHT + V_FRONT_PORCH) and height_counter_q < (HEIGHT + V_FRONT_PORCH + V_SYNC_PULSE)) then
                    pixel_next := PIXEL_BLACK;
                    VS_on := '0';
                end if;

                --IN ACTIVE VIDEO
                if  ((width_counter_q >= H_BACK_PORCH and width_counter_q < WIDTH) and
                    (height_counter_q >= V_BACK_PORCH and height_counter_q < HEIGHT))
                then
                    rd_d <= '1';
                else
                    rd_d <= '0';
                end if;

                HS_d <= HS_on;
                VS_d <= VS_on;
                internal_pixel_d <= pixel_next;

            when others =>
                rd_d <= '0';
                HS_d <= '0';
                VS_d <= '0';
                width_counter_d <= (others => '0');
                height_counter_d <= (others => '0');
                internal_pixel_d <= PIXEL_BLACK;
        end case;

    end process;

    LOGIC_FF: process (clk) begin
        if rising_edge(clk) then
            if (rstn = '0') then
                rd_q <= '0';
                width_counter_q <= (others => '0');
                height_counter_q <= (others => '0');
                internal_pixel_q <= PIXEL_BLACK;
                HS_q <= '0';
                VS_q <= '0';
            else
                rd_q <= rd_d;
                HS_q <= HS_d;
                VS_q <= VS_d;
                width_counter_q <= width_counter_d;
                height_counter_q <= height_counter_d;
                internal_pixel_q <= internal_pixel_d;
            end if;
        end if;
    end process;

    STATE_COMB: process (state_q) begin
        state_d <= state_q;
        case (state_q) is
            when IDLE =>
                if (pixel_tvalid = '1') then
                    state_d <= WORKING;
                end if;
            when WORKING =>
                if (pixel_tlast = '1') then
                    state_d <= IDLE;
                end if;
            when others =>
                state_d <= IDLE;
        end case;
    end process;

    STATE_FF: process (clk) begin
        if rising_edge(clk) then
            if (rstn = '0') then
                state_q <= IDLE;
            else
                state_q <= state_d;
            end if;
        end if;
    end process;

    pixel_tready <= rd_q;
    HS <= HS_q;
    VS <= VS_q;
    R <= internal_pixel_q.red;
    G <= internal_pixel_q.green;
    B <= internal_pixel_q.blue;

end architecture;