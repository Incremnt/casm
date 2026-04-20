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
  mov       rbx, INSTR_BIT + DIR_BIT              ; rbx - parser bit mask (expected tokens and one phdr bit)
  mov       r12, qword [lex_irbuf_ptr]            ; r12 - token buffer pointer
  xor       r15, r15                              ; r15 - address & special byte register (offset in elf headers, instruction's addresses and SIB or ModR/M)
  xor       r11, r11                              ; r11 - how much memory need phdr buffer (x2 after expand)
  mov       qword [par_irbuf_ptr], r14            ; save parser IR buffer start pointer

parse_ir:
  movzx     rax, byte [r12]                       ; handle token group
  jmp       qword [group_jmp_tbl + rax * 8]       ;

skip_ir:
  lea       r12, [r12 + 2]                        ; skip useless tokens
  jmp       parse_ir                              ;

ctrl_group:
  movzx     rax, byte [r12 + 1]                   ;
  jmp       qword [ctrl_jmp_tbl + rax * 8]        ;

.handle_eof:
  cmp       rbp, r11                              ; write last phdr and exit
  jl        .skip_expand                          ;
  push      r11                                   ;
  SYSCALL_1 SYS_BRK, 0                            ;
  pop       r11                                   ;
  lea       rdx, [rax + r11]                      ;
  SYSCALL_1 SYS_BRK, rdx                          ;
.skip_expand:
  mov       rdx, qword [phdr]                     ;
  mov       qword [rbp], rdx                      ;
  mov       rdx, qword [phdr + 8]                 ;
  mov       qword [rbp + 8], rdx                  ;
  mov       rdx, qword [phdr + 16]                ;
  mov       qword [rbp + 16], rdx                 ;
  mov       rdx, qword [phdr + 24]                ;
  mov       qword [rbp + 24], rdx                 ;
  jmp       parser_end                            ;

.handle_num:
  mov       rcx, 1                                ; write 1, 2 or 4 bytes of number
  mov       rdi, 2                                ;
  mov       rsi, 4                                ;
  test      rbx, IMM16_BIT                        ;
  cmovnz    rcx, rdi                              ;
  test      rbx, IMM32_BIT                        ;
  cmovnz    rcx, rsi                              ;
  lea       r12, [r12 + 2]                        ;
  lea       r13, [r12 + 4]                        ;
.write_num:
  mov       al, byte [r12]                        ;
  mov       byte [r14], al                        ;
  inc       r15d                                  ;
  inc       r14                                   ;
  inc       r12                                   ;
  dec       rcx                                   ;
  jnz       .write_num                            ;
  mov       r12, r13                              ;
  jmp       parse_ir                              ;

.handle_mem_num:


.handle_str:
  mov       rcx, 1                                ; number with extra steps
  mov       rsi, 2                                ;
  mov       rdi, 4                                ;
  test      rbx, IMM16_BIT                        ;
  cmovnz    rcx, rsi                              ;
  test      rbx, IMM32_BIT                        ;
  cmovnz    rcx, rdi                              ;
  lea       r12, [r12 + 2]                        ;
  lea       r13, [r12 + rcx]                      ;
.write_str:
  mov       al, byte [r12]                        ;
  mov       byte [r14], al                        ;
  inc       r15d                                  ;
  inc       r12                                   ;
  inc       r14                                   ;
  dec       rcx                                   ;
  test      rcx, rcx                              ;
  jnz       .write_str                            ;
  mov       r12, r13                              ;
  mov       ax, word [r12]                        ;
  xchg      ah, al                                ; fix endianess
  cmp       ax, C_STR                             ;
  jne       op_sz_not_match_err                   ; handle operand size error
  lea       r12, [r12 + 2]                        ;
  jmp       parse_ir                              ;

.handle_mem_str:

.handle_label:
.handle_address:
  SYSCALL_3 SYS_WRITE, STDERR, e_unusedlbl_msg, E_UNUSEDLBL_MSG_SZ ; first CASM versions don't support labels
  SYSCALL_1 SYS_EXIT, EXIT_FAILURE                                 ;

.handle_mem:
  push      rbx                                                         ; enter memory mode & save parser flags
  mov       rbx, PLUS_BIT + MINUS_BIT + MUL_BIT + IMM32_BIT + IMM8_BIT  ;
  mov       qword [ctrl_jmp_tbl + C_MEM * 8], .handle_mem_mem           ;
  mov       qword [ctrl_jmp_tbl + C_NUM * 8], .handle_mem_num           ;
  mov       qword [ctrl_jmp_tbl + C_STR * 8], .handle_mem_str           ;
  mov       qword [group_jmp_tbl + G_REG32 * 8], .handle_mem_reg32      ;
  mov       qword [group_jmp_tbl + G_REG16 * 8], invalid_expression_err ;
  mov       qword [group_jmp_tbl + G_REG8 * 8], invalid_expression_err  ;
  mov       qword [ctrl_jmp_tbl + C_COM * 8], invalid_expression_err    ;
  mov       qword [ctrl_jmp_tbl + C_LF * 8], invalid_expression_err     ;
  lea       r12, [r12 + 2]                                              ;
  jmp       parse_ir                                                    ;

.handle_mem_mem:
  pop       rbx                                                         ; exit memory mode & restore parser flags
  mov       qword [ctrl_jmp_tbl + C_MEM * 8], .handle_mem               ;
  mov       qword [ctrl_jmp_tbl + C_NUM * 8], .handle_num               ;
  mov       qword [ctrl_jmp_tbl + C_STR * 8], .handle_str               ;
  mov       qword [group_jmp_tbl + G_REG32 * 8], skip_ir                ;
  mov       qword [group_jmp_tbl + G_REG16 * 8], skip_ir                ;
  mov       qword [group_jmp_tbl + G_REG8 * 8], skip_ir                 ;
  mov       qword [ctrl_jmp_tbl + C_COM * 8], .handle_comma             ;
  mov       qword [ctrl_jmp_tbl + C_LF * 8], .handle_lf                 ;
  lea       r12, [r12 + 2]                                              ;
  jmp       parse_ir                                                    ;

.handle_mem_reg32:


.handle_plus:
  test      rbx, PLUS_BIT                         ; first versions without memory expressions too
  jz        invalid_expression_err                ;
  xor       rbx, PLUS_BIT                         ;
  lea       r12, [r12 + 2]                        ;
  jmp       parse_ir                              ;

.handle_minus:
  test      rbx, MINUS_BIT                        ;
  jz        invalid_expression_err                ;
  xor       rbx, MINUS_BIT                        ;
  lea       r12, [r12 + 2]                        ;
  jmp       parse_ir                              ;

.handle_mul:
  test      rbx, MUL_BIT                          ;
  jz        invalid_expression_err                ;
  xor       rbx, MUL_BIT                          ;

  lea       r12, [r12 + 2]                        ;
  jmp       parse_ir                              ;

.handle_comma:
  lea       r12, [r12 + 2]                        ; skip it
  jmp       parse_ir                              ;

.handle_lf:
  mov       rbx, INSTR_BIT + DIR_BIT              ; set instruction + directive bits
  lea       r12, [r12 + 2]                        ;
  jmp       parse_ir                              ;

.handle_byte:
  test      rbx, MEM8_BIT                         ; CASM always need a keyword before memory expression
  jz        invalid_expression_err                ;
  xor       rbx, MEM8_BIT                         ;
  cmp       word [r12 + 2], C_MEM                 ;
  jne       invalid_expression_err                ;
  lea       r12, [r12 + 2]                        ;
  jmp       parse_ir                              ;

.handle_word:
  test      rbx, MEM16_BIT                        ;
  jz        invalid_expression_err                ;
  xor       rbx, MEM16_BIT                        ;
  cmp       word [r12 + 2], C_MEM                 ;
  jne       invalid_expression_err                ;
  lea       r12, [r12 + 2]                        ;
  jmp       parse_ir                              ;

.handle_dword:
  test      rbx, MEM32_BIT                        ;
  jz        invalid_expression_err                ;
  xor       rbx, MEM32_BIT                        ;
  cmp       word [r12 + 2], C_MEM                 ;
  jne       invalid_expression_err                ;
  lea       r12, [r12 + 2]                        ;
  jmp       parse_ir                              ;

instr_group:
  test      rbx, INSTR_BIT                        ; traverse operands
  jz        invalid_expression_err                ;
  movzx     rax, byte [r12 + 1]                   ;
  mov       rsi, qword [instr_node_tbl + rax * 8] ;
  lea       r12, [r12 + 2]                        ;
  movzx     rax, byte [r12]                       ;
  mov       r13, r12                              ;
  jmp       traverse_operands                     ;

einst_group:
  test      rbx, INSTR_BIT                        ; like normal instructions
  jz        invalid_expression_err                ;
  movzx     rax, byte [r12 + 1]                   ;
  mov       rsi, qword [einst_node_tbl + rax * 8] ;
  lea       r12, [r12 + 2]                        ;
  movzx     rax, byte [r12]                       ;
  mov       r13, r12                              ;

traverse_operands:
  cmp       al, G_CTRL                            ; token trie have nodeflags for memory and immediate, check it
  jne       .continue_traverse                    ;
  mov       dil, byte [r13 + 1]                   ;
  cmp       dil, C_NUM                            ;
  je        .cmp_num                              ;
  cmp       dil, C_STR                            ;
  je        .cmp_num                              ;
  cmp       dil, C_BYTE                           ;
  jl        invalid_expression_err                ;
  test      word [rsi + PAR_NODEFLAGS_OFF], MEM   ;
  jnz       .continue_traverse                    ;
  jmp       .go_to_sibling                        ;
.cmp_num:
  test      word [rsi + PAR_NODEFLAGS_OFF], IMM   ;
  jz        .go_to_sibling                        ;

.continue_traverse:
  cmp       al, byte [rsi]                        ;
  je        .group_matches                        ;
.go_to_sibling:
  movzx     rdi, byte [rsi + PAR_SIBOFF_OFF]      ; go to sibling if group don't matches
  test      di, di                                ;
  jz        invalid_expression_err                ;
  lea       rsi, [rsi + rdi * 8]                  ;
  jmp       traverse_operands                     ;

.group_matches:
  test      word [rsi + PAR_NODEFLAGS_OFF], TERM  ; write opcode if node is terminal
  jnz       .terminal                             ;
  movzx     rdi, byte [rsi + PAR_CHDOFF_OFF]      ; else, go to the child node
  test      di, di                                ;
  jz        invalid_expression_err                ;
  lea       r13, [r13 + 4]                        ;
  cmp       ax, C_NUM                             ;
  jne       .not_num                              ;
  lea       r13, [r13 + 4]                        ; numbers and string have longer token to skip
.not_num:
  cmp       ax, C_STR                             ;
  jne       .not_str                              ;
  lea       r13, [r13 + 2]                        ;
.skip_str:
  inc       r13                                   ;
  cmp       byte [r13 - 1], C_STR                 ;
  jne       .skip_str                             ;
.not_str:
  lea       rsi, [rsi + rdi * 8]                  ;
  cmp       byte [r13 - 1], C_COM                 ;
  jne       invalid_expression_err                ;
  movzx     rax, byte [r13]                       ;
  jmp       traverse_operands                     ;

.terminal:
  mov       al, byte [rsi + PAR_OP_OFF]              ; write opcode
  mov       di, word [rsi + PAR_NODEFLAGS_OFF]       ;
  test      word [rsi + PAR_NODEFLAGS_OFF], SHORT_OP ; add register to opcode if opcode have short form (TODO: other opcode flags)
  jz        .not_short                               ;
  add       al, byte [r12 + 1]                       ;
.not_short:
  mov       byte [r14], al                           ;
  inc       r14                                      ;
  movzx     rbx, word [rsi + PAR_PARFLAGS_OFF]       ; go to operands logic
  inc       r15d                                     ;
  jmp       parse_ir                                 ;

dir_group:
  movzx     rax, byte [r12 + 1]                      ;
  jmp       qword [dir_jmp_tbl + rax * 8]            ;

.handle_db:
  mov       rbx, IMM8_BIT                            ; just set bits
  lea       r12, [r12 + 2]                           ;
  jmp       parse_ir                                 ;

.handle_dw:
  mov       rbx, IMM16_BIT                           ;
  lea       r12, [r12 + 2]                           ;
  jmp       parse_ir                                 ;

.handle_dd:
  mov       rbx, IMM32_BIT                           ;
  lea       r12, [r12 + 2]                           ;
  jmp       parse_ir                                 ;

.handle_text:
  inc       word [ehdr.phnum]                        ;
  mov       byte [phdr.flags], R + X                 ;
  test      rbx, PHFIRST_BIT                         ;
  jz        .write_phdr                              ;
  add       dword [phdr.filesz], EHSIZE              ; first elf segment have ehdr in it
  jmp       .skip_write                              ;

.handle_data:
  inc       word [ehdr.phnum]                        ;
  mov       byte [phdr.flags], R + W                 ;
  test      rbx, PHFIRST_BIT                         ;
  jz        .write_phdr                              ;
  add       dword [phdr.filesz], EHSIZE              ;
  jmp       .skip_write                              ;

.handle_rodata:
  inc       word [ehdr.phnum]                        ;
  mov       byte [phdr.flags], R                     ;
  test      rbx, PHFIRST_BIT                         ;
  jz        .write_phdr                              ;
  add       dword [phdr.filesz], EHSIZE              ;
  jmp       .skip_write                              ;

.write_phdr:
  cmp       rbp, r11                                 ;
  jl        .skip_expand                             ;
  push      r11                                      ; expand phdr buffer if it needs more space
  push      r11                                      ;
  SYSCALL_1 SYS_BRK, 0                               ;
  pop       r11                                      ;
  lea       rdx, [rax + r11]                         ;
  SYSCALL_1 SYS_BRK, rdx                             ;
  pop       r11                                      ;
  lea       r11, [r11 * 2]                           ; expand by x2 more next time
.skip_expand:
  mov       rdx, qword [phdr]                        ; write phdr to phdr buffer
  mov       qword [rbp], rdx                         ;
  mov       rdx, qword [phdr + 8]                    ;
  mov       qword [rbp + 8], rdx                     ;
  mov       rdx, qword [phdr + 16]                   ;
  mov       qword [rbp + 16], rdx                    ;
  mov       rdx, qword [phdr + 24]                   ;
  mov       qword [rbp + 24], rdx                    ;
  lea       rbp, [rbp + 32]                          ;
.skip_write:
  mov       rdx, r15                                 ; set phdr fields
  mov       dword [phdr.offset], edx                 ;
  add       edx, dword [ehdr.entry]                  ;
  sub       edx, EHSIZE                              ;
  mov       dword [phdr.vaddr], edx                  ;
  mov       dword [phdr.paddr], edx                  ;
  add       dword [phdr.filesz], PHENTSIZE           ;
  add       dword [phdr.memsz], PHENTSIZE            ;
  add       dword [ehdr.entry], PHENTSIZE            ;
  lea       r12, [r12 + 2]                           ;
  jmp       parse_ir                                 ;

parser_end = $
