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

class riscv_transaction extends uvm_sequence_item;
  `uvm_object_utils(riscv_transaction)

  rand bit [15:0] instrn;

  bit clk;
  bit rst;
  bit rst_cpu;
  bit rst_sys;

  dii_flit [1:0] debug_ring_in;
  dii_flit [1:0] debug_ring_out;

  bit [1:0] debug_ring_in_ready;
  bit [1:0] debug_ring_out_ready;

  bit            ahb3_ext_hsel_i;
  bit [PLEN-1:0] ahb3_ext_haddr_i;
  bit [XLEN-1:0] ahb3_ext_hwdata_i;
  bit            ahb3_ext_hwrite_i;
  bit [     2:0] ahb3_ext_hsize_i;
  bit [     2:0] ahb3_ext_hburst_i;
  bit [     3:0] ahb3_ext_hprot_i;
  bit [     1:0] ahb3_ext_htrans_i;
  bit            ahb3_ext_hmastlock_i;

  bit [XLEN-1:0] ahb3_ext_hrdata_o;
  bit            ahb3_ext_hready_o;
  bit            ahb3_ext_hresp_o;

  // Flits from NoC->tiles
  bit [CHANNELS-1:0][FLIT_WIDTH-1:0] link_in_flit;
  bit [CHANNELS-1:0]                 link_in_last;
  bit [CHANNELS-1:0]                 link_in_valid;
  bit [CHANNELS-1:0]                 link_in_ready;

  // Flits from tiles->NoC
  bit [CHANNELS-1:0][FLIT_WIDTH-1:0] link_out_flit;
  bit [CHANNELS-1:0]                 link_out_last;
  bit [CHANNELS-1:0]                 link_out_valid;
  bit [CHANNELS-1:0]                 link_out_ready;

  constraint input_constraint {
    //Cosntraint to prevent EOF operation
    instrn inside {[16'h0000:16'hEFFF]};
  }

  function new (string name = "");
    super.new(name);
  endfunction
endclass: riscv_transaction

class inst_sequence extends uvm_sequence#(riscv_transaction);
  `uvm_object_utils(inst_sequence)

  function new (string name = "");
    super.new(name);
  endfunction

  bit [15:0] inst;

  //riscv_transaction req;
  task body;
    req = riscv_transaction::type_id::create("req");
    start_item(req);

    if (!req.randomize()) begin
      `uvm_error("Instruction Sequence", "Randomize failed.");
    end

    inst = req.instrn;

    finish_item(req);
  endtask: body
endclass: inst_sequence

class riscv_sequence extends uvm_sequence#(riscv_transaction);
  `uvm_object_utils(riscv_sequence)

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
endclass: riscv_sequence
