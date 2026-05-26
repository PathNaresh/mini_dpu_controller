//============================================================
// File: apb_slave_if.sv
// Description:
// APB slave interface for Mini DPU Controller project.
//
// Features:
// - APB3 simplified slave
// - Register read/write support
// - Control and status register interface
// - Generates configuration outputs for DPU controller
//
// Registers:
// 0x00 : CTRL
// 0x04 : STATUS
// 0x08 : SRC_ADDR
// 0x0C : DST_ADDR
// 0x10 : LENGTH
// 0x14 : IRQ_STATUS
// 0x18 : IRQ_CLEAR
//
// Notes:
// - PREADY always asserted
// - No wait-state support
// - Word-aligned accesses only
//
// Project:
// Mini DPU Controller
//============================================================

module apb_slave_if (

    input  logic         pclk,
    input  logic         preset_n,

    //========================================================
    // APB Interface Signals
    //========================================================
    input  logic         psel,
    input  logic         penable,
    input  logic         pwrite,
    input  logic [15:0]  paddr,
    input  logic [31:0]  pwdata,

    output logic [31:0]  prdata,
    output logic         pready,
    output logic         pslverr,

    //========================================================
    // Controller Status Inputs
    //========================================================
    input  logic         busy,
    input  logic         done,
    input  logic         error,
    input  logic         irq_status,

    //========================================================
    // Configuration Outputs To Controller
    //========================================================
    output logic         start,
    output logic [7:0]   src_addr,
    output logic [7:0]   dst_addr,
    output logic [15:0]  length,
    output logic         irq_clear
);

    //========================================================
    // Register Address Map
    //========================================================
    localparam CTRL_ADDR       = 16'h0000;
    localparam STATUS_ADDR     = 16'h0004;
    localparam SRC_ADDR_REG    = 16'h0008;
    localparam DST_ADDR_REG    = 16'h000C;
    localparam LENGTH_REG      = 16'h0010;
    localparam IRQ_STATUS_REG  = 16'h0014;
    localparam IRQ_CLEAR_REG   = 16'h0018;

    //========================================================
    // Internal Registers
    //========================================================
    logic start_reg;

    //========================================================
    // APB Ready/Error Response
    //========================================================
    assign pready  = 1'b1;
    assign pslverr = 1'b0;

    //========================================================
    // Register Write Logic
    //========================================================
    always_ff @(posedge pclk or negedge preset_n) begin
        if (!preset_n) begin
            start_reg <= 1'b0;
            src_addr  <= '0;
            dst_addr  <= '0;
            length    <= '0;
            irq_clear <= 1'b0;
        end
        else begin

            // Default pulse signals
            start_reg <= 1'b0;
            irq_clear <= 1'b0;

            // APB WRITE
            if (psel && penable && pwrite) begin

                case (paddr)

                    CTRL_ADDR: begin
                        start_reg <= pwdata[0];
                    end

                    SRC_ADDR_REG: begin
                        src_addr <= pwdata[7:0];
                    end

                    DST_ADDR_REG: begin
                        dst_addr <= pwdata[7:0];
                    end

                    LENGTH_REG: begin
                        length <= pwdata[15:0];
                    end

                    IRQ_CLEAR_REG: begin
                        irq_clear <= pwdata[0];
                    end

                    default: begin
                    end

                endcase
            end
        end
    end

    //========================================================
    // START Pulse Output
    //========================================================
    assign start = start_reg;

    //========================================================
    // Register Read Logic
    //========================================================
    always_comb begin

        prdata = 32'h0;

        if (psel && !pwrite) begin

            case (paddr)

                CTRL_ADDR: begin
                    prdata[0] = start_reg;
                end

                STATUS_ADDR: begin
                    prdata[0] = busy;
                    prdata[1] = done;
                    prdata[2] = error;
                end

                SRC_ADDR_REG: begin
                    prdata[7:0] = src_addr;
                end

                DST_ADDR_REG: begin
                    prdata[7:0] = dst_addr;
                end

                LENGTH_REG: begin
                    prdata[15:0] = length;
                end

                IRQ_STATUS_REG: begin
                    prdata[0] = irq_status;
                end

                default: begin
                    prdata = 32'h0;
                end

            endcase
        end
    end

endmodule

