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

  bit [ 7:0] pc;
  bit [15:0] inst_out;
  bit [15:0] reg_data;
  bit [ 1:0] reg_en;
  bit [ 2:0] reg_add;
  bit [15:0] mem_data;
  bit        mem_en;
  bit [ 2:0] mem_add;

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
