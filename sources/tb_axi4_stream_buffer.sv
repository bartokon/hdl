`timescale 1ns/10ps;

module tb_axi4_stream_buffer;

    localparam DATA_SIZE = 32;

    //Read port
    reg [DATA_SIZE - 1 :0] read_data = 0;
    reg read_data_valid = 0;
    wire read_data_ready;

    //Write port
    wire [DATA_SIZE - 1 :0] write_data;
    wire write_data_valid;
    reg write_data_ready = 0;

    //Misc
    reg clk = 0;
    reg resetn = 0;

    task write_stream(input int in);
        @(posedge clk) begin
            read_data <= in;
            read_data_valid <= 1;
        end
        @(posedge clk) begin
            if (read_data_valid == 1 && read_data_ready == 1) begin
                read_data_valid <= 0;
            end
        end
    endtask

    task read_stream(input int in);
        @(posedge clk) begin
            write_data_ready <= 1;
        end
        wait(write_data_valid == 1);
        @(negedge clk) begin
            if (write_data_valid == 1 && write_data_ready == 1) begin
                assert(write_data == in) else $display("Fail");
            end
            @(posedge clk) write_data_ready <= 0;
        end
    endtask

    task write_stream_burst(input int in[8]);
        for (int i = 0; i < 8; i = i + 1) begin
            @(posedge clk) begin
                read_data <= in[i];
                read_data_valid <= 1;
            end
            wait(!clk);
            wait(read_data_valid == 1 && read_data_ready == 1);
    //        @(read_data_valid == 1 && read_data_ready == 1) begin
    //            wait(read_data_ready == 0);
    //            @(negedge clk) read_data_valid <= 0;
    //        end
        end
        read_data_valid <= 0; //EOS
    endtask

    task read_stream_burst(input int in[8]);
        for (int i = 0; i < 8; i = i + 1) begin
            @(posedge clk) begin
                write_data_ready <= 1;
            end
            wait(write_data_valid == 1 && write_data_ready == 1);
            @(negedge clk) begin
                if (write_data_valid == 1 && write_data_ready == 1) begin
                    assert(write_data == in[i]) else begin
                        $display("Fail %d", i);
                        $display("GOT: %d, EXPECTED: %d", write_data, in[i]);
                    end
                end
            end
        end
        write_data_ready <= 0;
    endtask

    axi4_stream_buffer
    #(
        .DATA_SIZE(DATA_SIZE)
    ) u0_axi4_stream_buffer
    (
        //Read port
        .read_data(read_data),
        .read_data_valid(read_data_valid),
        .read_data_ready(read_data_ready),

        //Write port
        .write_data(write_data),
        .write_data_valid(write_data_valid),
        .write_data_ready(write_data_ready),

        //Misc
        .clk(clk),
        .resetn(resetn)
    );

    always #10 clk <= !clk;

    initial begin
        $display("BUGS EVERYWHERE");
        #100 resetn <= !resetn;
        #50 write_stream(10);
        #50 read_stream(10);
        fork
            write_stream_burst({0, 1, 2, 3, 4, 5, 6, 7});
            read_stream_burst({0, 1, 2, 3, 4, 5, 6, 7});
        join
        fork
            write_stream_burst({8, 9, 10, 11, 12, 13, 14, 15});
            #200 read_stream_burst({8, 9, 10, 11, 12, 13, 14, 15});
        join
    end

endmodule
