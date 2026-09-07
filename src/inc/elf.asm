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

; variables
custom_entry dq 0
phdr_flags   dq 0

; x86
ehdr:
  .magic     db 0x7F, "ELF"
  .class     db EI_CLASS32
  .endianess db EI_DATA2LSB
  .elfver    db EV_CURRENT
  .osabi     db EI_OSABI
  .abiver    db EI_VERCURR
  .padding   db 7 dup(0)

  .type      dw ET_EXEC
  .machine   dw EM_386
  .version   dd EV_CURRENT
  .entry     dd 0x08048034
  .phoff     dd EHSIZE
  .shoff     dd 0x00000000
  .flags     dd 0x00000000
  .ehsize    dw EHSIZE
  .phentsize dw PHENTSIZE
  .phnum     dw 0
  .shentsize dw 0
  .shnum     dw 0
  .shstrndx  dw 0
  EHSIZE = $ - ehdr

phdr:
  .type      dd PT_LOAD
  .offset    dd 0
  .vaddr     dd 0
  .paddr     dd 0
  .filesz    dd 0
  .memsz     dd 0
  .flags     dd 0
  .align     dd 0x00001000
  PHENTSIZE = $ - phdr

; x86-64
ehdr64:
  .magic     db 0x7F, "ELF"
  .class     db EI_CLASS64
  .endianess db EI_DATA2LSB
  .elfver    db EV_CURRENT
  .osabi     db EI_OSABI
  .abiver    db EI_VERCURR
  .padding   db 7 dup(0)

  .type      dw ET_EXEC
  .machine   dw EM_X86_64
  .version   dd EV_CURRENT
  .entry     dq 0x0000000000400040
  .phoff     dq EHSIZE64
  .shoff     dq 0x0000000000000000
  .flags     dd 0x00000000
  .ehsize    dw EHSIZE64
  .phentsize dw PHENTSIZE64
  .phnum     dw 0
  .shentsize dw 0
  .shnum     dw 0
  .shstrndx  dw 0
  EHSIZE64 = $ - ehdr64

phdr64:
  .type      dd PT_LOAD
  .flags     dd 0
  .offset    dq 0
  .vaddr     dq 0
  .paddr     dq 0
  .filesz    dq 0
  .memsz     dq 0
  .align     dq 0x0000000000001000
  PHENTSIZE64 = $ - phdr64
