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
  mov       rsi, qword [par_irbuf_ptr]                           ; write opcodes
  mov       rcx, r14                                             ;
  sub       rcx, rsi                                             ;
  SYSCALL_3 SYS_WRITE, rbx, rsi, rcx                             ;

  SYSCALL_1 SYS_CLOSE, rbx                                       ; close file

codegen_end = $
