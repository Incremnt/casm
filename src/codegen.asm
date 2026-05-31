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
; File:      codegen.asm         ;
; File type: Part                ;
; Author:    Incremnt            ;
; License:   GPLv3               ;
;================================;
codegen:
  mov       rbx, qword [output_fd]                               ;
  cmp       byte [do_gen_elf], 0                                 ; don't generate headers if there was --noelf flag
  je        dont_gen_elf                                         ;
  SYSCALL_3 SYS_WRITE, rbx, ehdr, EHSIZE                         ; write elf header to the output file

  mov       rcx, rbp                                             ; write program headers
  sub       rcx, qword [phdrbuf_ptr]                             ;
  mov       rbp, qword [phdrbuf_ptr]                             ;
  SYSCALL_3 SYS_WRITE, rbx, rbp, rcx                             ;

dont_gen_elf:
  cmp       byte [do_show_bytes], 0                              ; show output file size if there was --bytes flag
  je        dont_show_bytes                                      ;
  mov       rsi, qword [par_irbuf_ptr]                           ;
  mov       rax, r14                                             ;
  sub       rax, rsi                                             ;
  mov       rcx, BYTES_BUF_SZ - 1                                ;
  cmp       byte [do_gen_elf], 0                                 ;
  je        .convert_file_size                                   ;
  xor       rdx, rdx                                             ;
  mov       dx, word [ehdr.phnum]                                ;
  imul      rdx, rdx, PHENTSIZE                                  ;
  lea       rax, [rdx + rax + EHSIZE]                            ;
.convert_file_size:
  xor       rdx, rdx                                             ;
  mov       rbp, 10                                              ;
  div       rbp                                                  ;
  add       dl, '0'                                              ;
  mov       byte [bytes_buf + rcx], dl                           ;
  dec       rcx                                                  ;
  test      rax, rax                                             ;
  jnz       .convert_file_size                                   ;
  SYSCALL_3 SYS_WRITE, STDERR, e_bytes_msg_st, E_BYTES_MSG_ST_SZ ;
  SYSCALL_3 SYS_WRITE, STDERR, bytes_buf, BYTES_BUF_SZ           ;
  SYSCALL_3 SYS_WRITE, STDERR, e_bytes_msg_en, E_BYTES_MSG_EN_SZ ;

dont_show_bytes:
  cmp       byte [do_show_rank], 0                               ;
  je        dont_show_style                                      ;
  mov       rax, 100                                             ; calculate style points percentage
  mov       rbp, qword [current_line]                            ;
  xor       rdx, rdx                                             ;
  dec       rbp                                                  ;
  cmp       rbp, 101                                             ;
  jl        .not_float                                           ;
  xchg      rax, rbp                                             ;
.not_float:
  div       rbp                                                  ;
  mov       rcx, rax                                             ;
  mov       rax, qword [style_points]                            ;
  mov       rbp, qword [current_line]                            ;
  xor       rdx, rdx                                             ;
  div       rbp                                                  ;
  test      rax, rax                                             ;
  jnz       .p_rank_overflow                                     ;
  mov       rax, rdx                                             ;
  xor       rdx, rdx                                             ;
  cmp       qword [current_line], 102                            ;
  jge       .float                                               ;
  mul       rcx                                                  ;
  jmp       .float_skip                                          ;
.float:
  div       rcx                                                  ;
.float_skip:
  cmp       rax, 25                                              ; ranks:
  jl        .d_rank                                              ; P 100-85%
  cmp       rax, 40                                              ; S 85-70%
  jl        .c_rank                                              ; A 70-65%
  cmp       rax, 65                                              ; B 65-40%
  jl        .b_rank                                              ; C 40-25%
  cmp       rax, 70                                              ; D 25-0%
  jl        .a_rank                                              ;
  cmp       rax, 85                                              ;
  jl        .s_rank                                              ;
  jmp       .p_rank                                              ;
.p_rank_overflow:
  mov       rax, 100                                             ;
.p_rank:
  mov       qword [rank_ptr], st_p                               ;
  jmp       .write_style                                         ;
.s_rank:
  mov       qword [rank_ptr], st_s                               ;
  jmp       .write_style                                         ;
.a_rank:
  mov       qword [rank_ptr], st_a                               ;
  jmp       .write_style                                         ;
.b_rank:
  mov       qword [rank_ptr], st_b                               ;
  jmp       .write_style                                         ;
.c_rank:
  mov       qword [rank_ptr], st_c                               ;
  jmp       .write_style                                         ;
.d_rank:
  mov       qword [rank_ptr], st_d                               ;
  jmp       .write_style                                         ;
.write_style:
  mov       rcx, STYLE_BUF_SZ - 1                                ;
.convert_style:
  xor       rdx, rdx                                             ;
  mov       rbp, 10                                              ;
  div       rbp                                                  ;
  add       dl, '0'                                              ;
  mov       byte [style_buf + rcx], dl                           ;
  dec       rcx                                                  ;
  test      rax, rax                                             ;
  jnz       .convert_style                                       ;
  SYSCALL_3 SYS_WRITE, STDERR, e_style_msg_st, E_STYLE_MSG_ST_SZ ;
  SYSCALL_3 SYS_WRITE, STDERR, style_buf, STYLE_BUF_SZ           ;
  SYSCALL_3 SYS_WRITE, STDERR, e_style_msg_en, E_STYLE_MSG_EN_SZ ;
  SYSCALL_3 SYS_WRITE, STDERR, e_rank_msg_st, E_RANK_MSG_ST_SZ   ;
  mov       rsi, qword [rank_ptr]                                ;
  SYSCALL_3 SYS_WRITE, STDERR, rsi, RANK_SZ                      ;
  SYSCALL_3 SYS_WRITE, STDERR, e_rank_msg_en, E_RANK_MSG_EN_SZ   ;

dont_show_style:
  mov       rsi, qword [par_irbuf_ptr]                           ; write opcodes
  mov       rcx, r14                                             ;
  sub       rcx, rsi                                             ;
  SYSCALL_3 SYS_WRITE, rbx, rsi, rcx                             ;

  SYSCALL_1 SYS_CLOSE, rbx                                       ; close file

codegen_end = $
