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
; File:      macros.inc          ;
; FIle type: Part                ; 
; Author:    Incremnt            ;
; License:   GPLv3               ;
;================================;

;--------------;
;--- macros ---;
;--------------;
macro SYSCALL_3 num, arg1, arg2, arg3 {
  mov rax, num
  mov rdi, arg1
  mov rsi, arg2
  mov rdx, arg3
  syscall
}

macro SYSCALL_1 num, arg1 {
  mov rax, num
  mov rdi, arg1
  syscall
}

macro LEX_NODE char, ir_group, ir, child_offset, sibling_offset, is_terminal {
  db char
  db ir_group
  db ir
  dw child_offset
  dw sibling_offset
  db is_terminal
}

macro PAR_NODE ir_group, opcode_prefix, opcode, child_offset, sibling_offset, parser_flags, node_flags {
  db ir_group
  db opcode_prefix
  db opcode
  db child_offset
  db sibling_offset
  dw parser_flags
  db node_flags
}

;-----------------;
;--- constants ---;
;-----------------;
; syscall numbers
SYS_READ  = 0
SYS_WRITE = 1
SYS_OPEN  = 2
SYS_CLOSE = 3
SYS_LSEEK = 8
SYS_BRK   = 12
SYS_EXIT  = 60

; syscall arguments
SEEK_END     = 2
SEEK_SET     = 0
EXIT_SUCCESS = 0
EXIT_FAILURE = 1

; lexer trie node offsets
LEX_IR_OFF     = 1
LEX_CHDOFF_OFF = 3
LEX_SIBOFF_OFF = 5
LEX_TERM_OFF   = 7

; parser trie node offsets
PAR_PREF_OFF      = 1
PAR_OP_OFF        = 2
PAR_CHDOFF_OFF    = 3
PAR_SIBOFF_OFF    = 4
PAR_PARFLAGS_OFF  = 5
PAR_NODEFLAGS_OFF = 7

; bool constants
VALID    = 1

; parser trie bits
TERM     = 0x01
MODRM    = 0x02
SIB      = 0x04
SHORT_OP = 0x08
MEM      = 0x10
IMM      = 0x20

; standard streams
STDIN  = 0
STDOUT = 1
STDERR = 2

; flags
O_RDONLY = 0

; characters
NUL = 0
TAB = 9
LF  = 10
ESC = 27
SPC = 32

; delimiters
DELIM   = 1
IGN_DEL = 1
CMT_DEL = 2
LBL_DEL = 3
NUM_DEL = 4
STR_DEL = 5
BRT_DEL = 6
PLS_DEL = 7
MIN_DEL = 8
MUL_DEL = 9
COM_DEL = 10
LF_DEL  = 11
ADR_DEL = 12

; lexer IR buffer size
LEX_IR_BUF_SZ = 8192

; parser status bits
LF_BIT    = 0x0001
INSTR_BIT = 0x0002
DIR_BIT   = 0x0008
PLUS_BIT  = 0x0010
MINUS_BIT = 0x0020
MUL_BIT   = 0x0040
IMM8_BIT  = 0x0080
IMM16_BIT = 0x0100
IMM32_BIT = 0x0200
MEM8_BIT  = 0x0400
MEM16_BIT = 0x0800
MEM32_BIT = 0x1000
ADDR_BIT  = 0x2000

; IR groups
G_CTRL  = 0
G_INSTR = 1
G_EINST = 2
G_REG32 = 3
G_REG16 = 4
G_REG8  = 5
G_DIR   = 6

; control IRs
C_EOF   = 0
C_NUM   = 1
C_STR   = 2
C_LBL   = 3
C_ADR   = 4
C_MEM   = 5
C_PLS   = 6
C_MIN   = 7
C_MUL   = 8
C_COM   = 9
C_LF    = 10
C_BYTE  = 11
C_WORD  = 12
C_DWORD = 13

; directives
D_DB     = 0
D_DW     = 1
D_DD     = 2
D_TEXT   = 3
D_BSS    = 4
D_DATA   = 5
D_RODATA = 6
D_STACK  = 7

; instructions
I_MOV  = 0
I_MUL  = 1
I_PUSH = 2
I_POP  = 3
I_CALL = 4
I_CMP  = 5
I_JMP  = 6
I_TEST = 7
I_OR   = 8
I_OUT  = 9
I_AND  = 10
I_ADD  = 11
I_XOR  = 12
I_NOT  = 13
I_NOP  = 14
I_IN   = 15
I_INT  = 16
I_INC  = 17
I_DEC  = 18
I_SUB  = 19

; extended instructions (0x0F prefix in opcode)
E_JE    = 0
E_JZ    = 1
E_JL    = 2
E_JLE   = 3
E_JG    = 4
E_JGE   = 5
E_JA    = 6
E_JAE   = 7
E_JB    = 8
E_JBE   = 9
E_JC    = 10
E_JS    = 11
E_JO    = 12
E_JP    = 13
E_JPO   = 14
E_JPE   = 15
E_JNE   = 16
E_JNZ   = 17
E_JNC   = 18
E_JNS   = 19
E_JNO   = 20
E_JNP   = 21
E_MOVZX = 22
E_MOVSX = 23

; 32-bit registers
R32_EAX = 0
R32_ECX = 1
R32_EBX = 2
R32_EDX = 3
R32_ESP = 4
R32_EBP = 5
R32_ESI = 6
R32_EDI = 7

; 16-bit registers
R16_AX  = 0
R16_CX  = 1
R16_BX  = 2
R16_DX  = 3
R16_SP  = 4
R16_BP  = 5
R16_SI  = 6
R16_DI  = 7

; 8-bit registers
R8_AL = 0
R8_BL = 1
R8_CL = 2
R8_DL = 3
R8_AH = 4
R8_BH = 5
R8_CH = 6
R8_DH = 7
