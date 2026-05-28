Mini DPU Controller Subsystem v2.0
Overview

The Mini DPU Controller Subsystem is a small SoC-style hardware subsystem developed for learning and practicing:

APB-based peripheral integration
FSM-based RTL design
Interrupt handling architecture
Peripheral controller design
Memory-mapped register programming
Subsystem-level verification

This project evolves from a standalone DPU engine into a multi-peripheral subsystem containing:

DPU Controller
SPI Controller
Interrupt Controller
APB Interconnect
SRAM Model

The design is intentionally educational and modular while following clean industry-style RTL structure.

                 +----------------------+
 APB MASTER ---> |  APB INTERCONNECT    |
                 +----+-----------+-----+
                      |           |
                      |           |
                      v           v

               +----------+   +----------+
               | DPU      |   | SPI CTRL |
               +-----+----+   +-----+----+
                     |              |
                     +------+-------+
                            |
                            v

                    +---------------+
                    | IRQ CONTROLLER|
                    +-------+-------+
                            |
                            v
                       GLOBAL_IRQ

Subsystem Components :

1. DPU Controller - FSM-based memory transfer engine.
Features
SRAM-to-SRAM transfer
Address pointer management
Transfer counter
DONE / ERROR handling
Interrupt generation

FSM Flow : IDLE -> ISSUE_READ -> READ_WAIT -> WRITE -> DONE / ERROR

2. SPI Controller - Simple APB-programmable SPI transmit controller.
Features
Single-byte transfer
FSM-controlled serial shifting
SPI clock generation
MOSI transmission
Transfer completion interrupt

FSM Flow : IDLE -> LOAD -> SHIFT -> DONE

3. Interrupt Controller - Centralized interrupt aggregation block.
Responsibilities
Capture interrupt sources
Maintain pending interrupt status
Support interrupt masking
Generate global interrupt output
Supported Interrupt Sources
IRQ Bit	Source
0	DPU Controller
1	SPI Controller
4. APB Interconnect

Simple APB address decoder/router.
Responsibilities
Decode APB peripheral address
Route APB transactions
Select target peripheral
Peripheral Address Map
Peripheral	Base Address
DPU	0x0000
IRQ Controller	0x1000
SPI Controller	0x2000
5. SRAM Model

Behavioral memory model used by the DPU controller.

Features
256 x 32-bit memory
Synchronous write
Combinational read
Word-addressable storage
Register Maps
DPU Registers
Address	Register	Description
0x0000	CTRL	START control
0x0004	STATUS	BUSY/DONE/ERROR
0x0008	SRC_ADDR	Source address
0x000C	DST_ADDR	Destination address
0x0010	LENGTH	Transfer length
0x0014	IRQ_STATUS	IRQ state
0x0018	IRQ_CLEAR	IRQ clear
IRQ Controller Registers
Address	Register	Description
0x1000	IRQ_STATUS	Pending IRQs
0x1004	IRQ_MASK	IRQ enable mask
0x1008	IRQ_CLEAR	Clear pending IRQ
SPI Controller Registers
Address	Register	Description
0x2000	SPI_CTRL	START/ENABLE
0x2004	SPI_STATUS	BUSY/DONE
0x2008	SPI_TXDATA	TX byte
0x200C	SPI_RXDATA	RX byte
0x2010	SPI_CLKDIV	Optional future use
Project Directory Structure
mini_dpu_controller/
└── v2.0/
    ├── rtl/
    │   ├── subsystem_top.sv
    │   ├── apb_interconnect.sv
    │   ├── apb_slave_if.sv
    │   ├── dpu_controller.sv
    │   ├── irq_controller.sv
    │   ├── spi_controller.sv
    │   └── sram_model.sv
    │
    ├── tb/
    │   └── tb_top.sv
    │
    ├── sim/
    │   └── run_vcs.sh
    │
    └── common/
        ├── dpu_defines.svh
        └── dpu_types.svh
Verification Plan
DPU Tests
Basic SRAM copy
Zero-length transfer
Address overflow handling
IRQ generation
SPI Tests
Single-byte transfer
SPI clock generation
MOSI shifting validation
Transfer completion IRQ
IRQ Controller Tests
Pending bit update
Interrupt masking
IRQ clear handling
Multiple interrupt source handling
Learning Objectives

This project helps understand:

Topic	Concepts
APB Protocol	peripheral integration
FSM Design	controller implementation
Interrupt Architecture	IRQ aggregation/masking
SPI Protocol	serial communication
Memory Subsystems	SRAM interaction
SoC Integration	subsystem architecture
Verification	directed RTL testing
Future Enhancements

Planned future improvements include:

APB wait-state support
Burst transfers
SPI receive path
FIFO support
DMA arbitration
Multiple SRAM banks
Priority-based interrupt handling
UVM-based verification
