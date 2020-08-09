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
`include "or1k_sequence.svh"
`include "or1k_driver.svh"
`include "or1k_monitor.svh"
`include "or1k_scoreboard.svh"
`include "or1k_subscriber.svh"
`include "or1k_agent.svh"
`include "or1k_env.svh"
`include "or1k_test.svh"

`include "or1k-defines.sv"

module test;

  parameter OPTION_OPERAND_WIDTH = 32;

  parameter OPTION_CPU0 = "CAPPUCCINO";

  parameter FEATURE_DATACACHE          = "NONE";
  parameter OPTION_DCACHE_BLOCK_WIDTH  = 5;
  parameter OPTION_DCACHE_SET_WIDTH    = 9;
  parameter OPTION_DCACHE_WAYS         = 2;
  parameter OPTION_DCACHE_LIMIT_WIDTH  = 32;
  parameter OPTION_DCACHE_SNOOP        = "NONE";
  parameter FEATURE_DMMU               = "NONE";
  parameter FEATURE_DMMU_HW_TLB_RELOAD = "NONE";
  parameter OPTION_DMMU_SET_WIDTH      = 6;
  parameter OPTION_DMMU_WAYS           = 1;
  parameter FEATURE_INSTRUCTIONCACHE   = "NONE";
  parameter OPTION_ICACHE_BLOCK_WIDTH  = 5;
  parameter OPTION_ICACHE_SET_WIDTH    = 9;
  parameter OPTION_ICACHE_WAYS         = 2;
  parameter OPTION_ICACHE_LIMIT_WIDTH  = 32;
  parameter FEATURE_IMMU               = "NONE";
  parameter FEATURE_IMMU_HW_TLB_RELOAD = "NONE";
  parameter OPTION_IMMU_SET_WIDTH      = 6;
  parameter OPTION_IMMU_WAYS           = 1;
  parameter FEATURE_TIMER              = "ENABLED";
  parameter FEATURE_DEBUGUNIT          = "NONE";
  parameter FEATURE_PERFCOUNTERS       = "NONE";
  parameter OPTION_PERFCOUNTERS_NUM    = 0;
  parameter FEATURE_MAC                = "NONE";

  parameter FEATURE_SYSCALL = "ENABLED";
  parameter FEATURE_TRAP    = "ENABLED";
  parameter FEATURE_RANGE   = "ENABLED";

  parameter FEATURE_PIC          = "ENABLED";
  parameter OPTION_PIC_TRIGGER   = "LEVEL";
  parameter OPTION_PIC_NMI_WIDTH = 0;

  parameter FEATURE_DSX        = "NONE";
  parameter FEATURE_OVERFLOW   = "NONE";
  parameter FEATURE_CARRY_FLAG = "ENABLED";

  parameter FEATURE_FASTCONTEXTS     = "NONE";
  parameter OPTION_RF_CLEAR_ON_INIT  = 0;
  parameter OPTION_RF_NUM_SHADOW_GPR = 0;
  parameter OPTION_RF_ADDR_WIDTH     = 5;
  parameter OPTION_RF_WORDS          = 32;

  parameter OPTION_RESET_PC = {{(OPTION_OPERAND_WIDTH-13){1'b0}}, `OR1K_RESET_VECTOR, 8'd0};

  parameter OPTION_TCM_FETCHER = "DISABLED";

  parameter FEATURE_MULTIPLIER = "THREESTAGE";
  parameter FEATURE_DIVIDER    = "NONE";

  parameter OPTION_SHIFTER = "BARREL";

  parameter FEATURE_ADDC   = "NONE";
  parameter FEATURE_SRA    = "ENABLED";
  parameter FEATURE_ROR    = "NONE";
  parameter FEATURE_EXT    = "NONE";
  parameter FEATURE_CMOV   = "NONE";
  parameter FEATURE_FFL1   = "NONE";
  parameter FEATURE_MSYNC  = "ENABLED";
  parameter FEATURE_PSYNC  = "NONE";
  parameter FEATURE_CSYNC  = "NONE";
  parameter FEATURE_ATOMIC = "ENABLED";

  parameter FEATURE_FPU          = "NONE"; // ENABLED|NONE
  parameter OPTION_FTOI_ROUNDING = "CPP"; // "CPP" / "IEEE"

  parameter FEATURE_CUST1 = "NONE";
  parameter FEATURE_CUST2 = "NONE";
  parameter FEATURE_CUST3 = "NONE";
  parameter FEATURE_CUST4 = "NONE";
  parameter FEATURE_CUST5 = "NONE";
  parameter FEATURE_CUST6 = "NONE";
  parameter FEATURE_CUST7 = "NONE";
  parameter FEATURE_CUST8 = "NONE";

  parameter FEATURE_STORE_BUFFER            = "ENABLED";
  parameter OPTION_STORE_BUFFER_DEPTH_WIDTH = 8;

  parameter FEATURE_MULTICORE = "NONE";

  parameter FEATURE_TRACEPORT_EXEC   = "NONE";
  parameter FEATURE_BRANCH_PREDICTOR = "SIMPLE";

  // Instantiate interface
  or1k_interface or1k_if();

  // Instantiate dut
  or1k_cpu #(
    .OPTION_OPERAND_WIDTH            (OPTION_OPERAND_WIDTH),
    .OPTION_CPU                      (OPTION_CPU0),
    .FEATURE_DATACACHE               (FEATURE_DATACACHE),
    .OPTION_DCACHE_BLOCK_WIDTH       (OPTION_DCACHE_BLOCK_WIDTH),
    .OPTION_DCACHE_SET_WIDTH         (OPTION_DCACHE_SET_WIDTH),
    .OPTION_DCACHE_WAYS              (OPTION_DCACHE_WAYS),
    .OPTION_DCACHE_LIMIT_WIDTH       (OPTION_DCACHE_LIMIT_WIDTH),
    .OPTION_DCACHE_SNOOP             (OPTION_DCACHE_SNOOP),
    .FEATURE_DMMU                    (FEATURE_DMMU),
    .FEATURE_DMMU_HW_TLB_RELOAD      (FEATURE_DMMU_HW_TLB_RELOAD),
    .OPTION_DMMU_SET_WIDTH           (OPTION_DMMU_SET_WIDTH),
    .OPTION_DMMU_WAYS                (OPTION_DMMU_WAYS),
    .FEATURE_INSTRUCTIONCACHE        (FEATURE_INSTRUCTIONCACHE),
    .OPTION_ICACHE_BLOCK_WIDTH       (OPTION_ICACHE_BLOCK_WIDTH),
    .OPTION_ICACHE_SET_WIDTH         (OPTION_ICACHE_SET_WIDTH),
    .OPTION_ICACHE_WAYS              (OPTION_ICACHE_WAYS),
    .OPTION_ICACHE_LIMIT_WIDTH       (OPTION_ICACHE_LIMIT_WIDTH),
    .FEATURE_IMMU                    (FEATURE_IMMU),
    .FEATURE_IMMU_HW_TLB_RELOAD      (FEATURE_IMMU_HW_TLB_RELOAD),
    .OPTION_IMMU_SET_WIDTH           (OPTION_IMMU_SET_WIDTH),
    .OPTION_IMMU_WAYS                (OPTION_IMMU_WAYS),
    .FEATURE_PIC                     (FEATURE_PIC),
    .FEATURE_TIMER                   (FEATURE_TIMER),
    .FEATURE_DEBUGUNIT               (FEATURE_DEBUGUNIT),
    .FEATURE_PERFCOUNTERS            (FEATURE_PERFCOUNTERS),
    .OPTION_PERFCOUNTERS_NUM         (OPTION_PERFCOUNTERS_NUM),
    .FEATURE_MAC                     (FEATURE_MAC),
    .FEATURE_SYSCALL                 (FEATURE_SYSCALL),
    .FEATURE_TRAP                    (FEATURE_TRAP),
    .FEATURE_RANGE                   (FEATURE_RANGE),
    .OPTION_PIC_TRIGGER              (OPTION_PIC_TRIGGER),
    .OPTION_PIC_NMI_WIDTH            (OPTION_PIC_NMI_WIDTH),
    .FEATURE_DSX                     (FEATURE_DSX),
    .FEATURE_OVERFLOW                (FEATURE_OVERFLOW),
    .FEATURE_CARRY_FLAG              (FEATURE_CARRY_FLAG),
    .FEATURE_FASTCONTEXTS            (FEATURE_FASTCONTEXTS),
    .OPTION_RF_CLEAR_ON_INIT         (OPTION_RF_CLEAR_ON_INIT),
    .OPTION_RF_NUM_SHADOW_GPR        (OPTION_RF_NUM_SHADOW_GPR),
    .OPTION_RF_ADDR_WIDTH            (OPTION_RF_ADDR_WIDTH),
    .OPTION_RF_WORDS                 (OPTION_RF_WORDS),
    .OPTION_RESET_PC                 (OPTION_RESET_PC),
    .FEATURE_MULTIPLIER              (FEATURE_MULTIPLIER),
    .FEATURE_DIVIDER                 (FEATURE_DIVIDER),
    .FEATURE_ADDC                    (FEATURE_ADDC),
    .FEATURE_SRA                     (FEATURE_SRA),
    .FEATURE_ROR                     (FEATURE_ROR),
    .FEATURE_EXT                     (FEATURE_EXT),
    .FEATURE_CMOV                    (FEATURE_CMOV),
    .FEATURE_FFL1                    (FEATURE_FFL1),
    .FEATURE_ATOMIC                  (FEATURE_ATOMIC),
    .FEATURE_FPU                     (FEATURE_FPU), // or1k_cpu instance
    .OPTION_FTOI_ROUNDING            (OPTION_FTOI_ROUNDING), // or1k_cpu instance       
    .FEATURE_CUST1                   (FEATURE_CUST1),
    .FEATURE_CUST2                   (FEATURE_CUST2),
    .FEATURE_CUST3                   (FEATURE_CUST3),
    .FEATURE_CUST4                   (FEATURE_CUST4),
    .FEATURE_CUST5                   (FEATURE_CUST5),
    .FEATURE_CUST6                   (FEATURE_CUST6),
    .FEATURE_CUST7                   (FEATURE_CUST7),
    .FEATURE_CUST8                   (FEATURE_CUST8),
    .OPTION_SHIFTER                  (OPTION_SHIFTER),
    .FEATURE_STORE_BUFFER            (FEATURE_STORE_BUFFER),
    .OPTION_STORE_BUFFER_DEPTH_WIDTH (OPTION_STORE_BUFFER_DEPTH_WIDTH),
    .FEATURE_MULTICORE               (FEATURE_MULTICORE),
    .FEATURE_TRACEPORT_EXEC          (FEATURE_TRACEPORT_EXEC),
    .FEATURE_BRANCH_PREDICTOR        (FEATURE_BRANCH_PREDICTOR)
  )
  dut (
    .clk    (or1k_if.clk),
    .rst    (or1k_if.rst),

    .ibus_err_i   (or1k_if.ibus_err_i),
    .ibus_ack_i   (or1k_if.ibus_ack_i),
    .ibus_dat_i   (or1k_if.ibus_dat_i[`OR1K_INSN_WIDTH-1:0]),
    .ibus_adr_o   (or1k_if.ibus_adr_o[OPTION_OPERAND_WIDTH-1:0]),
    .ibus_req_o   (or1k_if.ibus_req_o),
    .ibus_burst_o (or1k_if.ibus_burst_o),

    .dbus_err_i   (or1k_if.dbus_err_i),
    .dbus_ack_i   (or1k_if.dbus_ack_i),
    .dbus_dat_i   (or1k_if.dbus_dat_i[OPTION_OPERAND_WIDTH-1:0]),
    .dbus_adr_o   (or1k_if.dbus_adr_o[OPTION_OPERAND_WIDTH-1:0]),
    .dbus_dat_o   (or1k_if.dbus_dat_o[OPTION_OPERAND_WIDTH-1:0]),
    .dbus_req_o   (or1k_if.dbus_req_o),
    .dbus_bsel_o  (or1k_if.dbus_bsel_o[3:0]),
    .dbus_we_o    (or1k_if.dbus_we_o),
    .dbus_burst_o (or1k_if.dbus_burst_o),

    .irq_i (or1k_if.irq_i[31:0]),

    .du_addr_i   (or1k_if.du_addr_i[15:0]),
    .du_stb_i    (or1k_if.du_stb_i),
    .du_dat_i    (or1k_if.du_dat_i[OPTION_OPERAND_WIDTH-1:0]),
    .du_we_i     (or1k_if.du_we_i),
    .du_dat_o    (or1k_if.du_dat_o[OPTION_OPERAND_WIDTH-1:0]),
    .du_ack_o    (or1k_if.du_ack_o),
    .du_stall_o  (or1k_if.du_stall_o),
    .du_stall_i  (or1k_if.du_stall_i),

    .traceport_exec_valid_o    (or1k_if.traceport_exec_valid_o),
    .traceport_exec_pc_o       (or1k_if.traceport_exec_pc_o[31:0]),
    .traceport_exec_jb_o       (or1k_if.traceport_exec_jb_o),
    .traceport_exec_jal_o      (or1k_if.traceport_exec_jal_o),
    .traceport_exec_jr_o       (or1k_if.traceport_exec_jr_o),
    .traceport_exec_jbtarget_o (or1k_if.traceport_exec_jbtarget_o[31:0]),
    .traceport_exec_insn_o     (or1k_if.traceport_exec_insn_o[`OR1K_INSN_WIDTH-1:0]),
    .traceport_exec_wbdata_o   (or1k_if.traceport_exec_wbdata_o[OPTION_OPERAND_WIDTH-1:0]),
    .traceport_exec_wbreg_o    (or1k_if.traceport_exec_wbreg_o[OPTION_RF_ADDR_WIDTH-1:0]),
    .traceport_exec_wben_o     (or1k_if.traceport_exec_wben_o),


    .spr_bus_addr_o     (or1k_if.spr_bus_addr_o[15:0]),
    .spr_bus_we_o       (or1k_if.spr_bus_we_o),
    .spr_bus_stb_o      (or1k_if.spr_bus_stb_o),
    .spr_bus_dat_o      (or1k_if.spr_bus_dat_o[OPTION_OPERAND_WIDTH-1:0]),
    .spr_bus_dat_dmmu_i (),
    .spr_bus_ack_dmmu_i (),
    .spr_bus_dat_immu_i (),
    .spr_bus_ack_immu_i (),
    .spr_bus_dat_mac_i  (),
    .spr_bus_ack_mac_i  (),
    .spr_bus_dat_pmu_i  (),
    .spr_bus_ack_pmu_i  (),
    .spr_bus_dat_pcu_i  (),
    .spr_bus_ack_pcu_i  (),
    .spr_bus_dat_fpu_i  (),
    .spr_bus_ack_fpu_i  (),
    .spr_sr_o           (or1k_if.spr_sr_o[15:0]),

    .multicore_coreid_i   (or1k_if.multicore_coreid_i[OPTION_OPERAND_WIDTH-1:0]),
    .multicore_numcores_i (or1k_if.multicore_numcores_i[OPTION_OPERAND_WIDTH-1:0]),

    .snoop_adr_i (or1k_if.snoop_adr_i[31:0]),
    .snoop_en_i  (or1k_if.snoop_en_i)
  );

  //Clock generation
  always #5 or1k_if.clk = ~or1k_if.clk;
  
  initial begin
    or1k_if.clk = 0;
  end

  initial begin
    // Place the interface into the UVM configuration database
    uvm_config_db#(virtual or1k_interface)::set(null, "*", "or1k_vif", or1k_if);
    
    // Start the test
    run_test();
  end

  initial begin
    $vcdpluson();
  end
endmodule
