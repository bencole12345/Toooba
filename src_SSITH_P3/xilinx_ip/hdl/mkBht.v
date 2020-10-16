//
// Generated by Bluespec Compiler (build 39ae402)
//
//
//
//
// Ports:
// Name                         I/O  size props
// pred_0_pred                    O     1
// RDY_pred_0_pred                O     1 const
// pred_1_pred                    O     1
// RDY_pred_1_pred                O     1 const
// RDY_update                     O     1 const
// RDY_flush                      O     1 const
// flush_done                     O     1 const
// RDY_flush_done                 O     1 const
// CLK                            I     1 clock
// RST_N                          I     1 unused
// pred_0_pred_pc                 I    64
// pred_1_pred_pc                 I    64
// update_pc                      I    64
// update_taken                   I     1
// update_mispred                 I     1 unused
// EN_update                      I     1
// EN_flush                       I     1 unused
// EN_pred_0_pred                 I     1 unused
// EN_pred_1_pred                 I     1 unused
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkBht(CLK,
	     RST_N,

	     pred_0_pred_pc,
	     EN_pred_0_pred,
	     pred_0_pred,
	     RDY_pred_0_pred,

	     pred_1_pred_pc,
	     EN_pred_1_pred,
	     pred_1_pred,
	     RDY_pred_1_pred,

	     update_pc,
	     update_taken,
	     update_mispred,
	     EN_update,
	     RDY_update,

	     EN_flush,
	     RDY_flush,

	     flush_done,
	     RDY_flush_done);
  input  CLK;
  input  RST_N;

  // actionvalue method pred_0_pred
  input  [63 : 0] pred_0_pred_pc;
  input  EN_pred_0_pred;
  output pred_0_pred;
  output RDY_pred_0_pred;

  // actionvalue method pred_1_pred
  input  [63 : 0] pred_1_pred_pc;
  input  EN_pred_1_pred;
  output pred_1_pred;
  output RDY_pred_1_pred;

  // action method update
  input  [63 : 0] update_pc;
  input  update_taken;
  input  update_mispred;
  input  EN_update;
  output RDY_update;

  // action method flush
  input  EN_flush;
  output RDY_flush;

  // value method flush_done
  output flush_done;
  output RDY_flush_done;

  // signals for module outputs
  wire RDY_flush,
       RDY_flush_done,
       RDY_pred_0_pred,
       RDY_pred_1_pred,
       RDY_update,
       flush_done,
       pred_0_pred,
       pred_1_pred;

  // ports of submodule hist
  wire [6 : 0] hist$ADDR_1,
	       hist$ADDR_2,
	       hist$ADDR_3,
	       hist$ADDR_4,
	       hist$ADDR_5,
	       hist$ADDR_IN;
  wire [1 : 0] hist$D_IN, hist$D_OUT_1, hist$D_OUT_2, hist$D_OUT_3;
  wire hist$WE;

  // rule scheduling signals
  wire CAN_FIRE_flush,
       CAN_FIRE_pred_0_pred,
       CAN_FIRE_pred_1_pred,
       CAN_FIRE_update,
       WILL_FIRE_flush,
       WILL_FIRE_pred_0_pred,
       WILL_FIRE_pred_1_pred,
       WILL_FIRE_update;

  // remaining internal signals
  wire [1 : 0] next_hist__h472, next_hist__h478;

  // actionvalue method pred_0_pred
  assign pred_0_pred = hist$D_OUT_2[1] ;
  assign RDY_pred_0_pred = 1'd1 ;
  assign CAN_FIRE_pred_0_pred = 1'd1 ;
  assign WILL_FIRE_pred_0_pred = EN_pred_0_pred ;

  // actionvalue method pred_1_pred
  assign pred_1_pred = hist$D_OUT_1[1] ;
  assign RDY_pred_1_pred = 1'd1 ;
  assign CAN_FIRE_pred_1_pred = 1'd1 ;
  assign WILL_FIRE_pred_1_pred = EN_pred_1_pred ;

  // action method update
  assign RDY_update = 1'd1 ;
  assign CAN_FIRE_update = 1'd1 ;
  assign WILL_FIRE_update = EN_update ;

  // action method flush
  assign RDY_flush = 1'd1 ;
  assign CAN_FIRE_flush = 1'd1 ;
  assign WILL_FIRE_flush = EN_flush ;

  // value method flush_done
  assign flush_done = 1'd1 ;
  assign RDY_flush_done = 1'd1 ;

  // submodule hist
  RegFile #(.addr_width(32'd7),
	    .data_width(32'd2),
	    .lo(7'd0),
	    .hi(7'd127)) hist(.CLK(CLK),
			      .ADDR_1(hist$ADDR_1),
			      .ADDR_2(hist$ADDR_2),
			      .ADDR_3(hist$ADDR_3),
			      .ADDR_4(hist$ADDR_4),
			      .ADDR_5(hist$ADDR_5),
			      .ADDR_IN(hist$ADDR_IN),
			      .D_IN(hist$D_IN),
			      .WE(hist$WE),
			      .D_OUT_1(hist$D_OUT_1),
			      .D_OUT_2(hist$D_OUT_2),
			      .D_OUT_3(hist$D_OUT_3),
			      .D_OUT_4(),
			      .D_OUT_5());

  // submodule hist
  assign hist$ADDR_1 = pred_1_pred_pc[8:2] ;
  assign hist$ADDR_2 = pred_0_pred_pc[8:2] ;
  assign hist$ADDR_3 = update_pc[8:2] ;
  assign hist$ADDR_4 = 7'h0 ;
  assign hist$ADDR_5 = 7'h0 ;
  assign hist$ADDR_IN = update_pc[8:2] ;
  assign hist$D_IN = update_taken ? next_hist__h472 : next_hist__h478 ;
  assign hist$WE = EN_update ;

  // remaining internal signals
  assign next_hist__h472 =
	     (hist$D_OUT_3 == 2'b11) ? hist$D_OUT_3 : hist$D_OUT_3 + 2'd1 ;
  assign next_hist__h478 =
	     (hist$D_OUT_3 == 2'b0) ? hist$D_OUT_3 : hist$D_OUT_3 - 2'd1 ;
endmodule  // mkBht

