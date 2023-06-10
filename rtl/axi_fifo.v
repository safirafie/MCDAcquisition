// Ignore synthesis for the time being
// synopsys translate_off
`timescale 1ns / 1ps
// Resume synthesis
// synopsys translate_on

// Module definition for AXI write FIFO
module axi_fifo #(
  // Defining parameters
  parameter   DW  =  64      , // Data width (can be 8, 16, ..., 1024)
  parameter   AW  =  32      , // Address width
  parameter   FW  =   5      , // FIFO pointers' address width
  parameter   SW  = DW >> 3    // Strobe width - 1 bit for every data byte
)
(
   // Global signals
   input                  axi_clk_i          , // Global clock
   input                  axi_rstn_i         , // Global reset

   // Connection to AXI master
   output reg  [ AW-1: 0] axi_waddr_o        , // Write address
   output reg  [ DW-1: 0] axi_wdata_o        , // Write data
   output reg  [ SW-1: 0] axi_wsel_o         , // Write byte select
   output reg             axi_wvalid_o       , // Write data validity
   output reg  [  4-1: 0] axi_wlen_o         , // Write burst length
   output reg             axi_wfixed_o       , // Write burst type (fixed/incremental)
   input                  axi_werr_i         , // Write error
   input                  axi_wrdy_i         , // Write readiness

   // Data and configuration
   input       [ DW-1: 0] wr_data_i          , // Write data
   input                  wr_val_i           , // Write data validity
   input       [ AW-1: 0] ctrl_start_addr_i  , // Range start address
   input       [ AW-1: 0] ctrl_stop_addr_i   , // Range stop address
   input       [  4-1: 0] ctrl_trig_size_i   , // Trigger level
   input                  ctrl_wrap_i        , // Restart from beginning when stop is reached
   input                  ctrl_clr_i         , // Clear/flush
   output reg             stat_overflow_o    , // Overflow indicator
   output      [ AW-1: 0] stat_cur_addr_o    , // Current address
   output reg             stat_write_data_o    // Write data indicator
);

endmodule
