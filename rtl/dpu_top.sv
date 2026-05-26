
//============================================================
// File: dpu_top.sv
// Description:
// Top-level integration module for Mini DPU Controller.
//
// Integrates:
// - APB Slave Interface
// - DPU Controller FSM
// - SRAM Model
//
// Responsibilities:
// - Connect configuration path
// - Connect SRAM datapath
// - Export APB interface
// - Export interrupt output
//
// Project:
// Mini DPU Controller
//============================================================

module dpu_top (

    input  logic         pclk,
    input  logic         preset_n,

    //========================================================
    // APB Interface
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
    // Interrupt Output
    //========================================================
    output logic         irq

);

    //========================================================
    // Internal Configuration Signals
    //========================================================
    logic         start;
    logic [7:0]   src_addr;
    logic [7:0]   dst_addr;
    logic [15:0]  length;
    logic         irq_clear;

    //========================================================
    // Status Signals
    //========================================================
    logic busy;
    logic done;
    logic error;

    //========================================================
    // SRAM Interface Signals
    //========================================================
    logic         sram_we;
    logic [7:0]   sram_waddr;
    logic [31:0]  sram_wdata;

    logic [7:0]   sram_raddr;
    logic [31:0]  sram_rdata;

    //========================================================
    // APB Slave Interface Instance
    //========================================================
    apb_slave_if u_apb_slave_if (

        .pclk        (pclk),
        .preset_n    (preset_n),

        .psel        (psel),
        .penable     (penable),
        .pwrite      (pwrite),
        .paddr       (paddr),
        .pwdata      (pwdata),

        .prdata      (prdata),
        .pready      (pready),
        .pslverr     (pslverr),

        .busy        (busy),
        .done        (done),
        .error       (error),
        .irq_status  (irq),

        .start       (start),
        .src_addr    (src_addr),
        .dst_addr    (dst_addr),
        .length      (length),
        .irq_clear   (irq_clear)

    );

    //========================================================
    // DPU Controller Instance
    //========================================================
    dpu_controller u_dpu_controller (

        .clk            (pclk),
        .rst_n          (preset_n),

        .start          (start),
        .src_addr       (src_addr),
        .dst_addr       (dst_addr),
        .length         (length),
        .irq_clear      (irq_clear),

        .sram_we        (sram_we),
        .sram_waddr     (sram_waddr),
        .sram_wdata     (sram_wdata),

        .sram_raddr     (sram_raddr),
        .sram_rdata     (sram_rdata),

        .busy           (busy),
        .done           (done),
        .error          (error),
        .irq            (irq)

    );

    //========================================================
    // SRAM Model Instance
    //========================================================
    sram_model u_sram_model (

        .clk        (pclk),
        .rst_n      (preset_n),

        .we         (sram_we),
        .waddr      (sram_waddr),
        .wdata      (sram_wdata),

        .raddr      (sram_raddr),
        .rdata      (sram_rdata)

    );

endmodule

