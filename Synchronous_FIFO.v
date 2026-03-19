`timescale 1ns / 1ps

module SyncFIFO #(parameter FIFO_SIZE = 8, parameter WIDTH = 32)
(
    input clk,
    input rst_n,        // Active low reset
    input enable,       // chip select equivalent
    input write_en,
    input read_en,
    input [WIDTH-1:0] din,

    output reg [WIDTH-1:0] dout,
    output reg fifo_full,
    output reg fifo_empty
);

// log2 of FIFO size
localparam ADDR_BITS = $clog2(FIFO_SIZE);

// FIFO memory
reg [WIDTH-1:0] mem [FIFO_SIZE-1:0];

// pointers (extra bit for full/empty detection)
reg [ADDR_BITS:0] wr_ptr;
reg [ADDR_BITS:0] rd_ptr;

// WRITE LOGIC
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        wr_ptr <= 0;
    else if (enable && write_en && !fifo_full) begin
        mem[wr_ptr[ADDR_BITS-1:0]] <= din;
        wr_ptr <= wr_ptr + 1'b1;
    end
end

// READ LOGIC
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_ptr <= 0;
        dout   <= 0;
    end
    else if (enable && read_en && !fifo_empty) begin
        dout <= mem[rd_ptr[ADDR_BITS-1:0]];
        rd_ptr <= rd_ptr + 1'b1;
    end
end

// STATUS FLAGS
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fifo_full  <= 1'b0;
        fifo_empty <= 1'b1;
    end
    else begin
        // Empty condition
        fifo_empty <= (rd_ptr == wr_ptr);

        // Full condition (MSB inverted comparison)
        fifo_full <= (rd_ptr == {~wr_ptr[ADDR_BITS], wr_ptr[ADDR_BITS-1:0]});
    end
end

endmodule