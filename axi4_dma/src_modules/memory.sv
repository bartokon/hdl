module memory #(
    parameter int unsigned DEPTH = 8,
    parameter int unsigned DATA_SIZE = 32
) (
    input logic [$clog2(DEPTH) - 1 : 0] addra,
    input logic [DATA_SIZE - 1 : 0] dina,
    input logic [DATA_SIZE / 8 - 1 : 0 ] wea,

    input logic [$clog2(DEPTH) - 1 : 0] addrb,
    output logic [DATA_SIZE -1 : 0] doutb,

    input logic clk,
    input logic rst
);
   // xpm_memory_sdpram: Simple Dual Port RAM
   // Xilinx Parameterized Macro, version 2024.2
    localparam read_latency = 1;
    xpm_memory_sdpram #(
      .ADDR_WIDTH_A($clog2(DEPTH)),   // DECIMAL
      .ADDR_WIDTH_B($clog2(DEPTH)),   // DECIMAL
      .AUTO_SLEEP_TIME(0),            // DECIMAL
      .BYTE_WRITE_WIDTH_A(8),         // DECIMAL
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CLOCKING_MODE("common_clock"), // String
      .ECC_BIT_RANGE("7:0"),          // String
      .ECC_MODE("no_ecc"),            // String
      .ECC_TYPE("none"),              // String
      .IGNORE_INIT_SYNTH(0),          // DECIMAL
      .MEMORY_INIT_FILE("none"),      // String
      .MEMORY_INIT_PARAM("0"),        // String
      .MEMORY_OPTIMIZATION("true"),   // String
      .MEMORY_PRIMITIVE("auto"),      // String
      .MEMORY_SIZE(DEPTH*DATA_SIZE),  // DECIMAL
      .MESSAGE_CONTROL(0),            // DECIMAL
      .RAM_DECOMP("auto"),            // String
      .READ_DATA_WIDTH_B(DATA_SIZE),  // DECIMAL
      .READ_LATENCY_B(read_latency),  // DECIMAL
      .READ_RESET_VALUE_B("0"),       // String
      .RST_MODE_A("SYNC"),            // String
      .RST_MODE_B("SYNC"),            // String
      .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
      .USE_MEM_INIT(1),               // DECIMAL
      .USE_MEM_INIT_MMI(0),           // DECIMAL
      .WAKEUP_TIME("disable_sleep"),  // String
      .WRITE_DATA_WIDTH_A(32),        // DECIMAL
      .WRITE_MODE_B("no_change"),     // String
      .WRITE_PROTECT(0)               // DECIMAL
   )
   xpm_memory_sdpram_inst (
      .doutb(doutb),           // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
      .addra(addra),           // ADDR_WIDTH_A-bit input: Address for port A write operations.
      .addrb(addrb),           // ADDR_WIDTH_B-bit input: Address for port B read operations.
      .clka(clk),              // 1-bit input: Clock signal for port A. Also clocks port B when  parameter CLOCKING_MODE is "common_clock".
      .dina(dina),             // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      .ena(|wea),               // 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
      .enb(1'b1),              // 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
      .regceb(1'b1),           // 1-bit input: Clock Enable for the last register stage on the output data path
      .rstb(rst),              // 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.
      .wea(wea)            // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
   );
   // End of xpm_memory_sdpram_inst instantiation
endmodule

module tb_memory;

    logic [2 - 1 : 0] addra = 0;
    logic [32 - 1 : 0] dina = 0;
    logic [4 - 1 : 0] wea = 0;
    logic [2 - 1 : 0] addrb = 0;
    logic [32 -1 : 0] doutb;
    logic clk = 0;
    logic rst = 1;

    memory #(
        .DEPTH(2), 
        .DATA_SIZE(32)
    ) u0_mem (
        .addra(addra),
        .dina(dina),
        .wea(wea),
        .addrb(addrb),
        .doutb(doutb),
        .clk(clk),
        .rst(rst)
    );
    
    task write_to_ram(
        input logic [31:0] data,
        input logic [3 : 0] we,
        input logic [1:0] addr
     );
        dina = data;
        addra = addr;
        wea = we;
        @(posedge clk) begin 
            wea = 4'd0;
            data = 32'd0;
            addr = 2'd0;
        end
    endtask
    
    task read_from_ram(
        input logic [1:0] addr,
        output logic [31:0] doutb
    );
        @(negedge clk) begin 
            addrb = addr;
        end
        @(posedge clk) begin
            doutb = doutb;
        end
    endtask
    
    always #10 clk = ~clk;
    
    initial begin
        #100 rst = ~rst;
        for (int i = 'hFE; i < 'hFFF; i = i + 1) begin
            @(negedge clk);
            write_to_ram(i, 4'b0001, 2'd0);
        end
    end
    
endmodule