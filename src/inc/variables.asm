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

; pointers
lex_irbuf_ptr        dq 0
par_irbuf_ptr        dq 0
phdrbuf_ptr          dq 0
labelbuf_ptr         dq 0
deladrbuf_ptr        dq 0
modrm_ptr            dq 0
sib_ptr              dq 0
sib_offset_ptr       dq 0
rex_ptr              dq 0
deladr_offset        dq 0
labelbuf_slot_offset dq 0
rank_ptr             dq 0
current_ptr          dq 0x0000000008048034
repeat_ir_ptr        dq 0
heap_ptr             dq 0

; miscellaneous
repeats_count  dd 0
repeat_line_sz dq 0
reserved_bytes dq 0
reserve_scale  dq 0

; file descriptors
output_fd dq 0
