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

usage_err:
  mov       rsi, e_help_msg
  jmp       err_exit

open_err:
  mov       rsi, e_open_msg
  jmp       err_exit

lseek_err:
  mov       rsi, e_lseek_msg
  jmp       err_exit

brk_err:
  mov       rsi, e_brk_msg
  jmp       err_exit

read_err:
  mov       rsi, e_read_msg
  jmp       err_exit

unk_tkn_err:
  mov       rsi, e_unktkn_msg
  jmp       err_exit_line

long_num_err:
  mov       rsi, e_longnum_msg
  jmp       err_exit_line

invalid_char_err:
  mov       rsi, e_invalid_char_msg
  jmp       err_exit_line

invalid_name_err:
  mov       rsi, e_invalid_name_msg
  jmp       err_exit_line

invalid_expression_err:
  mov       rsi, e_invalid_expr_msg
  jmp       err_exit_line

op_sz_not_match_err:
  mov       rsi, e_op_sz_match_msg
  jmp       err_exit_line

undef_lbl_err:
  mov       rsi, e_undef_lbl_msg
  jmp       err_exit_line

defined_lbl_err:
  mov       rsi, e_defined_lbl_msg
  jmp       err_exit_line

rel_jmp_range_err:
  mov       rsi, e_reljmp_range_msg
  jmp       err_exit_line

label_range_err:
  mov       rsi, e_label_range_msg
  jmp       err_exit_line

invalid_operands_err:
  mov       rsi, e_invalid_opds_msg
  jmp       err_exit_line

trailing_chars_err:
  mov       rsi, e_trail_chars_msg
  jmp       err_exit_line

err_exit:
  xor       rcx, rcx
  push      rsi
.calc_size:
  inc       rcx
  inc       rsi
  cmp       byte [rsi], NUL
  jne       .calc_size
  pop       rsi
  SYSCALL_3 SYS_WRITE, STDERR, rsi, rcx
  SYSCALL_1 SYS_EXIT, EXIT_FAILURE

err_exit_line:
  xor       rcx, rcx
  push      rsi
.calc_size:
  inc       rcx
  inc       rsi
  cmp       byte [rsi], NUL
  jne       .calc_size
  pop       rsi
  SYSCALL_3 SYS_WRITE, STDERR, rsi, rcx
  mov       rax, qword [current_line]
  mov       rcx, LINE_BUF_SZ - 1
.convert_line:
  xor       rdx, rdx
  mov       rbx, 10
  div       rbx
  add       dl, '0'
  mov       byte [line_buf + rcx], dl
  dec       rcx
  test      rax, rax
  jnz       .convert_line
  SYSCALL_3 SYS_WRITE, STDERR, e_line_msg_st, E_LINE_MSG_ST_SZ
  SYSCALL_3 SYS_WRITE, STDERR, line_buf, LINE_BUF_SZ
  SYSCALL_3 SYS_WRITE, STDERR, e_line_msg_end, E_LINE_MSG_END_SZ
  SYSCALL_1 SYS_EXIT, EXIT_FAILURE
