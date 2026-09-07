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

lexer:
  mov       rax, delimiter_tbl             ; init the delimiter table
  mov       byte [rax + TAB], IGN_DEL      ;
  mov       byte [rax + SPC], IGN_DEL      ;
  mov       byte [rax + ';'], CMT_DEL      ;
  mov       byte [rax + '#'], LBL_DEL      ;
  mov       byte [rax + '0'], NUM_DEL      ;
  mov       byte [rax + '1'], NUM_DEL      ;
  mov       byte [rax + '2'], NUM_DEL      ;
  mov       byte [rax + '3'], NUM_DEL      ;
  mov       byte [rax + '4'], NUM_DEL      ;
  mov       byte [rax + '5'], NUM_DEL      ;
  mov       byte [rax + '6'], NUM_DEL      ;
  mov       byte [rax + '7'], NUM_DEL      ;
  mov       byte [rax + '8'], NUM_DEL      ;
  mov       byte [rax + '9'], NUM_DEL      ;
  mov       byte [rax + '"'], STR_DEL      ;
  mov       byte [rax + "'"], STR_DEL      ;
  mov       byte [rax + '['], LBR_DEL      ;
  mov       byte [rax + ']'], RBR_DEL      ;
  mov       byte [rax + '+'], PLS_DEL      ;
  mov       byte [rax + '-'], MIN_DEL      ;
  mov       byte [rax + '*'], MUL_DEL      ;
  mov       byte [rax + ','], COM_DEL      ;
  mov       byte [rax + LF ], LF_DEL       ;
  mov       byte [rax + '@'], ADR_DEL      ;

  mov       rax, lex_trie_tbl                                        ; init the trie table
  mov       word [rax + 'e' * 2], lex_trie.e_node - lex_trie         ;
  mov       word [rax + 'm' * 2], lex_trie.m_node - lex_trie         ;
  mov       word [rax + 'b' * 2], lex_trie.b_node - lex_trie         ;
  mov       word [rax + 'w' * 2], lex_trie.w_node - lex_trie         ;
  mov       word [rax + 'd' * 2], lex_trie.d_node - lex_trie         ;
  mov       word [rax + 'p' * 2], lex_trie.p_node - lex_trie         ;
  mov       word [rax + 'c' * 2], lex_trie.c_node - lex_trie         ;
  mov       word [rax + 'j' * 2], lex_trie.j_node - lex_trie         ;
  mov       word [rax + 't' * 2], lex_trie.t_node - lex_trie         ;
  mov       word [rax + 'o' * 2], lex_trie.o_node - lex_trie         ;
  mov       word [rax + 'a' * 2], lex_trie.a_node - lex_trie         ;
  mov       word [rax + 'x' * 2], lex_trie.x_node - lex_trie         ;
  mov       word [rax + 'n' * 2], lex_trie.n_node - lex_trie         ;
  mov       word [rax + 'i' * 2], lex_trie.i_node - lex_trie         ;
  mov       word [rax + 's' * 2], lex_trie.s_node - lex_trie         ;
  mov       word [rax + 'l' * 2], lex_trie.l_node - lex_trie         ;
  mov       word [rax + 'r' * 2], lex_trie.r_node - lex_trie         ;
  mov       word [rax + 'u' * 2], lex_trie.u_node - lex_trie         ;
  mov       word [rax + 'f' * 2], lex_trie.f_node - lex_trie         ;
  mov       word [rax + 'g' * 2], lex_trie.g_node - lex_trie         ;
  mov       word [rax + 'v' * 2], lex_trie.v_node - lex_trie         ;
  mov       word [rax + 'h' * 2], lex_trie.h_node - lex_trie         ;
  mov       word [rax + 'q' * 2], lex_trie.q_node - lex_trie         ;
  mov       word [rax + '.' * 2], lex_trie.sec_node - lex_trie       ;

  mov       rax, valid_char_tbl          ; init the table of valid characters
  mov       byte [rax + NUL], VALID      ;
  mov       byte [rax + TAB], VALID      ;
  mov       byte [rax + LF ], VALID      ;
  mov       byte [rax + SPC], VALID      ;
  mov       byte [rax + ','], VALID      ;
  mov       byte [rax + '+'], VALID      ;
  mov       byte [rax + '-'], VALID      ;
  mov       byte [rax + '*'], VALID      ;
  mov       byte [rax + ';'], VALID      ;
  mov       byte [rax + '['], VALID      ;
  mov       byte [rax + ']'], VALID      ;

  mov       r13, LEX_IRBUF_SIZE          ; init pointers
  lea       rbp, [r14 + r13 - 1]         ;
  mov       r15, lex_trie                ;

next_lex:
  movzx     rax, byte [r12]                    ;
  test      al, al                             ;
  jz        handle_eof                         ;
  cmp       byte [delimiter_tbl + rax], DELIM  ; handle delimiter
  jae       handle_del                         ;
  movzx     rdx, word [lex_trie_tbl + rax * 2] ;
  test      dx, dx                             ; error if the node is unknown
  jz        unk_tkn_err                        ;
  lea       r15, [lex_trie + rdx]              ;

traverse:
  cmp       al, byte [r15]                    ;
  je        .char_matches                     ; jump to the handler if char matches
  mov       dx, word [r15 + LEX_SIBOFF_OFF]   ;
  test      dx, dx                            ; error if the node has no siblings
  jz        unk_tkn_err                       ;
  lea       r15, [r15 + rdx * 8]              ; else, go to the sibling node
  jmp       traverse                          ;
.char_matches:
  test      byte [r15 + LEX_FLAGS_OFF], TERM  ; maybe write IR if the node is terminal
  jnz       terminal                          ;
  inc       r12                               ;
  movzx     rax, byte [r12]                   ;
  mov       dx, word [r15 + LEX_CHDOFF_OFF]   ; go to the child node
  test      dx, dx                            ; error if the node has no children
  jz        unk_tkn_err                       ;
  lea       r15, [r15 + rdx * 8]              ;
  jmp       traverse                          ;

terminal:
  inc       r12                                ;
  movzx     rax, byte [r12]                    ;
  cmp       word [r15 + LEX_CHDOFF_OFF], 0     ; write IR if the node has no children
  je        write_ir                           ;
  cmp       byte [valid_char_tbl + rax], VALID ;
  je        write_ir                           ;
  mov       r8, r15                            ;
  movzx     rdx, byte [r15 + LEX_CHDOFF_OFF]   ;
  lea       r15, [r15 + rdx * 8]               ; go to the child node
  jmp       chd_traverse                       ; traverse children of the terminal node

chd_traverse:
  cmp       al, byte [r15]                    ; continue the traverse if char matches
  je        .chd_char_matches                 ;
  mov       dx, word [r15 + LEX_SIBOFF_OFF]   ; error if there's no siblings and next char isn't valid
  test      dx, dx                            ;
  jz        .chd_no_siblings                  ;
  lea       r15, [r15 + rdx * 8]              ; else, go to the sibling node
  jmp       chd_traverse                      ;
.chd_char_matches:
  test      byte [r15 + LEX_FLAGS_OFF], TERM   ; write IR if the node is terminal
  jnz       terminal                           ;
  inc       r12                                ;
  mov       al, byte [r12]                     ;
  cmp       byte [valid_char_tbl + rax], VALID ;
  je        unk_tkn_err                        ;
  mov       dx, word [r15 + LEX_CHDOFF_OFF]    ; go to the child node
  test      dx, dx                             ; error if the node has no children
  jz        unk_tkn_err                        ;
  lea       r15, [r15 + rdx * 8]               ;
  jmp       chd_traverse                       ;
.chd_no_siblings:
  cmp       byte [valid_char_tbl + rax], VALID ; jump to the parent node if next char isn't letter
  je        .to_parent                         ;
  jmp       unk_tkn_err                        ; else, error
.to_parent:
  mov       r15, r8                           ; restore parental position and write IR

write_ir:
  cmp       byte [r12 - 1], ':'               ; don't exit with error if it's a segment prefix
  je        .skip_check                       ;
  movzx     rsi, byte [valid_char_tbl + rax]  ;
  test      si, si                            ; error if character after lexeme is letter, number or string
  jz        unk_tkn_err                       ;
.skip_check:
  cmp       r14, rbp                          ; expand IR buffer if it needs more space
  jb        .skip_call                        ;
  call      exp_ir_buf                        ;
.skip_call:
  test      byte [r15 + LEX_FLAGS_OFF], PHDR  ;
  jz        .not_segment                      ;
  inc       dword [ehdr.phnum]                ;
  cmp       byte [do_gen_elf], 0              ;
  je        .not_segment                      ;
  cmp       byte [do_gen_64], 1               ;
  je        .seg64                            ;
  add       qword [current_ptr], PHENTSIZE    ;
  jmp       .not_segment                      ;
.seg64:
  add       qword [current_ptr], PHENTSIZE64  ;
.not_segment:
  test      byte [r15 + LEX_FLAGS_OFF], AMD64 ;
  jz        .not_64bit                        ;
  cmp       byte [do_gen_64], 0               ;
  je        unk_tkn_err                       ;
.not_64bit:
  mov       si, word [r15 + LEX_IR_OFF]       ; write IR to the IR buffer
  mov       word [r14], si                    ;
  lea       r14, [r14 + 2]                    ;
  jmp       next_lex                          ;

handle_del:
  movzx     rsi, byte [delimiter_tbl + rax]   ;
  jmp       qword [del_jmp_tbl + rsi * 8 - 8] ;

.ignore_del:
  inc       r12                               ;
  movzx     rax, byte [r12]                   ;
  jmp       next_lex                          ;

.comment_del:
  inc       r12                               ;
  cmp       byte [r12], LF                    ;
  jne       .comment_del                      ;
  movzx     rax, byte [r12]                   ;
  jmp       next_lex                          ;

.label_del:
  mov       si, C_LBL                         ;
  jmp       write_label                       ;

.number_del:
  xor       rdi, rdi                          ;
  jmp       write_number                      ;

.string_del:
  mov       rsi, rax                          ;
  jmp       write_string                      ;

.address_del:
  mov       si, C_ADR                         ;
  jmp       write_label                       ;

.lbracket_del:
  mov       si, C_MEMST                       ;
  jmp       write_del                         ;

.rbracket_del:
  mov       si, C_MEMEN                       ;
  jmp       write_del                         ;

.plus_del:
  mov       si, C_PLUS                        ;
  jmp       write_del                         ;

.minus_del:
  mov       si, C_MINUS                       ;
  jmp       write_del                         ;

.multiply_del:
  mov       si, C_MULT                        ;
  jmp       write_del                         ;

.comma_del:
  mov       si, C_COM                         ;
  jmp       write_del                         ;

.newline_del:
  inc       qword [current_line]              ;
  mov       si, C_LF                          ;
  jmp       write_del                         ;

write_del:
  cmp       r14, rbp                 ; expand IR buffer if it needs more space
  jb        .skip_call               ;
  call      exp_ir_buf               ;
.skip_call:
  mov       byte [r14 + 1], sil      ;
  lea       r14, [r14 + 2]           ;
  inc       r12                      ;
  movzx     rax, byte [r12]          ;
  jmp       next_lex                 ;

write_label:
  cmp       r14, rbp                         ; expand IR buffer if it needs more space
  jb        .skip_call                       ;
  call      exp_ir_buf                       ;
.skip_call:
  mov       byte [r14 + 1], sil                ; set address/label delimiter start IR
  lea       r14, [r14 + 2]                     ;
  movzx     rax, byte [r12 + 1]                ;
  cmp       byte [valid_char_tbl + rax], VALID ;
  je        invalid_name_err                   ;
.write_insides:
  cmp       r14, rbp                         ;
  jb        .skip_call2                      ;
  call      exp_ir_buf                       ;
.skip_call2:
  inc       r12                                ;
  movzx     rax, byte [r12]                    ;
  cmp       byte [valid_char_tbl + rax], VALID ;
  je        .end_write                         ;
  mov       byte [r14], al                     ; write name in IR buffer
  inc       r14                                ;
  jmp       .write_insides                     ;
.end_write:
  cmp       r14, rbp                         ; expand IR buffer if it needs more space
  jb        .skip_call3                      ;
  call      exp_ir_buf                       ;
.skip_call3:
  mov       byte [r14 + 1], sil                ; set long delimiter end IR
  lea       r14, [r14 + 2]                     ;
  movzx     rax, byte [r12]                    ;
  cmp       byte [valid_char_tbl + rax], VALID ;
  jne       unk_tkn_err                        ;
  jmp       next_lex                           ;

write_string:
  cmp       r14, rbp                         ; expand IR buffer if it needs more space
  jb        .skip_call                       ;
  call      exp_ir_buf                       ;
.skip_call:
  mov       byte [r14 + 1], C_STR            ; set string start IR
  lea       r14, [r14 + 2]                   ;
  mov       r8, qword [current_line]         ;
.write_insides:
  inc       r12                              ; write characters inside of string
  movzx     rax, byte [r12]                  ;
  cmp       al, LF                           ;
  jne       .not_lf                          ;
  inc       qword [current_line]             ;
.not_lf:
  cmp       r14, rbp                         ;
  jb        .skip_call2                      ;
  push      rax                              ;
  call      exp_ir_buf                       ;
  pop       rax                              ;
.skip_call2:
  cmp       rax, rsi                         ; end if found " or '
  je        write_strend_ir                  ;
  cmp       rax, NUL                         ;
  je        .invalid_char                    ;
  mov       byte [r14], al                   ;
  inc       r14                              ;
  jmp       .write_insides                   ;
.invalid_char:
  mov       qword [current_line], r8         ;
  jmp       invalid_char_err                 ;
write_strend_ir:
  cmp       r14, rbp                         ;
  jb        .skip_call                       ;
  call      exp_ir_buf                       ;
.skip_call:
  mov       byte [r14 + 1], C_STR              ; set string end IR
  lea       r14, [r14 + 2]                     ;
  inc       r12                                ;
  movzx     rax, byte [r12]                    ;
  cmp       byte [valid_char_tbl + rax], VALID ;
  jne       unk_tkn_err                        ;
  jmp       next_lex                           ;

write_number:
  cmp       r14, rbp                         ; expand IR buffer if it needs more space
  jb        .skip_call                       ;
  call      exp_ir_buf                       ;
.skip_call:
  mov       byte [r14 + 1], C_NUM            ; set number start IR
  lea       r14, [r14 + 2]                   ;
  xor       rdi, rdi                         ; rdi - converted number buffer
  movzx     rsi, byte [r12]                  ;
.convert_num:
  lea       rsi, [rsi - '0']                    ; convert character to number
  cmp       sil, 10                             ; error if it is not number character
  jae       unk_tkn_err                         ;
  lea       rdi, [rdi + rdi * 4]                ;
  shl       rdi, 1                              ;
  jc        long_num_err                        ;
  lea       rdi, [rdi + rsi]                    ; error if number is longer than 4 bytes
  inc       r12                                 ;
  movzx     rsi, byte [r12]                     ;
  cmp       byte [delimiter_tbl + rsi], NUM_DEL ; stop converting if found not-number character
  je        .convert_num                        ;
  mov       rsi, rdi                            ;
  shr       rdi, 32                             ;
  test      rdi, rdi                            ;
  jnz       long_num_err                        ;
  mov       rdi, 4                              ;
.write_insides:
  cmp       r14, rbp                         ;
  jb        .skip_call2                      ;
  push      rdi                              ;
  call      exp_ir_buf                       ;
  pop       rdi                              ;
.skip_call2:
  test      rsi, rsi                         ; write converted number
  jz        end_num_write                    ;
  mov       byte [r14], sil                  ;
  inc       r14                              ;
  dec       rdi                              ;
  shr       rsi, 8                           ;
  jmp       .write_insides                   ;
end_num_write:
  lea       r14, [r14 + rdi]                   ; make the number 4 bytes long
  movzx     rax, byte [r12]                    ;
  cmp       byte [valid_char_tbl + rax], VALID ;
  jne       unk_tkn_err                        ;
  jmp       next_lex                           ;

exp_ir_buf:
  push      rsi                              ;
  SYSCALL_1 SYS_BRK, 0                       ; get current heap pointer
  lea       rsi, [rax + r13]                 ;
  SYSCALL_1 SYS_BRK, rsi                     ; allocate memory
  mov       rsi, qword [lex_irbuf_ptr]       ;
  lea       r13, [r13 * 2]                   ; it will allocate x2 more memory next time
  lea       rbp, [rsi + r13 - 1]             ;
  pop       rsi                              ;
  ret                                        ;

handle_eof:
  mov       ax, word [r14 - 2]                            ; wrap the eof with newline char
  xchg      ah, al                                        ;
  cmp       ax, C_LF                                      ;
  je        .dont_write_lf                                ;
  cmp       r14, rbp                                      ;
  jb        .skip_call                                    ;
  call      exp_ir_buf                                    ;
.skip_call:
  mov       byte [r14 + 1], C_LF                          ;
  lea       r14, [r14 + 2]                                ;
.dont_write_lf:
  lea       rbp, [r14 + 2]                                ; rbp - pointer to the phdr buffer
  xor       rax, rax                                      ; r14 - pointer to the parser IR buffer
  cmp       byte [do_gen_64], 1                           ;
  je        .calc_phbuf64_sz                              ;
  imul      eax, dword [ehdr.phnum], PHENTSIZE            ;
  add       rax, EHSIZE                                   ;
  jmp       .end_calc                                     ;
.calc_phbuf64_sz:
  imul      eax, dword [ehdr.phnum], PHENTSIZE64          ;
  add       rax, EHSIZE64                                 ;
.end_calc:
  mov       dword [ehdr.phnum], 0                         ;
  push      rax                                           ;
  SYSCALL_1 SYS_BRK, 0
  lea       rsi, [rax + r13 * 8]                          ; allocate memory for the buffers
  mov       qword [heap_ptr], rsi                         ;
  SYSCALL_1 SYS_BRK, rsi                                  ;
  pop       rax                                           ;
  lea       r14, [rbp + r13 * 4 + 3]                      ;
  lea       r14, [r14 + r13 * 2]                          ;
  mov       qword [phdrbuf_ptr], rbp                      ; save buffer pointers
  lea       rax, [rbp + rax + 1]                          ;
  mov       qword [labelbuf_ptr], rax                     ;
  lea       rax, [rax + r13 * 2 + 1]                      ;
  add       rax, r13                                      ;
  mov       qword [deladrbuf_ptr], rax                    ;

lexer_end = $
