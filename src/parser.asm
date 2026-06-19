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
  mov       qword [current_line], 1                            ;
  mov       rbx, INSTR_BIT + DIR_BIT + LABEL_BIT + PHFIRST_BIT ; rbx - parser bit mask (expected tokens and other)
  mov       r12, qword [lex_irbuf_ptr]                         ; r12 - token buffer pointer
  xor       r15, r15                                           ; r15 - offset in elf headers
  lea       r11, [rbp + PHDRBUF_SIZE]                          ; r11 - how much memory need phdr buffer (x2 after expand)
  mov       qword [par_irbuf_ptr], r14                         ; save parser IR buffer start pointer

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
  mov       rdi, qword [deladrbuf_ptr]             ;
  push      qword [current_line]                   ;
  push      r14                                    ;
.next_deladdr:
  mov       r13, qword [labelbuf_ptr]              ;
  mov       r12, qword [rdi]                       ;
  mov       r14, qword [rdi + 8]                   ;
  mov       rax, qword [rdi + 16]                  ;
  mov       qword [current_line], rax              ;
  mov       r8, r12                                ;
.write_del_addr:
  cmp       qword [rdi], 0                         ;
  je        .end_deladr_write                      ;
  mov       al, byte [r12]                         ;
  cmp       byte [r13], al                         ;
  jne       .sec_next_label                        ;
  inc       r12                                    ;
  inc       r13                                    ;
  cmp       byte [r12], G_CTRL                     ;
  jne       .write_del_addr                        ;
  cmp       byte [r13], 0                          ;
  jne       .sec_next_label                        ;
  mov       esi, dword [r13 + 1]                   ;
  cmp       byte [rdi + 28], '-'                   ;
  jne       .skip_addr_neg                         ;
  neg       esi                                    ;
.skip_addr_neg:
  cmp       byte [rdi + 28], 'E'                   ;
  jne       .skip_deladdr_entry                    ;
  mov       dword [custom_entry], esi              ;
  add       rdi, 29                                ;
  jmp       .next_deladdr                          ;
.skip_deladdr_entry:
  cmp       byte [rdi + 28], 'B'                   ;
  jne       .skip_deladdr_rel8                     ;
  sub       esi, dword [rdi + 24]                  ;
  cmp       esi, 127                               ;
  jg        rel_jmp_range_err                      ;
.skip_deladdr_rel8:
  add       dword [r14], esi                       ;
  add       rdi, 29                                ;
  jmp       .next_deladdr                          ;
.sec_next_label:
  cmp       byte [r13], 0                          ;
  je        .sec_found_next                        ;
  inc       r13                                    ;
  jmp       .sec_next_label                        ;
.sec_found_next:
  lea       r13, [r13 + 5]                         ;
  mov       r12, r8                                ;
  cmp       byte [r13], 0                          ;
  je        undef_lbl_err                          ;
  jmp       .write_del_addr                        ;
.end_deladr_write:
  pop       r14                                    ;
  pop       qword [current_line]                   ;
  cmp       dword [custom_entry], 0                ;
  je        .default_entry                         ; write custom entry if there was .entry directive
  mov       edi, dword [custom_entry]              ;
  mov       dword [ehdr.entry], edi                ;
.default_entry:
  test      rbx, PHFIRST_BIT                       ;
  jnz       parser_end                             ;
  cmp       rbp, r11                               ;
  jl        .skip_expand                           ;
  sub       r11, qword [phdrbuf_ptr]               ;
  push      r11                                    ; expand phdr buffer if it needs more space
  push      r11                                    ;
  SYSCALL_1 SYS_BRK, 0                             ;
  pop       r11                                    ;
  lea       rdx, [rax + r11]                       ;
  SYSCALL_1 SYS_BRK, rdx                           ;
  pop       r11                                    ;
  lea       r11, [r11 * 2]                         ; expand by x2 more next time
  add       r11, qword [phdrbuf_ptr]               ;
.skip_expand:
  mov       edx, dword [phdr_flags]                ;
  mov       dword [phdr.flags], edx                ;
  mov       edx, dword [phdr.filesz]               ;
  add       dword [phdr.offset], edx               ;
  cmp       qword [phdrbuf_ptr], rbp               ;
  je        .first_segment                         ;
  sub       r15d, PHENTSIZE                        ;
.first_segment:
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
  mov       rdi, qword [phdrbuf_ptr]               ;
  movzx     ecx, word [ehdr.phnum]                 ;
  cmp       ecx, 1                                 ;
  jne       .not_1_phdr                            ;
  mov       ecx, PHENTSIZE                         ;
  sub       dword [rdi + phdr.filesz - phdr], ecx  ;
  sub       dword [rdi + phdr.memsz - phdr], ecx   ;
  jmp       parser_end                             ;
.not_1_phdr:
  sub       ecx, 2                                 ;
  imul      ecx, ecx, PHENTSIZE                    ;
.fix_phdr_fields:
  add       rdi, PHENTSIZE                         ;
  cmp       rdi, rbp                               ;
  je        parser_end                             ;
  add       dword [rdi + phdr.offset - phdr], ecx  ;
  add       dword [rdi + phdr.vaddr - phdr], ecx   ;
  add       dword [rdi + phdr.paddr - phdr], ecx   ;
  jmp       .fix_phdr_fields                       ;

.handle_num:
  test      rbx, IMM_BIT                           ;
  jz        invalid_operands_err                   ;
  test      rbx, ENTRY_BIT                         ;
  jz        .not_custom_entry                      ;
  mov       edi, dword [r12 + 2]                   ;
  mov       dword [custom_entry], edi              ;
  lea       r12, [r12 + 6]                         ;
  jmp       parse_ir                               ;
.not_custom_entry:
  test      rbx, IMM8_BIT                          ;
  jz        .skip_imm8                             ;
  mov       rcx, 1                                 ;
  mov       edx, 0xFFFFFF00                        ;
  mov       rsi, IMM8_BIT                          ;
.skip_imm8:
  test      rbx, IMM16_BIT                         ;
  jz        .skip_imm16                            ;
  mov       rcx, 2                                 ;
  mov       edx, 0xFFFF0000                        ;
  mov       rsi, IMM16_BIT                         ;
.skip_imm16:
  test      rbx, IMM32_BIT                         ;
  jz        .skip_imm32                            ;
  mov       rcx, 4                                 ;
  mov       edx, 0x00000000                        ;
  mov       rsi, IMM32_BIT                         ;
.skip_imm32:
  test      rbx, UNLIMIMM_BIT                      ;
  jnz       .skip_bits_clear                       ;
  xor       rbx, rsi                               ;
.skip_bits_clear:
  lea       r12, [r12 + 2]                         ;
  mov       esi, dword [r12]                       ;
  test      esi, edx                               ;
  jnz       op_sz_not_match_err                    ;
  lea       rdx, [r12 + 4]                         ;
.write_num:
  mov       al, byte [r12]                         ;
  mov       byte [r14], al                         ;
  inc       r15d                                   ;
  inc       dword [current_ptr]                    ;
  inc       r14                                    ;
  inc       r12                                    ;
  dec       rcx                                    ;
  jnz       .write_num                             ;
  mov       r12, rdx                               ;
  jmp       parse_ir                               ;

.handle_sib_num:
  test      rbx, PLUS_BIT + MINUS_BIT + MULT_BIT   ;
  jz        invalid_expression_err                 ;
  mov       ax, word [r12 + 6]                     ;
  xchg      ah, al                                 ;
  cmp       ax, C_MULT                             ;
  je        invalid_expression_err                 ;
  mov       rdx, PLUS_BIT                          ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
  test      rbx, MULT_BIT                          ;
  jnz       .write_scale                           ;
  mov       edx, dword [r12 + 2]                   ;
  test      rbx, MINUS_BIT                         ;
  jz        .skip_num_neg                          ;
  neg       edx                                    ;
  xor       rbx, MINUS_BIT                         ;
.skip_num_neg:
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
  inc       qword [style_points]                   ; scale in SIB is cool
  lea       r12, [r12 + 6]                         ;
  jmp       parse_ir                               ;

.handle_str:
  inc       qword [style_points]                   ; strings are cool too
  lea       r12, [r12 + 2]                         ;
  test      rbx, UNLIMSTR_BIT                      ; write all string if there was db directive
  jnz       .write_all_str                         ;
  test      rbx, IMM_BIT                           ;
  jz        invalid_operands_err                   ;
  mov       rcx, 1                                 ; number with extra steps
  mov       rsi, 2                                 ;
  mov       rdi, 4                                 ;
  test      rbx, IMM16_BIT                         ;
  cmovnz    rcx, rsi                               ;
  test      rbx, IMM32_BIT                         ;
  cmovnz    rcx, rdi                               ;
  imul      rdx, rcx, IMM8_BIT                     ;
  xor       rbx, rdx                               ;
  xor       rdx, rdx                               ;
  mov       ax, word [r12]                         ;
  xchg      ah, al                                 ; fix endianess
  cmp       ax, C_STR                              ;
  je        .skip_str_write                        ;
.write_str:
  mov       al, byte [r12]                         ;
  mov       byte [r14], al                         ;
  cmp       al, LF                                 ;
  jne       .not_lf                                ;
  inc       qword [current_line]                   ;
.not_lf:
  inc       r15d                                   ;
  inc       dword [current_ptr]                    ;
  inc       r12                                    ;
  inc       r14                                    ;
  inc       rdx                                    ;
  mov       ax, word [r12]                         ;
  xchg      ah, al                                 ; fix endianess
  cmp       ax, C_STR                              ;
  jne       .write_str                             ;
.skip_str_write:
  cmp       rdx, rcx                               ;
  jg        op_sz_not_match_err                    ;
  sub       rcx, rdx                               ;
  add       r14, rcx                               ;
  add       r15d, ecx                              ;
  add       dword [current_ptr], ecx               ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.write_all_str:
  mov       al, byte [r12]                         ;
  cmp       al, G_CTRL                             ;
  je        skip_ir                                ;
  mov       byte [r14], al                         ;
  cmp       al, LF                                 ;
  jne       .all_not_lf                            ;
  inc       qword [current_line]                   ;
.all_not_lf:
  inc       r12                                    ;
  inc       r14                                    ;
  inc       r15d                                   ;
  inc       dword [current_ptr]                    ;
  jmp       .write_all_str                         ;

.handle_sib_str:
  test      rbx, PLUS_BIT + MINUS_BIT              ;
  jz        invalid_expression_err                 ;
  add       qword [style_points], 2                ; strings in memory expressions are very cool
  mov       rdx, PLUS_BIT                          ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
  test      rbx, MULT_BIT                          ;
  jnz       invalid_expression_err                 ;
  xor       rcx, rcx                               ;
  xor       edi, edi                               ;
  mov       edx, dword [r12 + 2]                   ;
  lea       r12, [r12 + 2]                         ;
.check_strlen:
  mov       ax, word [r12]                         ;
  xchg      ah, al                                 ;
  cmp       ax, C_STR                              ;
  je        .end_strlen_check                      ;
  inc       r12                                    ;
  inc       rcx                                    ;
  shl       edi, 8                                 ;
  not       dil                                    ;
  jmp       .check_strlen                          ;
.end_strlen_check:
  cmp       ecx, 4                                 ;
  jg        op_sz_not_match_err                    ;
  and       edx, edi                               ;
  mov       rdi, qword [sib_offset_ptr]            ;
  test      rbx, MINUS_BIT                         ;
  jz        .skip_str_neg                          ;
  neg       edx                                    ;
  xor       rbx, MINUS_BIT                         ;
.skip_str_neg:
  add       edx, dword [rdi]                       ;
  mov       dword [rdi], edx                       ;
  mov       ax, word [r12 + 2]                     ;
  xchg      ah, al                                 ;
  cmp       ax, C_MULT                             ;
  je        invalid_expression_err                 ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_mod_reg:
  test      rbx, REGFIRST_BIT                      ;
  jnz       .not_empty_rm                          ;
  or        rbx, REGFIRST_BIT                      ;
  cmp       byte [r12 + 1], R_CONST                ;
  je        skip_ir                                ;
  mov       dl, byte [r12 + 1]                     ;
  mov       rdi, qword [modrm_ptr]                 ;
  or        byte [rdi], dl                         ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.not_empty_rm:
  xor       rbx, REGFIRST_BIT                      ;
  cmp       byte [r12 + 1], R_CONST                ;
  je        skip_ir                                ;
  mov       dl, byte [r12 + 1]                     ;
  shl       dl, 3                                  ;
  mov       rdi, qword [modrm_ptr]                 ;
  or        byte [rdi], dl                         ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_sib_reg:
  test      rbx, MINUS_BIT + MULT_BIT              ;
  jnz       invalid_expression_err                 ;
  test      rbx, PLUS_BIT                          ;
  jz        invalid_expression_err                 ;
  test      rbx, SIBRFIRST_BIT                     ;
  jz        .skip_modset                           ;
  mov       rdi, qword [modrm_ptr]                 ;
  and       byte [rdi], 00111000b                  ; unset mod & r/m fields
  or        byte [rdi], 00000100b                  ; set SIB mode
  xor       rbx, SIBRFIRST_BIT                     ;
.skip_modset:
  mov       rdx, PLUS_BIT                          ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
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

.handle_segpref:
  inc       qword [style_points]                   ; segment prefixes are cool
  mov       ax, word [r12 - 2]                     ;
  xchg      ah, al                                 ;
  cmp       ax, C_MEMST                            ;
  jne       invalid_expression_err                 ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_memstart:
  push      rbx                                           ; save parser bits in stack
  or        rbx, IMM32_BIT + BASFIRST_BIT + SIBRFIRST_BIT ;
  or        rbx, PLUS_BIT                                 ;
  inc       qword [style_points]                          ; memory expressions are cool
  mov       ax, word [r12 + 2]                            ;
  xchg      ah, al                                        ;
  cmp       ax, C_MULT                                    ;
  je        invalid_expression_err                        ;
  lea       r12, [r12 + 2]                                ;
  jmp       parse_ir                                      ;

.handle_memend:
  test      rbx, PLUS_BIT + MINUS_BIT + MULT_BIT   ;
  jnz       invalid_expression_err                 ;
  call      normal_mode                            ;
  call      modrm_mode                             ;
  pop       rbx                                    ; restore parser bits
  mov       rdx, MEM_BIT                           ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_byte:
  call      sib_mode                               ;
  cmp       byte [r12 + 2], G_CTRL                 ; CASM always need size keyword before memory expression
  jne       invalid_operands_err                   ;
  cmp       byte [r12 + 3], C_MEMST                ;
  jne       invalid_operands_err                   ;
  test      rbx, MEM8_BIT                          ;
  jz        invalid_operands_err                   ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_word:
  call      sib_mode                               ;
  cmp       byte [r12 + 2], G_CTRL                 ;
  jne       invalid_operands_err                   ;
  cmp       byte [r12 + 3], C_MEMST                ;
  jne       invalid_operands_err                   ;
  test      rbx, MEM16_BIT                         ;
  jz        invalid_operands_err                   ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_dword:
  call      sib_mode                               ;
  cmp       byte [r12 + 2], G_CTRL                 ;
  jne       invalid_operands_err                   ;
  cmp       byte [r12 + 3], C_MEMST                ;
  jne       invalid_operands_err                   ;
  test      rbx, MEM32_BIT                         ;
  jz        invalid_operands_err                   ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_label:
  test      rbx, LABEL_BIT                         ;
  jz        invalid_expression_err                 ;
  xor       rbx, LABEL_BIT                         ;
  inc       qword [style_points]                   ; labels are cool
  mov       r13, qword [labelbuf_ptr]              ;
  add       r13, qword [labelbuf_slot_offset]      ;
  lea       r12, [r12 + 2]                         ;
.write_label:
  mov       al, byte [r12]                         ;
  mov       byte [r13], al                         ;
  inc       qword [labelbuf_slot_offset]           ;
  cmp       byte [r12 + 2], C_LBL                  ;
  je        .end_label_write                       ;
  inc       r12                                    ;
  inc       r13                                    ;
  jmp       .write_label                           ;
.end_label_write:
  lea       r12, [r12 + 3]                         ;
  mov       edi, dword [current_ptr]               ;
  mov       dword [r13 + 2], edi                   ;
  add       qword [labelbuf_slot_offset], 5        ;
  jmp       parse_ir                               ;

.handle_address:
  test      rbx, IMM_BIT                           ;
  jz        invalid_operands_err                   ;
  inc       qword [style_points]                   ; addresses are cool
  lea       r12, [r12 + 2]                         ;
  mov       r8, r12                                ;
  mov       r13, qword [labelbuf_ptr]              ;
  cmp       byte [r13], 0                          ;
  je        .delayed_addr                          ;
.compare_label:
  mov       al, byte [r12]                         ;
  cmp       byte [r13], al                         ;
  jne       .next_label                            ;
  inc       r12                                    ;
  inc       r13                                    ;
  cmp       byte [r12], G_CTRL                     ;
  jne       .compare_label                         ;
  cmp       byte [r13], 0                          ;
  jne       .next_label                            ;
  test      rbx, ENTRY_BIT                         ;
  jz        .not_entry                             ;
  mov       edi, dword [r13 + 1]                   ;
  mov       dword [custom_entry], edi              ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.not_entry:
  mov       edi, dword [r13 + 1]                   ;
  test      rbx, REL8_BIT                          ;
  jz        .not_rel8                              ;
  sub       edi, dword [current_ptr]               ;
  dec       edi                                    ;
  mov       eax, edi                               ;
  and       eax, 0xFFFFFF00                        ;
  cmp       eax, 0xFFFFFF00                        ;
  jne       rel_jmp_range_err                      ;
  mov       byte [r14], dil                        ;
  inc       r14                                    ;
  inc       dword [current_ptr]                    ;
  inc       r15d                                   ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.not_rel8:
  test      rbx, REL32_BIT                         ;
  jz        .not_rel32                             ;
  sub       edi, dword [current_ptr]               ;
  sub       edi, 4                                 ;
.not_rel32:
  mov       dword [r14], edi                       ;
  lea       r14, [r14 + 4]                         ;
  lea       r15d, [r15d + 4]                       ;
  add       dword [current_ptr], 4                 ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.next_label:
  cmp       byte [r13], 0                          ;
  je        .found_next                            ;
  inc       r13                                    ;
  jmp       .next_label                            ;
.found_next:
  lea       r13, [r13 + 5]                         ;
  mov       r12, r8                                ;
  cmp       byte [r13], 0                          ;
  je        .delayed_addr                          ;
  jmp       .compare_label                         ;
.delayed_addr:
  mov       rdi, qword [deladrbuf_ptr]             ;
  add       rdi, qword [deladr_offset]             ;
  mov       qword [rdi], r12                       ;
  mov       qword [rdi + 8], r14                   ;
  mov       rax, qword [current_line]              ;
  mov       qword [rdi + 16], rax                  ;
  test      rbx, ENTRY_BIT                         ;
  jz        .skip_entry_bit                        ;
  mov       byte [rdi + 28], 'E'                   ;
  sub       r14, 4                                 ;
  sub       dword [current_ptr], 4                 ;
  sub       r15d, 4                                ;
.skip_entry_bit:
  test      rbx, REL8_BIT                          ;
  jz        .del_not_rel8                          ;
  mov       byte [rdi + 28], 'B'                   ;
  mov       eax, dword [current_ptr]               ;
  inc       eax                                    ;
  mov       dword [rdi + 24], eax                  ;
  sub       r14, 3                                 ;
  sub       dword [current_ptr], 3                 ;
  sub       r15d, 3                                ;
  jmp       .del_not_rel32                         ;
.del_not_rel8:
  test      rbx, REL32_BIT                         ;
  jz        .del_not_rel32                         ;
  mov       esi, dword [current_ptr]               ;
  add       esi, 4                                 ;
  sub       dword [r14], esi                       ;
.del_not_rel32:
  add       r14, 4                                 ;
  add       dword [current_ptr], 4                 ;
  add       r15d, 4                                ;
  add       qword [deladr_offset], 29              ;
.del_skip_adr:
  mov       ax, word [r12]                         ;
  xchg      ah, al                                 ;
  cmp       ax, C_ADR                              ;
  je        skip_ir                                ;
  inc       r12                                    ;
  jmp       .del_skip_adr                          ;

.handle_sib_address:
  test      rbx, MULT_BIT                          ;
  jnz       invalid_expression_err                 ;
  test      rbx, PLUS_BIT + MINUS_BIT              ;
  jz        invalid_expression_err                 ;
  mov       rdx, PLUS_BIT                          ;
  not       rdx                                    ;
  and       rbx, rdx                               ;
  lea       r12, [r12 + 2]                         ;
  mov       r8, r12                                ;
  mov       r13, qword [labelbuf_ptr]              ;
  cmp       byte [r13], 0                          ;
  je        .sib_deladdr                           ;
.sib_compare_label:
  mov       al, byte [r12]                         ;
  cmp       byte [r13], al                         ;
  jne       .sib_next_label                        ;
  inc       r12                                    ;
  inc       r13                                    ;
  cmp       byte [r12], G_CTRL                     ;
  jne       .sib_compare_label                     ;
  cmp       byte [r13], 0                          ;
  jne       .sib_next_label                        ;
  mov       esi, dword [r13 + 1]                   ;
  mov       rdi, qword [sib_offset_ptr]            ;
  test      rbx, MINUS_BIT                         ;
  jz        .skip_sib_addr_neg                     ;
  neg       esi                                    ;
  xor       rbx, MINUS_BIT                         ;
.skip_sib_addr_neg:
  add       dword [rdi], esi                       ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;
.sib_next_label:
  cmp       byte [r13], 0                          ;
  je        .sib_found_next                        ;
  inc       r13                                    ;
  jmp       .sib_next_label                        ;
.sib_found_next:
  lea       r13, [r13 + 5]                         ;
  mov       r12, r8                                ;
  cmp       byte [r13], 0                          ;
  je        .sib_deladdr                           ;
  jmp       .sib_compare_label                     ;
.sib_deladdr:
  mov       rdi, qword [deladrbuf_ptr]             ;
  add       rdi, qword [deladr_offset]             ;
  mov       qword [rdi], r12                       ;
  mov       rsi, qword [sib_offset_ptr]            ;
  mov       qword [rdi + 8], rsi                   ;
  mov       rax, qword [current_line]              ;
  mov       qword [rdi + 16], rax                  ;
  test      rbx, MINUS_BIT                         ;
  jz        .skip_deladdr_neg                      ;
  mov       byte [rdi + 28], '-'                   ;
  xor       rbx, MINUS_BIT                         ;
.skip_deladdr_neg:
  add       qword [deladr_offset], 29              ;
.sib_del_skip:
  mov       ax, word [r12]                         ;
  xchg      ah, al                                 ;
  cmp       ax, C_ADR                              ;
  je        skip_ir                                ;
  inc       r12                                    ;
  jmp       .sib_del_skip                          ;

.handle_plus:
  test      rbx, PLUS_BIT                          ; yea just bits
  jnz       invalid_expression_err                 ;
  or        rbx, PLUS_BIT                          ;
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

.handle_minus:
  test      rbx, MINUS_BIT                         ;
  jnz       invalid_expression_err                 ;
  or        rbx, MINUS_BIT                         ;
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
  inc       qword [current_line]                   ;
  and       rbx, PHFIRST_BIT                       ;
  or        rbx, INSTR_BIT + DIR_BIT + LABEL_BIT   ; set instruction + directive + label bits
  call      normal_mode                            ; restore handler labels after custom modes
  lea       r12, [r12 + 2]                         ;
  jmp       parse_ir                               ;

instr_group:
  test      rbx, INSTR_BIT                         ; traverse operands
  jz        invalid_expression_err                 ;
  xor       rbx, INSTR_BIT + DIR_BIT + LABEL_BIT   ;
  movzx     rax, byte [r12 + 1]                    ;
  mov       rsi, qword [instr_node_tbl + rax * 8]  ;
  lea       r12, [r12 + 2]                         ;
  movzx     rax, word [r12]                        ;
  mov       r13, r12                               ;
  mov       r10, 0                                 ;
  mov       r9, 0                                  ;
  jmp       traverse_operands                      ;

einst_group:
  test      rbx, INSTR_BIT                         ; like normal instructions
  jz        invalid_expression_err                 ;
  add       qword [style_points], 2                ; weird instructions are very cool
  xor       rbx, INSTR_BIT + DIR_BIT + LABEL_BIT   ;
  movzx     rax, byte [r12 + 1]                    ;
  mov       rsi, qword [einst_node_tbl + rax * 8]  ;
  lea       r12, [r12 + 2]                         ;
  movzx     rax, word [r12]                        ;
  mov       r13, r12                               ;
  mov       r10, 0                                 ;
  mov       r9, 0                                  ;

traverse_operands:
  cmp       al, G_CTRL                               ;
  jne       .continue_traverse                       ;
  cmp       ah, C_NUM                                ;
  je        .cmp_num                                 ;
  cmp       ah, C_ADR                                ;
  je        .cmp_num                                 ;
  cmp       ah, C_STR                                ;
  je        .cmp_num                                 ;
  cmp       ah, C_BYTE                               ;
  je        .cmp_mem8                                ;
  cmp       ah, C_WORD                               ;
  je        .cmp_mem16                               ;
  cmp       ah, C_DWORD                              ;
  je        .cmp_mem32                               ;
  test      r10, r10                                 ;
  jz        .not_longest_match                       ;
  cmp       ah, C_LF                                 ;
  jne       invalid_operands_err                     ;
  mov       rsi, r10                                 ;
  jmp       .write_opcode                            ;
.not_longest_match:
  cmp       ah, C_LF                                 ;
  je        .cmp_no_operand                          ;
  jmp       invalid_operands_err                     ;
.cmp_mem16:
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
  test      word [rsi + PAR_PARFLAGS_OFF], REG_BIT   ;
  jnz       .cmp_reg                                 ;
  test      word [rsi + PAR_NODEFLAGS_OFF], SREG     ;
  jz        .cmp_group                               ;
.cmp_reg:
  mov       dl, ah                                   ;
  cmp       al, G_REG32                              ;
  je        .cmp_reg32                               ;
  cmp       al, G_REG16                              ;
  je        .cmp_reg16                               ;
  cmp       al, G_REG8                               ;
  je        .cmp_reg8                                ;
  cmp       al, G_SREG                               ;
  je        .cmp_sreg                                ;
  jmp       .go_to_sibling                           ;
.cmp_reg32:
  test      word [rsi + PAR_PARFLAGS_OFF], REG32_BIT ;
  jz        .go_to_sibling                           ;
  cmp       dl, byte [rsi]                           ;
  jne       .go_to_sibling                           ;
  mov       byte [r13 + 1], R_CONST                  ;
  jmp       .group_matches                           ;
.cmp_reg16:
  test      word [rsi + PAR_PARFLAGS_OFF], REG16_BIT ;
  jz        .go_to_sibling                           ;
  cmp       dl, byte [rsi]                           ;
  jne       .go_to_sibling                           ;
  mov       byte [r13 + 1], R_CONST                  ;
  jmp       .group_matches                           ;
.cmp_reg8:
  test      word [rsi + PAR_PARFLAGS_OFF], REG8_BIT  ;
  jz        .go_to_sibling                           ;
  cmp       dl, byte [rsi]                           ;
  jne       .go_to_sibling                           ;
  mov       byte [r13 + 1], R_CONST                  ;
  jmp       .group_matches                           ;
.cmp_sreg:
  test      word [rsi + PAR_NODEFLAGS_OFF], SREG     ;
  jz        .go_to_sibling                           ;
  cmp       dl, byte [rsi]                           ;
  jne       .go_to_sibling                           ;
  mov       byte [r13 + 1], R_CONST                  ;
  jmp       .group_matches                           ;
.cmp_group:
  cmp       al, byte [rsi]                         ;
  je        .group_matches                         ;
.go_to_sibling:
  movzx     rdi, byte [rsi + PAR_SIBOFF_OFF]       ; go to sibling if group don't matches
  test      di, di                                 ;
  jz        invalid_operands_err                   ;
  lea       rsi, [rsi + rdi * 8]                   ;
  jmp       traverse_operands                      ;

.group_matches:
  movzx     rax, word [r13]                        ;
  cmp       al, G_CTRL                             ;
  jne       .not_ctrl                              ;
  cmp       ah, C_COM                              ;
  jne       .not_comma                             ;
  lea       r13, [r13 + 2]                         ;
  movzx     rax, word [r13]                        ;
.not_comma:
  test      r10, r10                               ;
  jz        .not_longest                           ;
  test      di, di                                 ;
  cmovz     rsi, r10                               ;
  jz        .terminal                              ;
.not_longest:
  cmp       ah, C_BYTE                             ;
  jl        .not_mem                               ;
  cmp       ah, C_DWORD                            ;
  jg        .not_mem                               ;
.skip_mem:
  lea       r13, [r13 + 2]                         ;
  cmp       byte [r13 - 2], G_SPREF                ;
  cmove     r9d, dword [r13 - 1]                   ;
  cmp       byte [r13 - 2], G_CTRL                 ;
  jne       .skip_mem                              ;
  cmp       byte [r13 - 1], C_LF                   ;
  je        invalid_expression_err                 ;
  cmp       byte [r13 - 1], C_NUM                  ;
  jne       .skip_num_skip                         ;
  lea       r13, [r13 + 4]                         ;
.skip_num_skip:
  cmp       byte [r13 - 1], C_ADR                  ;
  jne       .skip_address_skip                     ;
.skip_address:
  mov       dx, word [r13]                         ;
  inc       r13                                    ;
  xchg      dh, dl                                 ;
  cmp       dx, C_ADR                              ;
  jne       .skip_address                          ;
  inc       r13                                    ;
.skip_address_skip:
  cmp       byte [r13 - 1], C_STR                  ;
  jne       .skip_str_skip                         ;
.mem_skip_str:
  mov       dx, word [r13]                         ;
  inc       r13                                    ;
  xchg      dh, dl                                 ;
  cmp       dx, C_STR                              ;
  jne       .mem_skip_str                          ;
  inc       r13                                    ;
.skip_str_skip:
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
  cmp       ah, C_ADR                              ;
  jne       .not_address                           ;
.skip_address2:
  inc       r13                                    ;
  cmp       byte [r13 - 1], C_ADR                  ;
  jne       .skip_address2                         ;
.not_address:
  mov       ax, word [r13]                         ;
  xchg      ah, al                                 ;
  cmp       ax, C_COM                              ;
  jne       .skip_comma2                           ;
  lea       r13, [r13 + 2]                         ;
.skip_comma2:
  test      word [rsi + PAR_NODEFLAGS_OFF], TERM   ; write opcode if node is terminal
  jnz       .terminal                              ;
  movzx     rdi, byte [rsi + PAR_CHDOFF_OFF]       ; else, go to the child node
  test      di, di                                 ;
  jz        invalid_operands_err                   ;
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
  test      word [rsi + PAR_NODEFLAGS_OFF], TERM   ;
  jnz       .terminal                              ;
  movzx     rdi, byte [rsi + PAR_CHDOFF_OFF]       ;
  test      di, di                                 ;
  jz        invalid_operands_err                   ;
  movzx     rax, word [r13]                        ;
  lea       rsi, [rsi + rdi * 8]                   ;
  jmp       traverse_operands                      ;

.terminal:
  cmp       byte [rsi + PAR_CHDOFF_OFF], 0            ; find longest match
  je        .write_opcode                             ;
  mov       r10, rsi                                  ;
  movzx     rdi, byte [rsi + PAR_CHDOFF_OFF]          ;
  lea       rsi, [rsi + rdi * 8]                      ;
  movzx     rax, word [r13]                           ;
  mov       dx, ax                                    ;
  xchg      dh, dl                                    ;
  cmp       dx, C_COM                                 ;
  jne       traverse_operands                         ;
  lea       r13, [r13 + 2]                            ;
  movzx     rax, word [r13]                           ;
  jmp       traverse_operands                         ;
.write_opcode:
  call      operand_mode                              ;
  mov       al, byte [rsi + PAR_OP_OFF]               ; write opcode
  mov       di, word [rsi + PAR_NODEFLAGS_OFF]        ;
  test      r9, r9                                    ;
  jz        .skip_segpref                             ;
  mov       byte [r14], r9b                           ;
  inc       r14                                       ;
  inc       r15d                                      ;
  inc       dword [current_ptr]                       ;
.skip_segpref:
  test      di, OPSIZE                                ; handle prefix opcode flags
  jz        .skip_opsize                              ;
  mov       byte [r14], 0x66                          ;
  inc       r14                                       ;
  inc       r15d                                      ;
  inc       dword [current_ptr]                       ;
.skip_opsize:
  test      di, TWOBYTE                               ;
  jz        .skip_twobyte                             ;
  mov       byte [r14], 0x0F                          ;
  inc       r14                                       ;
  inc       r15d                                      ;
  inc       dword [current_ptr]                       ;
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
  add       dword [current_ptr], 2                    ;
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
  add       dword [current_ptr], 5                    ;
  jmp       parse_ir                                  ;
.skip_flags:
  mov       byte [r14], al                            ;
  inc       r14                                       ;
  movzx     rsi, word [rsi + PAR_PARFLAGS_OFF]        ;
  and       rbx, PHFIRST_BIT                          ;
  or        rbx, rsi                                  ;
  inc       r15d                                      ;
  inc       dword [current_ptr]                       ;
  jmp       parse_ir                                  ; go to operands logic

dir_group:
  movzx     rax, byte [r12 + 1]                       ;
  jmp       qword [dir_jmp_tbl + rax * 8]             ;

.handle_db:
  and       rbx, PHFIRST_BIT                            ; just set bits
  or        rbx, UNLIMSTR_BIT + IMM8_BIT + UNLIMIMM_BIT ; set unlimited lenght to string (quality of life)
  call      operand_mode                                ;
  lea       r12, [r12 + 2]                              ;
  jmp       parse_ir                                    ;

.handle_dw:
  and       rbx, PHFIRST_BIT                            ;
  or        rbx, IMM16_BIT + UNLIMIMM_BIT               ;
  call      operand_mode                                ;
  lea       r12, [r12 + 2]                              ;
  jmp       parse_ir                                    ;

.handle_dd:
  and       rbx, PHFIRST_BIT                            ;
  or        rbx, IMM32_BIT + UNLIMIMM_BIT               ;
  call      operand_mode                                ;
  lea       r12, [r12 + 2]                              ;
  jmp       parse_ir                                    ;

.handle_text:
  inc       qword [style_points]                        ;
  mov       rdi, qword [phdrbuf_ptr]                    ;
  add       dword [rdi + phdr.filesz - phdr], PHENTSIZE ;
  add       dword [rdi + phdr.memsz - phdr], PHENTSIZE  ;
  mov       edx, dword [phdr_flags]                     ;
  mov       dword [phdr.flags], edx                     ;
  inc       word [ehdr.phnum]                           ;
  add       dword [ehdr.entry], PHENTSIZE               ;
  mov       byte [phdr_flags], R + X                    ;
  test      rbx, PHFIRST_BIT                            ;
  jz        .write_phdr                                 ;
  add       r15d, EHSIZE + PHENTSIZE                    ;
  xor       rbx, PHFIRST_BIT                            ;
  jmp       .skip_write                                 ;

.handle_data:
  inc       qword [style_points]                        ;
  mov       rdi, qword [phdrbuf_ptr]                    ;
  add       dword [rdi + phdr.filesz - phdr], PHENTSIZE ;
  add       dword [rdi + phdr.memsz - phdr], PHENTSIZE  ;
  mov       edx, dword [phdr_flags]                     ;
  mov       dword [phdr.flags], edx                     ;
  inc       word [ehdr.phnum]                           ;
  add       dword [ehdr.entry], PHENTSIZE               ;
  mov       byte [phdr_flags], R + W                    ;
  test      rbx, PHFIRST_BIT                            ;
  jz        .write_phdr                                 ;
  add       r15d, EHSIZE + PHENTSIZE                    ;
  xor       rbx, PHFIRST_BIT                            ;
  jmp       .skip_write                                 ;

.handle_rodata:
  inc       qword [style_points]                        ;
  mov       rdi, qword [phdrbuf_ptr]                    ;
  add       dword [rdi + phdr.filesz - phdr], PHENTSIZE ;
  add       dword [rdi + phdr.memsz - phdr], PHENTSIZE  ;
  mov       edx, dword [phdr_flags]                     ;
  mov       dword [phdr.flags], edx                     ;
  inc       word [ehdr.phnum]                           ;
  add       dword [ehdr.entry], PHENTSIZE               ;
  mov       byte [phdr_flags], R                        ;
  test      rbx, PHFIRST_BIT                            ;
  jz        .write_phdr                                 ;
  add       r15d, EHSIZE + PHENTSIZE                    ;
  xor       rbx, PHFIRST_BIT                            ;
  jmp       .skip_write                                 ;

.handle_entry:
  test      rbx, DIR_BIT                              ;
  jz        invalid_expression_err                    ;
  xor       rbx, DIR_BIT                              ;
  add       qword [style_points], 2                   ; custom entries are very stylish
  mov       ax, word [r12 + 2]                        ;
  xchg      ah, al                                    ;
  cmp       ax, C_ADR                                 ;
  je        .valid_entry                              ;
  cmp       ax, C_NUM                                 ;
  jne       invalid_operands_err                      ;
.valid_entry:
  or        rbx, IMM32_BIT + ENTRY_BIT                ;
  lea       r12, [r12 + 2]                            ;
  jmp       parse_ir                                  ;

.write_phdr:
  cmp       rbp, r11                                  ;
  jl        .skip_expand                              ;
  sub       r11, qword [phdrbuf_ptr]                  ;
  push      r11                                       ; expand phdr buffer if it needs more space
  push      r11                                       ;
  SYSCALL_1 SYS_BRK, 0                                ;
  pop       r11                                       ;
  lea       rdx, [rax + r11]                          ;
  SYSCALL_1 SYS_BRK, rdx                              ;
  pop       r11                                       ;
  lea       r11, [r11 * 2]                            ; expand by x2 more next time
  add       r11, qword [phdrbuf_ptr]                  ;
.skip_expand:
  mov       edx, dword [phdr.filesz]                  ;
  add       dword [phdr.offset], edx                  ;
  cmp       qword [phdrbuf_ptr], rbp                  ;
  je        .first_segment                            ;
  sub       r15d, PHENTSIZE                           ;
.first_segment:
  mov       dword [phdr.filesz], r15d                 ;
  mov       dword [phdr.memsz], r15d                  ;
  mov       rcx, qword [phdrbuf_ptr]                  ;
  add       rcx, PHENTSIZE                            ;
  cmp       rbp, rcx                                  ;
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

pref_group:
  test      rbx, INSTR_BIT                            ;
  jz        invalid_expression_err                    ;
  inc       qword [style_points]                      ; prefixes are cool
  mov       al, byte [r12 + 1]                        ;
  mov       byte [r14], al                            ;
  inc       r14                                       ;
  inc       r15d                                      ;
  add       dword [current_ptr], 1                    ;
  lea       r12, [r12 + 2]                            ;
  jmp       parse_ir                                  ;

modrm_mode:
  mov       qword [group_jmp_tbl + G_REG32 * 8], ctrl_group.handle_mod_reg     ; modrm mode for ModR/M bytes
  mov       qword [group_jmp_tbl + G_REG16 * 8], ctrl_group.handle_mod_reg     ;
  mov       qword [group_jmp_tbl + G_REG8 * 8], ctrl_group.handle_mod_reg      ;
  mov       qword [group_jmp_tbl + G_SREG * 8], ctrl_group.handle_mod_reg      ;
  mov       qword [group_jmp_tbl + G_CREG * 8], ctrl_group.handle_mod_reg      ;
  mov       qword [group_jmp_tbl + G_DREG * 8], ctrl_group.handle_mod_reg      ;
  mov       qword [ctrl_jmp_tbl + C_COM * 8], ctrl_group.handle_comma          ;
  ret                                                                          ;

sib_mode:
  mov       qword [ctrl_jmp_tbl + C_MEMST * 8], ctrl_group.handle_memstart     ; sib mode for SIB bytes
  mov       qword [ctrl_jmp_tbl + C_MEMEN * 8], ctrl_group.handle_memend       ;
  mov       qword [group_jmp_tbl + G_REG32 * 8], ctrl_group.handle_sib_reg     ;
  mov       qword [group_jmp_tbl + G_REG16 * 8], invalid_expression_err        ;
  mov       qword [group_jmp_tbl + G_REG8 * 8], invalid_expression_err         ;
  mov       qword [group_jmp_tbl + G_SREG * 8], invalid_expression_err         ;
  mov       qword [group_jmp_tbl + G_CREG * 8], invalid_expression_err         ;
  mov       qword [group_jmp_tbl + G_DREG * 8], invalid_expression_err         ;
  mov       qword [group_jmp_tbl + G_SPREF * 8], ctrl_group.handle_segpref     ;
  mov       qword [ctrl_jmp_tbl + C_NUM * 8], ctrl_group.handle_sib_num        ;
  mov       qword [ctrl_jmp_tbl + C_ADR * 8], ctrl_group.handle_sib_address    ;
  mov       qword [ctrl_jmp_tbl + C_STR * 8], ctrl_group.handle_sib_str        ;
  mov       qword [ctrl_jmp_tbl + C_COM * 8], invalid_expression_err           ;
  mov       qword [ctrl_jmp_tbl + C_LF  * 8], invalid_expression_err           ;
  mov       qword [ctrl_jmp_tbl + C_PLUS * 8], ctrl_group.handle_plus          ;
  mov       qword [ctrl_jmp_tbl + C_MINUS * 8], ctrl_group.handle_minus        ;
  mov       qword [ctrl_jmp_tbl + C_MULT * 8], ctrl_group.handle_mul           ;
  ret                                                                          ;

operand_mode:
  mov       qword [group_jmp_tbl + G_REG32 * 8], skip_ir                       ;
  mov       qword [group_jmp_tbl + G_REG16 * 8], skip_ir                       ;
  mov       qword [group_jmp_tbl + G_REG8 * 8], skip_ir                        ;
  mov       qword [group_jmp_tbl + G_SREG * 8], skip_ir                        ;
  mov       qword [group_jmp_tbl + G_CREG * 8], skip_ir                        ;
  mov       qword [group_jmp_tbl + G_DREG * 8], skip_ir                        ;
  mov       qword [ctrl_jmp_tbl + C_COM * 8], ctrl_group.handle_comma          ;
  ret                                                                          ;

normal_mode:
  mov       qword [ctrl_jmp_tbl + C_MEMST * 8], invalid_expression_err         ; restore labels after custom modes
  mov       qword [ctrl_jmp_tbl + C_MEMEN * 8], invalid_expression_err         ;
  mov       qword [group_jmp_tbl + G_REG32 * 8], invalid_expression_err        ;
  mov       qword [group_jmp_tbl + G_REG16 * 8], invalid_expression_err        ;
  mov       qword [group_jmp_tbl + G_REG8 * 8], invalid_expression_err         ;
  mov       qword [group_jmp_tbl + G_SREG * 8], invalid_expression_err         ;
  mov       qword [group_jmp_tbl + G_CREG * 8], invalid_expression_err         ;
  mov       qword [group_jmp_tbl + G_DREG * 8], invalid_expression_err         ;
  mov       qword [group_jmp_tbl + G_SPREF * 8], invalid_expression_err        ;
  mov       qword [ctrl_jmp_tbl + C_NUM * 8], ctrl_group.handle_num            ;
  mov       qword [ctrl_jmp_tbl + C_ADR * 8], ctrl_group.handle_address        ;
  mov       qword [ctrl_jmp_tbl + C_STR * 8], ctrl_group.handle_str            ;
  mov       qword [ctrl_jmp_tbl + C_COM * 8], invalid_expression_err           ;
  mov       qword [ctrl_jmp_tbl + C_LF  * 8], ctrl_group.handle_lf             ;
  mov       qword [ctrl_jmp_tbl + C_PLUS * 8], invalid_expression_err          ;
  mov       qword [ctrl_jmp_tbl + C_MINUS * 8], invalid_expression_err         ;
  mov       qword [ctrl_jmp_tbl + C_MULT * 8], invalid_expression_err          ;
  ret                                                                          ;

parser_end = $
