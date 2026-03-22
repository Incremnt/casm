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
; File:      lexer.asm           ;
; FIle type: Part                ; 
; Author:    Incremnt            ;
; License:   GPLv3               ;
;================================;

lexer:
  mov       rbp, delimiter_tbl             ; init delimiter table
  mov       byte [rbp + TAB], IGN_DEL      ;
  mov       byte [rbp + SPC], IGN_DEL      ; 
  mov       byte [rbp + ';'], CMT_DEL      ;
  mov       byte [rbp + '#'], LBL_DEL      ;
  mov       byte [rbp + '0'], NUM_DEL      ;
  mov       byte [rbp + '1'], NUM_DEL      ;
  mov       byte [rbp + '2'], NUM_DEL      ;
  mov       byte [rbp + '3'], NUM_DEL      ;
  mov       byte [rbp + '4'], NUM_DEL      ;
  mov       byte [rbp + '5'], NUM_DEL      ;
  mov       byte [rbp + '6'], NUM_DEL      ;
  mov       byte [rbp + '7'], NUM_DEL      ;
  mov       byte [rbp + '8'], NUM_DEL      ;
  mov       byte [rbp + '9'], NUM_DEL      ;
  mov       byte [rbp + '"'], STR_DEL      ;
  mov       byte [rbp + "'"], STR_DEL      ;
  mov       byte [rbp + '['], BRT_DEL      ;
  mov       byte [rbp + ']'], BRT_DEL      ;
  mov       byte [rbp + '+'], PLS_DEL      ;
  mov       byte [rbp + '-'], MIN_DEL      ;
  mov       byte [rbp + '*'], MUL_DEL      ;
  mov       byte [rbp + ','], COM_DEL      ;
  mov       byte [rbp + LF ], LF_DEL       ;
  mov       byte [rbp + '@'], ADR_DEL      ;

  mov       rbx, lex_trie_tbl                                        ; init trie table
  mov       word [rbx + 'e' * 2], lex_trie.e_node - lex_trie         ;
  mov       word [rbx + 'm' * 2], lex_trie.m_node - lex_trie         ;
  mov       word [rbx + 'b' * 2], lex_trie.b_node - lex_trie         ;
  mov       word [rbx + 'w' * 2], lex_trie.w_node - lex_trie         ;
  mov       word [rbx + 'd' * 2], lex_trie.d_node - lex_trie         ;
  mov       word [rbx + 'p' * 2], lex_trie.p_node - lex_trie         ;
  mov       word [rbx + 'c' * 2], lex_trie.c_node - lex_trie         ;
  mov       word [rbx + 'j' * 2], lex_trie.j_node - lex_trie         ;
  mov       word [rbx + 't' * 2], lex_trie.t_node - lex_trie         ;
  mov       word [rbx + 'o' * 2], lex_trie.o_node - lex_trie         ;
  mov       word [rbx + 'a' * 2], lex_trie.a_node - lex_trie         ;
  mov       word [rbx + 'x' * 2], lex_trie.x_node - lex_trie         ;
  mov       word [rbx + 'n' * 2], lex_trie.n_node - lex_trie         ;
  mov       word [rbx + 'i' * 2], lex_trie.i_node - lex_trie         ;
  mov       word [rbx + 's' * 2], lex_trie.s_node - lex_trie         ;
  mov       word [rbx + '.' * 2], lex_trie.sec_node - lex_trie       ;

  mov       rcx, valid_char_tbl          ; init valid characters table
  mov       byte [rcx + NUL], VALID      ;
  mov       byte [rcx + TAB], VALID      ;
  mov       byte [rcx + LF ], VALID      ;
  mov       byte [rcx + SPC], VALID      ;
  mov       byte [rcx + ','], VALID      ;
  mov       byte [rcx + '+'], VALID      ;
  mov       byte [rcx + '-'], VALID      ;
  mov       byte [rcx + '*'], VALID      ;
  mov       byte [rcx + ';'], VALID      ;
  mov       byte [rcx + '['], VALID      ;
  mov       byte [rcx + ']'], VALID      ;

  lea       r13, [LEX_IR_BUF_SZ * 2]     ; init pointers
  lea       r9, [r14 + r13 - 1]          ;
  mov       r15, lex_trie                ;

  movzx     rax, byte [r12]
next_lex:
  test      al, al                            ; handle eof
  jz        handle_eof                        ;
  cmp       byte [rbp + rax], DELIM           ; other logic if char is delimiter
  jge       handle_del                        ; 
  movzx     rdx, word [rbx + rax * 2]         ; trie node index in rdx
  test      dx, dx                            ; error if node is unknown
  jz        unk_tkn_err                       ;
  lea       r15, [lex_trie + rdx]             ; trie node pointer in r15 

traverse:
  cmp       al, byte [r15]                    ; compare lexeme char with trie node char
  je        .char_matches                     ; jump to handler if char matches
  mov       dx, word [r15 + LEX_SIBOFF_OFF]   ;
  test      dx, dx                            ; error if no siblings
  jz        unk_tkn_err                       ;
  lea       r15, [r15 + rdx * 8]              ; else, go to the sibling node
  jmp       traverse                          ; 
.char_matches:
  cmp       byte [r15 + LEX_TERM_OFF], TERM   ; potentially write IR if node is terminal
  je        terminal                          ;
  inc       r12                               ;
  movzx     rax, byte [r12]                   ; next lexeme char in rax
  mov       dx, word [r15 + LEX_CHDOFF_OFF]   ; go to the child node
  test      dx, dx                            ; error if node has no children
  jz        unk_tkn_err                       ;
  lea       r15, [r15 + rdx * 8]              ;
  jmp       traverse                          ;

terminal:
  inc       r12                               ; next lexeme character in al
  mov       al, byte [r12]                    ;
  cmp       word [r15 + LEX_CHDOFF_OFF], 0    ; write IR if node doesn't have children
  je        write_ir                          ;
  push      r15                               ; else, save current position in stack
  movzx     rdx, byte [r15 + LEX_CHDOFF_OFF]  ;
  lea       r15, [r15 + rdx * 8]              ; go to the child node
  jmp       chd_traverse                      ; traverse children of terminal node
  
chd_traverse:
  cmp       al, byte [r15]                    ; continue traverse if char matches
  je        .chd_char_matches                 ;
  mov       dx, word [r15 + LEX_SIBOFF_OFF]   ; error if there's no siblings and next char isn't valid
  test      dx, dx                            ;
  jz        .chd_no_siblings                  ;
  lea       r15, [r15 + rdx * 8]              ; else, go to the sibling node
  jmp       chd_traverse                      ;
.chd_char_matches:
  cmp       byte [r15 + LEX_TERM_OFF], TERM   ; write IR if node is terminal
  je        terminal                          ;
  inc       r12                               ; next lexeme character in al
  mov       al, byte [r12]                    ;
  mov       dx, word [r15 + LEX_CHDOFF_OFF]   ; go to the child node
  test      dx, dx                            ; error if node has no children
  jz        unk_tkn_err                       ;
  lea       r15, [r15 + rdx * 8]              ;
  jmp       chd_traverse                      ;
.chd_no_siblings:
  cmp       byte [rcx + rax], VALID           ; jump to the parent node if next char isn't letter
  je        .to_parent                        ;
  jmp       unk_tkn_err                       ; else, error
.to_parent:
  pop       r15                               ; restore parental position and write IR

write_ir:
  movzx     rsi, byte [rcx + rax]             ;
  test      si, si                            ; error if character after lexeme is letter, number or string
  jz        unk_tkn_err                       ;
  cmp       r14, r9                           ; expand IR buffer if it needs more space
  jl        .skip_call                        ;
  call      exp_ir_buf                        ;
.skip_call:
  mov       si, word [r15 + LEX_IR_OFF]       ; write IR to the IR buffer
  mov       word [r14], si                    ;
  lea       r14, [r14 + 2]                    ;
  jmp       next_lex                          ;

handle_del:
  movzx     rsi, byte [rbp + rax]
  jmp       qword [del_jmp_tbl + rsi * 8 - 8]

.ignore_del:
  inc       r12
  movzx     rax, byte [r12]
  jmp       next_lex

.comment_del:
  inc       r12
  cmp       byte [r12], LF
  jne       .comment_del
  movzx     rax, byte [r12]
  jmp       next_lex

.label_del:
  mov       si, C_LBL
  inc       r12
  jmp       write_long_del

.number_del:
  xor       rdi, rdi
  jmp       write_number

.string_del:
  mov       rsi, rax
  jmp       write_string

.address_del:
  mov       si, C_ADR
  inc       r12
  jmp       write_long_del

.bracket_del:
  mov       si, C_MEM
  jmp       write_del

.plus_del:
  mov       si, C_PLS
  jmp       write_del

.minus_del:
  mov       si, C_MIN
  jmp       write_del

.multiply_del:
  mov       si, C_MUL
  jmp       write_del

.comma_del:
  mov       si, C_COM
  jmp       write_del

.newline_del:
  mov       si, C_LF
  jmp       write_del

write_del:
  cmp       r14, r9                  ; expand IR buffer if it needs more space
  jl        .skip_call               ;
  call      exp_ir_buf               ;
.skip_call:
  mov       byte [r14 + 1], sil      ;
  lea       r14, [r14 + 2]           ;
  inc       r12                      ;
  movzx     rax, byte [r12]          ;
  jmp       next_lex                 ;
 
write_long_del:
  cmp       r14, r9                          ; expand IR buffer if it needs more space
  jl        .skip_call                       ;
  call      exp_ir_buf                       ;
.skip_call:
  mov       byte [r14 + 1], sil              ; set long delimiter start IR
  lea       r14, [r14 + 2]                   ;
  movzx     rax, byte [r12]                  ;
.write_insides:
  cmp       r14, r9                          ;
  jl        .skip_call2                      ;
  push      rax                              ;
  call      exp_ir_buf                       ;
  pop       rax                              ;
.skip_call2:
  cmp       al, SPC                          ; error if name contains non-letter characters
  jl        invalid_char_err                 ;
  mov       byte [r14], al                   ; write name in IR buffer
  inc       r14                              ;
  inc       r12                              ;
  movzx     rax, byte [r12]                  ;
  cmp       byte [rbp + rax], DELIM          ; end write loop if found delimiter
  jl        .write_insides                   ;
  cmp       r14, r9                          ; expand IR buffer if it needs more space
  jl        .skip_call3                      ;
  call      exp_ir_buf                       ;
.skip_call3:
  mov       byte [r14 + 1], sil              ; set long delimiter end IR
  lea       r14, [r14 + 2]                   ;
  movzx     rax, byte [r12]                  ;
  jmp       next_lex                         ;
 
write_string:
  cmp       r14, r9                          ; expand IR buffer if it needs more space, blah, blah, blah...
  jl        .skip_call                       ;
  call      exp_ir_buf                       ;
.skip_call:
  mov       byte [r14 + 1], C_STR            ; set string start IR
  lea       r14, [r14 + 2]                   ;
.write_insides:
  inc       r12                              ; write characters inside of string
  movzx     rax, byte [r12]                  ;
  cmp       al, SPC                          ;
  jl        invalid_char_err                 ;
  cmp       r14, r9                          ;
  jl        .skip_call2                      ;
  push      rax                              ;
  call      exp_ir_buf                       ;
  pop       rax                              ;
.skip_call2:
  cmp       rax, rsi                         ; end if found " or '
  je        write_strend_ir                  ;
  mov       byte [r14], al                   ;
  inc       r14                              ;
  jmp       .write_insides                   ;
write_strend_ir:
  cmp       r14, r9                          ;
  jl        .skip_call                       ;
  call      exp_ir_buf                       ;
.skip_call:
  mov       byte [r14 + 1], C_STR            ; set string end IR
  lea       r14, [r14 + 2]                   ;
  inc       r12                              ;
  movzx     rax, byte [r12]                  ;
  jmp       next_lex                         ;

write_number:
  cmp       r14, r9                          ; expand... IR... buffer if it needs more space...
  jl        .skip_call                       ;
  call      exp_ir_buf                       ;
.skip_call:
  mov       byte [r14 + 1], C_NUM            ; set number start IR
  lea       r14, [r14 + 3]                   ;
  xor       rdi, rdi                         ; rdi will be use as converted number buffer
  movzx     rsi, byte [r12]                  ;
  lea       r11, [r14 - 1]                   ; r11 as pointer to the byte with lenght
.convert_num:
  lea       esi, [esi - '0']                 ; convert character to number
  cmp       sil, 10                          ; error if it is not number character
  jge       unk_tkn_err                      ;
  lea       edi, [edi + edi * 4]             ;
  shl       edi, 1                           ;
  lea       edi, [edi + esi]                 ; error if number is longer than 4 bytes
  jc        long_num_err                     ;
  inc       r12                              ;
  movzx     rsi, byte [r12]                  ;
  cmp       byte [rbp + rsi], NUM_DEL        ; stop converting if found not-number character
  je        .convert_num                     ;
  mov       esi, edi                         ;
  xor       r8, r8                           ;
.write_insides:
  cmp       r14, r9                          ;
  jl        .skip_call2                      ;
  push      r11                              ;
  call      exp_ir_buf                       ;
  pop       r11                              ;
.skip_call2:
  test      esi, esi                         ; write converted number
  jz        write_num_len                    ;
  mov       byte [r14], sil                  ;
  inc       r14                              ;
  shr       esi, 8                           ;
  inc       r8b                              ;
  jmp       .write_insides                   ;
write_num_len:
  cmp       r8, 3                            ;
  jl        .skip_exp                        ;
  inc       r14                              ;
  inc       r8b                              ;
.skip_exp:
  mov       byte [r11], r8b                  ;
  lea       r8, [r8 - 4]                     ;
  neg       r8                               ;
  lea       r14, [r14 + r8]                  ;
  cmp       r14, r9                          ;
  jl        .skip_call                       ;
  call      exp_ir_buf                       ;
.skip_call:                                  ;
  movzx     rax, byte [r12]                  ;
  jmp       next_lex                         ;

exp_ir_buf:
  push      rsi                              ; save rsi in stack (caller-saved register lmao)
  SYSCALL_1 SYS_BRK, 0                       ; get current heap pointer
  lea       rsi, [rax + r13]                 ;
  SYSCALL_1 SYS_BRK, rsi                     ; allocate memory
  mov       rcx, valid_char_tbl              ; restore valid characters table pointer
  mov       rsi, qword [lex_ir_buf_ptr]      ;
  lea       r13, [r13 * 2]                   ; will allocate x2 more memory next time
  lea       r9, [rsi + r13 - 1]              ; update r9
  pop       rsi                              ; restore rsi
  ret                                        ;

handle_eof:
  cmp       r14, r9                          ; expand IR buffer by 2 if it needs more space
  jl        .write_eof                       ;
  SYSCALL_1 SYS_BRK, 0                       ;
  lea       rsi, [rax + 2]                   ;
  SYSCALL_1 SYS_BRK, rsi                     ;
.write_eof:
  mov       byte [r14 + 1], C_EOF            ; write eof IR and end lexer
  lea       r14, [r14 + 2]                   ; r14 is pointer to parser IR buffer
  lea       rsi, [r14 + r13]                 ; allocate memory for parser IR buffer
  SYSCALL_1 SYS_BRK, rsi                     ;

lexer_end = $
