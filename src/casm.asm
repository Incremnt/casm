; Copyright (C) 2026 Denis Bazhenov
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program. If not, see <https://www.gnu.org/licenses/>.
;
;================================;
; Project:   Cool assembler      ;
; File:      casm.asm            ;
; File type: Main                ;
; Author:    Incremnt            ;
; License:   GPLv3               ;
;================================;

format ELF64 executable
entry _start

include "macros.inc"

;--------------------;
;--- text segment ---;
;--------------------;
segment readable executable
_start:
  cmp       qword [rsp], 3                                                 ; handle usage error (too many/few arguments)
  jne       usage_err                                                      ;

  mov       rbx, qword [rsp + 16]                                          ;
  SYSCALL_3 SYS_OPEN, rbx, O_RDONLY, 0                                     ; open input file in readonly mode
  mov       rbx, rax                                                       ; save fd in rbx
  test      rbx, rbx                                                       ; handle file open error
  js        open_err                                                       ;

  SYSCALL_3 SYS_LSEEK, rbx, 0, SEEK_END                                    ; calculate input file size
  test      rax, rax                                                       ;
  js        lseek_err                                                      ; handle lseek error
  mov       rbp, rax                                                       ; save file size in rbp

  SYSCALL_1 SYS_BRK, 0                                                     ; find current heap pointer
  lea       r12, [rax + 1]                                                 ; heap pointer in r12 (one byte before buffer for safety)
  push      rbp                                                            ;
  lea       rbp, [rbp + rax + LEX_IRBUF_SIZE + 2]                          ;
  SYSCALL_1 SYS_BRK, rbp                                                   ; allocate memory for file
  test      rax, rbp                                                       ;
  jz        brk_err                                                        ; handle brk error
  lea       r14, [rbp + 1]                                                 ; IR buffer pointer in r14
  mov       qword [lex_irbuf_ptr], r14                                     ; save r14 in memory
  pop       rbp                                                            ;

  SYSCALL_3 SYS_LSEEK, rbx, 0, SEEK_SET                                    ; restore file position
  test      rax, rax                                                       ;
  js        lseek_err                                                      ;

  SYSCALL_3 SYS_READ, rbx, r12, rbp                                        ; read source code from input file
  test      rax, rbp                                                       ; handle code read error
  jz        read_err                                                       ;

  SYSCALL_1 SYS_CLOSE, rbx                                                 ; close input file

  mov       rbx, qword [rsp + 24]                                          ;
  SYSCALL_3 SYS_OPEN, rbx, O_WRONLY + O_APPEND + O_CREAT + O_TRUNC, OC_744 ; open output file in writeonly + append mode
  test      rax, rax                                                       ; handle file open error
  js        open_err                                                       ;
  mov       qword [output_fd], rax                                         ; save fd

include "lexer.asm"
include "parser.asm"
include "codegen.asm"

  mov       rbx, qword [output_fd]
  SYSCALL_1 SYS_CLOSE, rbx
  SYSCALL_1 SYS_EXIT, EXIT_SUCCESS

; error handlers
usage_err:
  SYSCALL_3 SYS_WRITE, STDERR, e_usage_msg, E_USAGE_MSG_SZ
  jmp       err_exit

open_err:
  SYSCALL_3 SYS_WRITE, STDERR, e_open_msg, E_OPEN_MSG_SZ
  jmp       err_exit

lseek_err:
  SYSCALL_3 SYS_WRITE, STDERR, e_lseek_msg, E_LSEEK_MSG_SZ
  jmp       err_exit

brk_err:
  SYSCALL_3 SYS_WRITE, STDERR, e_brk_msg, E_BRK_MSG_SZ
  jmp       err_exit

read_err:
  SYSCALL_3 SYS_WRITE, STDERR, e_read_msg, E_READ_MSG_SZ
  jmp       err_exit

unk_tkn_err:
  SYSCALL_3 SYS_WRITE, STDERR, e_unktkn_msg, E_UNKTKN_MSG_SZ
  jmp       err_exit

long_num_err:
  SYSCALL_3 SYS_WRITE, STDERR, e_longnum_msg, E_LONGNUM_MSG_SZ
  jmp       err_exit

invalid_char_err:
  SYSCALL_3 SYS_WRITE, STDERR, e_invalid_char_msg, E_INVALID_CHAR_MSG_SZ
  jmp       err_exit

invalid_expression_err:
  SYSCALL_3 SYS_WRITE, STDERR, e_invalid_expr_msg, E_INVALID_EXPR_MSG_SZ
  jmp       err_exit

op_sz_not_match_err:
  SYSCALL_3 SYS_WRITE, STDERR, e_op_sz_match_msg, E_OP_SZ_MATCH_MSG_SZ
  jmp       err_exit

err_exit:
  SYSCALL_1 SYS_EXIT, EXIT_FAILURE

;--------------------;
;--- data segment ---;
;--------------------;
segment readable writable

; error messages
e_usage_msg        db ESC, '[31m', "[Error]: Too many/few arguments.", ESC, '[0m', LF
E_USAGE_MSG_SZ = $ - e_usage_msg

e_open_msg         db ESC, '[31m', "[Error]: Can't open file.", ESC, '[0m', LF
E_OPEN_MSG_SZ = $ - e_open_msg

e_lseek_msg        db ESC, '[31m', "[Error]: SYS_LSEEK failed.", ESC, '[0m', LF
E_LSEEK_MSG_SZ = $ - e_lseek_msg

e_brk_msg          db ESC, '[31m', "[Error]: Can't allocate memory.", ESC, '[0m', LF
E_BRK_MSG_SZ = $ - e_brk_msg

e_read_msg         db ESC, '[31m', "[Error]: SYS_READ failed.", ESC, '[0m', LF
E_READ_MSG_SZ = $ - e_read_msg

e_unktkn_msg       db ESC, '[31m', "[Error]: Unknown token.", ESC, '[0m', LF
E_UNKTKN_MSG_SZ = $ - e_unktkn_msg

e_longnum_msg      db ESC, '[31m', "[Error]: Number is too long.", ESC, '[0m', LF
E_LONGNUM_MSG_SZ = $ - e_longnum_msg

e_invalid_char_msg db ESC, '[31m', "[Error]: Unexpected character in string.", ESC, '[0m', LF
E_INVALID_CHAR_MSG_SZ = $ - e_invalid_char_msg

e_invalid_expr_msg db ESC, '[31m', "[Error]: Invalid expression.", ESC, '[0m', LF
E_INVALID_EXPR_MSG_SZ = $ - e_invalid_expr_msg

e_op_sz_match_msg  db ESC, '[31m', "[Error]: Operand size is not match.", ESC, '[0m', LF
E_OP_SZ_MATCH_MSG_SZ  = $ - e_op_sz_match_msg

e_unusedlbl_msg    db ESC, '[31m', "[Error]: First CASM versions don't support labels and addresses.", ESC, '[0m', LF
E_UNUSEDLBL_MSG_SZ    = $ - e_unusedlbl_msg

; pointers
lex_irbuf_ptr dq 0
par_irbuf_ptr dq 0
phdrbuf_ptr   dq 0

; file descriptors
output_fd dq 0

; ELF stuff (first CASM versions is Linux x86 and load segments only)
ehdr:
  .magic     db 0x7F, "ELF"
  .class     db EI_CLASS32
  .endianess db EI_DATA2LSB
  .elfver    db EV_CURRENT
  .osabi     db EI_OSABI
  .abiver    db EI_VERCURR
  .padding   db 7 dup(0)

  .type      dw ET_EXEC
  .machine   dw EM_386
  .version   dd EV_CURRENT
  .entry     dd 0x08048034
  .phoff     dd 0x00000034
  .shoff     dd 0x00000000
  .flags     dd 0x00000000
  .ehsize    dw 0x0034
  .phentsize dw 0x0020
  .phnum     dw 0
  .shentsize dw 0
  .shnum     dw 0
  .shstrndx  dw 0
  EHSIZE = $ - ehdr

phdr:
  .type      dd PT_LOAD
  .offset    dd 0
  .vaddr     dd 0
  .paddr     dd 0
  .filesz    dd 0
  .memsz     dd 0
  .flags     dd 0
  .align     dd 0x00001000
  PHENTSIZE = $ - phdr

; tables
delimiter_tbl  db 256 dup(0)
valid_char_tbl db 256 dup(0)
lex_trie_tbl   dw 256 dup(0)

del_jmp_tbl:
  dq handle_del.ignore_del
  dq handle_del.comment_del
  dq handle_del.label_del
  dq handle_del.number_del
  dq handle_del.string_del
  dq handle_del.bracket_del
  dq handle_del.plus_del
  dq handle_del.minus_del
  dq handle_del.multiply_del
  dq handle_del.comma_del
  dq handle_del.newline_del
  dq handle_del.address_del

group_jmp_tbl:
  dq ctrl_group
  dq instr_group
  dq einst_group
  dq skip_ir
  dq skip_ir
  dq skip_ir
  dq dir_group

ctrl_jmp_tbl:
  dq ctrl_group.handle_eof
  dq ctrl_group.handle_num
  dq ctrl_group.handle_str
  dq ctrl_group.handle_label
  dq ctrl_group.handle_address
  dq ctrl_group.handle_mem
  dq ctrl_group.handle_plus
  dq ctrl_group.handle_minus
  dq ctrl_group.handle_mul
  dq ctrl_group.handle_comma
  dq ctrl_group.handle_lf
  dq skip_ir
  dq skip_ir
  dq skip_ir

dir_jmp_tbl:
  dq dir_group.handle_db
  dq dir_group.handle_dw
  dq dir_group.handle_dd
  dq dir_group.handle_text
  dq dir_group.handle_data
  dq dir_group.handle_rodata

instr_node_tbl:
  dq par_trie.mov_node
  dq par_trie.mul_node
  dq par_trie.push_node
  dq par_trie.pop_node
  dq par_trie.call_node
  dq par_trie.cmp_node
  dq par_trie.jmp_node
  dq par_trie.test_node
  dq par_trie.or_node
  dq par_trie.and_node
  dq par_trie.add_node
  dq par_trie.xor_node
  dq par_trie.not_node
  dq par_trie.nop_node
  dq par_trie.int_node
  dq par_trie.inc_node
  dq par_trie.dec_node
  dq par_trie.sub_node

einst_node_tbl:
  dq par_trie.je_node
  dq par_trie.jz_node
  dq par_trie.jl_node
  dq par_trie.jle_node
  dq par_trie.jg_node
  dq par_trie.jge_node
  dq par_trie.ja_node
  dq par_trie.jae_node
  dq par_trie.jb_node
  dq par_trie.jbe_node
  dq par_trie.jc_node
  dq par_trie.js_node
  dq par_trie.jo_node
  dq par_trie.jp_node
  dq par_trie.jpo_node
  dq par_trie.jpe_node
  dq par_trie.jne_node
  dq par_trie.jnz_node
  dq par_trie.jnc_node
  dq par_trie.jns_node
  dq par_trie.jno_node
  dq par_trie.jnp_node
  dq par_trie.movzx_node
  dq par_trie.movsx_node

; lexeme trie
lex_trie:
  ; node for unknown lexemes
  LEX_NODE 0, 0, 0, 0, 0, TERM

.sec_node:
  LEX_NODE '.', 0, 0, 1, 0, 0
    LEX_NODE 't', 0, 0, 1, 4, 0
      LEX_NODE 'e', 0, 0, 1, 0, 0
        LEX_NODE 'x', 0, 0, 1, 0, 0
          LEX_NODE 't', G_DIR, D_TEXT, 0, 0, TERM
    LEX_NODE 'd', 0, 0, 1, 4, 0
      LEX_NODE 'a', 0, 0, 1, 0, 0
        LEX_NODE 't', 0, 0, 1, 0, 0
          LEX_NODE 'a', G_DIR, D_DATA, 0, 0, TERM
    LEX_NODE 'r', 0, 0, 1, 0, 0
      LEX_NODE 'o', 0, 0, 1, 0, 0
        LEX_NODE 'd', 0, 0, 1, 0, 0
          LEX_NODE 'a', 0, 0, 1, 0, 0
            LEX_NODE 't', 0, 0, 1, 0, 0
              LEX_NODE 'a', G_DIR, D_RODATA, 0, 0, TERM

.e_node:
  LEX_NODE 'e', 0, 0, 1, 0, 0
    LEX_NODE 'a', 0, 0, 1, 2, 0
      LEX_NODE 'x', G_REG32, R32_EAX, 0, 0, TERM
    LEX_NODE 'b', 0, 0, 1, 3, 0
      LEX_NODE 'x', G_REG32, R32_EBX, 0, 5, TERM
      LEX_NODE 'p', G_REG32, R32_EBP, 0, 0, TERM
    LEX_NODE 'c', 0, 0, 1, 2, 0
      LEX_NODE 'x', G_REG32, R32_ECX, 0, 0, TERM
    LEX_NODE 'd', 0, 0, 1, 3, 0
      LEX_NODE 'x', G_REG32, R32_EDX, 0, 10, TERM
      LEX_NODE 'i', G_REG32, R32_EDI, 0, 0, TERM
    LEX_NODE 's', 0, 0, 1, 0, 0
      LEX_NODE 'i', G_REG32, R32_ESI, 0, 13, TERM
      LEX_NODE 'p', G_REG32, R32_ESP, 0, 0, TERM

.m_node:
  LEX_NODE 'm', 0, 0, 1, 0, 0
    LEX_NODE 'o', 0, 0, 1, 6, 0
      LEX_NODE 'v', G_INSTR, I_MOV, 1, 0, TERM
        LEX_NODE 'z', 0, 0, 1, 2, 0
          LEX_NODE 'x', G_EINST, E_MOVZX, 0, 0, TERM
        LEX_NODE 's', 0, 0, 1, 0, 0
          LEX_NODE 'x', G_EINST, E_MOVSX, 0, 0, TERM
    LEX_NODE 'u', 0, 0, 1, 0, 0
      LEX_NODE 'l', G_INSTR, I_MUL, 0, 0, TERM

.p_node:
  LEX_NODE 'p', 0, 0, 1, 0, 0
    LEX_NODE 'u', 0, 0, 1, 3, 0
      LEX_NODE 's', 0, 0, 1, 0, 0
        LEX_NODE 'h', G_INSTR, I_PUSH, 0, 0, TERM
    LEX_NODE 'o', 0, 0, 1, 0, 0
      LEX_NODE 'p', G_INSTR, I_POP, 0, 0, TERM

.c_node:
  LEX_NODE 'c', 0, 0, 1, 0, 0
    LEX_NODE 'a', 0, 0, 1, 3, 0
      LEX_NODE 'l', 0, 0, 3, 0, 0
        LEX_NODE 'l', G_INSTR, I_CALL, 0, 0, TERM
    LEX_NODE 'm', 0, 0, 1, 2, 0
      LEX_NODE 'p', G_INSTR, I_CMP, 0, 0, TERM
    LEX_NODE 'x', G_REG16, R16_CX, 0, 1, TERM
    LEX_NODE 'h', G_REG8, R8_CH, 0, 1, TERM
    LEX_NODE 'l', G_REG8, R8_CL, 0, 0, TERM

.j_node:
  LEX_NODE 'j', 0, 0, 1, 0, 0
    LEX_NODE 'm', 0, 0, 1, 2, 0
      LEX_NODE 'p', G_INSTR, I_JMP, 0, 0, TERM
    LEX_NODE 'e', G_EINST, E_JE, 0, 1, TERM
    LEX_NODE 'z', G_EINST, E_JZ, 0, 1, TERM
    LEX_NODE 'l', G_EINST, E_JL, 1, 2, TERM
      LEX_NODE 'e', G_EINST, E_JLE, 0, 0, TERM
    LEX_NODE 'g', G_EINST, E_JG, 1, 2, TERM
      LEX_NODE 'e', G_EINST, E_JGE, 0, 0, TERM
    LEX_NODE 'a', G_EINST, E_JA, 1, 2, TERM
      LEX_NODE 'e', G_EINST, E_JAE, 0, 0, TERM
    LEX_NODE 'b', G_EINST, E_JB, 1, 2, TERM
      LEX_NODE 'e', G_EINST, E_JBE, 0, 0, TERM
    LEX_NODE 'c', G_EINST, E_JC, 0, 1, TERM
    LEX_NODE 's', G_EINST, E_JS, 0, 1, TERM
    LEX_NODE 'o', G_EINST, E_JO, 0, 1, TERM
    LEX_NODE 'p', G_EINST, E_JP, 1, 3, TERM
      LEX_NODE 'o', G_EINST, E_JPO, 0, 1, TERM
      LEX_NODE 'e', G_EINST, E_JPE, 0, 0, TERM
    LEX_NODE 'n', 0, 0, 1, 0, 0
      LEX_NODE 'e', G_EINST, E_JNE, 0, 1, TERM
      LEX_NODE 'z', G_EINST, E_JNZ, 0, 1, TERM
      LEX_NODE 'c', G_EINST, E_JNC, 0, 1, TERM
      LEX_NODE 's', G_EINST, E_JNS, 0, 1, TERM
      LEX_NODE 'o', G_EINST, E_JNO, 0, 1, TERM
      LEX_NODE 'p', G_EINST, E_JNP, 0, 0, TERM

.t_node:
  LEX_NODE 't', 0, 0, 1, 0, 0
    LEX_NODE 'e', 0, 0, 1, 0, 0
      LEX_NODE 's', 0, 0, 1, 0, 0
        LEX_NODE 't', G_INSTR, I_TEST, 0, 0, TERM

.o_node:
  LEX_NODE 'o', 0, 0, 1, 0, 0
    LEX_NODE 'r', G_INSTR, I_OR, 0, 0, TERM

.a_node:
  LEX_NODE 'a', 0, 0, 1, 0, 0
    LEX_NODE 'n', 0, 0, 1, 2, 0
      LEX_NODE 'd', G_INSTR, I_AND, 0, 0, TERM
    LEX_NODE 'd', 0, 0, 1, 2, 0
      LEX_NODE 'd', G_INSTR, I_ADD, 0, 0, TERM
    LEX_NODE 'h', G_REG8, R8_AH, 0, 1, TERM
    LEX_NODE 'l', G_REG8, R8_AL, 0, 1, TERM
    LEX_NODE 'x', G_REG16, R16_AX, 0, 0, TERM

.x_node:
  LEX_NODE 'x', 0, 0, 1, 0, 0
    LEX_NODE 'o', 0, 0, 1, 0, 0
      LEX_NODE 'r', G_INSTR, I_XOR, 0, 0, TERM

.n_node:
  LEX_NODE 'n', 0, 0, 1, 0, 0
    LEX_NODE 'o', 0, 0, 1, 0, 0
      LEX_NODE 't', G_INSTR, I_NOT, 0, 1, TERM
      LEX_NODE 'p', G_INSTR, I_NOP, 0, 0, TERM

.i_node:
  LEX_NODE 'i', 0, 0, 1, 0, 0
    LEX_NODE 'n', 0, 0, 1, 0, 0
      LEX_NODE 't', G_INSTR, I_INT, 0, 1, TERM
      LEX_NODE 'c', G_INSTR, I_INC, 0, 0, TERM

.d_node:
  LEX_NODE 'd', 0, 0, 1, 0, 0
    LEX_NODE 'b', G_DIR, D_DB, 0, 1, TERM
    LEX_NODE 'd', G_DIR, D_DD, 0, 1, TERM
    LEX_NODE 'w', G_DIR, D_DW, 1, 4, TERM
      LEX_NODE 'o', 0, 0, 1, 0, 0
        LEX_NODE 'r', 0, 0, 1, 0, 0
          LEX_NODE 'd', G_CTRL, C_DWORD, 0, 0, TERM
    LEX_NODE 'e', 0, 0, 1, 2, 0

.b_node:
  LEX_NODE 'b', 0, 0, 1, 0, 0
    LEX_NODE 'y', 0, 0, 1, 3, 0
      LEX_NODE 't', 0, 0, 1, 0, 0
        LEX_NODE 'e', G_CTRL, C_BYTE, 0, 0, TERM
    LEX_NODE 'x', G_REG16, R16_BX, 0, 1, TERM
    LEX_NODE 'h', G_REG8, R8_BH, 0, 1, TERM
    LEX_NODE 'l', G_REG8, R8_BL, 0, 1, TERM
    LEX_NODE 'p', G_REG16, R16_BP, 0, 0, TERM

.w_node:
  LEX_NODE 'w', 0, 0, 1, 0, 0
    LEX_NODE 'o', 0, 0, 1, 0, 0
      LEX_NODE 'r', 0, 0, 1, 0, 0
        LEX_NODE 'd', G_CTRL, C_WORD, 0, 0, TERM

.s_node:
  LEX_NODE 's', 0, 0, 1, 0, 0
    LEX_NODE 'u', 0, 0, 1, 2, 0
      LEX_NODE 'b', G_INSTR, I_SUB, 0, 0, TERM
    LEX_NODE 'i', G_REG16, R16_SI, 0, 1, TERM
    LEX_NODE 'p', G_REG16, R16_SP, 0, 0, TERM

; token trie
par_trie:
.mov_node:
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x8B, 0, 1, MEM32_BIT, MEM + MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x89, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0xB8, 0, 0, IMM32_BIT, IMM + SHORT_OP + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x8B, 0, 1, MEM32_BIT, MEM + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x8B, 0, 1, 0, MEM + MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x88, 0, 1, 0, MEM + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xC7, 0, 1, IMM32_BIT, MEM + IMM + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xC6, 0, 0, IMM8_BIT, MEM + IMM + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x8B, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x89, 0, 1, 0, OPSIZE + MODRM + TERM
    PAR_NODE G_CTRL, 0xB8, 0, 0, IMM16_BIT, OPSIZE + IMM + SHORT_OP + TERM
  PAR_NODE G_REG8, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG8, 0x88, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0xB0, 0, 0, IMM8_BIT, IMM + SHORT_OP + TERM

.mul_node:
  PAR_NODE G_REG32, 0xf7, 0, 1, 0, MODRM + OPNUM5 + TERM
  PAR_NODE G_REG8, 0xf6, 0, 1, 0, OPSIZE + MODRM + OPNUM5 + TERM
  PAR_NODE G_REG16, 0xf7, 0, 1, 0, MODRM + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 1, MEM32_BIT, MODRM + SIB + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0xf6, 0, 1, MEM8_BIT, MODRM + SIB + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + OPNUM5 + TERM

.push_node:
  PAR_NODE G_REG32, 0x50, 0, 1, 0, SHORT_OP + TERM
  PAR_NODE G_CTRL, 0x68, 0, 0, IMM32_BIT, IMM + TERM

.pop_node:
  PAR_NODE G_REG32, 0x58, 0, 0, 0, SHORT_OP + TERM

.call_node:
  PAR_NODE G_CTRL, 0xE8, 0, 0, IMM32_BIT + ADDR_BIT, TERM

.cmp_node:
  PAR_NODE G_CTRL, 0x00, 1, 4, 0, 0
    PAR_NODE G_REG32, 0x39, 0, 1, MEM32_BIT, MEM + MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x38, 0, 1, MEM8_BIT, MEM + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x39, 0, 0, MEM16_BIT, OPSIZE + MEM + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_CTRL, 0x3B, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x3B, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG8, 0x00, 1, 3, 0, 0
    PAR_NODE G_CTRL, 0x3A, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x3A, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x3B, 0, 1, MEM16_BIT, OPSIZE + MEM + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x3B, 0, 0, 0, OPSIZE + MODRM + TERM

.jmp_node:
  PAR_NODE G_CTRL, 0xE9, 0, 1, IMM32_BIT + ADDR_BIT, TERM
  PAR_NODE G_CTRL, 0xEB, 0, 0, IMM8_BIT + ADDR_BIT, TERM

.test_node:
  PAR_NODE G_CTRL, 0x00, 1, 4, 0, 0
    PAR_NODE G_REG32, 0x85, 0, 1, MEM32_BIT, MEM + MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x84, 0, 1, MEM8_BIT, MEM + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x84, 0, 0, MEM16_BIT, OPSIZE + MEM + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x85, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0xf7, 0, 0, IMM32_BIT, IMM + MODRM + OPNUM1 + TERM
  PAR_NODE G_REG8, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG8, 0x84, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0xf7, 0, 0, IMM8_BIT, IMM + MODRM + OPNUM1 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG16, 0x84, 0, 1, 0, OPSIZE + MODRM + TERM
    PAR_NODE G_CTRL, 0xf7, 0, 0, IMM16_BIT, OPSIZE + IMM + MODRM + OPNUM1 + TERM

.or_node:
  PAR_NODE G_CTRL, 0x00, 1, 6, 0, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, MEM8_BIT + IMM8_BIT, MEM + IMM + MODRM + SIB + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM32_BIT + IMM32_BIT, MEM + IMM + MODRM + SIB + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM16_BIT + IMM16_BIT, OPSIZE + MEM + IMM + MODRM + SIB + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0x83, 0, 1, MEM32_BIT + IMM8_BIT, MEM + IMM + MODRM + SIB + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0x83, 0, 1, MEM16_BIT + IMM8_BIT, OPSIZE + MEM + IMM + MODRM + SIB + OPNUM2 + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM32_BIT, IMM + MODRM + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0x83, 0, 0, IMM8_BIT, IMM + MODRM + OPNUM2 + TERM
  PAR_NODE G_REG8, 0x00, 1, 2, 0, 0
    PAR_NODE G_CTRL, 0x80, 0, 0, IMM8_BIT, IMM + MODRM + OPNUM2 + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM16_BIT, OPSIZE + IMM + MODRM + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0x83, 0, 0, IMM8_BIT, OPSIZE + IMM + MODRM + OPNUM2 + TERM
    ; TODO: 08-0D opcodes (i forgot)

.and_node:
  ;PAR_NODE G_

.add_node:
.xor_node:
.not_node:
.nop_node:
.int_node:
  PAR_NODE G_CTRL, 0xCD, 0, 0, IMM8_BIT, IMM + TERM
.inc_node:
.dec_node:
.sub_node:

; extended instructions
.je_node:
.jz_node:
.jl_node:
.jle_node:
.jg_node:
.jge_node:
.ja_node:
.jae_node:
.jb_node:
.jbe_node:
.jc_node:
.js_node:
.jo_node:
.jp_node:
.jpo_node:
.jpe_node:
.jne_node:
.jnz_node:
.jnc_node:
.jns_node:
.jno_node:
.jnp_node:
.movzx_node:
.movsx_node:
