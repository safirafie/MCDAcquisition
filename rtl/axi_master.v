/*
* Description: This Verilog module defines an AXI master with customizable parameters. 
* It implements the AXI write and read channels and a system write and read channel.
*
*/

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on

module axi_master #(
  parameter    DW    =  64,   // Data width (Can be 8,16,...,1024)
  parameter    AW    =  32,   // Address width
  parameter    ID    =   0,   // Master ID
  parameter    IW    =   4,   // Master ID width
  parameter    LW    =   4,   // Length width
  parameter    SW    = DW >> 3 // Strobe width - 1 bit for every data byte
)
(
   // Global Signals
   input                   axi_clk_i,      // Global Clock
   input                   axi_rstn_i,     // Global Reset (Active Low)

   // AXI Write Address Channel
   output     [IW-1: 0]    axi_awid_o,     // Write Address ID
   output reg [AW-1: 0]    axi_awaddr_o,   // Write Address
   output reg [ 4-1: 0]    axi_awlen_o,    // Write Burst Length
   output     [ 3-1: 0]    axi_awsize_o,   // Write Burst Size
   output reg [ 2-1: 0]    axi_awburst_o,  // Write Burst Type
   output     [ 2-1: 0]    axi_awlock_o,   // Write Lock Type
   output     [ 4-1: 0]    axi_awcache_o,  // Write Cache Type
   output     [ 3-1: 0]    axi_awprot_o,   // Write Protection Type
   output reg              axi_awvalid_o,  // Write Address Valid
   input                   axi_awready_i,  // Write Ready

   // AXI Write Data Channel
   output     [IW-1: 0]    axi_wid_o,      // Write Data ID
   output reg [DW-1: 0]    axi_wdata_o,    // Write Data
   output reg [SW-1: 0]    axi_wstrb_o,    // Write Strobes
   output reg              axi_wlast_o,    // Write Last
   output reg              axi_wvalid_o,   // Write Valid
   input                   axi_wready_i,   // Write Ready

   // AXI Write Response Channel
   input      [IW-1: 0]    axi_bid_i,      // Write Response ID
   input      [ 2-1: 0]    axi_bresp_i,    // Write Response
   input                   axi_bvalid_i,   // Write Response Valid
   output                  axi_bready_o,   // Write Response Ready

   // AXI Read Address Channel
   output     [IW-1: 0]    axi_arid_o,     // Read Address ID
) 