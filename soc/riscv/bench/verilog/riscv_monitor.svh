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

class riscv_monitor extends uvm_monitor;
  // register the monitor in the UVM factory
  `uvm_component_utils(riscv_monitor)

  int count;

  // Declare virtual interface
  virtual riscv_interface riscv_vif;

  // Analysis port to broadcast results to scoreboard 
  uvm_analysis_port #(riscv_transaction) monitor2scoreboard_port;

  // Analysis port to broadcast results to subscriber 
  uvm_analysis_port #(riscv_transaction) aport;
    
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual riscv_interface)::get(this, "", "riscv_vif", riscv_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end

    monitor2scoreboard_port = new("monitor2scoreboard",this);
    aport = new("aport",this);
  endfunction

  task run_phase(uvm_phase phase);
    riscv_transaction pu_transaction;
    pu_transaction = new ("transaction");
    count = 0;
    fork
      forever begin
        @(riscv_vif.monitor_if_mp.monitor_cb.inst_out) begin
          if(count<17) begin
            count++;
          end
          else begin
            // Instruction Memory Access bus
            pu_transaction.if_stall_nxt_pc      = or1k_vif.monitor_if_mp.monitor_cb.if_stall_nxt_pc;
            pu_transaction.if_nxt_pc            = or1k_vif.monitor_if_mp.monitor_cb.if_nxt_pc;
            pu_transaction.if_stall             = or1k_vif.monitor_if_mp.monitor_cb.if_stall;
            pu_transaction.if_flush             = or1k_vif.monitor_if_mp.monitor_cb.if_flush;
            pu_transaction.if_parcel            = or1k_vif.monitor_if_mp.monitor_cb.if_parcel;
            pu_transaction.if_parcel_pc         = or1k_vif.monitor_if_mp.monitor_cb.if_parcel_pc;
            pu_transaction.if_parcel_valid      = or1k_vif.monitor_if_mp.monitor_cb.if_parcel_valid;
            pu_transaction.if_parcel_misaligned = or1k_vif.monitor_if_mp.monitor_cb.if_parcel_misaligned;
            pu_transaction.if_parcel_page_fault = or1k_vif.monitor_if_mp.monitor_cb.if_parcel_page_fault;

            // Data Memory Access bus
            pu_transaction.dmem_adr        = or1k_vif.monitor_if_mp.monitor_cb.dmem_adr;
            pu_transaction.dmem_d          = or1k_vif.monitor_if_mp.monitor_cb.dmem_d;
            pu_transaction.dmem_q          = or1k_vif.monitor_if_mp.monitor_cb.dmem_q;
            pu_transaction.dmem_we         = or1k_vif.monitor_if_mp.monitor_cb.dmem_we;
            pu_transaction.dmem_size       = or1k_vif.monitor_if_mp.monitor_cb.dmem_size;
            pu_transaction.dmem_req        = or1k_vif.monitor_if_mp.monitor_cb.dmem_req;
            pu_transaction.dmem_ack        = or1k_vif.monitor_if_mp.monitor_cb.dmem_ack;
            pu_transaction.dmem_err        = or1k_vif.monitor_if_mp.monitor_cb.dmem_err;
            pu_transaction.dmem_misaligned = or1k_vif.monitor_if_mp.monitor_cb.dmem_misaligned;
            pu_transaction.dmem_page_fault = or1k_vif.monitor_if_mp.monitor_cb.dmem_page_fault;

            // cpu state
            pu_transaction.st_prv     = or1k_vif.monitor_if_mp.monitor_cb.st_prv;
            pu_transaction.st_pmpcfg  = or1k_vif.monitor_if_mp.monitor_cb.st_pmpcfg;
            pu_transaction.st_pmpaddr = or1k_vif.monitor_if_mp.monitor_cb.st_pmpaddr;

            pu_transaction.bu_cacheflush = or1k_vif.monitor_if_mp.monitor_cb.bu_cacheflush;

            // Interrupts
            pu_transaction.ext_nmi  = or1k_vif.monitor_if_mp.monitor_cb.ext_nmi;
            pu_transaction.ext_tint = or1k_vif.monitor_if_mp.monitor_cb.ext_tint;
            pu_transaction.ext_sint = or1k_vif.monitor_if_mp.monitor_cb.ext_sint;
            pu_transaction.ext_int  = or1k_vif.monitor_if_mp.monitor_cb.ext_int;

            // Debug Interface
            pu_transaction.dbg_stall = or1k_vif.monitor_if_mp.monitor_cb.dbg_stall;
            pu_transaction.dbg_strb  = or1k_vif.monitor_if_mp.monitor_cb.dbg_strb;
            pu_transaction.dbg_we    = or1k_vif.monitor_if_mp.monitor_cb.dbg_we;
            pu_transaction.dbg_addr  = or1k_vif.monitor_if_mp.monitor_cb.dbg_addr;
            pu_transaction.dbg_dati  = or1k_vif.monitor_if_mp.monitor_cb.dbg_dati;
            pu_transaction.dbg_dato  = or1k_vif.monitor_if_mp.monitor_cb.dbg_dato;
            pu_transaction.dbg_ack   = or1k_vif.monitor_if_mp.monitor_cb.dbg_ack;
            pu_transaction.dbg_bp    = or1k_vif.monitor_if_mp.monitor_cb.dbg_bp;

            // Send transaction to Scoreboard
            monitor2scoreboard_port.write(pu_transaction);

            // Send transaction to subscriber
            aport.write(pu_transaction);
            count = 0;
          end
        end
      end
    join
  endtask : run_phase
endclass : riscv_monitor
