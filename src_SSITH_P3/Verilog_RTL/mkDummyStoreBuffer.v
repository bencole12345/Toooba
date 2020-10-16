//
// Generated by Bluespec Compiler (build 39ae402)
//
//
//
//
// Ports:
// Name                         I/O  size props
// isEmpty                        O     1 const
// RDY_isEmpty                    O     1 const
// getEnqIndex                    O     2 const
// RDY_getEnqIndex                O     1 const
// RDY_enq                        O     1 const
// deq                            O   634 const
// RDY_deq                        O     1 const
// issue                          O   635 const
// RDY_issue                      O     1 const
// search                         O    67 const
// RDY_search                     O     1 const
// noMatchLdQ                     O     1 const
// RDY_noMatchLdQ                 O     1 const
// noMatchStQ                     O     1 const
// RDY_noMatchStQ                 O     1 const
// CLK                            I     1 unused
// RST_N                          I     1 unused
// getEnqIndex_paddr              I    64 unused
// enq_idx                        I     1 unused
// enq_paddr                      I    64 unused
// enq_be                         I     8 unused
// enq_data                       I    64 unused
// deq_idx                        I     1 unused
// search_paddr                   I    64 unused
// search_be                      I     8 unused
// noMatchLdQ_paddr               I    64 unused
// noMatchLdQ_be                  I     8 unused
// noMatchStQ_paddr               I    64 unused
// noMatchStQ_be                  I     8 unused
// EN_enq                         I     1 unused
// EN_deq                         I     1 unused
// EN_issue                       I     1 unused
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

module mkDummyStoreBuffer(CLK,
			  RST_N,

			  isEmpty,
			  RDY_isEmpty,

			  getEnqIndex_paddr,
			  getEnqIndex,
			  RDY_getEnqIndex,

			  enq_idx,
			  enq_paddr,
			  enq_be,
			  enq_data,
			  EN_enq,
			  RDY_enq,

			  deq_idx,
			  EN_deq,
			  deq,
			  RDY_deq,

			  EN_issue,
			  issue,
			  RDY_issue,

			  search_paddr,
			  search_be,
			  search,
			  RDY_search,

			  noMatchLdQ_paddr,
			  noMatchLdQ_be,
			  noMatchLdQ,
			  RDY_noMatchLdQ,

			  noMatchStQ_paddr,
			  noMatchStQ_be,
			  noMatchStQ,
			  RDY_noMatchStQ);
  input  CLK;
  input  RST_N;

  // value method isEmpty
  output isEmpty;
  output RDY_isEmpty;

  // value method getEnqIndex
  input  [63 : 0] getEnqIndex_paddr;
  output [1 : 0] getEnqIndex;
  output RDY_getEnqIndex;

  // action method enq
  input  enq_idx;
  input  [63 : 0] enq_paddr;
  input  [7 : 0] enq_be;
  input  [63 : 0] enq_data;
  input  EN_enq;
  output RDY_enq;

  // actionvalue method deq
  input  deq_idx;
  input  EN_deq;
  output [633 : 0] deq;
  output RDY_deq;

  // actionvalue method issue
  input  EN_issue;
  output [634 : 0] issue;
  output RDY_issue;

  // value method search
  input  [63 : 0] search_paddr;
  input  [7 : 0] search_be;
  output [66 : 0] search;
  output RDY_search;

  // value method noMatchLdQ
  input  [63 : 0] noMatchLdQ_paddr;
  input  [7 : 0] noMatchLdQ_be;
  output noMatchLdQ;
  output RDY_noMatchLdQ;

  // value method noMatchStQ
  input  [63 : 0] noMatchStQ_paddr;
  input  [7 : 0] noMatchStQ_be;
  output noMatchStQ;
  output RDY_noMatchStQ;

  // signals for module outputs
  wire [634 : 0] issue;
  wire [633 : 0] deq;
  wire [66 : 0] search;
  wire [1 : 0] getEnqIndex;
  wire RDY_deq,
       RDY_enq,
       RDY_getEnqIndex,
       RDY_isEmpty,
       RDY_issue,
       RDY_noMatchLdQ,
       RDY_noMatchStQ,
       RDY_search,
       isEmpty,
       noMatchLdQ,
       noMatchStQ;

  // rule scheduling signals
  wire CAN_FIRE_deq,
       CAN_FIRE_enq,
       CAN_FIRE_issue,
       WILL_FIRE_deq,
       WILL_FIRE_enq,
       WILL_FIRE_issue;

  // value method isEmpty
  assign isEmpty = 1'd1 ;
  assign RDY_isEmpty = 1'd1 ;

  // value method getEnqIndex
  assign getEnqIndex = 2'd0 ;
  assign RDY_getEnqIndex = 1'd1 ;

  // action method enq
  assign RDY_enq = 1'd1 ;
  assign CAN_FIRE_enq = 1'd1 ;
  assign WILL_FIRE_enq = EN_enq ;

  // actionvalue method deq
  assign deq =
	     634'h2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ;
  assign RDY_deq = 1'd1 ;
  assign CAN_FIRE_deq = 1'd1 ;
  assign WILL_FIRE_deq = EN_deq ;

  // actionvalue method issue
  assign issue =
	     635'h2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ;
  assign RDY_issue = 1'd1 ;
  assign CAN_FIRE_issue = 1'd1 ;
  assign WILL_FIRE_issue = EN_issue ;

  // value method search
  assign search = 67'h0AAAAAAAAAAAAAAAA ;
  assign RDY_search = 1'd1 ;

  // value method noMatchLdQ
  assign noMatchLdQ = 1'd1 ;
  assign RDY_noMatchLdQ = 1'd1 ;

  // value method noMatchStQ
  assign noMatchStQ = 1'd1 ;
  assign RDY_noMatchStQ = 1'd1 ;
endmodule  // mkDummyStoreBuffer

