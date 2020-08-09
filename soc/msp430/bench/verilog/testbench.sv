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

//Include UVM files
`include "uvm_macros.svh"
`include "uvm_pkg.sv"
import uvm_pkg::*;

//Include common files
`include "msp430_sequence.svh"
`include "msp430_driver.svh"
`include "msp430_monitor.svh"
`include "msp430_scoreboard.svh"
`include "msp430_subscriber.svh"
`include "msp430_agent.svh"
`include "msp430_env.svh"
`include "msp430_test.svh"

module test;

  // Instantiate interface
  msp430_interface msp430_if();

  // Instantiate dut
  msp430_pu dut (
    .dbg_clk           (msp430_if.dbg_clk),
    .dbg_rst           (msp430_if.dbg_rst),
    .irq_detect        (msp430_if.irq_detect),
    .nmi_detect        (msp430_if.nmi_detect),

    .i_state           (msp430_if.i_state_bin),
    .e_state           (msp430_if.e_state_bin),
    .decode            (msp430_if.decode),
    .ir                (msp430_if.ir),
    .irq_num           (msp430_if.irq_num),
    .pc                (msp430_if.pc),

    .nodiv_smclk       (msp430_if.nodiv_smclk),

    .aclk              (msp430_if.aclk),              // ASIC ONLY: ACLK
    .aclk_en           (msp430_if.aclk_en),           // FPGA ONLY: ACLK enable
    .dbg_freeze        (msp430_if.dbg_freeze),        // Freeze peripherals
    .dbg_i2c_sda_out   (msp430_if.dbg_sda_slave_out), // Debug interface: I2C SDA OUT
    .dbg_uart_txd      (msp430_if.dbg_uart_txd),      // Debug interface: UART TXD
    .dco_enable        (msp430_if.dco_enable),        // ASIC ONLY: Fast oscillator enable
    .dco_wkup          (msp430_if.dco_wkup),          // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    .dmem_addr         (msp430_if.dmem_addr),         // Data Memory address
    .dmem_cen          (msp430_if.dmem_cen),          // Data Memory chip enable (low active)
    .dmem_din          (msp430_if.dmem_din),          // Data Memory data input
    .dmem_wen          (msp430_if.dmem_wen),          // Data Memory write enable (low active)
    .irq_acc           (msp430_if.irq_acc),           // Interrupt request accepted (one-hot signal)
    .lfxt_enable       (msp430_if.lfxt_enable),       // ASIC ONLY: Low frequency oscillator enable
    .lfxt_wkup         (msp430_if.lfxt_wkup),         // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    .mclk              (msp430_if.mclk),              // Main system clock
    .per_addr          (msp430_if.per_addr),          // Peripheral address
    .per_din           (msp430_if.per_din),           // Peripheral data input
    .per_we            (msp430_if.per_we),            // Peripheral write enable (high active)
    .per_en            (msp430_if.per_en),            // Peripheral enable (high active)
    .pmem_addr         (msp430_if.pmem_addr),         // Program Memory address
    .pmem_cen          (msp430_if.pmem_cen),          // Program Memory chip enable (low active)
    .pmem_din          (msp430_if.pmem_din),          // Program Memory data input (optional)
    .pmem_wen          (msp430_if.pmem_wen),          // Program Memory write enable (low active) (optional)
    .puc_rst           (msp430_if.puc_rst),           // Main system reset
    .smclk             (msp430_if.smclk),             // ASIC ONLY: SMCLK
    .smclk_en          (msp430_if.smclk_en),          // FPGA ONLY: SMCLK enable

    // INPUTs
    .cpu_en            (msp430_if.cpu_en),            // Enable CPU code execution (asynchronous)
    .dbg_en            (msp430_if.dbg_en),            // Debug interface enable (asynchronous)
    .dbg_i2c_addr      (msp430_if.I2C_ADDR),          // Debug interface: I2C Address
    .dbg_i2c_broadcast (msp430_if.I2C_BROADCAST),     // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl       (msp430_if.dbg_scl_slave),     // Debug interface: I2C SCL
    .dbg_i2c_sda_in    (msp430_if.dbg_sda_slave_in),  // Debug interface: I2C SDA IN
    .dbg_uart_rxd      (msp430_if.dbg_uart_rxd),      // Debug interface: UART RXD (asynchronous)
    .dco_clk           (msp430_if.dco_clk),           // Fast oscillator (fast clock)
    .dmem_dout         (msp430_if.dmem_dout),         // Data Memory data output
    .irq               (msp430_if.irq_in),            // Maskable interrupts
    .lfxt_clk          (msp430_if.lfxt_clk),          // Low frequency oscillator (typ 32kHz)
    .nmi               (msp430_if.nmi),               // Non-maskable interrupt (asynchronous)
    .per_dout          (msp430_if.per_dout),          // Peripheral data output
    .pmem_dout         (msp430_if.pmem_dout),         // Program Memory data output
    .reset_n           (msp430_if.reset_n),           // Reset Pin (low active, asynchronous)
    .scan_enable       (msp430_if.scan_enable),       // ASIC ONLY: Scan enable (active during scan shifting)
    .scan_mode         (msp430_if.scan_mode),         // ASIC ONLY: Scan mode
    .wkup              (|msp430_if.wkup_in),          // ASIC ONLY: System Wake-up (asynchronous)

    .r0                (msp430_if.r0),
    .r1                (msp430_if.r1),
    .r2                (msp430_if.r2),
    .r3                (msp430_if.r3),
    .r4                (msp430_if.r4),
    .r5                (msp430_if.r5),
    .r6	               (msp430_if.r6),
    .r7                (msp430_if.r7),
    .r8                (msp430_if.r8),
    .r9                (msp430_if.r9),
    .r10               (msp430_if.r10),
    .r11               (msp430_if.r11),
    .r12               (msp430_if.r12),
    .r13               (msp430_if.r13),
    .r14               (msp430_if.r14),
    .r15               (msp430_if.r15)
  );

  //Clock generation
  always #5 msp430_if.dbg_clk = ~msp430_if.dbg_clk;
  
  initial begin
    msp430_if.dbg_clk = 0;
  end

  initial begin
    // Place the interface into the UVM configuration database
    uvm_config_db#(virtual msp430_interface)::set(null, "*", "msp430_vif", msp430_if);
    
    // Start the test
    run_test();
  end

  initial begin
    $vcdpluson();
  end
endmodule
