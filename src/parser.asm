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
  mov       rbx, INSTR_BIT + DIR_BIT + PHFIRST_BIT ; rbx - parser bit mask (expected tokens and one phdr bit)
  mov       r12, qword [lex_irbuf_ptr]             ; r12 - token buffer pointer
  xor       r15, r15                               ; r15 - address & special byte register (offset in elf headers, instruction addresses and SIB or ModR/M)
  lea       r11, [rbp + PHDRBUF_SIZE]              ; r11 - how much memory need phdr buffer (x2 after expand)
  mov       qword [par_irbuf_ptr], r14             ; save parser IR buffer start pointer

parse_ir:
  movzx     rax, byte [r12]                        ; handle token group
  jmp       qword [group_jmp_tbl + rax * 8]        ;

skip_ir:
  lea       r12, [r12 + 2]                         ; skip useless tokens
  jmp       parse_ir                               ;

ctrl_group:
  movzx     rax, byte [r12 + 1]                    ;
  jmp       qword [ctrl_jmp_tbl + rax * 8]         ;

.handle_eof:
  test      rbx, PHFIRST_BIT                       ;
  jnz       parser_end                             ;
  cmp       rbp, r11                               ;
  jl        .skip_expand                           ;
  push      r11                                    ; expand phdr buffer if it needs more space
  push      r11                                    ;
  SYSCALL_1 SYS_BRK, 0                             ;
  pop       r11                                    ;
  lea       rdx, [rax + r11]                       ;
  SYSCALL_1 SYS_BRK, rdx                           ;
  pop       r11                                    ;
  lea       r11, [r11 * 2]                         ; expand by x2 more next time
.skip_expand:
  mov       edx, dword [phdr_flags]                ;
  mov       dword [phdr.flags], edx                ;
  mov       edx, dword [phdr.filesz]               ;
  add       dword [phdr.offset], edx               ;
  mov       dword [phdr.filesz], r15d              ;
  mov       dword [phdr.memsz], r15d               ;
  mov       rdx, qword [phdr]                      ; write phdr to phdr buffer
  mov       qword [rbp], rdx                       ;
  mov       rdx, qword [phdr + 8]                  ;
  mov       qword [rbp + 8], rdx                   ;
  mov       rdx, qword [phdr + 16]                 ;
  mov       qword [rbp + 16], rdx                  ;
  mov       rdx, qword [phdr + 24]                 ;
  mov       qword [rbp + 24], rdx                  ;
  lea       rbp, [rbp + 32]                        ;
  jmp       parser_end                             ;

.handle_num:
  test      rbx, IMM_BIT                           ;
  jz        invalid_expression_err                 ;
  mov       rcx, 1                                 ; write 1, 2 or 4 bytes of number
  mov       rdi, 2                                 ;
  mov       rsi, 4                                 ;
  test      rbx, IMM16_BIT                         ;
  cmovnz    rcx, rdi                               ;
  test      rbx, IMM32_BIT                         ;
  cmovnz    rcx, rsi                               ;
  lea       r12, [r12 + 2]                         ;
  lea       rdx, [r12 + 4]                         ;
.write_num:
  mov       al, byte [r12]                         ;
  mov       byte [r14], al                         ;
  inc       r15d                                   ;
  inc       r14                                    ;
  inc       r12                                    ;
  dec       rcx                                    ;
  jnz       .write_num                             ;
  mov       r12, rdx                               ;
  jmp       parse_ir                               ;

.handle_sib_num:
  mov       rdx, PLUS_BIT                          ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
  test      rbx, MULT_BIT                          ;
  jnz       .write_scale                           ;
  mov       edx, dword [r12 + 2]                   ;
  mov       rdi, qword [sib_offset_ptr]            ;
  add       edx, dword [rdi]                       ;
  mov       dword [rdi], edx                       ;
  lea       r12, [r12 + 6]                         ;
  jmp       parse_ir                               ;
.write_scale:
  mov       ecx, dword [r12 + 2]                   ; error if scale number isn't 1, 2, 4 or 8
  lea       edx, [ecx - 1]                         ;
  test      ecx, edx                               ;
  jnz       invalid_expression_err                 ;
  bsr       ecx, ecx                               ;
  cmp       ecx, 3                                 ;
  jg        invalid_expression_err                 ;
  mov       rdi, qword [sib_ptr]                   ;
  and       byte [rdi], 00111111b                  ;
  shl       cl, 6                                  ;
  or        byte [rdi], cl                         ;
  xor       rbx, MULT_BIT                          ;
  lea       r12, [r12 + 6]                         ;
  jmp       parse_ir                               ;

.handle_str:
  lea       r12, [r12 + 2]                         ;
  test      rbx, UNLIMSTR_BIT                      ; write all string if there was db directive
  jnz       .write_all_str                         ;
  test      rbx, IMM_BIT                           ;
  jz        invalid_expression_err                 ;
  mov       rcx, 1                                 ; number with extra steps
  mov       rsi, 2                                 ;
  mov       rdi, 4                                 ;
  test      rbx, IMM16_BIT                         ;
  cmovnz    rcx, rsi                               ;
  test      rbx, IMM32_BIT                         ;
  cmovnz    rcx, rdi                               ;
  lea       rdx, [r12 + rcx]                       ;
.write_str:
  mov       al, byte [r12]                         ;
  mov       byte [r14], al                         ;
  inc       r15d                                   ;
  inc       r12                                    ;
  inc       r14                                    ;
  dec       rcx                                    ;
  test      rcx, rcx                               ;
  jnz       .write_str                             ;
  mov       r12, rdx                               ;
  mov       ax, word [r12]                         ;
  xchg      ah, al                                 ; fix endianess
  cmp       ax, C_STR                              ;
  jne       op_sz_not_match_err                    ; handle operand size error
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.write_all_str:
  mov       al, byte [r12]                         ;
  cmp       al, G_CTRL                             ;
  je        skip_ir                                ;
  mov       byte [r14], al                         ;
  inc       r12                                    ;
  inc       r14                                    ;
  inc       r15d                                   ;
  jmp       .write_all_str                         ;

.handle_sib_str:
  mov       rdx, PLUS_BIT                          ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
  test      rbx, MULT_BIT                          ; string can contain only characters from 32 to 255
  jnz       invalid_expression_err                 ;
  xor       rcx, rcx                               ;
  lea       r12, [r12 + 2]                         ;
.check_strlen:
  mov       ax, word [r12]                         ;
  xchg      ah, al                                 ;
  cmp       ax, C_STR                              ;
  je        .end_strlen_check                      ;
  inc       r12                                    ;
  inc       rcx                                    ;
  jmp       .check_strlen                          ;
.end_strlen_check:
  cmp       ecx, 4                                 ;
  jne       invalid_expression_err                 ;
  mov       rdi, qword [sib_offset_ptr]            ;
  mov       edx, dword [rdi]                       ;
  add       edx, dword [r12 - 4]                   ;
  mov       dword [rdi], edx                       ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_mod_reg:
  test      rbx, REGFIRST_BIT                      ;
  jnz       .not_empty_rm                          ;
  mov       dl, byte [r12 + 1]                     ;
  mov       rdi, qword [modrm_ptr]                 ;
  or        byte [rdi], dl                         ;
  or        rbx, REGFIRST_BIT                      ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.not_empty_rm:
  mov       dl, byte [r12 + 1]                     ;
  shl       dl, 3                                  ;
  mov       rdi, qword [modrm_ptr]                 ;
  or        byte [rdi], dl                         ;
  xor       rbx, REGFIRST_BIT                      ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_sib_reg:
  test      rbx, PLUS_BIT                          ;
  jnz       .skip_modset                           ;
  mov       rdi, qword [modrm_ptr]                 ;
  and       byte [rdi], 00111000b                  ; unset mod & r/m fields
  or        byte [rdi], 00000100b                  ; set SIB mode
.skip_modset:
  mov       rdx, PLUS_BIT                          ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
  test      rbx, MULT_BIT                          ;
  jnz       invalid_expression_err                 ;
  mov       ax, word [r12 + 2]                     ; write register to index field if next token is multiply token
  xchg      ah, al                                 ;
  mov       r8, IDXFIRST_BIT                       ;
  xor       r9, r9                                 ;
  cmp       ax, C_MULT                             ;
  cmove     r9, r8                                 ;
  or        rbx, r9                                ;
  mov       dl, byte [r12 + 1]                     ;
  cmp       dl, R32_EBP                            ; change ModR/M to SIB + disp32
  je        .set_modrm                             ;
  cmp       dl, R32_ESP                            ; esp register can be in base field only
  je        .write_base                            ;
  test      rbx, IDXFIRST_BIT                      ;
  jnz       .write_index                           ;
  jmp       .write_base                            ;
.set_modrm:
  test      rbx, IDXFIRST_BIT                      ;
  jz        .set_modrm_base                        ;
  mov       rdi, qword [modrm_ptr]                 ;
  and       byte [rdi], 00111000b                  ;
  or        byte [rdi], 10000100b                  ; set SIB + disp32 mode
  mov       rdi, qword [sib_ptr]                   ;
  and       byte [rdi], 11000111b                  ;
  or        byte [rdi], 00101000b                  ; fill index field with ebp register
  xor       rbx, IDXFIRST_BIT                      ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.set_modrm_base:
  test      rbx, BASFIRST_BIT                      ;
  jz        invalid_expression_err                 ;
  mov       rdi, qword [modrm_ptr]                 ;
  and       byte [rdi], 00111000b                  ;
  or        byte [rdi], 10000100b                  ;
  mov       rdi, qword [sib_ptr]                   ;
  or        byte [rdi], 00000101b                  ; fill base field with ebp register
  mov       rdx, BASFIRST_BIT                      ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
  or        rbx, IDXFIRST_BIT                      ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.write_base:
  test      rbx, BASFIRST_BIT                      ;
  jz        invalid_expression_err                 ;
  mov       dl, byte [r12 + 1]                     ;
  mov       rdi, qword [sib_ptr]                   ;
  and       byte [rdi], 11111000b                  ; unset base field
  or        byte [rdi], dl                         ;
  mov       rdi, qword [modrm_ptr]                 ;
  and       byte [rdi], 00111000b                  ; unset mod & r/m fields
  or        byte [rdi], 10000100b                  ; set SIB + disp32 mode
  mov       rdx, BASFIRST_BIT                      ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
  or        rbx, IDXFIRST_BIT                      ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.write_index:
  mov       rdi, qword [sib_ptr]                   ;
  mov       dl, byte [rdi]                         ;
  and       dl, 00111000b                          ;
  cmp       dl, 00100000b                          ; 100 means no index
  jne       invalid_expression_err                 ;
  mov       dl, byte [r12 + 1]                     ;
  shl       dl, 3                                  ;
  and       byte [rdi], 11000111b                  ; unset index field
  or        byte [rdi], dl                         ;
  mov       rdx, IDXFIRST_BIT                      ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_memstart:
  push      rbx                                    ; save parser bits in stack
  or        rbx, IMM32_BIT + BASFIRST_BIT          ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_memend:
  call      normal_mode                            ;
  call      modrm_mode                             ;
  pop       rbx                                    ; restore parser bits
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_byte:
  call      sib_mode                               ;
  cmp       byte [r12 + 2], G_CTRL                 ; CASM always need size keyword before memory expression
  jne       invalid_expression_err                 ;
  cmp       byte [r12 + 3], C_MEMST                ;
  jne       invalid_expression_err                 ;
  test      rbx, MEM8_BIT                          ;
  jz        invalid_expression_err                 ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_word:
  call      sib_mode                               ;
  cmp       byte [r12 + 2], G_CTRL                 ;
  jne       invalid_expression_err                 ;
  cmp       byte [r12 + 3], C_MEMST                ;
  jne       invalid_expression_err                 ;
  test      rbx, MEM16_BIT                         ;
  jz        invalid_expression_err                 ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_dword:
  call      sib_mode                               ;
  cmp       byte [r12 + 2], G_CTRL                 ;
  jne       invalid_expression_err                 ;
  cmp       byte [r12 + 3], C_MEMST                ;
  jne       invalid_expression_err                 ;
  test      rbx, MEM32_BIT                         ;
  jz        invalid_expression_err                 ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_label:
.handle_address:
  SYSCALL_3 SYS_WRITE, STDERR, e_unusedlbl_msg, E_UNUSEDLBL_MSG_SZ  ; first CASM versions don't support labels
  SYSCALL_1 SYS_EXIT, EXIT_FAILURE                                  ;

.handle_plus:
  test      rbx, PLUS_BIT                          ; yea just bits
  jnz       invalid_expression_err                 ;
  or        rbx, PLUS_BIT                          ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_mul:
  test      rbx, MULT_BIT                          ;
  jnz       invalid_expression_err                 ;
  or        rbx, MULT_BIT                          ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_comma:
  lea       r12, [r12 + 2]                         ; skip it
  jmp       parse_ir                               ;

.handle_lf:
  and       rbx, PHFIRST_BIT                       ;
  or        rbx, INSTR_BIT + DIR_BIT               ; set instruction + directive bits
  call      normal_mode                            ; restore handler labels after custom modes
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

instr_group:
  test      rbx, INSTR_BIT                         ; traverse operands
  jz        invalid_expression_err                 ;
  movzx     rax, byte [r12 + 1]                    ;
  mov       rsi, qword [instr_node_tbl + rax * 8]  ;
  lea       r12, [r12 + 2]                         ;
  movzx     rax, word [r12]                        ;
  mov       r13, r12                               ;
  jmp       traverse_operands                      ;

einst_group:
  test      rbx, INSTR_BIT                         ; like normal instructions
  jz        invalid_expression_err                 ;
  movzx     rax, byte [r12 + 1]                    ;
  mov       rsi, qword [einst_node_tbl + rax * 8]  ;
  lea       r12, [r12 + 2]                         ;
  movzx     rax, word [r12]                        ;
  mov       r13, r12                               ;

traverse_operands:
  cmp       al, G_CTRL                               ;
  jne       .continue_traverse                       ;
  cmp       ah, C_NUM                                ;
  je        .cmp_num                                 ;
  cmp       ah, C_STR                                ;
  je        .cmp_num                                 ;
  cmp       ah, C_LF                                 ;
  je        .cmp_no_operand                          ;
  cmp       ah, C_BYTE                               ;
  jl        invalid_expression_err                   ;
  je        .cmp_mem8                                ;
  cmp       ah, C_DWORD                              ;
  jg        invalid_expression_err                   ;
  je        .cmp_mem32                               ;
  test      word [rsi + PAR_PARFLAGS_OFF], MEM16_BIT ;
  jnz       .continue_traverse                       ;
  jmp       .go_to_sibling                           ;
.cmp_mem8:
  test      word [rsi + PAR_PARFLAGS_OFF], MEM8_BIT  ;
  jnz       .continue_traverse                       ;
  jmp       .go_to_sibling                           ;
.cmp_mem32:
  test      word [rsi + PAR_PARFLAGS_OFF], MEM32_BIT ;
  jnz       .continue_traverse                       ;
  jmp       .go_to_sibling                           ;
.cmp_num:
  test      word [rsi + PAR_PARFLAGS_OFF], IMM_BIT   ;
  jnz       .continue_traverse                       ;
  jmp       .go_to_sibling                           ;
.cmp_no_operand:
  test      word [rsi + PAR_PARFLAGS_OFF], NOP_BIT   ;
  jz        .go_to_sibling                           ;

.continue_traverse:
  cmp       al, byte [rsi]                         ;
  je        .group_matches                         ;
.go_to_sibling:
  movzx     rdi, byte [rsi + PAR_SIBOFF_OFF]       ; go to sibling if group don't matches
  test      di, di                                 ;
  jz        invalid_expression_err                 ;
  lea       rsi, [rsi + rdi * 8]                   ;
  jmp       traverse_operands                      ;

.group_matches:
  test      word [rsi + PAR_NODEFLAGS_OFF], TERM   ; write opcode if node is terminal
  jnz       .terminal                              ;
  movzx     rdi, byte [rsi + PAR_CHDOFF_OFF]       ; else, go to the child node
  test      di, di                                 ;
  jz        invalid_expression_err                 ;
  movzx     rax, word [r13]                        ;
  cmp       al, G_CTRL                             ;
  jne       .not_ctrl                              ;
  cmp       ah, C_COM                              ;
  jne       .not_comma                             ;
  lea       r13, [r13 + 2]                         ;
  movzx     rax, word [r13]                        ;
.not_comma:
  cmp       ah, C_BYTE                             ;
  jl        .not_mem                               ;
  cmp       ah, C_DWORD                            ;
  jg        .not_mem                               ;
.skip_mem:
  lea       r13, [r13 + 2]                         ;
  cmp       byte [r13 - 2], G_CTRL                 ;
  jne       .skip_mem                              ;
  cmp       byte [r13 - 1], C_NUM                  ;
  jne       .skip_num_skip                         ;
  lea       r13, [r13 + 4]
.skip_num_skip:
  cmp       byte [r13 - 1], C_MEMEN                ;
  jne       .skip_mem                              ;
.not_mem:
  cmp       ah, C_NUM                              ;
  jne       .not_num                               ;
  lea       r13, [r13 + 6]                         ;
.not_num:
  cmp       ah, C_STR                              ;
  jne       .not_str                               ;
  lea       r13, [r13 + 2]                         ;
.skip_str:
  inc       r13                                    ;
  cmp       byte [r13 - 1], C_STR                  ;
  jne       .skip_str                              ;
.not_str:
  mov       ax, word [r13]                         ;
  xchg      ah, al                                 ;
  cmp       ax, C_COM                              ;
  jne       .skip_comma2                           ;
  lea       r13, [r13 + 2]                         ;
.skip_comma2:
  movzx     rax, word [r13]                        ;
  lea       rsi, [rsi + rdi * 8]                   ;
  jmp       traverse_operands                      ;
.not_ctrl:
  lea       r13, [r13 + 2]                         ;
  mov       ax, word [r13]                         ;
  xchg      ah, al                                 ;
  cmp       ax, C_COM                              ;
  jne       .skip_comma3                           ;
  lea       r13, [r13 + 2]                         ;
.skip_comma3:
  movzx     rax, word [r13]                        ;
  lea       rsi, [rsi + rdi * 8]                   ;
  jmp       traverse_operands                      ;

.terminal:
  mov       al, byte [rsi + PAR_OP_OFF]               ; write opcode
  mov       di, word [rsi + PAR_NODEFLAGS_OFF]        ;
  test      di, OPSIZE                                ; handle prefix opcode flags
  jz        .skip_opsize                              ;
  mov       byte [r14], 0x66                          ;
  inc       r14                                       ;
  inc       r15d                                      ;
.skip_opsize:
  test      di, TWOBYTE                               ;
  jz        .skip_twobyte                             ;
  mov       byte [r14], 0x0F                          ;
  inc       r14                                       ;
  inc       r15d                                      ;
.skip_twobyte:
  test      di, SHORT_OP                              ; handle node flags for opcodes
  jnz       .short                                    ;
  test      di, MODRM                                 ;
  jnz       .modrm                                    ;
  jmp       .skip_flags                               ;
.short:
  add       al, byte [r12 + 1]                        ; short opcodes always have register as first operand btw
  jmp       .skip_flags                               ;
.modrm:
  call      modrm_mode                                ;
  inc       r14                                       ;
  mov       qword [modrm_ptr], r14                    ;
  mov       byte [r14], 11000000b                     ; set reg/reg mode (will be overwrited by memory handlers anyway)
  dec       r14                                       ;
  mov       byte [r14], al                            ;
  lea       r14, [r14 + 2]                            ;
  add       r15d, 2                                   ;
  movzx     rsi, word [rsi + PAR_PARFLAGS_OFF]        ;
  and       rbx, PHFIRST_BIT                          ;
  or        rbx, rsi                                  ;
  test      di, OPNUM                                 ;
  jz        .skip_opnum                               ;
  mov       dx, di                                    ;
  and       dx, OPNUM                                 ;
  bsr       dx, dx                                    ;
  shl       dx, 3                                     ;
  or        byte [r14 - 1], dl                        ;
.skip_opnum:
  test      di, SIB                                   ;
  jz        parse_ir                                  ;
  and       byte [r14 - 1], 00111111b                 ; reset mod
  or        byte [r14 - 1], 00000100b                 ; set SIB mode in ModR/M (disp32 defined in SIB)
  or        rbx, REGFIRST_BIT                         ;
  mov       qword [sib_ptr], r14                      ;
  mov       byte [r14], 00100101b                     ; set disp32 mode in SIB
  inc       r14                                       ;
  mov       qword [sib_offset_ptr], r14               ;
  lea       r14, [r14 + 4]                            ;
  add       r15d, 5                                   ;
  jmp       parse_ir                                  ;
.skip_flags:
  mov       byte [r14], al                            ;
  inc       r14                                       ;
  movzx     rsi, word [rsi + PAR_PARFLAGS_OFF]        ;
  and       rbx, PHFIRST_BIT                          ;
  or        rbx, rsi                                  ;
  inc       r15d                                      ;
  jmp       parse_ir                                  ; go to operands logic

dir_group:
  movzx     rax, byte [r12 + 1]                       ;
  jmp       qword [dir_jmp_tbl + rax * 8]             ;

.handle_db:
  and       rbx, PHFIRST_BIT                          ; just set bits
  or        rbx, UNLIMSTR_BIT + IMM8_BIT              ; set unlimited lenght to string (quality of life)
  lea       r12, [r12 + 2]                            ;
  jmp       parse_ir                                  ;

.handle_dw:
  and       rbx, PHFIRST_BIT                          ;
  or        rbx, IMM16_BIT                            ;
  lea       r12, [r12 + 2]                            ;
  jmp       parse_ir                                  ;

.handle_dd:
  and       rbx, PHFIRST_BIT                          ;
  or        rbx, IMM32_BIT                            ;
  lea       r12, [r12 + 2]                            ;
  jmp       parse_ir                                  ;

.handle_text:
  mov       edx, dword [phdr_flags]                   ;
  mov       dword [phdr.flags], edx                   ;
  inc       word [ehdr.phnum]                         ;
  add       dword [ehdr.entry], PHENTSIZE             ;
  mov       byte [phdr_flags], R + X                  ;
  test      rbx, PHFIRST_BIT                          ;
  jz        .write_phdr                               ;
  add       r15d, EHSIZE                              ;
  xor       rbx, PHFIRST_BIT                          ;
  jmp       .skip_write                               ;

.handle_data:
  mov       edx, dword [phdr_flags]                   ;
  mov       dword [phdr.flags], edx                   ;
  inc       word [ehdr.phnum]                         ;
  add       dword [ehdr.entry], PHENTSIZE             ;
  mov       byte [phdr_flags], R + W                  ;
  test      rbx, PHFIRST_BIT                          ;
  jz        .write_phdr                               ;
  add       r15d, EHSIZE                              ;
  xor       rbx, PHFIRST_BIT                          ;
  jmp       .skip_write                               ;

.handle_rodata:
  mov       edx, dword [phdr_flags]                   ;
  mov       dword [phdr.flags], edx                   ;
  inc       word [ehdr.phnum]                         ;
  add       dword [ehdr.entry], PHENTSIZE             ;
  mov       byte [phdr_flags], R                      ;
  test      rbx, PHFIRST_BIT                          ;
  jz        .write_phdr                               ;
  add       r15d, EHSIZE                              ;
  xor       rbx, PHFIRST_BIT                          ;
  jmp       .skip_write                               ;

.write_phdr:
  cmp       rbp, r11                                  ;
  jl        .skip_expand                              ;
  push      r11                                       ; expand phdr buffer if it needs more space
  push      r11                                       ;
  SYSCALL_1 SYS_BRK, 0                                ;
  pop       r11                                       ;
  lea       rdx, [rax + r11]                          ;
  SYSCALL_1 SYS_BRK, rdx                              ;
  pop       r11                                       ;
  lea       r11, [r11 * 2]                            ; expand by x2 more next time
.skip_expand:
  mov       edx, dword [phdr.filesz]                  ;
  add       dword [phdr.offset], edx                  ;
  mov       dword [phdr.filesz], r15d                 ;
  mov       dword [phdr.memsz], r15d                  ;
  mov       rdx, qword [phdr]                         ; write phdr to phdr buffer
  mov       qword [rbp], rdx                          ;
  mov       rdx, qword [phdr + 8]                     ;
  mov       qword [rbp + 8], rdx                      ;
  mov       rdx, qword [phdr + 16]                    ;
  mov       qword [rbp + 16], rdx                     ;
  mov       rdx, qword [phdr + 24]                    ;
  mov       qword [rbp + 24], rdx                     ;
  lea       rbp, [rbp + 32]                           ;
  xor       r15, r15                                  ;
.skip_write:
  mov       edx, dword [phdr.offset]                  ; set phdr fields
  add       edx, dword [ehdr.entry]                   ;
  movzx     edi, word [ehdr.phnum]                    ;
  imul      edi, edi, PHENTSIZE                       ;
  sub       edx, edi                                  ;
  sub       edx, EHSIZE                               ;
  add       edx, dword [phdr.filesz]                  ;
  mov       dword [phdr.vaddr], edx                   ;
  mov       dword [phdr.paddr], edx                   ;
  add       r15d, PHENTSIZE                           ;
  lea       r12, [r12 + 2]                            ;
  jmp       parse_ir                                  ;

modrm_mode:
  mov       qword [group_jmp_tbl + G_REG32 * 8], ctrl_group.handle_mod_reg     ; modrm mode for ModR/M bytes
  mov       qword [group_jmp_tbl + G_REG16 * 8], ctrl_group.handle_mod_reg     ;
  mov       qword [group_jmp_tbl + G_REG8 * 8], ctrl_group.handle_mod_reg      ;
  ret                                                                          ;

sib_mode:
  mov       qword [ctrl_jmp_tbl + C_MEMST * 8], ctrl_group.handle_memstart     ; sib mode for SIB bytes
  mov       qword [ctrl_jmp_tbl + C_MEMEN * 8], ctrl_group.handle_memend       ;
  mov       qword [group_jmp_tbl + G_REG32 * 8], ctrl_group.handle_sib_reg     ;
  mov       qword [group_jmp_tbl + G_REG16 * 8], invalid_expression_err        ;
  mov       qword [group_jmp_tbl + G_REG8 * 8], invalid_expression_err         ;
  mov       qword [ctrl_jmp_tbl + C_NUM * 8], ctrl_group.handle_sib_num        ;
  mov       qword [ctrl_jmp_tbl + C_STR * 8], ctrl_group.handle_sib_str        ;
  mov       qword [ctrl_jmp_tbl + C_COM * 8], invalid_expression_err           ;
  mov       qword [ctrl_jmp_tbl + C_LF  * 8], invalid_expression_err           ;
  ret                                                                          ;

normal_mode:
  mov       qword [ctrl_jmp_tbl + C_MEMST * 8], invalid_expression_err         ; restore labels after custom modes
  mov       qword [ctrl_jmp_tbl + C_MEMEN * 8], invalid_expression_err         ;
  mov       qword [group_jmp_tbl + G_REG32 * 8], skip_ir                       ;
  mov       qword [group_jmp_tbl + G_REG16 * 8], skip_ir                       ;
  mov       qword [group_jmp_tbl + G_REG8 * 8], skip_ir                        ;
  mov       qword [ctrl_jmp_tbl + C_NUM * 8], ctrl_group.handle_num            ;
  mov       qword [ctrl_jmp_tbl + C_STR * 8], ctrl_group.handle_str            ;
  mov       qword [ctrl_jmp_tbl + C_COM * 8], ctrl_group.handle_comma          ;
  mov       qword [ctrl_jmp_tbl + C_LF  * 8], ctrl_group.handle_lf             ;
  mov       qword [modrm_ptr], modrm_ptr                                       ;
  ret                                                                          ;

parser_end = $
