default Order dec
$include <prelude.sail>
$include <string.sail>

val EXTZ : forall 'n 'm, 'm >= 'n. (implicit('m), bits('n)) -> bits('m)
function EXTZ(m, v) = sail_zero_extend(v, m)
print_endline("Defined EXTZ") // function signature

val EXTS : forall 'n 'm, 'm >= 'n. (implicit('m), bits('n)) -> bits('m)
function EXTS(m, v) = sail_sign_extend(v, m)
print_endline("Defined EXTS") // function signature

type xlen : Int = 64
type xlen_bytes : Int = 8
type xlenbits = bits(xlen) // typedefs

type regbits = bits(5)

register PC : xlenbits // register definitions
register next_PC : xlenbits

register Xs : vector(32, dec, xlenbits)

val rX : regbits -> xlenbits // function signature
function rX(r) =
  match r {
    0b00000 => EXTZ(0x0), _ => Xs[unsigned(r)]
  }

val wX : (regbits, xlenbits) -> unit // function signature
function wX(r, v) = 
  if r != 0b00000 then {
    Xs[unsigned(r)] = v;
  }

overload X = {rX, wX}

val MEMr = monadic { lem: "MEMr", coq: "MEMr", _ : "read_ram" } : forall 'n 'm, 'n >= 0.
   (int('m), int('n), bits('m), bits('m)) -> bits(8 * 'n)

val read_mem : forall 'n, 'n >= 0. (xlenbits, int('n)) -> bits(8 * 'n)
function read_mem(addr, width) =
    MEMr(sizeof(xlen), width, EXTZ(0x0), addr)

enum iop = {RISCV_ADDI}
// RISCV_ANDI, RISCV_SLTI, RISCV_SLTIU, RISCV_XORI, RISCV_ORI,

scattered union ast

val decode : bits(32) -> option(ast)
val execute : ast -> unit

union clause ast = ITYPE : (bits(12), regbits, regbits, iop)

function clause decode imm : bits(12) @ rs1 : regbits @ 0b000 @ rd : regbits @ 0b0010011
  = Some(ITYPE(imm, rs1, rd, RISCV_ADDI))

function clause execute (ITYPE (imm, rs1, rd, RISCV_ADDI)) = {
  let rs1_val = X(rs1);
  let imm_ext : xlenbits = EXTS(imm);
  let result = rs1_val + imm_ext;
  X(rd) = result
}
print_endline("Execute ADDI")

union clause ast = LOAD : (bits(12), regbits, regbits)

function clause decode imm : bits(12) @ rs1 : regbits @ 0b011 @ rd : regbits @ 0b0000011
  = Some(LOAD(imm, rs1, rd))

function clause execute(LOAD(imm, rs1, rd)) = {
    let addr : xlenbits = X(rs1) + EXTS(imm);
    let result : xlenbits = read_mem(addr, sizeof(xlen_bytes));
    X(rd) = result
}
print_endline("Execute LOAD")

function clause decode _ = None()

function main() : unit = {
  X(0b00001) = sail_zero_extend(0x10, xlen);

  let rs1_val = X(0b00001);
  let imm_ext : xlenbits = sail_sign_extend(0x1, xlen);
  let result = rs1_val + imm_ext;
  X(0b00010) = result;

  print_endline("Executed ADDI")
}

main();