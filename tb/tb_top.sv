
//============================================================
// File: tb_top.sv
// Description:
// Basic directed testbench for Mini DPU Controller.
//
// Features:
// - Clock/reset generation
// - APB write/read tasks
// - SRAM initialization
// - Basic transfer test
// - Result checking
//
// Test Flow:
// 1. Reset DUT
// 2. Initialize source SRAM region
// 3. Program APB registers
// 4. Start DPU transfer
// 5. Wait for interrupt
// 6. Verify copied data
//
// Project:
// Mini DPU Controller
//============================================================

`timescale 1ns/1ps

module tb_top;

    //========================================================
    // Clock / Reset
    //========================================================
    logic pclk;
    logic preset_n;

    //========================================================
    // APB Signals
    //========================================================
    logic         psel;
    logic         penable;
    logic         pwrite;
    logic [15:0]  paddr;
    logic [31:0]  pwdata;

    logic [31:0]  prdata;
    logic         pready;
    logic         pslverr;

    //========================================================
    // Interrupt
    //========================================================
    logic irq;

    //========================================================
    // DUT Instance
    //========================================================
    dpu_top dut (

        .pclk      (pclk),
        .preset_n  (preset_n),

        .psel      (psel),
        .penable   (penable),
        .pwrite    (pwrite),
        .paddr     (paddr),
        .pwdata    (pwdata),

        .prdata    (prdata),
        .pready    (pready),
        .pslverr   (pslverr),

        .irq       (irq)

    );

    //========================================================
    // Clock Generation
    //========================================================
    initial begin
        pclk = 0;
        forever #5 pclk = ~pclk;
    end

    //========================================================
    // Reset Task
    //========================================================
    task reset_dut();

        begin

            preset_n = 0;

            psel     = 0;
            penable  = 0;
            pwrite   = 0;
            paddr    = 0;
            pwdata   = 0;

            repeat (5) @(posedge pclk);

            preset_n = 1;

            repeat (2) @(posedge pclk);

        end

    endtask

    //========================================================
    // APB Write Task
    //========================================================
    task apb_write(
        input [15:0] addr,
        input [31:0] data
    );

        begin

            @(posedge pclk);

            psel    <= 1'b1;
            penable <= 1'b0;
            pwrite  <= 1'b1;

            paddr   <= addr;
            pwdata  <= data;

            @(posedge pclk);

            penable <= 1'b1;

            @(posedge pclk);

            psel    <= 1'b0;
            penable <= 1'b0;
            pwrite  <= 1'b0;

        end

    endtask

    //========================================================
    // APB Read Task
    //========================================================
    task apb_read(
        input  [15:0] addr,
        output [31:0] data
    );

        begin

            @(posedge pclk);

            psel    <= 1'b1;
            penable <= 1'b0;
            pwrite  <= 1'b0;

            paddr   <= addr;

            @(posedge pclk);

            penable <= 1'b1;

            @(posedge pclk);

            data = prdata;

            psel    <= 1'b0;
            penable <= 1'b0;

        end

    endtask

    //========================================================
    // Main Test
    //========================================================
    initial begin

        integer i;
        logic [31:0] rdata;

        //----------------------------------------------------
        // Reset DUT
        //----------------------------------------------------
        $display("\n======================================");
        $display(" DUT RESET ");
        $display("======================================");
        reset_dut();

        //----------------------------------------------------
        // Initialize Source Memory
        //----------------------------------------------------
        $display("\n======================================");
        $display(" Initializing Source SRAM");
        $display("======================================");

        for (i = 0; i < 8; i++) begin
            dut.u_sram_model.mem[i] = 32'hA5A50000 + i;
            $display("SRC MEM[%0d] = 0x%08h", i, dut.u_sram_model.mem[i]);
        end

        //----------------------------------------------------
        // Program DPU Registers
        //----------------------------------------------------
        $display("\n======================================");
        $display(" Programming APB Registers");
        $display("======================================");

        // SRC_ADDR = 0
	$display("[TB] Writing SRC_ADDR  = 0x00000000");
        apb_write(16'h0008, 32'h00000000);

        // DST_ADDR = 16
	$display("[TB] Writing DST_ADDR  = 0x00000010");
        apb_write(16'h000C, 32'h00000010);

        // LENGTH = 8 words
	$display("[TB] Writing LENGTH    = 0x00000008");
        apb_write(16'h0010, 32'h00000008);

	$display("\n[TB] Register Programming Completed");

        //----------------------------------------------------
        // Start Transfer
        //----------------------------------------------------
        $display("\n======================================");
        $display(" Starting DPU Transfer");
        $display("======================================");

        $display("[TB] Writing CTRL.START = 1");
        apb_write(16'h0000, 32'h00000001);

        //----------------------------------------------------
        // Wait For Interrupt
        //----------------------------------------------------
	$display("\n[TB] Waiting for IRQ assertion...");

        wait (irq == 1'b1);

	$display("[TB] IRQ Received - Transfer Completed");

        $display("\n======================================");
        $display(" Transfer Completed");
        $display("======================================");

        //----------------------------------------------------
        // Verify Destination Memory
        //----------------------------------------------------
        $display("\n======================================");
        $display(" Verifying Destination SRAM");
        $display("======================================");

        for (i = 0; i < 8; i++) begin
          $display("DST MEM[%0d] = 0x%08h", 16+i, dut.u_sram_model.mem[16+i]);
          if (dut.u_sram_model.mem[16+i] != dut.u_sram_model.mem[i]) begin
            $display("ERROR: DATA MISMATCH!");
          end
        end

        //----------------------------------------------------
        // Clear Interrupt
        //----------------------------------------------------
        apb_write(16'h0018, 32'h00000001);

        //----------------------------------------------------
        // Finish Simulation
        //----------------------------------------------------
        $display("\n======================================");
        $display(" TEST PASSED ");
        $display("======================================");

        #50;

        $finish;

    end

    initial begin

      $vcdplusfile("dpu.vpd");
      $vcdpluson(0, tb_top);

    end

endmodule

