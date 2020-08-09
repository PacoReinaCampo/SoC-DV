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

`include "or1k-defines.sv"

class or1k_transaction extends uvm_sequence_item;
  `uvm_object_utils(or1k_transaction)

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

  rand bit [15:0] instrn;

  // Instruction bus
  bit                            ibus_err_i;
  bit                            ibus_ack_i;
  bit [`OR1K_INSN_WIDTH    -1:0] ibus_dat_i;
  bit [OPTION_OPERAND_WIDTH-1:0] ibus_adr_o;
  bit                            ibus_req_o;
  bit                            ibus_burst_o;

  // Data bus
  bit                            dbus_err_i;
  bit                            dbus_ack_i;
  bit [OPTION_OPERAND_WIDTH-1:0] dbus_dat_i;
  bit [OPTION_OPERAND_WIDTH-1:0] dbus_adr_o;
  bit [OPTION_OPERAND_WIDTH-1:0] dbus_dat_o;
  bit                            dbus_req_o;
  bit [                     3:0] dbus_bsel_o;
  bit                            dbus_we_o;
  bit                            dbus_burst_o;

  // Interrupts
  bit [                     31:0] irq_i;

  // Debug interface
  bit [                    15:0] du_addr_i;
  bit                            du_stb_i;
  bit [OPTION_OPERAND_WIDTH-1:0] du_dat_i;
  bit                            du_we_i;
  bit [OPTION_OPERAND_WIDTH-1:0] du_dat_o;
  bit                            du_ack_o;

  // Stall control from debug interface
  bit                            du_stall_i;
  bit                            du_stall_o;

  bit                            traceport_exec_valid_o;
  bit [                    31:0] traceport_exec_pc_o;
  bit                            traceport_exec_jb_o;
  bit                            traceport_exec_jal_o;
  bit                            traceport_exec_jr_o;
  bit [                    31:0] traceport_exec_jbtarget_o;
  bit [`OR1K_INSN_WIDTH    -1:0] traceport_exec_insn_o;
  bit [OPTION_OPERAND_WIDTH-1:0] traceport_exec_wbdata_o;
  bit [OPTION_RF_ADDR_WIDTH-1:0] traceport_exec_wbreg_o;
  bit                            traceport_exec_wben_o;

  // SPR accesses to external units (cache; mmu; etc.)
  bit [                    15:0] spr_bus_addr_o;
  bit                            spr_bus_we_o;
  bit                            spr_bus_stb_o;
  bit [OPTION_OPERAND_WIDTH-1:0] spr_bus_dat_o;
  bit [OPTION_OPERAND_WIDTH-1:0] spr_bus_dat_dmmu_i;
  bit                            spr_bus_ack_dmmu_i;
  bit [OPTION_OPERAND_WIDTH-1:0] spr_bus_dat_immu_i;
  bit                            spr_bus_ack_immu_i;
  bit [OPTION_OPERAND_WIDTH-1:0] spr_bus_dat_mac_i;
  bit                            spr_bus_ack_mac_i;
  bit [OPTION_OPERAND_WIDTH-1:0] spr_bus_dat_pmu_i;
  bit                            spr_bus_ack_pmu_i;
  bit [OPTION_OPERAND_WIDTH-1:0] spr_bus_dat_pcu_i;
  bit                            spr_bus_ack_pcu_i;
  bit [OPTION_OPERAND_WIDTH-1:0] spr_bus_dat_fpu_i;
  bit                            spr_bus_ack_fpu_i;
  bit [                    15:0] spr_sr_o;

  // The multicore core identifier
  bit [OPTION_OPERAND_WIDTH-1:0] multicore_coreid_i;

  // The number of cores
  bit [OPTION_OPERAND_WIDTH-1:0] multicore_numcores_i;

  bit [                    31:0] snoop_adr_i;
  bit                            snoop_en_i;

  constraint input_constraint {
    //Cosntraint to prevent EOF operation
    instrn inside {[16'h0000:16'hEFFF]};
  }

  function new (string name = "");
    super.new(name);
  endfunction
endclass: or1k_transaction

class inst_sequence extends uvm_sequence#(or1k_transaction);
  `uvm_object_utils(inst_sequence)

  function new (string name = "");
    super.new(name);
  endfunction

  bit [15:0] inst;

  //or1k_transaction req;
  task body;
    req = or1k_transaction::type_id::create("req");
    start_item(req);

    if (!req.randomize()) begin
      `uvm_error("Instruction Sequence", "Randomize failed.");
    end

    inst = req.instrn;

    finish_item(req);
  endtask: body
endclass: inst_sequence

class or1k_sequence extends uvm_sequence#(or1k_transaction);
  `uvm_object_utils(or1k_sequence)

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
endclass: or1k_sequence
