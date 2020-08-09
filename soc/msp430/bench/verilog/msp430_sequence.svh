////////////////////////////////////////////////////////////////////////////////
//                                            __ _      _     _               //
//                                           / _(_)    | |   | |              //
//                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
//               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
//              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
//               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
//                  | |                                                       //
//                  |_|                                                       //
//                                                                            //
//                                                                            //
//              PU RISCV / OR1K / MSP430                                      //
//              Universal Verification Methodology                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2020-2021 by the author(s)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * =============================================================================
 * Author(s):
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

class msp430_transaction extends uvm_sequence_item;
  `uvm_object_utils(msp430_transaction)

  parameter DW = 16;

  parameter PMEM_MSB = 16;
  parameter DMEM_MSB = 16;

  parameter IRQ_NR = 64;

  rand bit [15:0] instrn;

  bit              irq_detect;
  bit              nmi_detect;

  bit [       2:0] i_state;
  bit [       3:0] e_state;
  bit              decode;
  bit [DW    -1:0] ir;
  bit [       5:0] irq_num;
  bit [DW    -1:0] pc;

  bit              nodiv_smclk;

  bit              aclk;              // ASIC ONLY: ACLK
  bit              aclk_en;           // FPGA ONLY: ACLK enable
  bit              dbg_freeze;        // Freeze peripherals
  bit              dbg_i2c_sda_out;   // Debug interface: I2C SDA OUT
  bit              dbg_uart_txd;      // Debug interface: UART TXD
  bit              dco_enable;        // ASIC ONLY: Fast oscillator enable
  bit              dco_wkup;          // ASIC ONLY: Fast oscillator wake-up (asynchronous)
  bit [IRQ_NR-3:0] irq_acc;           // Interrupt request accepted (one-hot signal)
  bit              lfxt_enable;       // ASIC ONLY: Low frequency oscillator enable
  bit              lfxt_wkup;         // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
  bit              mclk;              // Main system clock
  bit              puc_rst;           // Main system reset
  bit              smclk;             // ASIC ONLY: SMCLK
  bit              smclk_en;          // FPGA ONLY: SMCLK enable

  bit              cpu_en;            // Enable CPU code execution (asynchronous and non-glitchy)
  bit              dbg_en;            // Debug interface enable (asynchronous and non-glitchy)
  bit [       6:0] dbg_i2c_addr;      // Debug interface: I2C Address
  bit [       6:0] dbg_i2c_broadcast; // Debug interface: I2C Broadcast Address (for multicore systems)
  bit              dbg_i2c_scl;       // Debug interface: I2C SCL
  bit              dbg_i2c_sda_in;    // Debug interface: I2C SDA IN
  bit              dbg_uart_rxd;      // Debug interface: UART RXD (asynchronous)
  bit              dco_clk;           // Fast oscillator (fast clock)
  bit [IRQ_NR-3:0] irq;               // Maskable interrupts (14; 30 or 62)
  bit              lfxt_clk;          // Low frequency oscillator (typ 32kHz)
  bit              nmi;               // Non-maskable interrupt (asynchronous and non-glitchy)
  bit              reset_n;           // Reset Pin (active low; asynchronous and non-glitchy)
  bit              scan_enable;       // ASIC ONLY: Scan enable (active during scan shifting)
  bit              scan_mode;         // ASIC ONLY: Scan mode
  bit              wkup;              // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)

  bit [PMEM_MSB:0] pmem_addr;         // Program Memory address
  bit              pmem_cen;          // Program Memory chip enable (low active)
  bit [DW    -1:0] pmem_din;          // Program Memory data input (optional)
  bit [       1:0] pmem_wen;          // Program Memory write enable (low active) (optional)
  bit [DW    -1:0] pmem_dout;         // Program Memory data output


  bit [DMEM_MSB:0] dmem_addr;         // Data Memory address
  bit              dmem_cen;          // Data Memory chip enable (low active)
  bit [DW    -1:0] dmem_din;          // Data Memory data input
  bit [       1:0] dmem_wen;          // Data Memory write enable (low active)
  bit [DW    -1:0] dmem_dout;         // Data Memory data output

  bit [      13:0] per_addr;          // Peripheral address
  bit [DW    -1:0] per_din;           // Peripheral data input
  bit [       1:0] per_we;            // Peripheral write enable (high active)
  bit              per_en;            // Peripheral enable (high active)
  bit [DW    -1:0] per_dout;          // Peripheral data output

  bit [DW    -1:0] r0;
  bit [DW    -1:0] r1;
  bit [DW    -1:0] r2;
  bit [DW    -1:0] r3;
  bit [DW    -1:0] r4;
  bit [DW    -1:0] r5;
  bit [DW    -1:0] r6;
  bit [DW    -1:0] r7;
  bit [DW    -1:0] r8;
  bit [DW    -1:0] r9;
  bit [DW    -1:0] r10;
  bit [DW    -1:0] r11;
  bit [DW    -1:0] r12;
  bit [DW    -1:0] r13;
  bit [DW    -1:0] r14;
  bit [DW    -1:0] r15;

  constraint input_constraint {
    //Cosntraint to prevent EOF operation
    instrn inside {[16'h0000:16'hEFFF]};
  }

  function new (string name = "");
    super.new(name);
  endfunction
endclass: msp430_transaction

class inst_sequence extends uvm_sequence#(msp430_transaction);
  `uvm_object_utils(inst_sequence)

  function new (string name = "");
    super.new(name);
  endfunction

  bit [15:0] inst;

  //msp430_transaction req;
  task body;
    req = msp430_transaction::type_id::create("req");
    start_item(req);

    if (!req.randomize()) begin
      `uvm_error("Instruction Sequence", "Randomize failed.");
    end

    inst = req.instrn;

    finish_item(req);
  endtask: body
endclass: inst_sequence

class msp430_sequence extends uvm_sequence#(msp430_transaction);
  `uvm_object_utils(msp430_sequence)

  function new (string name = "");
    super.new(name);
  endfunction

  inst_sequence inst_seq;

  task body;
    //LOOP relative to use case (say 256)
    for(int i =0;i<10000;i++) begin
      inst_seq = inst_sequence::type_id::create("inst_seq");
      inst_seq.start(m_sequencer);
    end
  endtask: body
endclass: msp430_sequence
