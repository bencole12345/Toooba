//
// Generated by Bluespec Compiler (build 39ae402)
//
//
//
//
// Ports:
// Name                         I/O  size props
// RDY_enq                        O     1
// RDY_deq                        O     1
// first                          O   181
// RDY_first                      O     1
// RDY_specUpdate_incorrectSpeculation  O     1 const
// RDY_specUpdate_correctSpeculation  O     1 const
// CLK                            I     1 clock
// RST_N                          I     1 reset
// enq_x                          I   181
// specUpdate_incorrectSpeculation_kill_all  I     1
// specUpdate_incorrectSpeculation_kill_tag  I     2
// specUpdate_correctSpeculation_mask  I     4
// EN_enq                         I     1
// EN_deq                         I     1
// EN_specUpdate_incorrectSpeculation  I     1
// EN_specUpdate_correctSpeculation  I     1
//
// Combinational paths from inputs to outputs:
//   (specUpdate_incorrectSpeculation_kill_all,
//    specUpdate_incorrectSpeculation_kill_tag,
//    EN_deq,
//    EN_specUpdate_incorrectSpeculation) -> RDY_enq
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

module mkMemRegToExeFifo(CLK,
			 RST_N,

			 enq_x,
			 EN_enq,
			 RDY_enq,

			 EN_deq,
			 RDY_deq,

			 first,
			 RDY_first,

			 specUpdate_incorrectSpeculation_kill_all,
			 specUpdate_incorrectSpeculation_kill_tag,
			 EN_specUpdate_incorrectSpeculation,
			 RDY_specUpdate_incorrectSpeculation,

			 specUpdate_correctSpeculation_mask,
			 EN_specUpdate_correctSpeculation,
			 RDY_specUpdate_correctSpeculation);
  input  CLK;
  input  RST_N;

  // action method enq
  input  [180 : 0] enq_x;
  input  EN_enq;
  output RDY_enq;

  // action method deq
  input  EN_deq;
  output RDY_deq;

  // value method first
  output [180 : 0] first;
  output RDY_first;

  // action method specUpdate_incorrectSpeculation
  input  specUpdate_incorrectSpeculation_kill_all;
  input  [1 : 0] specUpdate_incorrectSpeculation_kill_tag;
  input  EN_specUpdate_incorrectSpeculation;
  output RDY_specUpdate_incorrectSpeculation;

  // action method specUpdate_correctSpeculation
  input  [3 : 0] specUpdate_correctSpeculation_mask;
  input  EN_specUpdate_correctSpeculation;
  output RDY_specUpdate_correctSpeculation;

  // signals for module outputs
  wire [180 : 0] first;
  wire RDY_deq,
       RDY_enq,
       RDY_first,
       RDY_specUpdate_correctSpeculation,
       RDY_specUpdate_incorrectSpeculation;

  // inlined wires
  wire [3 : 0] m_m_specBits_0_lat_1$wget;
  wire m_m_valid_0_lat_0$whas;

  // register m_m_row_0
  reg [176 : 0] m_m_row_0;
  wire [176 : 0] m_m_row_0$D_IN;
  wire m_m_row_0$EN;

  // register m_m_specBits_0_rl
  reg [3 : 0] m_m_specBits_0_rl;
  wire [3 : 0] m_m_specBits_0_rl$D_IN;
  wire m_m_specBits_0_rl$EN;

  // register m_m_valid_0_rl
  reg m_m_valid_0_rl;
  wire m_m_valid_0_rl$D_IN, m_m_valid_0_rl$EN;

  // ports of submodule m_m_deqP_ehr_dummy2_0
  wire m_m_deqP_ehr_dummy2_0$D_IN, m_m_deqP_ehr_dummy2_0$EN;

  // ports of submodule m_m_deqP_ehr_dummy2_1
  wire m_m_deqP_ehr_dummy2_1$D_IN, m_m_deqP_ehr_dummy2_1$EN;

  // ports of submodule m_m_specBits_0_dummy2_0
  wire m_m_specBits_0_dummy2_0$D_IN,
       m_m_specBits_0_dummy2_0$EN,
       m_m_specBits_0_dummy2_0$Q_OUT;

  // ports of submodule m_m_specBits_0_dummy2_1
  wire m_m_specBits_0_dummy2_1$D_IN,
       m_m_specBits_0_dummy2_1$EN,
       m_m_specBits_0_dummy2_1$Q_OUT;

  // ports of submodule m_m_valid_0_dummy2_0
  wire m_m_valid_0_dummy2_0$D_IN,
       m_m_valid_0_dummy2_0$EN,
       m_m_valid_0_dummy2_0$Q_OUT;

  // ports of submodule m_m_valid_0_dummy2_1
  wire m_m_valid_0_dummy2_1$D_IN,
       m_m_valid_0_dummy2_1$EN,
       m_m_valid_0_dummy2_1$Q_OUT;

  // rule scheduling signals
  wire CAN_FIRE_RL_m_m_specBits_0_canon,
       CAN_FIRE_RL_m_m_valid_0_canon,
       CAN_FIRE_deq,
       CAN_FIRE_enq,
       CAN_FIRE_specUpdate_correctSpeculation,
       CAN_FIRE_specUpdate_incorrectSpeculation,
       WILL_FIRE_RL_m_m_specBits_0_canon,
       WILL_FIRE_RL_m_m_valid_0_canon,
       WILL_FIRE_deq,
       WILL_FIRE_enq,
       WILL_FIRE_specUpdate_correctSpeculation,
       WILL_FIRE_specUpdate_incorrectSpeculation;

  // inputs to muxes for submodule ports
  wire MUX_m_m_valid_0_dummy2_0$write_1__SEL_1;

  // remaining internal signals
  wire [3 : 0] IF_m_m_specBits_0_dummy2_0_read__6_AND_m_m_spe_ETC___d29,
	       IF_m_m_specBits_0_lat_0_whas__0_THEN_m_m_specB_ETC___d13,
	       sb__h6306,
	       upd__h2315;

  // action method enq
  assign RDY_enq =
	     !m_m_valid_0_dummy2_1$Q_OUT ||
	     (m_m_valid_0_lat_0$whas ? !1'd0 : !m_m_valid_0_rl) ;
  assign CAN_FIRE_enq =
	     !m_m_valid_0_dummy2_1$Q_OUT ||
	     (m_m_valid_0_lat_0$whas ? !1'd0 : !m_m_valid_0_rl) ;
  assign WILL_FIRE_enq = EN_enq ;

  // action method deq
  assign RDY_deq =
	     m_m_valid_0_dummy2_0$Q_OUT && m_m_valid_0_dummy2_1$Q_OUT &&
	     m_m_valid_0_rl ;
  assign CAN_FIRE_deq = RDY_deq ;
  assign WILL_FIRE_deq = EN_deq ;

  // value method first
  assign first =
	     { m_m_row_0,
	       IF_m_m_specBits_0_dummy2_0_read__6_AND_m_m_spe_ETC___d29 } ;
  assign RDY_first = RDY_deq ;

  // action method specUpdate_incorrectSpeculation
  assign RDY_specUpdate_incorrectSpeculation = 1'd1 ;
  assign CAN_FIRE_specUpdate_incorrectSpeculation = 1'd1 ;
  assign WILL_FIRE_specUpdate_incorrectSpeculation =
	     EN_specUpdate_incorrectSpeculation ;

  // action method specUpdate_correctSpeculation
  assign RDY_specUpdate_correctSpeculation = 1'd1 ;
  assign CAN_FIRE_specUpdate_correctSpeculation = 1'd1 ;
  assign WILL_FIRE_specUpdate_correctSpeculation =
	     EN_specUpdate_correctSpeculation ;

  // submodule m_m_deqP_ehr_dummy2_0
  RevertReg #(.width(32'd1), .init(1'd1)) m_m_deqP_ehr_dummy2_0(.CLK(CLK),
								.D_IN(m_m_deqP_ehr_dummy2_0$D_IN),
								.EN(m_m_deqP_ehr_dummy2_0$EN),
								.Q_OUT());

  // submodule m_m_deqP_ehr_dummy2_1
  RevertReg #(.width(32'd1), .init(1'd1)) m_m_deqP_ehr_dummy2_1(.CLK(CLK),
								.D_IN(m_m_deqP_ehr_dummy2_1$D_IN),
								.EN(m_m_deqP_ehr_dummy2_1$EN),
								.Q_OUT());

  // submodule m_m_specBits_0_dummy2_0
  RevertReg #(.width(32'd1), .init(1'd1)) m_m_specBits_0_dummy2_0(.CLK(CLK),
								  .D_IN(m_m_specBits_0_dummy2_0$D_IN),
								  .EN(m_m_specBits_0_dummy2_0$EN),
								  .Q_OUT(m_m_specBits_0_dummy2_0$Q_OUT));

  // submodule m_m_specBits_0_dummy2_1
  RevertReg #(.width(32'd1), .init(1'd1)) m_m_specBits_0_dummy2_1(.CLK(CLK),
								  .D_IN(m_m_specBits_0_dummy2_1$D_IN),
								  .EN(m_m_specBits_0_dummy2_1$EN),
								  .Q_OUT(m_m_specBits_0_dummy2_1$Q_OUT));

  // submodule m_m_valid_0_dummy2_0
  RevertReg #(.width(32'd1), .init(1'd1)) m_m_valid_0_dummy2_0(.CLK(CLK),
							       .D_IN(m_m_valid_0_dummy2_0$D_IN),
							       .EN(m_m_valid_0_dummy2_0$EN),
							       .Q_OUT(m_m_valid_0_dummy2_0$Q_OUT));

  // submodule m_m_valid_0_dummy2_1
  RevertReg #(.width(32'd1), .init(1'd1)) m_m_valid_0_dummy2_1(.CLK(CLK),
							       .D_IN(m_m_valid_0_dummy2_1$D_IN),
							       .EN(m_m_valid_0_dummy2_1$EN),
							       .Q_OUT(m_m_valid_0_dummy2_1$Q_OUT));

  // rule RL_m_m_valid_0_canon
  assign CAN_FIRE_RL_m_m_valid_0_canon = 1'd1 ;
  assign WILL_FIRE_RL_m_m_valid_0_canon = 1'd1 ;

  // rule RL_m_m_specBits_0_canon
  assign CAN_FIRE_RL_m_m_specBits_0_canon = 1'd1 ;
  assign WILL_FIRE_RL_m_m_specBits_0_canon = 1'd1 ;

  // inputs to muxes for submodule ports
  assign MUX_m_m_valid_0_dummy2_0$write_1__SEL_1 =
	     EN_specUpdate_incorrectSpeculation &&
	     (specUpdate_incorrectSpeculation_kill_all ||
	      IF_m_m_specBits_0_dummy2_0_read__6_AND_m_m_spe_ETC___d29[specUpdate_incorrectSpeculation_kill_tag]) ;

  // inlined wires
  assign m_m_valid_0_lat_0$whas =
	     MUX_m_m_valid_0_dummy2_0$write_1__SEL_1 || EN_deq ;
  assign m_m_specBits_0_lat_1$wget =
	     sb__h6306 & specUpdate_correctSpeculation_mask ;

  // register m_m_row_0
  assign m_m_row_0$D_IN = enq_x[180:4] ;
  assign m_m_row_0$EN = EN_enq ;

  // register m_m_specBits_0_rl
  assign m_m_specBits_0_rl$D_IN =
	     EN_specUpdate_correctSpeculation ?
	       upd__h2315 :
	       IF_m_m_specBits_0_lat_0_whas__0_THEN_m_m_specB_ETC___d13 ;
  assign m_m_specBits_0_rl$EN = 1'd1 ;

  // register m_m_valid_0_rl
  assign m_m_valid_0_rl$D_IN =
	     EN_enq || (m_m_valid_0_lat_0$whas ? 1'd0 : m_m_valid_0_rl) ;
  assign m_m_valid_0_rl$EN = 1'd1 ;

  // submodule m_m_deqP_ehr_dummy2_0
  assign m_m_deqP_ehr_dummy2_0$D_IN = 1'd1 ;
  assign m_m_deqP_ehr_dummy2_0$EN = EN_deq ;

  // submodule m_m_deqP_ehr_dummy2_1
  assign m_m_deqP_ehr_dummy2_1$D_IN = 1'b0 ;
  assign m_m_deqP_ehr_dummy2_1$EN = 1'b0 ;

  // submodule m_m_specBits_0_dummy2_0
  assign m_m_specBits_0_dummy2_0$D_IN = 1'd1 ;
  assign m_m_specBits_0_dummy2_0$EN = EN_enq ;

  // submodule m_m_specBits_0_dummy2_1
  assign m_m_specBits_0_dummy2_1$D_IN = 1'd1 ;
  assign m_m_specBits_0_dummy2_1$EN = EN_specUpdate_correctSpeculation ;

  // submodule m_m_valid_0_dummy2_0
  assign m_m_valid_0_dummy2_0$D_IN = 1'd1 ;
  assign m_m_valid_0_dummy2_0$EN =
	     MUX_m_m_valid_0_dummy2_0$write_1__SEL_1 || EN_deq ;

  // submodule m_m_valid_0_dummy2_1
  assign m_m_valid_0_dummy2_1$D_IN = 1'd1 ;
  assign m_m_valid_0_dummy2_1$EN = EN_enq ;

  // remaining internal signals
  assign IF_m_m_specBits_0_dummy2_0_read__6_AND_m_m_spe_ETC___d29 =
	     (m_m_specBits_0_dummy2_0$Q_OUT &&
	      m_m_specBits_0_dummy2_1$Q_OUT) ?
	       m_m_specBits_0_rl :
	       4'd0 ;
  assign IF_m_m_specBits_0_lat_0_whas__0_THEN_m_m_specB_ETC___d13 =
	     EN_enq ? enq_x[3:0] : m_m_specBits_0_rl ;
  assign sb__h6306 =
	     m_m_specBits_0_dummy2_1$Q_OUT ?
	       IF_m_m_specBits_0_lat_0_whas__0_THEN_m_m_specB_ETC___d13 :
	       4'd0 ;
  assign upd__h2315 = m_m_specBits_0_lat_1$wget ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        m_m_specBits_0_rl <= `BSV_ASSIGNMENT_DELAY 4'hA;
	m_m_valid_0_rl <= `BSV_ASSIGNMENT_DELAY 1'd0;
      end
    else
      begin
        if (m_m_specBits_0_rl$EN)
	  m_m_specBits_0_rl <= `BSV_ASSIGNMENT_DELAY m_m_specBits_0_rl$D_IN;
	if (m_m_valid_0_rl$EN)
	  m_m_valid_0_rl <= `BSV_ASSIGNMENT_DELAY m_m_valid_0_rl$D_IN;
      end
    if (m_m_row_0$EN) m_m_row_0 <= `BSV_ASSIGNMENT_DELAY m_m_row_0$D_IN;
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    m_m_row_0 = 177'h0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    m_m_specBits_0_rl = 4'hA;
    m_m_valid_0_rl = 1'h0;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkMemRegToExeFifo

