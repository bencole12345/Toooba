//
// Generated by Bluespec Compiler (build 39ae402)
//
//
//
//
// Ports:
// Name                         I/O  size props
// RDY_to_proc_request_put        O     1
// to_proc_response_get           O    68
// RDY_to_proc_response_get       O     1
// RDY_flush                      O     1 const
// flush_done                     O     1 const
// RDY_flush_done                 O     1 const
// RDY_perf_setStatus             O     1 const
// RDY_perf_req                   O     1
// perf_resp                      O    66
// RDY_perf_resp                  O     1
// perf_respValid                 O     1
// RDY_perf_respValid             O     1 const
// to_parent_rsToP_notEmpty       O     1
// RDY_to_parent_rsToP_notEmpty   O     1 const
// RDY_to_parent_rsToP_deq        O     1
// to_parent_rsToP_first          O   579
// RDY_to_parent_rsToP_first      O     1
// to_parent_rqToP_notEmpty       O     1
// RDY_to_parent_rqToP_notEmpty   O     1 const
// RDY_to_parent_rqToP_deq        O     1
// to_parent_rqToP_first          O    72
// RDY_to_parent_rqToP_first      O     1
// to_parent_fromP_notFull        O     1
// RDY_to_parent_fromP_notFull    O     1 const
// RDY_to_parent_fromP_enq        O     1
// cRqStuck_get                   O    68 const
// RDY_cRqStuck_get               O     1 const
// pRqStuck_get                   O    68 const
// RDY_pRqStuck_get               O     1 const
// CLK                            I     1 clock
// RST_N                          I     1 reset
// to_proc_request_put            I    64
// perf_setStatus_doStats         I     1 unused
// perf_req_r                     I     2
// to_parent_fromP_enq_x          I   583
// EN_to_proc_request_put         I     1
// EN_flush                       I     1 unused
// EN_perf_setStatus              I     1 unused
// EN_perf_req                    I     1
// EN_to_parent_rsToP_deq         I     1
// EN_to_parent_rqToP_deq         I     1
// EN_to_parent_fromP_enq         I     1
// EN_to_proc_response_get        I     1
// EN_perf_resp                   I     1
// EN_cRqStuck_get                I     1 unused
// EN_pRqStuck_get                I     1 unused
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

module mkICoCache(CLK,
		  RST_N,

		  to_proc_request_put,
		  EN_to_proc_request_put,
		  RDY_to_proc_request_put,

		  EN_to_proc_response_get,
		  to_proc_response_get,
		  RDY_to_proc_response_get,

		  EN_flush,
		  RDY_flush,

		  flush_done,
		  RDY_flush_done,

		  perf_setStatus_doStats,
		  EN_perf_setStatus,
		  RDY_perf_setStatus,

		  perf_req_r,
		  EN_perf_req,
		  RDY_perf_req,

		  EN_perf_resp,
		  perf_resp,
		  RDY_perf_resp,

		  perf_respValid,
		  RDY_perf_respValid,

		  to_parent_rsToP_notEmpty,
		  RDY_to_parent_rsToP_notEmpty,

		  EN_to_parent_rsToP_deq,
		  RDY_to_parent_rsToP_deq,

		  to_parent_rsToP_first,
		  RDY_to_parent_rsToP_first,

		  to_parent_rqToP_notEmpty,
		  RDY_to_parent_rqToP_notEmpty,

		  EN_to_parent_rqToP_deq,
		  RDY_to_parent_rqToP_deq,

		  to_parent_rqToP_first,
		  RDY_to_parent_rqToP_first,

		  to_parent_fromP_notFull,
		  RDY_to_parent_fromP_notFull,

		  to_parent_fromP_enq_x,
		  EN_to_parent_fromP_enq,
		  RDY_to_parent_fromP_enq,

		  EN_cRqStuck_get,
		  cRqStuck_get,
		  RDY_cRqStuck_get,

		  EN_pRqStuck_get,
		  pRqStuck_get,
		  RDY_pRqStuck_get);
  input  CLK;
  input  RST_N;

  // action method to_proc_request_put
  input  [63 : 0] to_proc_request_put;
  input  EN_to_proc_request_put;
  output RDY_to_proc_request_put;

  // actionvalue method to_proc_response_get
  input  EN_to_proc_response_get;
  output [67 : 0] to_proc_response_get;
  output RDY_to_proc_response_get;

  // action method flush
  input  EN_flush;
  output RDY_flush;

  // value method flush_done
  output flush_done;
  output RDY_flush_done;

  // action method perf_setStatus
  input  perf_setStatus_doStats;
  input  EN_perf_setStatus;
  output RDY_perf_setStatus;

  // action method perf_req
  input  [1 : 0] perf_req_r;
  input  EN_perf_req;
  output RDY_perf_req;

  // actionvalue method perf_resp
  input  EN_perf_resp;
  output [65 : 0] perf_resp;
  output RDY_perf_resp;

  // value method perf_respValid
  output perf_respValid;
  output RDY_perf_respValid;

  // value method to_parent_rsToP_notEmpty
  output to_parent_rsToP_notEmpty;
  output RDY_to_parent_rsToP_notEmpty;

  // action method to_parent_rsToP_deq
  input  EN_to_parent_rsToP_deq;
  output RDY_to_parent_rsToP_deq;

  // value method to_parent_rsToP_first
  output [578 : 0] to_parent_rsToP_first;
  output RDY_to_parent_rsToP_first;

  // value method to_parent_rqToP_notEmpty
  output to_parent_rqToP_notEmpty;
  output RDY_to_parent_rqToP_notEmpty;

  // action method to_parent_rqToP_deq
  input  EN_to_parent_rqToP_deq;
  output RDY_to_parent_rqToP_deq;

  // value method to_parent_rqToP_first
  output [71 : 0] to_parent_rqToP_first;
  output RDY_to_parent_rqToP_first;

  // value method to_parent_fromP_notFull
  output to_parent_fromP_notFull;
  output RDY_to_parent_fromP_notFull;

  // action method to_parent_fromP_enq
  input  [582 : 0] to_parent_fromP_enq_x;
  input  EN_to_parent_fromP_enq;
  output RDY_to_parent_fromP_enq;

  // actionvalue method cRqStuck_get
  input  EN_cRqStuck_get;
  output [67 : 0] cRqStuck_get;
  output RDY_cRqStuck_get;

  // actionvalue method pRqStuck_get
  input  EN_pRqStuck_get;
  output [67 : 0] pRqStuck_get;
  output RDY_pRqStuck_get;

  // signals for module outputs
  wire [578 : 0] to_parent_rsToP_first;
  wire [71 : 0] to_parent_rqToP_first;
  wire [67 : 0] cRqStuck_get, pRqStuck_get, to_proc_response_get;
  wire [65 : 0] perf_resp;
  wire RDY_cRqStuck_get,
       RDY_flush,
       RDY_flush_done,
       RDY_pRqStuck_get,
       RDY_perf_req,
       RDY_perf_resp,
       RDY_perf_respValid,
       RDY_perf_setStatus,
       RDY_to_parent_fromP_enq,
       RDY_to_parent_fromP_notFull,
       RDY_to_parent_rqToP_deq,
       RDY_to_parent_rqToP_first,
       RDY_to_parent_rqToP_notEmpty,
       RDY_to_parent_rsToP_deq,
       RDY_to_parent_rsToP_first,
       RDY_to_parent_rsToP_notEmpty,
       RDY_to_proc_request_put,
       RDY_to_proc_response_get,
       flush_done,
       perf_respValid,
       to_parent_fromP_notFull,
       to_parent_rqToP_notEmpty,
       to_parent_rsToP_notEmpty;

  // inlined wires
  wire [2 : 0] perfReqQ_enqReq_lat_0$wget;

  // register perfReqQ_clearReq_rl
  reg perfReqQ_clearReq_rl;
  wire perfReqQ_clearReq_rl$D_IN, perfReqQ_clearReq_rl$EN;

  // register perfReqQ_data_0
  reg [1 : 0] perfReqQ_data_0;
  wire [1 : 0] perfReqQ_data_0$D_IN;
  wire perfReqQ_data_0$EN;

  // register perfReqQ_deqReq_rl
  reg perfReqQ_deqReq_rl;
  wire perfReqQ_deqReq_rl$D_IN, perfReqQ_deqReq_rl$EN;

  // register perfReqQ_empty
  reg perfReqQ_empty;
  wire perfReqQ_empty$D_IN, perfReqQ_empty$EN;

  // register perfReqQ_enqReq_rl
  reg [2 : 0] perfReqQ_enqReq_rl;
  wire [2 : 0] perfReqQ_enqReq_rl$D_IN;
  wire perfReqQ_enqReq_rl$EN;

  // register perfReqQ_full
  reg perfReqQ_full;
  wire perfReqQ_full$D_IN, perfReqQ_full$EN;

  // ports of submodule cache
  wire [582 : 0] cache$to_parent_fromP_enq_x;
  wire [578 : 0] cache$to_parent_rsToP_first;
  wire [71 : 0] cache$to_parent_rqToP_first;
  wire [67 : 0] cache$cRqStuck_get,
		cache$pRqStuck_get,
		cache$to_proc_resp_get;
  wire [63 : 0] cache$to_proc_req_put;
  wire [1 : 0] cache$getPerfData_t;
  wire cache$EN_cRqStuck_get,
       cache$EN_flush,
       cache$EN_pRqStuck_get,
       cache$EN_setPerfStatus,
       cache$EN_to_parent_fromP_enq,
       cache$EN_to_parent_rqToP_deq,
       cache$EN_to_parent_rsToP_deq,
       cache$EN_to_proc_req_put,
       cache$EN_to_proc_resp_get,
       cache$RDY_cRqStuck_get,
       cache$RDY_pRqStuck_get,
       cache$RDY_to_parent_fromP_enq,
       cache$RDY_to_parent_rqToP_deq,
       cache$RDY_to_parent_rqToP_first,
       cache$RDY_to_parent_rsToP_deq,
       cache$RDY_to_parent_rsToP_first,
       cache$RDY_to_proc_req_put,
       cache$RDY_to_proc_resp_get,
       cache$flush_done,
       cache$setPerfStatus_stats,
       cache$to_parent_fromP_notFull,
       cache$to_parent_rqToP_notEmpty,
       cache$to_parent_rsToP_notEmpty;

  // ports of submodule perfReqQ_clearReq_dummy2_0
  wire perfReqQ_clearReq_dummy2_0$D_IN, perfReqQ_clearReq_dummy2_0$EN;

  // ports of submodule perfReqQ_clearReq_dummy2_1
  wire perfReqQ_clearReq_dummy2_1$D_IN,
       perfReqQ_clearReq_dummy2_1$EN,
       perfReqQ_clearReq_dummy2_1$Q_OUT;

  // ports of submodule perfReqQ_deqReq_dummy2_0
  wire perfReqQ_deqReq_dummy2_0$D_IN, perfReqQ_deqReq_dummy2_0$EN;

  // ports of submodule perfReqQ_deqReq_dummy2_1
  wire perfReqQ_deqReq_dummy2_1$D_IN, perfReqQ_deqReq_dummy2_1$EN;

  // ports of submodule perfReqQ_deqReq_dummy2_2
  wire perfReqQ_deqReq_dummy2_2$D_IN,
       perfReqQ_deqReq_dummy2_2$EN,
       perfReqQ_deqReq_dummy2_2$Q_OUT;

  // ports of submodule perfReqQ_enqReq_dummy2_0
  wire perfReqQ_enqReq_dummy2_0$D_IN, perfReqQ_enqReq_dummy2_0$EN;

  // ports of submodule perfReqQ_enqReq_dummy2_1
  wire perfReqQ_enqReq_dummy2_1$D_IN, perfReqQ_enqReq_dummy2_1$EN;

  // ports of submodule perfReqQ_enqReq_dummy2_2
  wire perfReqQ_enqReq_dummy2_2$D_IN,
       perfReqQ_enqReq_dummy2_2$EN,
       perfReqQ_enqReq_dummy2_2$Q_OUT;

  // rule scheduling signals
  wire CAN_FIRE_RL_perfReqQ_canonicalize,
       CAN_FIRE_RL_perfReqQ_clearReq_canon,
       CAN_FIRE_RL_perfReqQ_deqReq_canon,
       CAN_FIRE_RL_perfReqQ_enqReq_canon,
       CAN_FIRE_cRqStuck_get,
       CAN_FIRE_flush,
       CAN_FIRE_pRqStuck_get,
       CAN_FIRE_perf_req,
       CAN_FIRE_perf_resp,
       CAN_FIRE_perf_setStatus,
       CAN_FIRE_to_parent_fromP_enq,
       CAN_FIRE_to_parent_rqToP_deq,
       CAN_FIRE_to_parent_rsToP_deq,
       CAN_FIRE_to_proc_request_put,
       CAN_FIRE_to_proc_response_get,
       WILL_FIRE_RL_perfReqQ_canonicalize,
       WILL_FIRE_RL_perfReqQ_clearReq_canon,
       WILL_FIRE_RL_perfReqQ_deqReq_canon,
       WILL_FIRE_RL_perfReqQ_enqReq_canon,
       WILL_FIRE_cRqStuck_get,
       WILL_FIRE_flush,
       WILL_FIRE_pRqStuck_get,
       WILL_FIRE_perf_req,
       WILL_FIRE_perf_resp,
       WILL_FIRE_perf_setStatus,
       WILL_FIRE_to_parent_fromP_enq,
       WILL_FIRE_to_parent_rqToP_deq,
       WILL_FIRE_to_parent_rsToP_deq,
       WILL_FIRE_to_proc_request_put,
       WILL_FIRE_to_proc_response_get;

  // remaining internal signals
  wire IF_perfReqQ_enqReq_lat_1_whas_THEN_perfReqQ_en_ETC___d13,
       NOT_perfReqQ_clearReq_dummy2_1_read__8_9_OR_IF_ETC___d53,
       NOT_perfReqQ_enqReq_dummy2_2_read__4_9_OR_IF_p_ETC___d74,
       perfReqQ_enqReq_dummy2_2_read__4_AND_IF_perfRe_ETC___d66;

  // action method to_proc_request_put
  assign RDY_to_proc_request_put = cache$RDY_to_proc_req_put ;
  assign CAN_FIRE_to_proc_request_put = cache$RDY_to_proc_req_put ;
  assign WILL_FIRE_to_proc_request_put = EN_to_proc_request_put ;

  // actionvalue method to_proc_response_get
  assign to_proc_response_get =
	     { cache$to_proc_resp_get[67],
	       cache$to_proc_resp_get[67] ?
		 cache$to_proc_resp_get[66:51] :
		 16'hAAAA,
	       cache$to_proc_resp_get[50],
	       cache$to_proc_resp_get[50] ?
		 cache$to_proc_resp_get[49:34] :
		 16'hAAAA,
	       cache$to_proc_resp_get[33],
	       cache$to_proc_resp_get[33] ?
		 cache$to_proc_resp_get[32:17] :
		 16'hAAAA,
	       cache$to_proc_resp_get[16],
	       cache$to_proc_resp_get[16] ?
		 cache$to_proc_resp_get[15:0] :
		 16'hAAAA } ;
  assign RDY_to_proc_response_get = cache$RDY_to_proc_resp_get ;
  assign CAN_FIRE_to_proc_response_get = cache$RDY_to_proc_resp_get ;
  assign WILL_FIRE_to_proc_response_get = EN_to_proc_response_get ;

  // action method flush
  assign RDY_flush = 1'd1 ;
  assign CAN_FIRE_flush = 1'd1 ;
  assign WILL_FIRE_flush = EN_flush ;

  // value method flush_done
  assign flush_done = cache$flush_done ;
  assign RDY_flush_done = 1'd1 ;

  // action method perf_setStatus
  assign RDY_perf_setStatus = 1'd1 ;
  assign CAN_FIRE_perf_setStatus = 1'd1 ;
  assign WILL_FIRE_perf_setStatus = EN_perf_setStatus ;

  // action method perf_req
  assign RDY_perf_req = !perfReqQ_full ;
  assign CAN_FIRE_perf_req = !perfReqQ_full ;
  assign WILL_FIRE_perf_req = EN_perf_req ;

  // actionvalue method perf_resp
  assign perf_resp = { perfReqQ_data_0, 64'd0 } ;
  assign RDY_perf_resp = !perfReqQ_empty ;
  assign CAN_FIRE_perf_resp = !perfReqQ_empty ;
  assign WILL_FIRE_perf_resp = EN_perf_resp ;

  // value method perf_respValid
  assign perf_respValid = !perfReqQ_empty ;
  assign RDY_perf_respValid = 1'd1 ;

  // value method to_parent_rsToP_notEmpty
  assign to_parent_rsToP_notEmpty = cache$to_parent_rsToP_notEmpty ;
  assign RDY_to_parent_rsToP_notEmpty = 1'd1 ;

  // action method to_parent_rsToP_deq
  assign RDY_to_parent_rsToP_deq = cache$RDY_to_parent_rsToP_deq ;
  assign CAN_FIRE_to_parent_rsToP_deq = cache$RDY_to_parent_rsToP_deq ;
  assign WILL_FIRE_to_parent_rsToP_deq = EN_to_parent_rsToP_deq ;

  // value method to_parent_rsToP_first
  assign to_parent_rsToP_first = cache$to_parent_rsToP_first ;
  assign RDY_to_parent_rsToP_first = cache$RDY_to_parent_rsToP_first ;

  // value method to_parent_rqToP_notEmpty
  assign to_parent_rqToP_notEmpty = cache$to_parent_rqToP_notEmpty ;
  assign RDY_to_parent_rqToP_notEmpty = 1'd1 ;

  // action method to_parent_rqToP_deq
  assign RDY_to_parent_rqToP_deq = cache$RDY_to_parent_rqToP_deq ;
  assign CAN_FIRE_to_parent_rqToP_deq = cache$RDY_to_parent_rqToP_deq ;
  assign WILL_FIRE_to_parent_rqToP_deq = EN_to_parent_rqToP_deq ;

  // value method to_parent_rqToP_first
  assign to_parent_rqToP_first = cache$to_parent_rqToP_first ;
  assign RDY_to_parent_rqToP_first = cache$RDY_to_parent_rqToP_first ;

  // value method to_parent_fromP_notFull
  assign to_parent_fromP_notFull = cache$to_parent_fromP_notFull ;
  assign RDY_to_parent_fromP_notFull = 1'd1 ;

  // action method to_parent_fromP_enq
  assign RDY_to_parent_fromP_enq = cache$RDY_to_parent_fromP_enq ;
  assign CAN_FIRE_to_parent_fromP_enq = cache$RDY_to_parent_fromP_enq ;
  assign WILL_FIRE_to_parent_fromP_enq = EN_to_parent_fromP_enq ;

  // actionvalue method cRqStuck_get
  assign cRqStuck_get = cache$cRqStuck_get ;
  assign RDY_cRqStuck_get = cache$RDY_cRqStuck_get ;
  assign CAN_FIRE_cRqStuck_get = cache$RDY_cRqStuck_get ;
  assign WILL_FIRE_cRqStuck_get = EN_cRqStuck_get ;

  // actionvalue method pRqStuck_get
  assign pRqStuck_get = cache$pRqStuck_get ;
  assign RDY_pRqStuck_get = cache$RDY_pRqStuck_get ;
  assign CAN_FIRE_pRqStuck_get = cache$RDY_pRqStuck_get ;
  assign WILL_FIRE_pRqStuck_get = EN_pRqStuck_get ;

  // submodule cache
  mkIBankWrapper cache(.CLK(CLK),
		       .RST_N(RST_N),
		       .getPerfData_t(cache$getPerfData_t),
		       .setPerfStatus_stats(cache$setPerfStatus_stats),
		       .to_parent_fromP_enq_x(cache$to_parent_fromP_enq_x),
		       .to_proc_req_put(cache$to_proc_req_put),
		       .EN_to_parent_rsToP_deq(cache$EN_to_parent_rsToP_deq),
		       .EN_to_parent_rqToP_deq(cache$EN_to_parent_rqToP_deq),
		       .EN_to_parent_fromP_enq(cache$EN_to_parent_fromP_enq),
		       .EN_to_proc_req_put(cache$EN_to_proc_req_put),
		       .EN_to_proc_resp_get(cache$EN_to_proc_resp_get),
		       .EN_cRqStuck_get(cache$EN_cRqStuck_get),
		       .EN_pRqStuck_get(cache$EN_pRqStuck_get),
		       .EN_flush(cache$EN_flush),
		       .EN_setPerfStatus(cache$EN_setPerfStatus),
		       .to_parent_rsToP_notEmpty(cache$to_parent_rsToP_notEmpty),
		       .RDY_to_parent_rsToP_notEmpty(),
		       .RDY_to_parent_rsToP_deq(cache$RDY_to_parent_rsToP_deq),
		       .to_parent_rsToP_first(cache$to_parent_rsToP_first),
		       .RDY_to_parent_rsToP_first(cache$RDY_to_parent_rsToP_first),
		       .to_parent_rqToP_notEmpty(cache$to_parent_rqToP_notEmpty),
		       .RDY_to_parent_rqToP_notEmpty(),
		       .RDY_to_parent_rqToP_deq(cache$RDY_to_parent_rqToP_deq),
		       .to_parent_rqToP_first(cache$to_parent_rqToP_first),
		       .RDY_to_parent_rqToP_first(cache$RDY_to_parent_rqToP_first),
		       .to_parent_fromP_notFull(cache$to_parent_fromP_notFull),
		       .RDY_to_parent_fromP_notFull(),
		       .RDY_to_parent_fromP_enq(cache$RDY_to_parent_fromP_enq),
		       .RDY_to_proc_req_put(cache$RDY_to_proc_req_put),
		       .to_proc_resp_get(cache$to_proc_resp_get),
		       .RDY_to_proc_resp_get(cache$RDY_to_proc_resp_get),
		       .cRqStuck_get(cache$cRqStuck_get),
		       .RDY_cRqStuck_get(cache$RDY_cRqStuck_get),
		       .pRqStuck_get(cache$pRqStuck_get),
		       .RDY_pRqStuck_get(cache$RDY_pRqStuck_get),
		       .RDY_flush(),
		       .flush_done(cache$flush_done),
		       .RDY_flush_done(),
		       .RDY_setPerfStatus(),
		       .getPerfData(),
		       .RDY_getPerfData());

  // submodule perfReqQ_clearReq_dummy2_0
  RevertReg #(.width(32'd1),
	      .init(1'd1)) perfReqQ_clearReq_dummy2_0(.CLK(CLK),
						      .D_IN(perfReqQ_clearReq_dummy2_0$D_IN),
						      .EN(perfReqQ_clearReq_dummy2_0$EN),
						      .Q_OUT());

  // submodule perfReqQ_clearReq_dummy2_1
  RevertReg #(.width(32'd1),
	      .init(1'd1)) perfReqQ_clearReq_dummy2_1(.CLK(CLK),
						      .D_IN(perfReqQ_clearReq_dummy2_1$D_IN),
						      .EN(perfReqQ_clearReq_dummy2_1$EN),
						      .Q_OUT(perfReqQ_clearReq_dummy2_1$Q_OUT));

  // submodule perfReqQ_deqReq_dummy2_0
  RevertReg #(.width(32'd1), .init(1'd1)) perfReqQ_deqReq_dummy2_0(.CLK(CLK),
								   .D_IN(perfReqQ_deqReq_dummy2_0$D_IN),
								   .EN(perfReqQ_deqReq_dummy2_0$EN),
								   .Q_OUT());

  // submodule perfReqQ_deqReq_dummy2_1
  RevertReg #(.width(32'd1), .init(1'd1)) perfReqQ_deqReq_dummy2_1(.CLK(CLK),
								   .D_IN(perfReqQ_deqReq_dummy2_1$D_IN),
								   .EN(perfReqQ_deqReq_dummy2_1$EN),
								   .Q_OUT());

  // submodule perfReqQ_deqReq_dummy2_2
  RevertReg #(.width(32'd1), .init(1'd1)) perfReqQ_deqReq_dummy2_2(.CLK(CLK),
								   .D_IN(perfReqQ_deqReq_dummy2_2$D_IN),
								   .EN(perfReqQ_deqReq_dummy2_2$EN),
								   .Q_OUT(perfReqQ_deqReq_dummy2_2$Q_OUT));

  // submodule perfReqQ_enqReq_dummy2_0
  RevertReg #(.width(32'd1), .init(1'd1)) perfReqQ_enqReq_dummy2_0(.CLK(CLK),
								   .D_IN(perfReqQ_enqReq_dummy2_0$D_IN),
								   .EN(perfReqQ_enqReq_dummy2_0$EN),
								   .Q_OUT());

  // submodule perfReqQ_enqReq_dummy2_1
  RevertReg #(.width(32'd1), .init(1'd1)) perfReqQ_enqReq_dummy2_1(.CLK(CLK),
								   .D_IN(perfReqQ_enqReq_dummy2_1$D_IN),
								   .EN(perfReqQ_enqReq_dummy2_1$EN),
								   .Q_OUT());

  // submodule perfReqQ_enqReq_dummy2_2
  RevertReg #(.width(32'd1), .init(1'd1)) perfReqQ_enqReq_dummy2_2(.CLK(CLK),
								   .D_IN(perfReqQ_enqReq_dummy2_2$D_IN),
								   .EN(perfReqQ_enqReq_dummy2_2$EN),
								   .Q_OUT(perfReqQ_enqReq_dummy2_2$Q_OUT));

  // rule RL_perfReqQ_canonicalize
  assign CAN_FIRE_RL_perfReqQ_canonicalize = 1'd1 ;
  assign WILL_FIRE_RL_perfReqQ_canonicalize = 1'd1 ;

  // rule RL_perfReqQ_enqReq_canon
  assign CAN_FIRE_RL_perfReqQ_enqReq_canon = 1'd1 ;
  assign WILL_FIRE_RL_perfReqQ_enqReq_canon = 1'd1 ;

  // rule RL_perfReqQ_deqReq_canon
  assign CAN_FIRE_RL_perfReqQ_deqReq_canon = 1'd1 ;
  assign WILL_FIRE_RL_perfReqQ_deqReq_canon = 1'd1 ;

  // rule RL_perfReqQ_clearReq_canon
  assign CAN_FIRE_RL_perfReqQ_clearReq_canon = 1'd1 ;
  assign WILL_FIRE_RL_perfReqQ_clearReq_canon = 1'd1 ;

  // inlined wires
  assign perfReqQ_enqReq_lat_0$wget = { 1'd1, perf_req_r } ;

  // register perfReqQ_clearReq_rl
  assign perfReqQ_clearReq_rl$D_IN = 1'd0 ;
  assign perfReqQ_clearReq_rl$EN = 1'd1 ;

  // register perfReqQ_data_0
  assign perfReqQ_data_0$D_IN =
	     EN_perf_req ?
	       perfReqQ_enqReq_lat_0$wget[1:0] :
	       perfReqQ_enqReq_rl[1:0] ;
  assign perfReqQ_data_0$EN =
	     NOT_perfReqQ_clearReq_dummy2_1_read__8_9_OR_IF_ETC___d53 &&
	     perfReqQ_enqReq_dummy2_2$Q_OUT &&
	     IF_perfReqQ_enqReq_lat_1_whas_THEN_perfReqQ_en_ETC___d13 ;

  // register perfReqQ_deqReq_rl
  assign perfReqQ_deqReq_rl$D_IN = 1'd0 ;
  assign perfReqQ_deqReq_rl$EN = 1'd1 ;

  // register perfReqQ_empty
  assign perfReqQ_empty$D_IN =
	     perfReqQ_clearReq_dummy2_1$Q_OUT && perfReqQ_clearReq_rl ||
	     NOT_perfReqQ_enqReq_dummy2_2_read__4_9_OR_IF_p_ETC___d74 ;
  assign perfReqQ_empty$EN = 1'd1 ;

  // register perfReqQ_enqReq_rl
  assign perfReqQ_enqReq_rl$D_IN = 3'b010 ;
  assign perfReqQ_enqReq_rl$EN = 1'd1 ;

  // register perfReqQ_full
  assign perfReqQ_full$D_IN =
	     NOT_perfReqQ_clearReq_dummy2_1_read__8_9_OR_IF_ETC___d53 &&
	     perfReqQ_enqReq_dummy2_2_read__4_AND_IF_perfRe_ETC___d66 ;
  assign perfReqQ_full$EN = 1'd1 ;

  // submodule cache
  assign cache$getPerfData_t = 2'h0 ;
  assign cache$setPerfStatus_stats = perf_setStatus_doStats ;
  assign cache$to_parent_fromP_enq_x = to_parent_fromP_enq_x ;
  assign cache$to_proc_req_put = to_proc_request_put ;
  assign cache$EN_to_parent_rsToP_deq = EN_to_parent_rsToP_deq ;
  assign cache$EN_to_parent_rqToP_deq = EN_to_parent_rqToP_deq ;
  assign cache$EN_to_parent_fromP_enq = EN_to_parent_fromP_enq ;
  assign cache$EN_to_proc_req_put = EN_to_proc_request_put ;
  assign cache$EN_to_proc_resp_get = EN_to_proc_response_get ;
  assign cache$EN_cRqStuck_get = EN_cRqStuck_get ;
  assign cache$EN_pRqStuck_get = EN_pRqStuck_get ;
  assign cache$EN_flush = EN_flush ;
  assign cache$EN_setPerfStatus = EN_perf_setStatus ;

  // submodule perfReqQ_clearReq_dummy2_0
  assign perfReqQ_clearReq_dummy2_0$D_IN = 1'b0 ;
  assign perfReqQ_clearReq_dummy2_0$EN = 1'b0 ;

  // submodule perfReqQ_clearReq_dummy2_1
  assign perfReqQ_clearReq_dummy2_1$D_IN = 1'd1 ;
  assign perfReqQ_clearReq_dummy2_1$EN = 1'd1 ;

  // submodule perfReqQ_deqReq_dummy2_0
  assign perfReqQ_deqReq_dummy2_0$D_IN = 1'd1 ;
  assign perfReqQ_deqReq_dummy2_0$EN = EN_perf_resp ;

  // submodule perfReqQ_deqReq_dummy2_1
  assign perfReqQ_deqReq_dummy2_1$D_IN = 1'b0 ;
  assign perfReqQ_deqReq_dummy2_1$EN = 1'b0 ;

  // submodule perfReqQ_deqReq_dummy2_2
  assign perfReqQ_deqReq_dummy2_2$D_IN = 1'd1 ;
  assign perfReqQ_deqReq_dummy2_2$EN = 1'd1 ;

  // submodule perfReqQ_enqReq_dummy2_0
  assign perfReqQ_enqReq_dummy2_0$D_IN = 1'd1 ;
  assign perfReqQ_enqReq_dummy2_0$EN = EN_perf_req ;

  // submodule perfReqQ_enqReq_dummy2_1
  assign perfReqQ_enqReq_dummy2_1$D_IN = 1'b0 ;
  assign perfReqQ_enqReq_dummy2_1$EN = 1'b0 ;

  // submodule perfReqQ_enqReq_dummy2_2
  assign perfReqQ_enqReq_dummy2_2$D_IN = 1'd1 ;
  assign perfReqQ_enqReq_dummy2_2$EN = 1'd1 ;

  // remaining internal signals
  assign IF_perfReqQ_enqReq_lat_1_whas_THEN_perfReqQ_en_ETC___d13 =
	     EN_perf_req ?
	       perfReqQ_enqReq_lat_0$wget[2] :
	       perfReqQ_enqReq_rl[2] ;
  assign NOT_perfReqQ_clearReq_dummy2_1_read__8_9_OR_IF_ETC___d53 =
	     !perfReqQ_clearReq_dummy2_1$Q_OUT || !perfReqQ_clearReq_rl ;
  assign NOT_perfReqQ_enqReq_dummy2_2_read__4_9_OR_IF_p_ETC___d74 =
	     (!perfReqQ_enqReq_dummy2_2$Q_OUT ||
	      (EN_perf_req ?
		 !perfReqQ_enqReq_lat_0$wget[2] :
		 !perfReqQ_enqReq_rl[2])) &&
	     (perfReqQ_deqReq_dummy2_2$Q_OUT &&
	      (EN_perf_resp || perfReqQ_deqReq_rl) ||
	      perfReqQ_empty) ;
  assign perfReqQ_enqReq_dummy2_2_read__4_AND_IF_perfRe_ETC___d66 =
	     perfReqQ_enqReq_dummy2_2$Q_OUT &&
	     IF_perfReqQ_enqReq_lat_1_whas_THEN_perfReqQ_en_ETC___d13 ||
	     (!perfReqQ_deqReq_dummy2_2$Q_OUT ||
	      !EN_perf_resp && !perfReqQ_deqReq_rl) &&
	     perfReqQ_full ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        perfReqQ_clearReq_rl <= `BSV_ASSIGNMENT_DELAY 1'd0;
	perfReqQ_data_0 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	perfReqQ_deqReq_rl <= `BSV_ASSIGNMENT_DELAY 1'd0;
	perfReqQ_empty <= `BSV_ASSIGNMENT_DELAY 1'd1;
	perfReqQ_enqReq_rl <= `BSV_ASSIGNMENT_DELAY 3'd2;
	perfReqQ_full <= `BSV_ASSIGNMENT_DELAY 1'd0;
      end
    else
      begin
        if (perfReqQ_clearReq_rl$EN)
	  perfReqQ_clearReq_rl <= `BSV_ASSIGNMENT_DELAY
	      perfReqQ_clearReq_rl$D_IN;
	if (perfReqQ_data_0$EN)
	  perfReqQ_data_0 <= `BSV_ASSIGNMENT_DELAY perfReqQ_data_0$D_IN;
	if (perfReqQ_deqReq_rl$EN)
	  perfReqQ_deqReq_rl <= `BSV_ASSIGNMENT_DELAY perfReqQ_deqReq_rl$D_IN;
	if (perfReqQ_empty$EN)
	  perfReqQ_empty <= `BSV_ASSIGNMENT_DELAY perfReqQ_empty$D_IN;
	if (perfReqQ_enqReq_rl$EN)
	  perfReqQ_enqReq_rl <= `BSV_ASSIGNMENT_DELAY perfReqQ_enqReq_rl$D_IN;
	if (perfReqQ_full$EN)
	  perfReqQ_full <= `BSV_ASSIGNMENT_DELAY perfReqQ_full$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    perfReqQ_clearReq_rl = 1'h0;
    perfReqQ_data_0 = 2'h2;
    perfReqQ_deqReq_rl = 1'h0;
    perfReqQ_empty = 1'h0;
    perfReqQ_enqReq_rl = 3'h2;
    perfReqQ_full = 1'h0;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkICoCache

