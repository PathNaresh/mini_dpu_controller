//============================================================
// File: dpu_controller.sv
// Description:
// Main DPU controller FSM for Mini DPU Controller project.
//
// Features:
// - FSM-controlled data transfer
// - SRAM read/write management
// - Transfer counter handling
// - DONE/ERROR status generation
// - Interrupt generation
//
// FSM Flow:
// IDLE -> READ -> WRITE -> DONE
//
// Error Conditions:
// - LENGTH = 0
// - Address out of range
//
// Project:
// Mini DPU Controller
//============================================================

module dpu_controller (

    input  logic         clk,
    input  logic         rst_n,

    //========================================================
    // Control Inputs From APB Interface
    //========================================================
    input  logic         start,
    input  logic [7:0]   src_addr,
    input  logic [7:0]   dst_addr,
    input  logic [15:0]  length,
    input  logic         irq_clear,

    //========================================================
    // SRAM Interface
    //========================================================
    output logic         sram_we,
    output logic [7:0]   sram_waddr,
    output logic [31:0]  sram_wdata,

    output logic [7:0]   sram_raddr,
    input  logic [31:0]  sram_rdata,

    //========================================================
    // Status Outputs
    //========================================================
    output logic         busy,
    output logic         done,
    output logic         error,
    output logic         irq
);

    //========================================================
    // FSM State Definition
    //========================================================
    typedef enum logic [2:0] {
        IDLE,
        READ,
        WRITE,
        DONE,
        ERROR
    } state_t;

    state_t current_state, next_state;

    //========================================================
    // Internal Registers
    //========================================================
    logic [7:0]  src_ptr;
    logic [7:0]  dst_ptr;
    logic [15:0] transfer_count;

    logic [31:0] data_buffer;

    //========================================================
    // Sequential FSM
    //========================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    //========================================================
    // FSM Next-State Logic
    //========================================================
    always_comb begin

        next_state = current_state;

        case (current_state)

            //------------------------------------------------
            // IDLE
            //------------------------------------------------
            IDLE: begin

                if (start) begin

                    if (length == 0)
                        next_state = ERROR;

                    else if ((src_addr + length > 256) ||
                             (dst_addr + length > 256))
                        next_state = ERROR;

                    else
                        next_state = READ;
                end
            end

            //------------------------------------------------
            // READ
            //------------------------------------------------
            READ: begin
                next_state = WRITE;
            end

            //------------------------------------------------
            // WRITE
            //------------------------------------------------
            WRITE: begin

                if (transfer_count == length)
                    next_state = DONE;
                else
                    next_state = READ;
            end

            //------------------------------------------------
            // DONE
            //------------------------------------------------
            DONE: begin
                if (irq_clear)
                    next_state = IDLE;
            end

            //------------------------------------------------
            // ERROR
            //------------------------------------------------
            ERROR: begin
                if (irq_clear)
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    //========================================================
    // Transfer Logic
    //========================================================
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            src_ptr        <= '0;
            dst_ptr        <= '0;
            transfer_count <= '0;

            data_buffer    <= '0;

        end
        else begin

            case (current_state)

                //--------------------------------------------
                // IDLE
                //--------------------------------------------
                IDLE: begin

                    if (start) begin
                        src_ptr        <= src_addr;
                        dst_ptr        <= dst_addr;
                        transfer_count <= 0;
                    end
                end

                //--------------------------------------------
                // READ
                //--------------------------------------------
                READ: begin
                    data_buffer <= sram_rdata;
                end

                //--------------------------------------------
                // WRITE
                //--------------------------------------------
                WRITE: begin

                    src_ptr        <= src_ptr + 1;
                    dst_ptr        <= dst_ptr + 1;
                    transfer_count <= transfer_count + 1;

                end

                default: begin
                end

            endcase
        end
    end

    //========================================================
    // SRAM Control Signals
    //========================================================
    always_comb begin

        sram_we     = 1'b0;

        sram_raddr  = src_ptr;

        sram_waddr  = dst_ptr;
        sram_wdata  = data_buffer;

        if (current_state == WRITE)
            sram_we = 1'b1;

    end

    //========================================================
    // Status Outputs
    //========================================================
    always_comb begin

        busy  = 1'b0;
        done  = 1'b0;
        error = 1'b0;

        case (current_state)

            READ,
            WRITE: begin
                busy = 1'b1;
            end

            DONE: begin
                done = 1'b1;
            end

            ERROR: begin
                error = 1'b1;
            end

            default: begin
            end

        endcase
    end

    //========================================================
    // Interrupt Logic
    //========================================================
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n)
            irq <= 1'b0;

        else begin

            case (current_state)

                DONE,
                ERROR: begin
                    irq <= 1'b1;
                end

                default: begin
                    if (irq_clear)
                        irq <= 1'b0;
                end

            endcase
        end
    end

endmodule

