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
; File:      parser.asm          ;
; File type: Part                ;
; Author:    Incremnt            ;
; License:   GPLv3               ;
;================================;

parser:
  mov       rbx, INSTR_BIT + DIR_BIT              ; rbx - mask of expected tokens
  mov       r12, qword [lex_ir_buf_ptr]           ; r12 - token buffer pointer
  xor       rbp, rbp                              ; rbp - special byte register (like SIB or ModR/M)
  xor       rcx, rcx                              ; rcx - counter  

parse_ir:
  movzx     rax, byte [r12]                       ; handle token group
  jmp       qword [group_jmp_tbl + rax * 8]       ;

skip_ir:
  lea       r12, [r12 + 2]                        ; skip useless tokens
  jmp       parse_ir                              ;

ctrl_group:
  movzx     rax, byte [r12 + 1]
  jmp       qword [ctrl_jmp_tbl + rax * 8]

.handle_eof:
  jmp       parser_end

.handle_num:
  lea       r12, [r12 + 3]                        ;
  mov       cl, byte [r12 - 1]                    ;
.write_num:
  mov       al, byte [r12]
  mov       byte [r14], al
  inc       r14
  inc       r12
  dec       cl
  jnz       .write_num
  jmp       parse_ir

.handle_mem_num:
  

.handle_str:
  lea       r12, [r12 + 2]
  mov       rsi, 2 
  mov       rdi, 4 
  test      rbx, IMM8_BIT
  setnz     cl
  test      rbx, IMM16_BIT
  cmovnz    rcx, rsi
  cmovz     rcx, rdi
.write_str:
  mov       al, byte [r12]
  mov       byte [r14], al
  inc       r12
  inc       r14
  test      al, al
  jz        .end_write
  dec       cl
  jmp       .write_str
.end_write:
  cmp       rbx, DIR_BIT + IMM8_BIT
  je        .skip_strlen_check
  test      cl, cl
  jnz       op_sz_not_match_err
  or        rbx, PLUS_BIT + MINUS_BIT
.skip_strlen_check:
  inc       r12
  jmp       parse_ir

.handle_label:

.handle_address:

.handle_mem:
  mov       rbx, PLUS_BIT + MINUS_BIT + MUL_BIT
  
  
.handle_plus:
  test      rbx, PLUS_BIT
  jz        invalid_expression_err
  xor       rbx, PLUS_BIT
  lea       r12, [r12 + 2]
  jmp       parse_ir

.handle_minus:
  test      rbx, MINUS_BIT
  jz        invalid_expression_err
  xor       rbx, MINUS_BIT
  lea       r12, [r12 + 2]
  jmp       parse_ir

.handle_mul:
  test      rbx, MUL_BIT
  jz        invalid_expression_err
  xor       rbx, MUL_BIT
  
  lea       r12, [r12 + 2]
  jmp       parse_ir

.handle_comma:
  lea       r12, [r12 + 2]
  jmp       parse_ir

.handle_lf:
  mov       rbx, INSTR_BIT + DIR_BIT
  lea       r12, [r12 + 2]
  jmp       parse_ir

instr_group:
  test      rbx, INSTR_BIT
  jz        invalid_expression_err
  movzx     rax, byte [r12 + 1]
  mov       rsi, qword [instr_node_tbl + rax * 8]
  lea       r12, [r12 + 2]
  movzx     rax, byte [r12]
  mov       r13, r12
  jmp       traverse_operands

einst_group:
  test      rbx, INSTR_BIT
  jz        invalid_expression_err
  movzx     rax, byte [r12 + 1]
  mov       rsi, qword [einst_node_tbl + rax * 8]
  lea       r12, [r12 + 2]
  movzx     rax, byte [r12]
  mov       r13, r12

traverse_operands:
  cmp       al, G_CTRL
  jne       .continue_traverse
  mov       dil, byte [r12 + 1]
  cmp       dil, C_NUM
  je        .cmp_num
  cmp       dil, C_BYTE
  jl        invalid_expression_err
  test      byte [rsi + PAR_NODEFLAGS_OFF], MEM
  jnz       .continue_traverse
  jmp       .go_to_sibling
.cmp_num:
  test      byte [rsi + PAR_NODEFLAGS_OFF], IMM
  jz        .go_to_sibling
.continue_traverse:
  cmp       al, byte [rsi]
  je        .group_matches
.go_to_sibling:
  movzx     rdi, byte [rsi + PAR_SIBOFF_OFF]
  test      di, di
  jz        invalid_expression_err
  lea       rsi, [rsi + rdi * 8]
  jmp       traverse_operands

.group_matches:
  test      byte [rsi + PAR_NODEFLAGS_OFF], TERM
  jnz       .terminal
  movzx     rdi, byte [rsi + PAR_CHDOFF_OFF]
  test      di, di
  jz        invalid_expression_err
  lea       rsi, [rsi + rdi * 8]
  cmp       byte [r12 - 1], C_COM
  jne       invalid_expression_err
  lea       r12, [r12 + 2]
  cmp       ax, C_NUM
  jne       .not_num
  lea       r12, [r12 + 5]
.not_num:
  movzx     rax, byte [r12]
  jmp       traverse_operands

.terminal:
  cmp       byte [rsi + PAR_PREF_OFF], 0
  je        .skip_prefix
  mov       al, byte [rsi + PAR_PREF_OFF]
  mov       byte [r14], al
  inc       r14
.skip_prefix:
  mov       al, byte [rsi + PAR_OP_OFF]
  mov       di, word [rsi + PAR_NODEFLAGS_OFF]
  mov       byte [r14], al
  inc       r14
  movzx     rbx, word [rsi + PAR_PARFLAGS_OFF]
  mov       r12, r13
  jmp       parse_ir                                      ;

dir_group:
  movzx     rax, byte [r12 + 1]                           ;
  jmp       qword [dir_jmp_tbl + rax * 8]                 ;

.handle_db:
.handle_dw:
.handle_dd:

.handle_text:
.handle_bss:
.handle_data:
.handle_rodata:
.handle_stack:
  SYSCALL_3 SYS_WRITE, STDOUT, e_work_msg, E_WORK_MSG_LEN ; idk how to handle elf stuff
  SYSCALL_3 SYS_EXIT, E_WORK                              ;

parser_end = $
