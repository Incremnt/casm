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

macro LEX_NODE char, ir_group, ir, child_offset, sibling_offset, flags {
  db char
  db ir_group
  db ir
  dw child_offset
  dw sibling_offset
  db flags
}

macro PAR_NODE ir_group, opcode, child_offset, sibling_offset, parser_flags, node_flags {
  db ir_group
  db opcode
  db child_offset
  db sibling_offset
  dw parser_flags
  dw node_flags
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

; elf stuff
EI_CLASS32  = 1
EI_CLASS64  = 2
EI_DATA2LSB = 1
EV_CURRENT  = 1
EI_OSABI    = 0
EI_VERCURR  = 0
ET_EXEC     = 2
EM_386      = 3
EM_X86_64   = 62
EV_CURRENT  = 1
PT_LOAD     = 1

; lexer trie node offsets
LEX_IR_OFF     = 1
LEX_CHDOFF_OFF = 3
LEX_SIBOFF_OFF = 5
LEX_FLAGS_OFF  = 7

; parser trie node offsets
PAR_OP_OFF        = 1
PAR_CHDOFF_OFF    = 2
PAR_SIBOFF_OFF    = 3
PAR_PARFLAGS_OFF  = 4
PAR_NODEFLAGS_OFF = 6

; bool constants
VALID    = 1

; lexer trie bits
TERM     = 0x01
PHDR     = 0x02
AMD64    = 0x04

; parser trie bits
TERM     = 0x0001
MODRM    = 0x0002
SIB      = 0x0004
SHORT_OP = 0x0008
TWOBYTE  = 0x0010
OPSIZE   = 0x0020
REXW     = 0x0040
SREG     = 0x0080
OPNUM1   = 0x0100
OPNUM2   = 0x0200
OPNUM3   = 0x0400
OPNUM4   = 0x0800
OPNUM5   = 0x1000
OPNUM6   = 0x2000
OPNUM7   = 0x4000
OPNUM8   = 0x8000
OPNUM    = OPNUM1 + OPNUM2 + OPNUM3 + OPNUM4 + OPNUM5 + OPNUM6 + OPNUM7 + OPNUM8

; standard streams
STDIN  = 0
STDOUT = 1
STDERR = 2

; file open flags
O_RDONLY = 0
O_WRONLY = 1
O_CREAT  = 64
O_APPEND = 1024
O_TRUNC  = 512

; rwx flags
R = 4
W = 2
X = 1

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
LBR_DEL = 6
RBR_DEL = 7
PLS_DEL = 8
MIN_DEL = 9
MUL_DEL = 10
COM_DEL = 11
LF_DEL  = 12
ADR_DEL = 13

; buffer sizes
LEX_IRBUF_SIZE = 8192
PHDRBUF_SIZE   = 4096

; parser status bits
IMM8_BIT      = 0x0001
IMM16_BIT     = 0x0002
IMM32_BIT     = 0x0004
MEM8_BIT      = 0x0008
MEM16_BIT     = 0x0010
MEM32_BIT     = 0x0020
REL8_BIT      = 0x0040
REL32_BIT     = 0x0080
NOP_BIT       = 0x0100
SIBRFIRST_BIT = 0x0200
BASFIRST_BIT  = 0x0400
REGFIRST_BIT  = 0x0800
IDXFIRST_BIT  = 0x1000
REG8_BIT      = 0x2000
REG16_BIT     = 0x4000
REG32_BIT     = 0x8000
UNLIMSTR_BIT  = 0x010000
ENTRY_BIT     = 0x020000
PHFIRST_BIT   = 0x040000
LABEL_BIT     = 0x080000
INSTR_BIT     = 0x100000
DIR_BIT       = 0x200000
PLUS_BIT      = 0x400000
MINUS_BIT     = 0x800000
MULT_BIT      = 0x01000000
UNLIMIMM_BIT  = 0x02000000
IMM64_BIT     = 0x04000000
REXW_BIT      = 0x08000000
REXSZ_BIT     = 0x10000000
RIPREL_BIT    = 0x20000000
ADSIZE_BIT    = 0x40000000
IMM_BIT       = IMM8_BIT + IMM16_BIT + IMM32_BIT
MEM_BIT       = MEM8_BIT + MEM16_BIT + MEM32_BIT
REG_BIT       = REG8_BIT + REG16_BIT + REG32_BIT

; IR groups
G_CTRL  = 0
G_INSTR = 1
G_EINST = 2
G_REG32 = 3
G_REG16 = 4
G_REG8  = 5
G_DIR   = 6
G_PREF  = 7
G_SPREF = 8
G_SREG  = 9
G_CREG  = 10
G_DREG  = 11
G_REG64 = 12

; control IRs
C_EOF   = 0
C_NUM   = 1
C_STR   = 2
C_LBL   = 3
C_ADR   = 4
C_MEMST = 5
C_MEMEN = 6
C_MINUS = 7
C_PLUS  = 8
C_MULT  = 9
C_COM   = 10
C_LF    = 11
C_BYTE  = 12
C_WORD  = 13
C_DWORD = 14
C_QWORD = 15

; directives
D_DB     = 0
D_DW     = 1
D_DD     = 2
D_TEXT   = 3
D_DATA   = 4
D_RODATA = 5
D_ENTRY  = 6
D_ORG    = 7
D_DQ     = 8

; instructions
I_MOV    = 0
I_MUL    = 1
I_PUSH   = 2
I_POP    = 3
I_CALL   = 4
I_CMP    = 5
I_JMP    = 6
I_TEST   = 7
I_OR     = 8
I_AND    = 9
I_ADD    = 10
I_XOR    = 11
I_NOT    = 12
I_INT    = 13
I_INC    = 14
I_DEC    = 15
I_SUB    = 16
I_LEA    = 17
I_XCHG   = 18
I_NOP    = 19
I_RET    = 20
I_PUSHA  = 21
I_POPA   = 22
I_ADC    = 23
I_SBB    = 24
I_DAA    = 25
I_DAS    = 26
I_AAA    = 27
I_AAS    = 28
I_BOUND  = 29
I_ARPL   = 30
I_IMUL   = 31
I_INSB   = 32
I_INSW   = 33
I_INSD   = 34
I_OUTSB  = 35
I_OUTSW  = 36
I_OUTSD  = 37
I_CBW    = 38
I_CWD    = 39
I_WAIT   = 40
I_PUSHF  = 41
I_POPF   = 42
I_SAHF   = 43
I_LAHF   = 44
I_MOVSB  = 45
I_MOVSW  = 46
I_MOVSD  = 47
I_CMPSB  = 48
I_CMPSW  = 49
I_CMPSD  = 50
I_STOSB  = 51
I_STOSW  = 52
I_STOSD  = 53
I_LODSB  = 54
I_LODSW  = 55
I_LODSD  = 56
I_SCASB  = 57
I_SCASW  = 58
I_SCASD  = 59
I_ROL    = 60
I_ROR    = 61
I_RCL    = 62
I_RCR    = 63
I_SHL    = 64
I_SHR    = 65
I_SAL    = 66
I_SAR    = 67
I_LES    = 68
I_LDS    = 69
I_ENTER  = 70
I_LEAVE  = 71
I_RETF   = 72
I_INT3   = 73
I_INTO   = 74
I_IRET   = 75
I_AAM    = 76
I_AAD    = 77
I_SALC   = 78
I_XLAT   = 79
I_LOOPNZ = 80
I_LOOPZ  = 81
I_LOOP   = 82
I_JCXZ   = 83
I_IN     = 84
I_OUT    = 85
I_INT1   = 86
I_HLT    = 87
I_CMC    = 88
I_DIV    = 89
I_IDIV   = 90
I_NEG    = 91
I_CLC    = 92
I_STC    = 93
I_CLI    = 94
I_STI    = 95
I_CLD    = 96
I_STD    = 97
I_CWDE   = 98
I_CDQ    = 99
I_CQO    = 100
I_CDQE   = 101
I_MOVSQ  = 102
I_CMPSQ  = 103
I_STOSQ  = 104
I_LODSQ  = 105
I_SCASQ  = 106

; extended instructions (0x0F prefix in opcode)
E_JE       = 0
E_JZ       = 1
E_JL       = 2
E_JLE      = 3
E_JG       = 4
E_JGE      = 5
E_JA       = 6
E_JAE      = 7
E_JB       = 8
E_JBE      = 9
E_JC       = 10
E_JS       = 11
E_JO       = 12
E_JP       = 13
E_JPO      = 14
E_JPE      = 15
E_JNE      = 16
E_JNZ      = 17
E_JNC      = 18
E_JNS      = 19
E_JNO      = 20
E_JNP      = 21
E_MOVZX    = 22
E_MOVSX    = 23
E_CMOVO    = 24
E_CMOVNO   = 25
E_CMOVB    = 26
E_CMOVNB   = 27
E_CMOVE    = 28
E_CMOVNE   = 29
E_CMOVBE   = 30
E_CMOVA    = 31
E_CMOVS    = 32
E_CMOVNS   = 33
E_CMOVPE   = 34
E_CMOVPO   = 35
E_CMOVL    = 36
E_CMOVGE   = 37
E_CMOVLE   = 38
E_CMOVG    = 39
E_SETO     = 40
E_SETNO    = 41
E_SETB     = 42
E_SETNB    = 43
E_SETE     = 44
E_SETNE    = 45
E_SETBE    = 46
E_SETA     = 47
E_SETS     = 48
E_SETNS    = 49
E_SETPE    = 50
E_SETPO    = 51
E_SETL     = 52
E_SETGE    = 53
E_SETLE    = 54
E_SETG     = 55
E_UD2      = 56
E_SLDT     = 57
E_STR      = 58
E_LLDT     = 59
E_LTR      = 60
E_VERR     = 61
E_VERW     = 62
E_LAR      = 63
E_LSL      = 64
E_CLTS     = 65
E_INVD     = 66
E_WBINVD   = 67
E_WRMSR    = 68
E_RDTSC    = 69
E_RDMSR    = 70
E_RDPMC    = 71
E_SYSENTER = 72
E_SYSEXIT  = 73
E_CPUID    = 74
E_BT       = 75
E_SHLD     = 76
E_RSM      = 77
E_BTS      = 78
E_SHRD     = 79
E_CMPXCHG  = 80
E_LSS      = 81
E_BTR      = 82
E_LFS      = 83
E_LGS      = 84
E_BTC      = 85
E_BSF      = 86
E_BSR      = 87
E_XADD     = 88
E_BSWAP    = 89
E_SGDT     = 90
E_SIDT     = 91
E_LGDT     = 92
E_LIDT     = 93
E_SMSW     = 94
E_LMSW     = 95
E_SYSCALL  = 96
E_SYSRET   = 97

; 32-bit registers
R32_EAX  = 0
R32_ECX  = 1
R32_EDX  = 2
R32_EBX  = 3
R32_ESP  = 4
R32_EBP  = 5
R32_ESI  = 6
R32_EDI  = 7
R32_R8D  = 16
R32_R9D  = 17
R32_R10D = 18
R32_R11D = 19
R32_R12D = 20
R32_R13D = 21
R32_R14D = 22
R32_R15D = 23

; 16-bit registers
R16_AX   = 0
R16_CX   = 1
R16_DX   = 2
R16_BX   = 3
R16_SP   = 4
R16_BP   = 5
R16_SI   = 6
R16_DI   = 7
R16_R8W  = 16
R16_R9W  = 17
R16_R10W = 18
R16_R11W = 19
R16_R12W = 20
R16_R13W = 21
R16_R14W = 22
R16_R15W = 23

; 8-bit registers
R8_AL   = 0
R8_CL   = 1
R8_DL   = 2
R8_BL   = 3
R8_AH   = 4
R8_CH   = 5
R8_DH   = 6
R8_BH   = 7
R8_R8B  = 16
R8_R9B  = 17
R8_R10B = 18
R8_R11B = 19
R8_R12B = 20
R8_R13B = 21
R8_R14B = 22
R8_R15B = 23
R8_SPL  = 36
R8_BPL  = 37
R8_SIL  = 38
R8_DIL  = 39

; prefixes (already contain opcode prefix)
P_REPE  = 0xF3
P_REPNE = 0xF2
P_LOCK  = 0xF0

; segment registers
SR_ES = 0
SR_CS = 1
SR_SS = 2
SR_DS = 3
SR_FS = 4
SR_GS = 5

; control registers
CR_CR0 = 0
CR_CR1 = 1
CR_CR2 = 2
CR_CR3 = 3
CR_CR4 = 4
CR_CR5 = 5
CR_CR6 = 6
CR_CR7 = 7

; debug registers
DR_DR0 = 0
DR_DR1 = 1
DR_DR2 = 2
DR_DR3 = 3
DR_DR4 = 4
DR_DR5 = 5
DR_DR6 = 6
DR_DR7 = 7

; segment prefixes
SP_ES = 0x26
SP_CS = 0x2E
SP_SS = 0x36
SP_DS = 0x3E
SP_FS = 0x64
SP_GS = 0x65

; 64-bit registers
R64_RAX = 0
R64_RCX = 1
R64_RDX = 2
R64_RBX = 3
R64_RSP = 4
R64_RBP = 5
R64_RSI = 6
R64_RDI = 7
R64_RIP = 8
R64_R8  = 16
R64_R9  = 17
R64_R10 = 18
R64_R11 = 19
R64_R12 = 20
R64_R13 = 21
R64_R14 = 22
R64_R15 = 23

; neutral group registers (for opcode short forms & parser)
REG_R8  = 16
REG_SPL = 36
R_CONST = 0xFF
