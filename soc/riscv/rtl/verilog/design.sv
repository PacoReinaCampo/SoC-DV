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

interface riscv_interface;

  wire clk;
  wire rst;
  wire rst_cpu;
  wire rst_sys;

  dii_flit [1:0] debug_ring_in;
  dii_flit [1:0] debug_ring_out;

  wire [1:0] debug_ring_in_ready;
  wire [1:0] debug_ring_out_ready;

  wire            ahb3_ext_hsel_i;
  wire [PLEN-1:0] ahb3_ext_haddr_i;
  wire [XLEN-1:0] ahb3_ext_hwdata_i;
  wire            ahb3_ext_hwrite_i;
  wire [     2:0] ahb3_ext_hsize_i;
  wire [     2:0] ahb3_ext_hburst_i;
  wire [     3:0] ahb3_ext_hprot_i;
  wire [     1:0] ahb3_ext_htrans_i;
  wire            ahb3_ext_hmastlock_i;

  wire [XLEN-1:0] ahb3_ext_hrdata_o;
  wire            ahb3_ext_hready_o;
  wire            ahb3_ext_hresp_o;

  // Flits from NoC->tiles
  wire [CHANNELS-1:0][FLIT_WIDTH-1:0] link_in_flit;
  wire [CHANNELS-1:0]                 link_in_last;
  wire [CHANNELS-1:0]                 link_in_valid;
  wire [CHANNELS-1:0]                 link_in_ready;

  // Flits from tiles->NoC
  wire [CHANNELS-1:0][FLIT_WIDTH-1:0] link_out_flit;
  wire [CHANNELS-1:0]                 link_out_last;
  wire [CHANNELS-1:0]                 link_out_valid;
  wire [CHANNELS-1:0]                 link_out_ready;
  
  clocking master_cb @(posedge clk);
    output clk;
    output rst;
    output rst_cpu;
    output rst_sys;

    output debug_ring_in;
    input  debug_ring_out;

    input  debug_ring_in_ready;
    output debug_ring_out_ready;

    input  ahb3_ext_hsel_i;
    input  ahb3_ext_haddr_i;
    input  ahb3_ext_hwdata_i;
    input  ahb3_ext_hwrite_i;
    input  ahb3_ext_hsize_i;
    input  ahb3_ext_hburst_i;
    input  ahb3_ext_hprot_i;
    input  ahb3_ext_htrans_i;
    input  ahb3_ext_hmastlock_i;

    output ahb3_ext_hrdata_o;
    output ahb3_ext_hready_o;
    output ahb3_ext_hresp_o;

    // Flits from NoC->tiles
    output link_in_flit;
    output link_in_last;
    output link_in_valid;
    input  link_in_ready;

    // Flits from tiles->NoC
    input  link_out_flit;
    input  link_out_last;
    input  link_out_valid;
    output link_out_ready;
  endclocking : master_cb

  clocking slave_cb @(posedge clk);
    input  clk;
    input  rst;
    input  rst_cpu;
    input  rst_sys;

    input  debug_ring_in;
    output debug_ring_out;

    output debug_ring_in_ready;
    input  debug_ring_out_ready;

    output ahb3_ext_hsel_i;
    output ahb3_ext_haddr_i;
    output ahb3_ext_hwdata_i;
    output ahb3_ext_hwrite_i;
    output ahb3_ext_hsize_i;
    output ahb3_ext_hburst_i;
    output ahb3_ext_hprot_i;
    output ahb3_ext_htrans_i;
    output ahb3_ext_hmastlock_i;

    input  ahb3_ext_hrdata_o;
    input  ahb3_ext_hready_o;
    input  ahb3_ext_hresp_o;

    // Flits from NoC->tiles
    input  link_in_flit;
    input  link_in_last;
    input  link_in_valid;
    output link_in_ready;

    // Flits from tiles->NoC
    output link_out_flit;
    output link_out_last;
    output link_out_valid;
    input  link_out_ready;
  endclocking : slave_cb
  
  clocking monitor_cb @(posedge clk);
    input clk;
    input rst;
    input rst_cpu;
    input rst_sys;

    input debug_ring_in;
    input debug_ring_out;

    input debug_ring_in_ready;
    input debug_ring_out_ready;

    input ahb3_ext_hsel_i;
    input ahb3_ext_haddr_i;
    input ahb3_ext_hwdata_i;
    input ahb3_ext_hwrite_i;
    input ahb3_ext_hsize_i;
    input ahb3_ext_hburst_i;
    input ahb3_ext_hprot_i;
    input ahb3_ext_htrans_i;
    input ahb3_ext_hmastlock_i;

    input ahb3_ext_hrdata_o;
    input ahb3_ext_hready_o;
    input ahb3_ext_hresp_o;

    // Flits from NoC->tiles
    input link_in_flit;
    input link_in_last;
    input link_in_valid;
    input link_in_ready;

    // Flits from tiles->NoC
    input link_out_flit;
    input link_out_last;
    input link_out_valid;
    input link_out_ready;
  endclocking : monitor_cb

  modport master(clocking master_cb);
  modport slave(clocking slave_cb);
  modport passive(clocking monitor_cb);
endinterface
