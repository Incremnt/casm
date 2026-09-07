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

; error messages
e_open_msg         db ESC, '[31m', "[Error]: Can't open file",                 ESC, '[0m', LF, NUL
e_lseek_msg        db ESC, '[31m', "[Error]: SYS_LSEEK failed",                ESC, '[0m', LF, NUL
e_brk_msg          db ESC, '[31m', "[Error]: Can't allocate memory",           ESC, '[0m', LF, NUL
e_read_msg         db ESC, '[31m', "[Error]: SYS_READ failed",                 ESC, '[0m', LF, NUL
e_unktkn_msg       db ESC, '[31m', "[Error]: Unknown token",                   ESC, '[0m', LF, NUL
e_longnum_msg      db ESC, '[31m', "[Error]: Number is too big",               ESC, '[0m', LF, NUL
e_invalid_char_msg db ESC, '[31m', "[Error]: Unexpected character in string",  ESC, '[0m', LF, NUL
e_invalid_name_msg db ESC, '[31m', "[Error]: Invalid label name",              ESC, '[0m', LF, NUL
e_invalid_expr_msg db ESC, '[31m', "[Error]: Invalid expression",              ESC, '[0m', LF, NUL
e_op_sz_match_msg  db ESC, '[31m', "[Error]: Operand size is not match",       ESC, '[0m', LF, NUL
e_undef_lbl_msg    db ESC, '[31m', "[Error]: Undefined label",                 ESC, '[0m', LF, NUL
e_defined_lbl_msg  db ESC, '[31m', "[Error]: Label is already defined",        ESC, '[0m', LF, NUL
e_reljmp_range_msg db ESC, '[31m', "[Error]: Relative jump out of range",      ESC, '[0m', LF, NUL
e_label_range_msg  db ESC, '[31m', "[Error]: Label's address is out of range", ESC, '[0m', LF, NUL
e_invalid_opds_msg db ESC, '[31m', "[Error]: Invalid operands",                ESC, '[0m', LF, NUL
e_trail_chars_msg  db ESC, '[31m', "[Error]: Trailing characters",             ESC, '[0m', LF, NUL

e_line_msg_st      db ESC, '[31m', "[Line]:  "
E_LINE_MSG_ST_SZ   = $ - e_line_msg_st
e_line_msg_end     db ESC, '[0m', LF
E_LINE_MSG_END_SZ  = $ - e_line_msg_end

e_bytes_msg_st     db "[Size]:  "
E_BYTES_MSG_ST_SZ  = $ - e_bytes_msg_st
e_bytes_msg_en     db " bytes", LF
E_BYTES_MSG_EN_SZ  = $ - e_bytes_msg_en

e_style_msg_st     db "[Style]: "
E_STYLE_MSG_ST_SZ  = $ - e_style_msg_st
e_style_msg_en     db "%", LF
E_STYLE_MSG_EN_SZ  = $ - e_style_msg_en

e_rank_msg_st      db "[Rank]:  "
E_RANK_MSG_ST_SZ   = $ - e_rank_msg_st
e_rank_msg_en      db LF
E_RANK_MSG_EN_SZ   = $ - e_rank_msg_en

e_help_msg         db "casm [OPTIONS] <SOURCE> <OUTPUT>", LF
                   db "  -n, --noelf    don't generate ELF header, error on PHDR directives", LF
                   db "  -a, --amd64    generate 64-bit code", LF
                   db "  -b, --bytes    show output file size in bytes", LF
                   db "  -s, --style    show your rank and style points percentage", LF
E_HELP_MSG_SZ      = $ - e_help_msg

current_line  dq 1
style_points  dq 0
line_buf      db 20 dup(0)
LINE_BUF_SZ   = $ - line_buf
bytes_buf     db 20 dup(0)
BYTES_BUF_SZ  = $ - bytes_buf
style_buf     db 20 dup(0)
STYLE_BUF_SZ  = $ - style_buf

; usage flags
noelf_flag  db "--noelf", NUL
noelf_sflag db "-n", 0, NUL
amd64_flag  db "--amd64", NUL
amd64_sflag db "-a", 0, NUL
bytes_flag  db "--bytes", NUL
bytes_sflag db "-b", 0, NUL
style_flag  db "--style", NUL
style_sflag db "-s", 0, NUL

; usage flag bools
do_gen_elf    db 1
do_gen_64     db 0
do_show_bytes db 0
do_show_rank  db 0

; ranks
st_p db ESC, "[38;5;255m", ESC, "[48;5;214m", " P ", ESC, "[0m", NUL
st_s db ESC, "[38;5;196m", "S", ESC, "[0m", NUL
st_a db ESC, "[38;5;208m", "A", ESC, "[0m", NUL
st_b db ESC, "[38;5;214m", "B", ESC, "[0m", NUL
st_c db ESC, "[38;5;112m", "C", ESC, "[0m", NUL
st_d db ESC, "[38;5;069m", "D", ESC, "[0m", NUL
