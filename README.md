Mini DPU Controller

A simplified ASIC-style Mini DPU (Data Processing Unit) Controller project designed for learning RTL design, APB protocol handling, FSM-based controller architecture, DMA-style data movement, and ASIC verification methodology.

The project models a small hardware accelerator that autonomously copies data between memory regions inside SRAM under CPU/APB control.

Features
APB3 simplified slave interface
Memory-mapped register architecture
FSM-based DPU controller
SRAM-based data movement
Interrupt generation
Directed verification environment
End-to-end data integrity checking
High-Level Architecture
                +----------------------+
APB Master ---->|   APB Slave IF       |
                +----------------------+
                           |
                           v
                +----------------------+
                |   DPU Controller     |
                | FSM + Transfer Logic |
                +----------------------+
                           |
                           v
                +----------------------+
                |      SRAM Model      |
                +----------------------+
Project Directory Structure
mini_dpu_controller/
├── rtl/
│   ├── sram_model.sv
│   ├── apb_slave_if.sv
│   ├── dpu_controller.sv
│   └── dpu_top.sv
│
├── tb/
│   └── tb_top.sv
│
├── sim/
├── docs/
├── waves/
└── README.md
Functional Overview

The Mini DPU performs:

Memory-to-memory copy operation

inside a single SRAM.

The CPU/software:

Programs source address
Programs destination address
Programs transfer length
Starts the DPU transfer

The DPU:

reads source data
writes destination data
repeats until transfer completes
generates interrupt on completion
Register Map
Address	Register	Access	Description
0x0000	CTRL	RW	Start transfer
0x0004	STATUS	RO	BUSY/DONE/ERROR
0x0008	SRC_ADDR	RW	Source address
0x000C	DST_ADDR	RW	Destination address
0x0010	LENGTH	RW	Transfer length
0x0014	IRQ_STATUS	RO	Interrupt status
0x0018	IRQ_CLEAR	WO	Clear interrupt
FSM States
State	Description
IDLE	Wait for START
READ	Read source data
WRITE	Write destination data
DONE	Transfer completed
ERROR	Illegal configuration
Example Transfer
Software Configuration
SRC_ADDR = 0
DST_ADDR = 16
LENGTH   = 8

Meaning:

Copy 8 words
from mem[0:7]
to mem[16:23]
Transfer Flow
CPU programs registers
        ↓
START asserted
        ↓
FSM enters READ state
        ↓
Read source SRAM data
        ↓
FSM enters WRITE state
        ↓
Write destination SRAM data
        ↓
Repeat until LENGTH complete
        ↓
DONE + IRQ asserted
        ↓
Software clears IRQ
        ↓
FSM returns to IDLE
Verification Environment

The project currently uses a:

Directed module-level verification environment

Testbench includes:

clock/reset generation
APB write/read tasks
SRAM initialization
interrupt wait mechanism
data integrity checks
Verification Coverage
Feature	Status
Reset verification	DONE
APB write verification	DONE
Register decode verification	DONE
FSM verification	DONE
SRAM read/write verification	DONE
Interrupt verification	DONE
Data integrity verification	DONE
Important Debug Signals
Signal	Purpose
current_state	FSM tracking
src_ptr	Source pointer
dst_ptr	Destination pointer
transfer_count	Transfer progress
sram_we	SRAM write enable
sram_raddr	SRAM read address
sram_waddr	SRAM write address
sram_wdata	Transfer data
irq	Completion interrupt
Example Memory Contents
Before Transfer
mem[0] = A5A50000
mem[1] = A5A50001
...
mem[7] = A5A50007
After Transfer
mem[16] = A5A50000
mem[17] = A5A50001
...
mem[23] = A5A50007
Build and Run
Compile
vlogan rtl/*.sv tb/*.sv
Run Simulation
./simv
View Waveforms
dve &
Learning Outcomes

This project helps in understanding:

APB protocol
Memory-mapped register design
FSM-based controller architecture
DMA-style transfers
Interrupt handling
Directed verification
End-to-end datapath checking
ASIC subsystem integration
Future Enhancements

Planned future upgrades:

AXI4 support
Burst transfers
Multi-channel DPU
UVM testbench
Assertions (SVA)
Functional coverage
Randomized testing
Performance counters
Multi-memory architecture
Project Type
ASIC RTL + Directed Verification Learning Project

Suitable for learning:

ASIC Design
Design Verification
SoC subsystem architecture
DMA/controller verification
