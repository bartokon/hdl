`timescale 1ns/100ps
`default_nettype none

module tb_very_simple_switch;

parameter integer DATA_WIDTH = 32;
parameter integer INPUT_QTY = 2;
parameter integer OUTPUT_QTY = 4;

/* clock, reset */
logic clk = 0;
logic reset = 1;

/* inputs */
logic [INPUT_QTY - 1 : 0] data_in_valid;
logic [INPUT_QTY - 1 : 0] [DATA_WIDTH - 1 : 0] data_in;
logic [INPUT_QTY - 1 : 0] [$clog2(OUTPUT_QTY) - 1 : 0] data_in_destination;

/* outputs */
logic [OUTPUT_QTY - 1 : 0] data_out_valid;
logic [OUTPUT_QTY - 1 : 0] [DATA_WIDTH - 1 : 0] data_out;

always #5ns clk = ~clk;

//one global clk -> clk
task automatic write_data(
    input logic [DATA_WIDTH - 1 : 0] data,
    input logic [$clog2(OUTPUT_QTY) - 1 : 0] destination,
    ref logic [DATA_WIDTH - 1 : 0] data_in_port,
    ref logic [$clog2(OUTPUT_QTY) - 1 : 0] data_in_destination_port,
    ref logic data_in_valid_port
);
    @(negedge clk);
    data_in_port = data;
    data_in_destination_port = destination;
    data_in_valid_port = 1'b1;
    wait(clk == 1'b1);
    @(negedge clk);
    data_in_valid_port = 1'b0;
endtask

task automatic read_data(
    output logic [DATA_WIDTH - 1 : 0] data_out,
    ref logic [DATA_WIDTH - 1 : 0] data_out_port,
    ref logic data_out_valid_port
);
    wait(data_out_valid_port == 1'b1);
    @(negedge clk);
    data_out = data_out_port;
endtask

very_simple_switch #(
    .DATA_WIDTH(DATA_WIDTH),
    .INPUT_QTY(INPUT_QTY),
    .OUTPUT_QTY(OUTPUT_QTY)
) u0_very_simple_switch (
    .clk(clk),
    .reset(reset),

    .data_in_valid(data_in_valid),
    .data_in(data_in),
    .data_in_destination(data_in_destination),

    .data_out_valid(data_out_valid),
    .data_out(data_out)
);

logic [DATA_WIDTH - 1 : 0] temp = 0;
logic sequential_test = 0;
logic parallel_test = 0;
logic conflict_test = 0;
logic burst_test = 0;
logic [DATA_WIDTH -1 : 0]  buffer_q[OUTPUT_QTY - 1 : 0][$];

initial begin
    $timeformat(-9, 2, " ns", 20);
    for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
        data_in[input_port] = 0;
        data_in_destination[input_port] = 0;
        data_in_valid[input_port] = 0;
    end
    #50ns
        reset = 0;

    //sequential test -> write to one port read from one port
    sequential_test = 1;
    $display("//******************************//");
    $display("Sequential test [%t]", $time);
    $display("//******************************//");
    for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
        for (integer output_port = 0; output_port < OUTPUT_QTY; output_port = output_port + 1) begin
            #50ns
                $display("Input port is: %d destination: %d value: %d [%t]", input_port, output_port, input_port + 1, $time);
                fork
                    write_data(
                        input_port + 1,
                        output_port,
                        data_in[input_port],
                        data_in_destination[input_port],
                        data_in_valid[input_port]
                    );
                    read_data(temp, data_out[output_port], data_out_valid[output_port]);
                join
                $display("Output port is: %d value: %d [%t]", output_port, temp, $time);
                assert (temp == (input_port + 1)) else begin
                    $display("Temp is %d", temp);
                    $stop;
                end
        end
    end
    sequential_test = 0;

        //Clear
        for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
            data_in[input_port] = 0;
            data_in_destination[input_port] = 0;
            data_in_valid[input_port] = 0;
        end
        reset = ~reset;
    #50
        reset = ~reset;

    #50
        //Parallel test -> write to all ports read from all ports (no conflict)
        if (INPUT_QTY == OUTPUT_QTY) begin
            parallel_test = 1;
            $display("//******************************//");
            $display("Parallel test [%t]", $time);
            $display("//******************************//");
            for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
                data_in[input_port] = input_port + 2;
                data_in_destination[input_port] = input_port;
                data_in_valid[input_port] = 1;
            end
            for (integer output_port = 0; output_port < OUTPUT_QTY; output_port = output_port + 1) begin
                    automatic logic [DATA_WIDTH - 1 : 0] temp = 0;
                    read_data(temp, data_out[output_port], data_out_valid[output_port]);
                    $display("Output port is: %d value: %d [%t]", output_port, temp, $time);
                    assert (temp == (output_port + 2)) else begin
                        $display("Temp is %d", temp);
                        $stop;
                    end
            end
        end
        parallel_test = 0;

     //Clear
        for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
            data_in[input_port] = 0;
            data_in_destination[input_port] = 0;
            data_in_valid[input_port] = 0;
        end
        reset = ~reset;
    #50
        reset = ~reset;

    //Conflict test
    conflict_test = 1;
    $display("//******************************//");
    $display("Conflict test [%t]", $time);
    $display("//******************************//");
    @(negedge clk);
    for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
        data_in[input_port] = input_port + 1;
        data_in_destination[input_port] = 0;
        data_in_valid[input_port] = 1;
    end
    @(negedge clk);
    fork
        for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
            data_in[input_port] = 0;
            data_in_destination[input_port] = 0;
            data_in_valid[input_port] = 0;
        end
        begin
            for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
                read_data(temp, data_out[0], data_out_valid[0]);
                $display("Output port is: %d value: %d [%t]", 0, temp, $time);
                assert (temp == input_port + 1) else begin
                    $display("Temp is %d", temp);
                    $stop;
                end
            end
        end
    join
    conflict_test = 0;

    //Clear
        for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
            data_in[input_port] = 0;
            data_in_destination[input_port] = 0;
            data_in_valid[input_port] = 0;
        end
        reset = ~reset;
    #50
        reset = ~reset;

    //BURST TEST
    burst_test = 1;
    $display("//******************************//");
    $display("BURST test + Conflict [%t]", $time);
    $display("//******************************//");
    temp = 1;
    fork
        begin
            $display("T1: %t", $time);
            for (integer dest = 0; dest < OUTPUT_QTY; dest = dest + 1) begin
                for (integer rep = 0; rep < 4; rep = rep + 1) begin
                    @(negedge clk);
                    for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
                        data_in[input_port] = 100*(input_port + 1) + 10*(dest + 1) + 1*(rep + 1);
                        data_in_destination[input_port] = dest;
                        data_in_valid[input_port] = 1;
                    end
                end
            end
            @(negedge clk);
            for (integer input_port = 0; input_port < INPUT_QTY; input_port = input_port + 1) begin
                    data_in[input_port] = 0;
                    data_in_destination[input_port] = 0;
                    data_in_valid[input_port] = 0;
            end
        end
        begin
            $display("T2: %t", $time);
            for (integer output_port = 0; output_port < OUTPUT_QTY; output_port = output_port + 1) begin
                automatic int i = output_port;
                fork
                    begin
                        wait(data_out_valid[i] == 1);
                        while(data_out_valid[i] == 1) begin
                            buffer_q[i].push_back(data_out[i]);
                            @(posedge clk);
                            wait (clk == 0);
                        end
                    end
                join_none
            end
        end
    join
    burst_test = 0;

    #500ns
        $display("Simulation finished.");
        $finish;
end
endmodule