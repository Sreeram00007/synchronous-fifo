`timescale 1ns / 1ps

module tb_sync_fifo();

parameter FIFO_SIZE = 8;
parameter WIDTH = 32;

reg clk_tb;
reg rstn_tb;
reg write_enable;
reg read_enable;
reg enable;
reg [WIDTH-1:0] din_tb;

wire [WIDTH-1:0] dout_tb;
wire full_flag;
wire empty_flag;

// DUT Instantiation
SyncFIFO dut (
    .clk(clk_tb),
    .cs(enable),
    .rst_n(rstn_tb),
    .wr_en(write_enable),
    .rd_en(read_enable),
    .data_in(din_tb),
    .data_out(dout_tb),
    .Full(full_flag),
    .Empty(empty_flag)
);

// Clock generation
initial clk_tb = 0;
always #5 clk_tb = ~clk_tb;


// WRITE TASK
task push_data(input [WIDTH-1:0] value);
begin
    @(posedge clk_tb)
    enable = 1; 
    write_enable = 1;
    din_tb <= value;

    $display($time, " PUSH -> data = %d", value);

    @(posedge clk_tb)
    write_enable = 0;
end
endtask


// READ TASK
task pop_data;
begin
    @(posedge clk_tb)
    enable = 1; 
    read_enable = 1;

    @(posedge clk_tb)
    $display($time, " POP -> data = %d", dout_tb);

    read_enable = 0;
end
endtask


// ================= TEST SEQUENCE =================

initial begin
    #1 rstn_tb = 0;
    read_enable = 0;
    write_enable = 0;

    @(posedge clk_tb)
    rstn_tb = 1;

    // -------- SCENARIO 1 --------
    $display($time, "\n SCENARIO 1");

    push_data(1);
    push_data(100);
    push_data(1000);

    pop_data();
    pop_data();
    pop_data();

    // -------- SCENARIO 2 --------
    $display($time, "\n SCENARIO 2");

    for (integer j = 0; j < FIFO_SIZE; j = j + 1) begin
        push_data(2**j);
        pop_data();
    end

    // -------- SCENARIO 3 --------
    $display($time, "\n SCENARIO 3");

    for (integer k = 0; k < FIFO_SIZE; k = k + 1) begin
        push_data(2**k);
    end

    for (integer k = 0; k < FIFO_SIZE; k = k + 1) begin
        pop_data();
    end

    #40 $finish;
end

endmodule