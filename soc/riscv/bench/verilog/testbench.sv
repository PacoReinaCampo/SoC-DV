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
`include "riscv_sequence.svh"
`include "riscv_driver.svh"
`include "riscv_monitor.svh"
`include "riscv_scoreboard.svh"
`include "riscv_subscriber.svh"
`include "riscv_agent.svh"
`include "riscv_env.svh"
`include "riscv_test.svh"

`include "riscv_mpsoc_pkg.sv"

module test;

  // Instantiate interface
  riscv_interface riscv_if();

  // Instantiate dut
  riscv_core #(
    .XLEN                  ( XLEN                  ),
    .PLEN                  ( PLEN                  ),
    .HAS_USER              ( HAS_USER              ),
    .HAS_SUPER             ( HAS_SUPER             ),
    .HAS_HYPER             ( HAS_HYPER             ),
    .HAS_BPU               ( HAS_BPU               ),
    .HAS_FPU               ( HAS_FPU               ),
    .HAS_MMU               ( HAS_MMU               ),
    .HAS_RVM               ( HAS_RVM               ),
    .HAS_RVA               ( HAS_RVA               ),
    .HAS_RVC               ( HAS_RVC               ),
    .IS_RV32E              ( IS_RV32E              ),

    .MULT_LATENCY          ( MULT_LATENCY          ),

    .BREAKPOINTS           ( BREAKPOINTS           ),
    .PMP_CNT               ( PMP_CNT               ),

    .BP_GLOBAL_BITS        ( BP_GLOBAL_BITS        ),
    .BP_LOCAL_BITS         ( BP_LOCAL_BITS         ),

    .TECHNOLOGY            ( TECHNOLOGY            ),

    .MNMIVEC_DEFAULT       ( MNMIVEC_DEFAULT       ),
    .MTVEC_DEFAULT         ( MTVEC_DEFAULT         ),
    .HTVEC_DEFAULT         ( HTVEC_DEFAULT         ),
    .STVEC_DEFAULT         ( STVEC_DEFAULT         ),
    .UTVEC_DEFAULT         ( UTVEC_DEFAULT         ),

    .JEDEC_BANK            ( JEDEC_BANK            ),
    .JEDEC_MANUFACTURER_ID ( JEDEC_MANUFACTURER_ID ),

    .HARTID                ( HARTID                ), 

    .PC_INIT               ( PC_INIT               ),
    .PARCEL_SIZE           ( PARCEL_SIZE           )
  )
  dut (
    .rstn                 ( riscv_if.rstn                 ),
    .clk                  ( riscv_if.clk                  ),

    .if_stall_nxt_pc      ( riscv_if.if_stall_nxt_pc      ),
    .if_nxt_pc            ( riscv_if.if_nxt_pc            ),
    .if_stall             ( riscv_if.if_stall             ),
    .if_flush             ( riscv_if.if_flush             ),
    .if_parcel            ( riscv_if.if_parcel            ),
    .if_parcel_pc         ( riscv_if.if_parcel_pc         ),
    .if_parcel_valid      ( riscv_if.if_parcel_valid      ),
    .if_parcel_misaligned ( riscv_if.if_parcel_misaligned ),
    .if_parcel_page_fault ( riscv_if.if_parcel_page_fault ),
    .dmem_adr             ( riscv_if.dmem_adr             ),
    .dmem_d               ( riscv_if.dmem_d               ),
    .dmem_q               ( riscv_if.dmem_q               ),
    .dmem_we              ( riscv_if.dmem_we              ),
    .dmem_size            ( riscv_if.dmem_size            ),
    .dmem_req             ( riscv_if.dmem_req             ),
    .dmem_ack             ( riscv_if.dmem_ack             ),
    .dmem_err             ( riscv_if.dmem_err             ),
    .dmem_misaligned      ( riscv_if.dmem_misaligned      ),
    .dmem_page_fault      ( riscv_if.dmem_page_fault      ),
    .st_prv               ( riscv_if.st_prv               ),
    .st_pmpcfg            ( riscv_if.st_pmpcfg            ),
    .st_pmpaddr           ( riscv_if.st_pmpaddr           ),

    .bu_cacheflush        ( riscv_if.cacheflush           ),

    .ext_nmi              ( riscv_if.ext_nmi              ),
    .ext_tint             ( riscv_if.ext_tint             ),
    .ext_sint             ( riscv_if.ext_sint             ),
    .ext_int              ( riscv_if.ext_int              ),
    .dbg_stall            ( riscv_if.dbg_stall            ),
    .dbg_strb             ( riscv_if.dbg_strb             ),
    .dbg_we               ( riscv_if.dbg_we               ),
    .dbg_addr             ( riscv_if.dbg_addr             ),
    .dbg_dati             ( riscv_if.dbg_dati             ),
    .dbg_dato             ( riscv_if.dbg_dato             ),
    .dbg_ack              ( riscv_if.dbg_ack              ),
    .dbg_bp               ( riscv_if.dbg_bp               )
  ); 

  //Clock generation
  always #5 riscv_if.clk = ~riscv_if.clk;
  
  initial begin
    riscv_if.clk = 0;
  end

  initial begin
    // Place the interface into the UVM configuration database
    uvm_config_db#(virtual riscv_interface)::set(null, "*", "riscv_vif", riscv_if);
    
    // Start the test
    run_test();
  end

  initial begin
    $vcdpluson();
  end
endmodule
