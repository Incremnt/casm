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

format ELF64 executable
entry _start

include "inc/macros.inc"

segment readable executable
_start:
  cmp       qword [rsp], 3                                                 ; handle usage error
  jb        usage_err                                                      ;

  mov       rcx, 2                                                         ; handle usage flags
  mov       rdx, 0                                                         ;
parse_flags:
  mov       rax, qword [rsp + rcx * 8]                                     ;
  mov       rax, qword [rax]                                               ;
  cmp       rax, qword [noelf_flag]                                        ;
  je        .noelf_flag                                                    ;
  cmp       rax, qword [amd64_flag]                                        ;
  je        .amd64_flag                                                    ;
  cmp       rax, qword [bytes_flag]                                        ;
  je        .bytes_flag                                                    ;
  cmp       rax, qword [style_flag]                                        ;
  je        .style_flag                                                    ;
  and       eax, 0x00FFFFFF                                                ;
  cmp       eax, dword [noelf_sflag]                                       ;
  je        .noelf_flag                                                    ;
  cmp       eax, dword [amd64_sflag]                                       ;
  je        .amd64_flag                                                    ;
  cmp       eax, dword [bytes_sflag]                                       ;
  je        .bytes_flag                                                    ;
  cmp       eax, dword [style_sflag]                                       ;
  je        .style_flag                                                    ;
  cmp       al, '-'                                                        ;
  je        usage_err                                                      ;
  inc       rdx                                                            ;
  cmp       rdx, 2                                                         ;
  ja        usage_err                                                      ;
  cmp       rcx, qword [rsp]                                               ;
  je        .end_flags_parse                                               ;
  inc       rcx                                                            ;
  jmp       parse_flags                                                    ;
.noelf_flag:
  test      rdx, rdx                                                       ;
  jnz       usage_err                                                      ;
  mov       byte [do_gen_elf], 0                                           ;
  cmp       rcx, qword [rsp]                                               ;
  je        .end_flags_parse                                               ;
  inc       rcx                                                            ;
  jmp       parse_flags                                                    ;
.amd64_flag:
  test      rdx, rdx                                                       ;
  jnz       usage_err                                                      ;
  mov       byte [do_gen_64], 1                                            ;
  mov       rax, qword [ehdr64.entry]                                      ;
  mov       qword [current_ptr], rax                                       ;
  cmp       rcx, qword [rsp]                                               ;
  je        .end_flags_parse                                               ;
  inc       rcx                                                            ;
  jmp       parse_flags                                                    ;
.bytes_flag:
  test      rdx, rdx                                                       ;
  jnz       usage_err                                                      ;
  mov       byte [do_show_bytes], 1                                        ;
  cmp       rcx, qword [rsp]                                               ;
  je        .end_flags_parse                                               ;
  inc       rcx                                                            ;
  jmp       parse_flags                                                    ;
.style_flag:
  test      rdx, rdx                                                       ;
  jnz       usage_err                                                      ;
  mov       byte [do_show_rank], 1                                         ;
  cmp       rcx, qword [rsp]                                               ;
  je        .end_flags_parse                                               ;
  inc       rcx                                                            ;
  jmp       parse_flags                                                    ;
.end_flags_parse:
  push      rcx                                                            ;

  mov       rbx, qword [rsp + rcx * 8]                                     ;
  cmp       byte [rbx], '-'                                                ;
  je        usage_err                                                      ;
  SYSCALL_3 SYS_OPEN, rbx, O_RDONLY, 0                                     ; open input file
  mov       rbx, rax                                                       ;
  test      rbx, rbx                                                       ; handle file open error
  js        open_err                                                       ;

  SYSCALL_3 SYS_LSEEK, rbx, 0, SEEK_END                                    ; calculate input file size
  test      rax, rax                                                       ;
  js        lseek_err                                                      ;
  mov       rbp, rax                                                       ;

  SYSCALL_1 SYS_BRK, 0                                                     ;
  lea       r12, [rax + 1]                                                 ;
  push      rbp                                                            ;
  lea       r14, [rbp + rax + 2]                                           ;
  lea       rbp, [rbp + rax + LEX_IRBUF_SIZE + 2]                          ;
  cmp       rax, rbp                                                       ;
  je        brk_err                                                        ; handle brk error
  SYSCALL_1 SYS_BRK, rbp                                                   ; allocate memory for file
  mov       qword [lex_irbuf_ptr], r14                                     ;
  pop       rbp                                                            ;

  SYSCALL_3 SYS_LSEEK, rbx, 0, SEEK_SET                                    ; restore file position
  test      rax, rax                                                       ;
  js        lseek_err                                                      ;

  SYSCALL_3 SYS_READ, rbx, r12, rbp                                        ; read source code from input file
  test      rax, rax                                                       ; handle code read error
  js        read_err                                                       ;

  SYSCALL_1 SYS_CLOSE, rbx                                                 ; close input file

  pop       rcx                                                            ;
  mov       rbx, qword [rsp + rcx * 8]                                     ;
  SYSCALL_3 SYS_OPEN, rbx, O_WRONLY + O_APPEND + O_CREAT + O_TRUNC, 0744o  ; open output file
  test      rax, rax                                                       ; handle file open error
  js        open_err                                                       ;
  mov       qword [output_fd], rax                                         ; save fd

include "lexer.asm"
include "parser.asm"
include "codegen.asm"

  mov       rbx, qword [output_fd]
  SYSCALL_1 SYS_CLOSE, rbx
  SYSCALL_1 SYS_EXIT, EXIT_SUCCESS

include "inc/handlers.asm"

segment readable writable
include "inc/errors.asm"
include "inc/elf.asm"
include "inc/tables.asm"
include "inc/trie.asm"
include "inc/variables.asm"
