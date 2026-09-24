/*
 * Copyright (c) 2024 Eva Siao
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // control inputs
  wire en       = ui_in[0];
  wire load     = ui_in[1];
  wire up_down  = ui_in[2];
  wire oe       = ui_in[3];

  // counter value (never Z inside the core)
  wire [7:0] count;

  programmable_counter counter_inst (
      .clk      (clk),
      .rst_n    (rst_n),
      .en       (en),
      .load     (load),
      .up_down  (up_down),
      .data_in  (uio_in),   // parallel load comes in on the bidirectional bus
      .oe       (1'b1),     // always enable output since tinytapeout can't do tri-state internally. instead use uio_oe to do tri-state output
      .data_out (count)
  );

  assign uo_out   = count;

  // bidirectional bus: drives the count when oe=1, otherwise acts as the load input (tri-state output)
  assign uio_out  = count;
  assign uio_oe   = {8{oe}};

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:4], 1'b0};

endmodule
