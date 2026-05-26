//============================================================
// File: sram_model.sv
// Description:
// Simple single-port SRAM model for Mini DPU Controller project.
//
// Features:
// - 256 x 32-bit memory
// - Synchronous write
// - Combinational read
// - Word-addressable memory
//
// Usage:
// - Stores source and destination data for DPU transfers
// - Used by controller during READ/WRITE operations
//
// Project:
// Mini DPU Controller
//============================================================

module sram_model #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 256
)(
    input  logic                     clk,
    input  logic                     rst_n,

    // Write Interface
    input  logic                     we,
    input  logic [ADDR_WIDTH-1:0]    waddr,
    input  logic [DATA_WIDTH-1:0]    wdata,

    // Read Interface
    input  logic [ADDR_WIDTH-1:0]    raddr,
    output logic [DATA_WIDTH-1:0]    rdata
);

    //========================================================
    // Memory Array
    //========================================================
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    //========================================================
    // Synchronous Write Logic
    //========================================================
    always @(posedge clk) begin
        if (we) begin
            mem[waddr] <= wdata;
            $display("[SRAM][WRITE] TIME=%0t ADDR=0x%0h DATA=0x%08h", $time, waddr, wdata);
        end
    end

    //========================================================
    // Combinational Read Logic
    //========================================================
    always_comb begin
        rdata = mem[raddr];
    end

endmodule

