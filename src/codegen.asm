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
  mov       rbx, qword [output_fd]            ; write elf header to the output file
  SYSCALL_3 SYS_WRITE, rbx, ehdr, EHSIZE      ;

  lea       rcx, [rbp]                        ; write program headers
  sub       rcx, qword [phdrbuf_ptr]          ;
  SYSCALL_3 SYS_WRITE, rbx, rbp, rcx          ;

  mov       rsi, qword [par_irbuf_ptr]        ; write opcodes
  mov       rcx, r14                          ;
  sub       rcx, rsi                          ;
  SYSCALL_3 SYS_WRITE, rbx, rsi, rcx          ;

  SYSCALL_1 SYS_CLOSE, rbx                    ; close file

codegen_end = $
