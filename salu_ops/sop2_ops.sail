default Order dec // sets the default order
$include <prelude.sail>
$include <string.sail>

// Chapter 5

type sdst : Int = 7
type op8 : Int = 8
type op7 : Int = 8
type op5 : Int = 8
type ssrc : Int = 8

enum SOP2 = {S_ADD_I32, S_ADD_U32, S_ADDC_U32, S_SUB_I32, S_SUB_U32, S_SUBB_U32, S_ABSDIFF_I32, S_MIN_I32, S_MIN_U32, S_MAX_I32, S_MAX_U32, S_MUL_I32, S_CSELECT_B32, S_AND_}

scattered union ast

val decode : bits(32) -> option(ast)
val execute : ast -> unit

union clause ast = SOP2_TYPE()