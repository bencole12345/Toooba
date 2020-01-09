
// Copyright (c) 2017 Massachusetts Institute of Technology
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

`include "ProcConfig.bsv"
import Vector::*;
import GetPut::*;
import Cntrs::*;
import ConfigReg::*;
import FIFO::*;
import Types::*;
import ProcTypes::*;
import CCTypes::*;
import Performance::*;
import ReorderBuffer::*;
import ReorderBufferSynth::*;
import RenamingTable::*;
import CsrFile::*;
import StoreBuffer::*;
import VerificationPacket::*;
import RenameDebugIF::*;

import Cur_Cycle :: *;

typedef struct {
    // info about the inst blocking at ROB head
    Addr pc;
    IType iType;
    Maybe#(Trap) trap;
    RobInstState state;
    Bool claimedPhyReg;
    Bool ldKilled;
    Bool memAccessAtCommit;
    Bool lsqAtCommitNotified;
    Bool nonMMIOStDone;
    Bool epochIncremented;
    SpecBits specBits;
    // info about LSQ/TLB
    Bool stbEmpty;
    Bool stqEmpty;
    Bool tlbNoPendingReq;
    // CSR info: previlige mode
    Bit#(2) prv;
    // inst count
    Data instCount;
} CommitStuck deriving(Bits, Eq, FShow);

interface CommitInput;
    // func units
    interface ReorderBufferSynth robIfc;
    interface RegRenamingTable rtIfc;
    interface CsrFile csrfIfc;
    // no stores
    method Bool stbEmpty;
    method Bool stqEmpty;
    // notify LSQ that inst has reached commit
    interface Vector#(SupSize, Put#(LdStQTag)) lsqSetAtCommit;
    // TLB has stopped processing now
    method Bool tlbNoPendingReq;
    // set flags
    method Action setFlushTlbs;
    method Action setUpdateVMInfo;
    method Action setFlushReservation;
    method Action setFlushBrPred; // security
    method Action setFlushCaches; // security
    method Action setReconcileI; // recocile I$
    method Action setReconcileD; // recocile D$
    // redirect
    method Action killAll;
    method Action redirectPc(Addr trap_pc);
    method Action setFetchWaitRedirect;
    method Action incrementEpoch;
    // record if we commit a CSR inst or interrupt
    method Action commitCsrInstOrInterrupt;
    // performance
    method Bool doStats;
    // deadlock check
    method Bool checkDeadlock;
endinterface

typedef struct {
    RenameError err;
    Addr pc;
    IType iType;
    Maybe#(Trap) trap;
    SpecBits specBits;
} RenameErrInfo deriving(Bits, Eq, FShow);

interface CommitStage;
    // performance
    method Data getPerf(ComStagePerfType t); 
    // deadlock check
    interface Get#(CommitStuck) commitInstStuck;
    interface Get#(CommitStuck) commitUserInstStuck;
    // rename debug
    method Action startRenameDebug;
    interface Get#(RenameErrInfo) renameErr;

`ifdef INCLUDE_GDB_CONTROL
   // Request halt into debug mode
   method Action halt_to_debug_mode_req;

   (* always_ready *)
   // Becomes true when pipeline is halted
   method Bool is_debug_halted;

   method Action resume_from_debug_mode;
`endif

endinterface

// we apply actions the end of commit rule
// use struct to record actions to be done
typedef struct {
    Addr pc;
    Addr addr;
    Trap trap;
} CommitTrap deriving(Bits, Eq, FShow);

// Bluespec: for debugger run-control
typedef enum {
   Run_State_RUNNING              // Normal state
`ifdef INCLUDE_GDB_CONTROL
   , Run_State_DEBUGGER_HALT         // When ready to halt for debugger after stop/step
   , Run_State_DEBUGGER_HALT_FLUSH   // When flushing state during debugger halt
   , Run_State_DEBUGGER_HALTED       // When halted for debugger
`endif
   } Run_State
deriving (Eq, FShow, Bits);

module mkCommitStage#(CommitInput inIfc)(CommitStage);
    Bool verbose = False;

    // Bluespec: for lightweight verbosity trace
    Integer verbosity = 1;
    Reg #(Bit #(64)) rg_instret <- mkReg (0);

   // Bluespec: for debugger run-control
   Reg #(Run_State) rg_run_state   <- mkReg (Run_State_RUNNING);

`ifdef INCLUDE_GDB_CONTROL
   // rg_stop_req is set True when debugger requests a stop (e.g., GDB ^C)
   Reg #(Bool)      rg_stop_req   <- mkReg (False);
   // When going into debug mode, these hold the cause for the break and the resume-PC
   Reg #(Bit #(3))  rg_debug_cause <- mkRegU;
   Reg #(Addr)      rg_debug_pc    <- mkRegU;
`endif

    // func units
    ReorderBufferSynth rob = inIfc.robIfc;
    RegRenamingTable regRenamingTable = inIfc.rtIfc;
    CsrFile csrf = inIfc.csrfIfc;

    // FIXME FIXME FIXME wires to set atCommit in LSQ: avoid scheduling cycle.
    // Using wire should be fine, because LSQ does not need to see atCommit
    // signal immediately. XXX The concern is about killAll which checks
    // atCommit in LSQ, but we never call killAll and setAtCommit in the same
    // cycle.
    Vector#(SupSize, RWire#(LdStQTag)) setLSQAtCommit <- replicateM(mkRWire);

    for(Integer i = 0; i< valueof(SupSize); i = i+1) begin
        (* fire_when_enabled, no_implicit_conditions *)
        rule doSetLSQAtCommit(setLSQAtCommit[i].wget matches tagged Valid .tag);
            inIfc.lsqSetAtCommit[i].put(tag);
        endrule
    end

    // commit stage performance counters
`ifdef PERF_COUNT
    // inst
    Count#(Data) instCnt <- mkCount(0);
    Count#(Data) userInstCnt <- mkCount(0);
    Count#(Data) supComUserCnt <- mkCount(0);
    // branch/jump inst
    Count#(Data) comBrCnt <- mkCount(0);
    Count#(Data) comJmpCnt <- mkCount(0);
    Count#(Data) comJrCnt <- mkCount(0);
    // mem inst
    Count#(Data) comLdCnt <- mkCount(0);
    Count#(Data) comStCnt <- mkCount(0);
    Count#(Data) comLrCnt <- mkCount(0);
    Count#(Data) comScCnt <- mkCount(0);
    Count#(Data) comAmoCnt <- mkCount(0);
    // load mispeculation
    Count#(Data) comLdKillByLdCnt <- mkCount(0);
    Count#(Data) comLdKillByStCnt <- mkCount(0);
    Count#(Data) comLdKillByCacheCnt <- mkCount(0);
    // exception/sys inst related
    Count#(Data) comSysCnt <- mkCount(0);
    Count#(Data) excepCnt <- mkCount(0);
    Count#(Data) interruptCnt <- mkCount(0);
    // flush tlb
    Count#(Data) flushTlbCnt <- mkCount(0);
    // flush security
    Count#(Data) flushSecurityCnt <- mkCount(0);
    Count#(Data) flushBPCnt <- mkCount(0);
    Count#(Data) flushCacheCnt <- mkCount(0);
`endif

    // deadlock check
`ifdef CHECK_DEADLOCK
    // timer to check deadlock
    Reg#(DeadlockTimer) commitInstTimer <- mkReg(0);
    Reg#(DeadlockTimer) commitUserInstTimer <- mkReg(0);
    // FIFOs to output deadlock info
    FIFO#(CommitStuck) commitInstStuckQ <- mkFIFO1;
    FIFO#(CommitStuck) commitUserInstStuckQ <- mkFIFO1;
    // wires to indicate that deadlock is reported, so reset timers
    PulseWire commitInstStuckSent <- mkPulseWire;
    PulseWire commitUserInstStuckSent <- mkPulseWire;
    // wires to reset timers since processor is making progress
    PulseWire commitInst <- mkPulseWire;
    PulseWire commitUserInst <- mkPulseWire;

    function CommitStuck commitStuck;
        let x = rob.deqPort[0].deq_data;
        return CommitStuck {
            pc: x.pc,
            iType: x.iType,
            trap: x.trap,
            state: x.rob_inst_state,
            claimedPhyReg: x.claimed_phy_reg,
            ldKilled: isValid(x.ldKilled),
            memAccessAtCommit: x.memAccessAtCommit,
            lsqAtCommitNotified: x.lsqAtCommitNotified,
            nonMMIOStDone: x.nonMMIOStDone,
            epochIncremented: x.epochIncremented,
            specBits: x.spec_bits,
            stbEmpty: inIfc.stbEmpty,
            stqEmpty: inIfc.stqEmpty,
            tlbNoPendingReq: inIfc.tlbNoPendingReq,
            prv: csrf.decodeInfo.prv,
            instCount: csrf.rd(CSRinstret)
        };
    endfunction

    (* fire_when_enabled *)
    rule checkDeadlock_commitInst(inIfc.checkDeadlock && commitInstTimer == maxBound);
        commitInstStuckQ.enq(commitStuck);
        commitInstStuckSent.send;
    endrule

    (* fire_when_enabled *)
    rule checkDeadlock_commitUserInst(inIfc.checkDeadlock && commitUserInstTimer == maxBound);
        commitUserInstStuckQ.enq(commitStuck);
        commitUserInstStuckSent.send;
    endrule

    (* fire_when_enabled, no_implicit_conditions *)
    rule incrDeadlockTimer(inIfc.checkDeadlock);
        function DeadlockTimer getNextTimer(DeadlockTimer t);
            return t == maxBound ? maxBound : t + 1;
        endfunction
        commitInstTimer <= (commitInst || commitInstStuckSent) ? 0 : getNextTimer(commitInstTimer);
        commitUserInstTimer <= (commitUserInst || commitUserInstStuckSent) ? 0 : getNextTimer(commitUserInstTimer);
    endrule
`endif

`ifdef RENAME_DEBUG
    // rename debug
    Reg#(Bool) renameDebugStarted <- mkConfigReg(False);
    Reg#(Maybe#(RenameErrInfo)) renameErrInfo <- mkConfigReg(Invalid);
    Bool canSetRenameErr = renameDebugStarted && renameErrInfo == Invalid; // only set err info once
    // only send 1 error msg
    FIFO#(RenameErrInfo) renameErrQ <- mkFIFO1;

    rule sendRenameErr(renameDebugStarted &&& renameErrInfo matches tagged Valid .info);
        renameErrQ.enq(info);
        renameDebugStarted <= False;
    endrule
`endif

    // we commit trap in two cycles: first cycle deq ROB and flush; second
    // cycle handles trap, redirect and handles system consistency
    Reg#(Maybe#(CommitTrap)) commitTrap <- mkReg(Invalid); // saves new pc here

    // maintain system consistency when system state (CSR) changes or for security
    function Action makeSystemConsistent(Bool flushTlb,
                                         Bool flushSecurity,
                                         Bool reconcileI);
    action
`ifndef SECURITY
        flushSecurity = False;
`endif

`ifndef DISABLE_SECURE_FLUSH_TLB
        if(flushTlb || flushSecurity) begin
`else
        if(flushTlb) begin
`endif
            inIfc.setFlushTlbs;
`ifdef PERF_COUNT
            if(inIfc.doStats) begin
                flushTlbCnt.incr(1);
            end
`endif
        end
        // notify TLB to keep update of CSR changes
        inIfc.setUpdateVMInfo;
        // always wait store buffer and SQ to be empty
        when(inIfc.stbEmpty && inIfc.stqEmpty, noAction);
        // We wait TLB to finish all requests and become sync with memory.
        // Notice that currently TLB is read only, so TLB is always in sync
        // with memory (i.e., there is no write to commit to memory). Since all
        // insts have been killed, nothing can be issued to D TLB at this time.
        // Since fetch stage is set to wait for redirect, fetch1 stage is
        // stalled, and nothing can be issued to I TLB at this time.
        // Therefore, we just need to make sure that I and D TLBs are not
        // handling any miss req. Besides, when I and D TLBs do not have any
        // miss req, L2 TLB must be idling.
        when(inIfc.tlbNoPendingReq, noAction);
        // yield load reservation in cache
        inIfc.setFlushReservation;

        // flush for security, we can delay the stall for fetch-empty and
        // wrong-path-load-empty until we really do the flush. This delay is
        // valid because these wrong path inst/req will not interfere with
        // whatever CSR changes we are making now.
        if(flushSecurity) begin
`ifdef PERF_COUNT
            if(inIfc.doStats) begin
                flushSecurityCnt.incr(1);
            end
`endif

`ifndef DISABLE_SECURE_FLUSH_BP
            inIfc.setFlushBrPred;
`ifdef PERF_COUNT
            if(inIfc.doStats) begin
                flushBPCnt.incr(1);
            end
`endif
`endif

`ifndef DISABLE_SECURE_FLUSH_CACHE
            inIfc.setFlushCaches;
`ifdef PERF_COUNT
            if(inIfc.doStats) begin
                flushCacheCnt.incr(1);
            end
`endif
`endif
        end

`ifdef SELF_INV_CACHE
        // reconcile I$
        if(reconcileI) begin
            inIfc.setReconcileI;
        end
`ifdef SYSTEM_SELF_INV_L1D
        // FIXME is this reconcile of D$ necessary?
        inIfc.setReconcileD;
`endif
`endif
    endaction
    endfunction

`ifdef INCLUDE_GDB_CONTROL
   // ================================================================
   // Bluespec: debugger run-control
   // Every time an instruction commits, we check this boolean
   // to decide whether we continue running of stop.

   // We halt after committing an instruction if:
   //     the debugger requested a stop
   //  or dcsr.step is True

   Maybe #(Bit #(3)) m_debug_stop_step_cause = (  rg_stop_req
						? tagged Valid 3            // Debug Module haltreq
						: (csrf.dcsr_stop_for_step
						   ? tagged Valid 4         // dcsr.step
						   : tagged Invalid));

   // ================================================================

   /*
   // Bluespec: debugger run-control
   // Rule cond should be identical to doCommitTrap_flush's cond
   // except for fn_ebreak_to_debug_mode()
    rule doCommitTrap_ebreak_to_debug_mode(
        (rg_run_state == Run_State_RUNNING) &&&    // Bluespec: debugger run-control
        !isValid(commitTrap) &&&
        rob.deqPort[0].deq_data.trap matches tagged Valid .trap &&&
        fn_ebreak_to_debug_mode (trap)             // Bluespec: debugger run-control
    );
       let x = rob.deqPort[0].deq_data;
       rg_run_state   <= Run_State_DEBUGGER_HALT;
       rg_debug_pc    <= x.pc;
       rg_debug_cause <= 1;    // cause: EBREAK
    endrule
   */
`endif

   // ================================================================

    // TODO Currently we don't check spec bits == 0 when we commit an
    // instruction. This is because killings of wrong path instructions are
    // done in a single cycle. However, when we make killings distributed or
    // pipelined, then we need to check spec bits at commit port.

    rule doCommitTrap_flush(
`ifdef INCLUDE_GDB_CONTROL
        (rg_run_state == Run_State_RUNNING) &&&    // Bluespec: debugger run-control
`endif
        !isValid(commitTrap) &&&
        rob.deqPort[0].deq_data.trap matches tagged Valid .trap
    );
        $display ("%0d: %m.CommitStage.rule_doCommitTrap_flush", cur_cycle);
        rob.deqPort[0].deq;
        let x = rob.deqPort[0].deq_data;
        if(verbose) $display("[doCommitTrap] ", fshow(x));

        // record trap info
        Addr vaddr = ?;
        if (   (trap == tagged Exception InstAccessFault)
	    || (trap == tagged Exception InstPageFault)) begin
	    vaddr = x.tval;
	end
        else if(x.ppc_vaddr_csrData matches tagged VAddr .va) begin
            vaddr = va;
        end
        let commitTrap_val = Valid (CommitTrap {
            trap: trap,
            pc: x.pc,
            addr: vaddr
	});
        commitTrap <= commitTrap_val;

        if (verbosity > 0) begin
	   $display ("instret:%0d  PC:0x%0h  instr:0x%08h", rg_instret, x.pc, x.orig_inst,
		     "  iType:", fshow (x.iType), "    [doCommitTrap]");
	end
        if (verbose) begin
	   $display ("CommitStage.doCommitTrap_flush: deq_data:   ", fshow (x));
	   $display ("CommitStage.doCommitTrap_flush: commitTrap: ", fshow (commitTrap_val));
	end

        // flush everything. Only increment epoch and stall fetch when we haven
        // not done it yet (we may have already done them at rename stage)
        inIfc.killAll;
        if(!x.epochIncremented) begin
            inIfc.incrementEpoch;
            inIfc.setFetchWaitRedirect;
        end

        // faulting mem inst may have claimed phy reg, we should not commit it;
        // instead, we kill the renaming by calling killAll

`ifdef PERF_COUNT
        // performance counter
        if(inIfc.doStats) begin
            if(trap matches tagged Exception .e) begin
                excepCnt.incr(1);
            end
            else begin
                interruptCnt.incr(1);
            end
        end
`endif

        // checks
        doAssert(x.rob_inst_state == Executed, "must be executed");
        doAssert(x.spec_bits == 0, "cannot have spec bits");
    endrule

    // This rule's condition is enabled only by the previous rule, doCommitTrap_flush
    rule doCommitTrap_handle(
`ifdef INCLUDE_GDB_CONTROL
       (rg_run_state == Run_State_RUNNING) &&&    // Bluespec: debugger run-control
`endif
       commitTrap matches tagged Valid .trap);

        $display ("%0d: %m.CommitStage.rule_doCommitTrap_handle", cur_cycle);

        // reset commitTrap
        commitTrap <= Invalid;

        // notify commit of interrupt (so MMIO pRq may be handled)
        if(trap.trap matches tagged Interrupt .inter) begin
            inIfc.commitCsrInstOrInterrupt;
        end

`ifdef INCLUDE_GDB_CONTROL
       if ((trap.trap == tagged Exception Breakpoint) && csrf.dcsr_stop_for_break) begin
	  // Don't handle the trap
	  rg_run_state <= Run_State_DEBUGGER_HALTED;
	  // Record debug CSRs for later Debugger query and later resumption
	  csrf.dcsr_cause_write (1);          // EBREAK dcsr.cause
	  csrf.dpc_write        (trap.pc);    // Where we'll resume on 'continue'
       end
       else begin
          // Handle the trap and redirect
          let new_pc <- csrf.trap(trap.trap, trap.pc, trap.addr);
	  inIfc.redirectPc (new_pc);

          if (m_debug_stop_step_cause matches tagged Valid .cause) begin
	     rg_run_state <= Run_State_DEBUGGER_HALTED;
	     // Record debug CSRs for later Debugger query and later resumption
	     csrf.dcsr_cause_write (cause);
	     csrf.dpc_write        (new_pc);    // Where we'll resume on 'continue'
	  end
       end
`else
       // trap handling & redirect
       let new_pc <- csrf.trap(trap.trap, trap.pc, trap.addr);
       inIfc.redirectPc(new_pc);
`endif

        // system consistency
        // TODO spike flushes TLB here, but perhaps it is because spike's TLB
        // does not include prv info, and it has to flush when prv changes.
        // XXX As approximation, Trap may cause context switch, so flush for
        // security
        makeSystemConsistent(False, True, False);
    endrule

    // commit misspeculated load
    rule doCommitKilledLd(
`ifdef INCLUDE_GDB_CONTROL
        (rg_run_state == Run_State_RUNNING) &&&    // Bluespec: debugger run-control
`endif
        !isValid(commitTrap) &&&
        !isValid(rob.deqPort[0].deq_data.trap) &&&
        rob.deqPort[0].deq_data.ldKilled matches tagged Valid .killBy
    );
        rob.deqPort[0].deq;
        let x = rob.deqPort[0].deq_data;
        if(verbose) $display("[doCommitKilledLd] ", fshow(x));

        // kill everything, redirect, and increment epoch
        inIfc.killAll;

`ifdef INCLUDE_GDB_CONTROL
       // Bluespec: debug run-control
       doAssert (x.iType != Ebreak, "CommitStage.rule_doCommitKilledLd iType should not be Ebreak");
       if (m_debug_stop_step_cause matches tagged Valid .cause) begin
	  rg_run_state   <= Run_State_DEBUGGER_HALT_FLUSH;
	  rg_debug_pc    <= x.pc;
	  rg_debug_cause <= cause;
       end
       else
`endif
          inIfc.redirectPc(x.pc);    // original (no debugger)

        inIfc.incrementEpoch;

        // the killed Ld should have claimed phy reg, we should not commit it;
        // instead, we have kill the renaming by calling killAll

`ifdef PERF_COUNT
        if(inIfc.doStats) begin
            case(killBy)
                Ld: comLdKillByLdCnt.incr(1);
                St: comLdKillByStCnt.incr(1);
                Cache: comLdKillByCacheCnt.incr(1);
            endcase
        end
`endif

        // checks
        doAssert(!x.epochIncremented, "cannot increment epoch before");
        doAssert(x.rob_inst_state == Executed, "must be executed");
        doAssert(x.spec_bits == 0, "cannot have spec bits");
    endrule

    // commit system inst
    rule doCommitSystemInst(
`ifdef INCLUDE_GDB_CONTROL
        (rg_run_state == Run_State_RUNNING) &&    // Bluespec: debugger run-control
`endif
        !isValid(commitTrap) &&
        !isValid(rob.deqPort[0].deq_data.trap) &&
        !isValid(rob.deqPort[0].deq_data.ldKilled) &&
        rob.deqPort[0].deq_data.rob_inst_state == Executed &&
        isSystem(rob.deqPort[0].deq_data.iType)
    );
        rob.deqPort[0].deq;
        let x = rob.deqPort[0].deq_data;
        if(verbose) $display("[doCommitSystemInst] ", fshow(x));
        if (verbosity > 0) begin
	   $display("instret:%0d  PC:0x%0h  instr:0x%08h", rg_instret, x.pc, x.orig_inst,
		    "   iType:", fshow (x.iType), "    [doCommitSystemInst]");
	   rg_instret <= rg_instret + 1;
	end

        // we claim a phy reg for every inst, so commit its renaming
        regRenamingTable.commit[0].commit;

        Bool write_satp = False; // flush tlb when satp csr is modified
        Bool flush_security = False; // flush for security when the flush csr is written
        if(x.iType == Csr) begin
            // notify commit of CSR (so MMIO pRq may be handled)
            inIfc.commitCsrInstOrInterrupt;
            // write CSR
            let csr_idx = validValue(x.csr);
            Data csr_data = ?;
            if(x.ppc_vaddr_csrData matches tagged CSRData .d) begin
                csr_data = d;
            end
            else begin
                doAssert(False, "must have csr data");
            end
            csrf.csrInstWr(csr_idx, csr_data);
            // check if satp is modified or not
            write_satp = csr_idx == CSRsatp;
`ifdef SECURITY
            flush_security = csr_idx == CSRmflush;
`endif
        end

        // redirect (Sret and Mret redirect pc is got from CSRF)
        Addr next_pc = x.ppc_vaddr_csrData matches tagged PPC .ppc ? ppc : (x.pc + 4);
        doAssert(next_pc == x.pc + 4, "ppc must be pc + 4");
        if(x.iType == Sret) begin
            next_pc <- csrf.sret;
        end
        else if(x.iType == Mret) begin
            next_pc <- csrf.mret;
        end

`ifdef INCLUDE_GDB_CONTROL
       // Bluespec: debug run-control
       doAssert (x.iType != Ebreak, "CommitStage.rule_doCommitSystemInst iType should not be Ebreak");
       if (m_debug_stop_step_cause matches tagged Valid .cause) begin
	  rg_run_state   <= Run_State_DEBUGGER_HALT_FLUSH;
	  rg_debug_pc    <= next_pc;
	  rg_debug_cause <= cause;
       end
       else
`endif
          inIfc.redirectPc(next_pc);    // original (no debugger)

        // rename stage only sends out system inst when ROB is empty, so no
        // need to flush ROB again

        // system consistency
        // flush TLB for SFence.VMA and when SATP CSR is modified
        // XXX as approximation, sret/mret may mean context switch, so flush
        // for security
        makeSystemConsistent(
            x.iType == SFence || write_satp, // TODO flush TLB when change sanctum regs?
            flush_security || x.iType == Sret || x.iType == Mret,
            x.iType == FenceI // reconcile I$ for fence.i
        );

        // incr inst cnt
        csrf.incInstret(1);

`ifdef PERF_COUNT
        if(inIfc.doStats) begin
            comSysCnt.incr(1);
            // inst count stats
            instCnt.incr(1);
            if(csrf.decodeInfo.prv == prvU) begin
                userInstCnt.incr(1);
            end
        end
`endif
`ifdef CHECK_DEADLOCK
        commitInst.send;
        if(csrf.decodeInfo.prv == 0) begin
            commitUserInst.send;
        end
`endif

        // checks
        doAssert(x.epochIncremented, "must have already incremented epoch");
        doAssert((x.iType == Csr) == isValid(x.csr), "only CSR has valid csr idx");
        doAssert(x.fflags == 0 && !x.will_dirty_fpu_state, "cannot dirty FPU");
        doAssert(x.spec_bits == 0, "cannot have spec bits");
        doAssert(x.claimed_phy_reg, "must have claimed phy reg");
`ifdef RENAME_DEBUG
        if(!x.claimed_phy_reg && canSetRenameErr) begin
            renameErrInfo <= Valid (RenameErrInfo {
                err: NonTrapCommitLackClaim,
                pc: x.pc,
                iType: x.iType,
                trap: x.trap,
                specBits: x.spec_bits
            });
        end
`endif
    endrule

    // Lr/Sc/Amo/MMIO cannot proceed to executed until we notify LSQ that it
    // has reached the commit stage
    rule notifyLSQCommit(
`ifdef INCLUDE_GDB_CONTROL
        (rg_run_state == Run_State_RUNNING) &&    // Bluespec: debugger run-control
`endif
        !isValid(commitTrap) &&
        !isValid(rob.deqPort[0].deq_data.trap) &&
        !isValid(rob.deqPort[0].deq_data.ldKilled) &&
        rob.deqPort[0].deq_data.rob_inst_state != Executed &&
        rob.deqPort[0].deq_data.memAccessAtCommit &&
        !rob.deqPort[0].deq_data.lsqAtCommitNotified
    );
        let x = rob.deqPort[0].deq_data;
        let inst_tag = rob.deqPort[0].getDeqInstTag;
        if(verbose) $display("[notifyLSQCommit] ", fshow(x), "; ", fshow(inst_tag));

        // notify LSQ, and record in ROB that notification is done
        setLSQAtCommit[0].wset(x.lsqTag);
        rob.setLSQAtCommitNotified(inst_tag);
    endrule

    // commit normal: fire when at least one commit can be done
    rule doCommitNormalInst(
`ifdef INCLUDE_GDB_CONTROL
        (rg_run_state == Run_State_RUNNING) &&    // Bluespec: debugger run-control
`endif
        !isValid(commitTrap) &&
        !isValid(rob.deqPort[0].deq_data.trap) &&
        !isValid(rob.deqPort[0].deq_data.ldKilled) &&
        rob.deqPort[0].deq_data.rob_inst_state == Executed &&
        !isSystem(rob.deqPort[0].deq_data.iType)
    );
        // stop superscalar commit after we
        // 1. see a trap or system inst or killed Ld
        // 2. inst is not ready to commit
        Bool stop = False;

        // Bluespec: debugger run-control
        // 3. one instr is committed and debugger halt is requested (due to stop or step)
        Bool stop_for_debugger = False;

        // We merge writes on FPU csr and apply writes at the end of the rule
        Bit#(5) fflags = 0;
        Bool will_dirty_fpu_state = False;
        // rename error
        Maybe#(RenameErrInfo) renameError = Invalid;
        // incr committed inst cnt at the end of rule
        SupCnt comInstCnt = 0;
        SupCnt comUserInstCnt = 0;
`ifdef PERF_COUNT
        // incr some performance counter at the end of rule
        SupCnt brCnt = 0;
        SupCnt jmpCnt = 0;
        SupCnt jrCnt = 0;
        SupCnt ldCnt = 0;
        SupCnt stCnt = 0;
        SupCnt lrCnt = 0;
        SupCnt scCnt = 0;
        SupCnt amoCnt = 0;
`endif

        Bit #(64) instret = 0;

        // compute what actions to take
        for(Integer i = 0; i < valueof(SupSize); i = i+1) begin

            if(!stop && (! stop_for_debugger) && rob.deqPort[i].canDeq) begin
                let x = rob.deqPort[i].deq_data;
                let inst_tag = rob.deqPort[i].getDeqInstTag;

                // check can be committed or not
                if(x.rob_inst_state != Executed || isValid(x.ldKilled) || isValid(x.trap) || isSystem(x.iType)) begin
                    // inst not ready for commit, or system inst, or trap, or killed, stop here
                    stop = True;
                end
                else begin
                    if (verbose) $display("[doCommitNormalInst - %d] ", i, fshow(inst_tag), " ; ", fshow(x));

		    if (verbosity > 0) begin
		       $display("instret:%0d  PC:0x%0h  instr:0x%08h", rg_instret + instret, x.pc, x.orig_inst,
				"   iType:", fshow (x.iType), "    [doCommitNormalInst [%0d]]", i);
		       instret = instret + 1;
		    end

                    // inst can be committed, deq it
                    rob.deqPort[i].deq;

                    // every inst here should have been renamed, commit renaming
                    regRenamingTable.commit[i].commit;
                    doAssert(x.claimed_phy_reg, "should have renamed");

`ifdef RENAME_DEBUG
                    // send debug msg for rename error
                    if(!x.claimed_phy_reg && !isValid(renameError)) begin
                        renameError = Valid (RenameErrInfo {
                            err: NonTrapCommitLackClaim,
                            pc: x.pc,
                            iType: x.iType,
                            trap: x.trap,
                            specBits: x.spec_bits
                        });
                    end
`endif

                    // cumulate writes to FPU csr
                    fflags = fflags | x.fflags;
                    will_dirty_fpu_state = will_dirty_fpu_state || x.will_dirty_fpu_state;

                    // for non-mmio st, notify SQ that store is committed
                    if(x.nonMMIOStDone) begin
                        setLSQAtCommit[i].wset(x.lsqTag);
                    end

                    // inst commit counter
                    comInstCnt = comInstCnt + 1;
                    if(csrf.decodeInfo.prv == 0) begin
                        comUserInstCnt = comUserInstCnt + 1; // user space inst
                    end

`ifdef INCLUDE_GDB_CONTROL
		   if (m_debug_stop_step_cause matches tagged Valid .cause
		       &&& (comInstCnt != 0))
		      begin
			 $display ("%0d: %m.CommitStage.rule_doCommitNormalInst: Stopping for debugger", cur_cycle);
			 stop_for_debugger = True;

			 // Compute next PC in case of debugger stop.
			 // Note: AluExePipeline.rule_doFinishAlu does inIfc.rob_setExecuted (... x.controlFlow)
			 //     which updates the rob entry's ppc_vaddr_csrData field with actual
			 //     branch/jump targets, which we retrieve here.
			 Addr next_pc = ?;
			 if (x.ppc_vaddr_csrData matches tagged PPC .addr
			    &&& ((x.iType == J) || (x.iType == Jr) || (x.iType == Br)))
			    // JAL, JALR, BRANCH
			    next_pc = addr;
			 else if (x.orig_inst [1:0] == 2'b11)
			    // RV32I RV64I
			    next_pc = x.pc + 4;
			 else
			    // RVC
			    next_pc = x.pc + 2;

			 rg_run_state   <= Run_State_DEBUGGER_HALT_FLUSH;
			 rg_debug_pc    <= next_pc;
			 rg_debug_cause <= cause;
		      end
`endif

`ifdef PERF_COUNT
                    // performance counter
                    case(x.iType)
                        Br: brCnt = brCnt + 1;
                        J : jmpCnt = jmpCnt + 1;
                        Jr: jrCnt = jrCnt + 1;
                        Ld: ldCnt = ldCnt + 1;
                        St: stCnt = stCnt + 1;
                        Lr: lrCnt = lrCnt + 1;
                        Sc: scCnt = scCnt + 1;
                        Amo: amoCnt = amoCnt + 1;
                    endcase
`endif
                end
            end
        end    // for-loop for superscalar width
        rg_instret <= rg_instret + instret;

        // write FPU csr
        if(csrf.fpuInstNeedWr(fflags, will_dirty_fpu_state)) begin
            csrf.fpuInstWr(fflags);
        end

        // incr inst cnt
        csrf.incInstret(comInstCnt);

`ifdef RENAME_DEBUG
        // set rename error
        if(canSetRenameErr && isValid(renameError)) begin
            renameErrInfo <= renameError;
        end
`endif

`ifdef CHECK_DEADLOCK
        commitInst.send; // ROB head is removed
        if(comUserInstCnt > 0) begin
            commitUserInst.send;
        end
`endif

`ifdef PERF_COUNT
        // performance counter
        if(inIfc.doStats) begin
            // branch stats
            comBrCnt.incr(zeroExtend(brCnt));
            comJmpCnt.incr(zeroExtend(jmpCnt));
            comJrCnt.incr(zeroExtend(jrCnt));
            // mem stats
            comLdCnt.incr(zeroExtend(ldCnt));
            comStCnt.incr(zeroExtend(stCnt));
            comLrCnt.incr(zeroExtend(lrCnt));
            comScCnt.incr(zeroExtend(scCnt));
            comAmoCnt.incr(zeroExtend(amoCnt));
            // inst count stats
            instCnt.incr(zeroExtend(comInstCnt));
            userInstCnt.incr(zeroExtend(comUserInstCnt));
            if(comUserInstCnt > 1) begin
                supComUserCnt.incr(1);
            end
        end
`endif
    endrule

`ifdef INCLUDE_GDB_CONTROL
   // ================================================================
   // Rules to move into debug mode

   // This rule is like rule doCommitTrap_flush, i.e., a debugger-halt is like an interrupt
   rule rl_enter_debug_mode_flush (rg_run_state == Run_State_DEBUGGER_HALT_FLUSH);
      $write ("%0d: %m.commitStage.rl_enter_debug_mode:", cur_cycle);
      if      (rg_debug_cause == 1) $display (" EBREAK");
      else if (rg_debug_cause == 3) $display (" Debugger halt request");
      else if (rg_debug_cause == 4) $display (" Halt after step");
      else                          $display (" Unknown cause %0d", rg_debug_cause);

      // flush everything. Only increment epoch and stall fetch when we haven
      // not done it yet (we may have already done them at rename stage)
      inIfc.killAll;
      inIfc.incrementEpoch;
      inIfc.setFetchWaitRedirect;

      rg_run_state <= Run_State_DEBUGGER_HALT;
   endrule

   // This rule is like rule doCommitTrap_handle, except we don't redirect
   rule rl_enter_debug_mode_halt (rg_run_state == Run_State_DEBUGGER_HALT);
      // system consistency
      // TODO spike flushes TLB here, but perhaps it is because spike's TLB
      // does not include prv info, and it has to flush when prv changes.
      // XXX As approximation, Trap may cause context switch, so flush for
      // security
      makeSystemConsistent(False, True, False);

      // Record debug CSRs for later Debugger query and later resumption
      csrf.dcsr_cause_write (rg_debug_cause);    // reason for entering debug mode
      csrf.dpc_write        (rg_debug_pc);       // Where we'll resume on 'continue'

      // Go to HALTED state where no rule fires.
      // To re-start, mkCore must call restart method.
      rg_run_state <= Run_State_DEBUGGER_HALTED;
   endrule

   // ================================================================
`endif

    method Data getPerf(ComStagePerfType t);
        return (case(t)
`ifdef PERF_COUNT
            InstCnt: instCnt;
            UserInstCnt: userInstCnt;
            SupComUserCnt: supComUserCnt;
            ComBrCnt: comBrCnt;
            ComJmpCnt: comJmpCnt;
            ComJrCnt: comJrCnt;
            ComLdCnt: comLdCnt;
            ComStCnt: comStCnt;
            ComLrCnt: comLrCnt;
            ComScCnt: comScCnt;
            ComAmoCnt: comAmoCnt;
            ComLdKillByLd: comLdKillByLdCnt;
            ComLdKillBySt: comLdKillByStCnt;
            ComLdKillByCache: comLdKillByCacheCnt;
            ComSysCnt: comSysCnt;
            ExcepCnt: excepCnt;
            InterruptCnt: interruptCnt;
            FlushTlbCnt: flushTlbCnt;
            FlushSecurityCnt: flushSecurityCnt;
            FlushBPCnt: flushBPCnt;
            FlushCacheCnt: flushCacheCnt;
`endif
            default: 0;
        endcase);
    endmethod

`ifdef CHECK_DEADLOCK
    interface commitInstStuck = toGet(commitInstStuckQ);
    interface commitUserInstStuck = toGet(commitUserInstStuckQ);
`else
    interface commitInstStuck = nullGet;
    interface commitUserInstStuck = nullGet;
`endif

`ifdef RENAME_DEBUG
    method Action startRenameDebug if(!renameDebugStarted);
        renameDebugStarted <= True;
    endmethod
    interface renameErr = toGet(renameErrQ);
`else
    method Action startRenameDebug;
        noAction;
    endmethod
    interface renameErr = nullGet;
`endif

`ifdef INCLUDE_GDB_CONTROL
   // Request halt into debug mode
   method Action halt_to_debug_mode_req () if (rg_run_state == Run_State_RUNNING);
      $display ("%0d: %m.commitStage.halt_to_debug_mode_req", cur_cycle);
      rg_stop_req <= True;
   endmethod

   // Becomes true when pipeline is halted
   method Bool is_debug_halted;
      return (rg_run_state == Run_State_DEBUGGER_HALTED);
   endmethod

   method Action resume_from_debug_mode () if (rg_run_state == Run_State_DEBUGGER_HALTED);
      $display ("%0d: %m.commitStage.resume_from_debug_mode", cur_cycle);
      rg_stop_req  <= False;
      rg_run_state <= Run_State_RUNNING;
   endmethod
`endif

endmodule
