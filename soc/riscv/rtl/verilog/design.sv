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

interface riscv_interface #(
  parameter            XLEN                  = 64,
  parameter            PLEN                  = 64,
  parameter            ILEN                  = 64,
  parameter            EXCEPTION_SIZE        = 16,
  parameter [XLEN-1:0] PC_INIT               = 'h200,
  parameter            HAS_USER              = 1,
  parameter            HAS_SUPER             = 1,
  parameter            HAS_HYPER             = 1,
  parameter            HAS_BPU               = 1,
  parameter            HAS_FPU               = 1,
  parameter            HAS_MMU               = 1,
  parameter            HAS_RVA               = 1,
  parameter            HAS_RVM               = 1,
  parameter            HAS_RVC               = 1,
  parameter            IS_RV32E              = 1,

  parameter            MULT_LATENCY          = 1,

  parameter            BREAKPOINTS           = 8,

  parameter            PMA_CNT               = 4,
  parameter            PMP_CNT               = 16,

  parameter            BP_GLOBAL_BITS        = 2,
  parameter            BP_LOCAL_BITS         = 10,
  parameter            BP_LOCAL_BITS_LSB     = 2,

  parameter            DU_ADDR_SIZE          = 12,
  parameter            MAX_BREAKPOINTS       = 8,

  parameter            TECHNOLOGY            = "GENERIC",

  parameter            MNMIVEC_DEFAULT       = PC_INIT - 'h004,
  parameter            MTVEC_DEFAULT         = PC_INIT - 'h040,
  parameter            HTVEC_DEFAULT         = PC_INIT - 'h080,
  parameter            STVEC_DEFAULT         = PC_INIT - 'h0C0,
  parameter            UTVEC_DEFAULT         = PC_INIT - 'h100,

  parameter            JEDEC_BANK            = 10,
  parameter            JEDEC_MANUFACTURER_ID = 'h6e,

  parameter            HARTID                = 0,

  parameter            PARCEL_SIZE           = 64
)
  ();

  logic                      rstn;  // Reset
  logic                      clk;   // Clock

  // Instruction Memory Access bus
  logic                      if_stall_nxt_pc;
  logic [XLEN          -1:0] if_nxt_pc;
  logic                      if_stall;
  logic                      if_flush;
  logic [PARCEL_SIZE   -1:0] if_parcel;
  logic [XLEN          -1:0] if_parcel_pc;
  logic [PARCEL_SIZE/16-1:0] if_parcel_valid;
  logic                      if_parcel_misaligned;
  logic                      if_parcel_page_fault;

  // Data Memory Access bus
  logic [XLEN         -1:0] dmem_adr;
  logic [XLEN         -1:0] dmem_d;
  logic [XLEN         -1:0] dmem_q;
  logic                     dmem_we;
  logic [              2:0] dmem_size;
  logic                     dmem_req;
  logic                     dmem_ack;
  logic                     dmem_err;
  logic                     dmem_misaligned;
  logic                     dmem_page_fault;

  // cpu state
  logic              [     1:0] st_prv;
  logic [PMP_CNT-1:0][     7:0] st_pmpcfg;
  logic [PMP_CNT-1:0][XLEN-1:0] st_pmpaddr;

  logic                     bu_cacheflush;

  // Interrupts
  logic                     ext_nmi;
  logic                     ext_tint;
  logic                     ext_sint;
  logic [              3:0] ext_int;

  // Debug Interface
  logic                     dbg_stall;
  logic                     dbg_strb;
  logic                     dbg_we;
  logic [PLEN         -1:0] dbg_addr;
  logic [XLEN         -1:0] dbg_dati;
  logic [XLEN         -1:0] dbg_dato;
  logic                     dbg_ack;
  logic                     dbg_bp;
  
  clocking master_cb @(posedge clk);
    output rstn;  // Reset
    output clk;   // Clock

    // Instruction Memory Access bus
    output if_stall_nxt_pc;
    input  if_nxt_pc;
    input  if_stall;
    input  if_flush;
    output if_parcel;
    output if_parcel_pc;
    output if_parcel_valid;
    output if_parcel_misaligned;
    output if_parcel_page_fault;

    // Data Memory Access bus
    input  dmem_adr;
    input  dmem_d;
    output dmem_q;
    input  dmem_we;
    input  dmem_size;
    input  dmem_req;
    output dmem_ack;
    output dmem_err;
    output dmem_misaligned;
    output dmem_page_fault;

    // cpu state
    input  st_prv;
    input  st_pmpcfg;
    input  st_pmpaddr;

    input  bu_cacheflush;

    // Interrupts
    output ext_nmi;
    output ext_tint;
    output ext_sint;
    output ext_int;

    // Debug Interface
    output dbg_stall;
    output dbg_strb;
    output dbg_we;
    output dbg_addr;
    output dbg_dati;
    input  dbg_dato;
    input  dbg_ack;
    input  dbg_bp;
  endclocking : master_cb

  clocking slave_cb @(posedge clk);
    input  rstn;  // Reset
    input  clk;   // Clock

    // Instruction Memory Access bus
    input  if_stall_nxt_pc;
    output if_nxt_pc;
    output if_stall;
    output if_flush;
    input  if_parcel;
    input  if_parcel_pc;
    input  if_parcel_valid;
    input  if_parcel_misaligned;
    input  if_parcel_page_fault;

    // Data Memory Access bus
    output dmem_adr;
    output dmem_d;
    input  dmem_q;
    output dmem_we;
    output dmem_size;
    output dmem_req;
    input  dmem_ack;
    input  dmem_err;
    input  dmem_misaligned;
    input  dmem_page_fault;

    // cpu state
    output st_prv;
    output st_pmpcfg;
    output st_pmpaddr;

    output bu_cacheflush;

    // Interrupts
    input  ext_nmi;
    input  ext_tint;
    input  ext_sint;
    input  ext_int;

    // Debug Interface
    input  dbg_stall;
    input  dbg_strb;
    input  dbg_we;
    input  dbg_addr;
    input  dbg_dati;
    output dbg_dato;
    output dbg_ack;
    output dbg_bp;
  endclocking : slave_cb
  
  clocking monitor_cb @(posedge clk);
    input rstn;  // Reset
    input clk;   // Clock

    // Instruction Memory Access bus
    input if_stall_nxt_pc;
    input if_nxt_pc;
    input if_stall;
    input if_flush;
    input if_parcel;
    input if_parcel_pc;
    input if_parcel_valid;
    input if_parcel_misaligned;
    input if_parcel_page_fault;

    // Data Memory Access bus
    input dmem_adr;
    input dmem_d;
    input dmem_q;
    input dmem_we;
    input dmem_size;
    input dmem_req;
    input dmem_ack;
    input dmem_err;
    input dmem_misaligned;
    input dmem_page_fault;

    // cpu state
    input st_prv;
    input st_pmpcfg;
    input st_pmpaddr;

    input bu_cacheflush;

    // Interrupts
    input ext_nmi;
    input ext_tint;
    input ext_sint;
    input ext_int;

    // Debug Interface
    input dbg_stall;
    input dbg_strb;
    input dbg_we;
    input dbg_addr;
    input dbg_dati;
    input dbg_dato;
    input dbg_ack;
    input dbg_bp;
  endclocking : monitor_cb

  modport master(clocking master_cb);
  modport slave(clocking slave_cb);
  modport passive(clocking monitor_cb);
endinterface
