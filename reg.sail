/* Global register widths bits/bytes */

type xlen : Int = 64
type xlen_bytes : Int = 8
type xlenbits = bits(xlen)

type sgpr_dst_bits = bits(7) // SGPR dst indexing
type sgpr_src_bits = bits(8) // SGPR src indexing

/* Reg read/write functions */

register PC : xlenbits // PC register of 64 bits
register nextPC : xlenbits

register SGPR : vector(255, dec, xlenbits)

val rSGPR : sgpr_src_bits -> xlenbits // SGPR getter

function rSGPR(r) =
    match r {
        0b1000000 => 0x0,
        _ => SGPR[unsigned(r)] = v;
    }

val wSGPR : (sgpr_dst_bits, xlenbits) -> unit

function wSGPR(r) =
    if r != 0b1000000 then {
        SGPR[unsigned(r)] = v; // r is just register idx!
    }


overload SGPR = {rSGPR, wSGPR} // overloads, selecting based on parameters