default Order dec // sets the default order
$include <prelude.sail>
$include <string.sail>

// Chapter 5

type op8 : Int = 8
type op7 : Int = 7
type op5 : Int = 5

enum SOP2_IA = {S_ADD_I32, S_ADD_U32, S_ADDC_U32, S_SUB_I32, S_SUB_U32, S_SUBB_U32, S_ABSDIFF_I32, S_MIN_I32, S_MIN_U32, S_MAX_I32, S_MAX_U32, S_MUL_I32}

enum SOP2_COND = {S_CSELECT_B32}

scattered union ast

val decode : bits(32) -> option(ast)
val execute : ast -> unit

union clause ast = SOP2 : (bits(2), op7, sgpr_dst_bits, sgpr_src_bits, sgpr_src_bits) // defining the SOP2 constructor for ast

function clause decode 0b10 @ 0b0000010 @ sdst : sgpr_dst_bits @ ssrc1 : sgpr_src_bits @ ssrc0 : sgpr_src_bits = Some(SOP2(sdst, ssrc1, ssrc0, S_ADD_I32))

function clause execute (SOP2(sdst, ssrc1, ssrc0, S_ADD_I32)) = {
    let ssrc1_val = SGPR(ssrc1);
    let ssrc0_val = SGPR(ssrc0);
    let result = ssrc1_val + ssrc0_val;
    SGPR(sdst) = result
}

function clause decode _ = None()


