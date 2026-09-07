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

; lexeme trie
lex_trie:
  ; node for unknown lexemes
  LEX_NODE 0, 0, 0, 0, 0, TERM

.sec_node:
  LEX_NODE '.', 0, 0, 1, 0, 0
    LEX_NODE 't', 0, 0, 1, 8, 0
      LEX_NODE 'e', 0, 0, 1, 3, 0
        LEX_NODE 'x', 0, 0, 1, 0, 0
          LEX_NODE 't', G_DIR, D_TEXT, 0, 0, PHDR + TERM
      LEX_NODE 'i', 0, 0, 1, 0, 0
        LEX_NODE 'm', 0, 0, 1, 0, 0
          LEX_NODE 'e', 0, 0, 1, 0, 0
            LEX_NODE 's', G_MACRO, M_REP, 0, 0, TERM
    LEX_NODE 'd', 0, 0, 1, 4, 0
      LEX_NODE 'a', 0, 0, 1, 0, 0
        LEX_NODE 't', 0, 0, 1, 0, 0
          LEX_NODE 'a', G_DIR, D_DATA, 0, 0, PHDR + TERM
    LEX_NODE 'r', 0, 0, 1, 6, 0
      LEX_NODE 'o', 0, 0, 1, 0, 0
        LEX_NODE 'd', 0, 0, 1, 0, 0
          LEX_NODE 'a', 0, 0, 1, 0, 0
            LEX_NODE 't', 0, 0, 1, 0, 0
              LEX_NODE 'a', G_DIR, D_RODATA, 0, 0, PHDR + TERM
    LEX_NODE 'e', 0, 0, 1, 5, 0
      LEX_NODE 'n', 0, 0, 1, 0, 0
        LEX_NODE 't', 0, 0, 1, 0, 0
          LEX_NODE 'r', 0, 0, 1, 0, 0
            LEX_NODE 'y', G_DIR, D_ENTRY, 0, 0, TERM
    LEX_NODE 'o', 0, 0, 1, 3, 0
      LEX_NODE 'r', 0, 0, 1, 0, 0
        LEX_NODE 'g', G_DIR, D_ORG, 0, 0, TERM
    LEX_NODE 'b', 0, 0, 1, 0, 0
      LEX_NODE 's', 0, 0, 1, 0, 0
        LEX_NODE 's', G_DIR, D_BSS, 0, 0, PHDR + TERM

.e_node:
  LEX_NODE 'e', 0, 0, 1, 0, 0
    LEX_NODE 's', G_SREG, SR_ES, 1, 4, TERM
      LEX_NODE ':', G_SPREF, SP_ES, 0, 1, TERM
      LEX_NODE 'i', G_REG32, R32_ESI, 0, 1, TERM
      LEX_NODE 'p', G_REG32, R32_ESP, 0, 0, TERM
    LEX_NODE 'a', 0, 0, 1, 2, 0
      LEX_NODE 'x', G_REG32, R32_EAX, 0, 0, TERM
    LEX_NODE 'b', 0, 0, 1, 3, 0
      LEX_NODE 'x', G_REG32, R32_EBX, 0, 1, TERM
      LEX_NODE 'p', G_REG32, R32_EBP, 0, 0, TERM
    LEX_NODE 'c', 0, 0, 1, 2, 0
      LEX_NODE 'x', G_REG32, R32_ECX, 0, 0, TERM
    LEX_NODE 'd', 0, 0, 1, 3, 0
      LEX_NODE 'x', G_REG32, R32_EDX, 0, 1, TERM
      LEX_NODE 'i', G_REG32, R32_EDI, 0, 0, TERM
    LEX_NODE 'n', 0, 0, 1, 0, 0
      LEX_NODE 't', 0, 0, 1, 0, 0
        LEX_NODE 'e', 0, 0, 1, 0, 0
          LEX_NODE 'r', G_INSTR, I_ENTER, 0, 0, TERM

.m_node:
  LEX_NODE 'm', 0, 0, 1, 0, 0
    LEX_NODE 'o', 0, 0, 1, 10, 0
      LEX_NODE 'v', G_INSTR, I_MOV, 1, 0, TERM
        LEX_NODE 'z', 0, 0, 1, 2, 0
          LEX_NODE 'x', G_EINST, E_MOVZX, 0, 0, TERM
        LEX_NODE 's', 0, 0, 1, 0, 0
          LEX_NODE 'x', G_EINST, E_MOVSX, 0, 1, TERM
          LEX_NODE 'b', G_INSTR, I_MOVSB, 0, 1, TERM
          LEX_NODE 'w', G_INSTR, I_MOVSW, 0, 1, TERM
          LEX_NODE 'd', G_INSTR, I_MOVSD, 0, 1, TERM
          LEX_NODE 'q', G_INSTR, I_MOVSQ, 0, 0, AMD64 + TERM
    LEX_NODE 'u', 0, 0, 1, 0, 0
      LEX_NODE 'l', G_INSTR, I_MUL, 0, 0, TERM

.p_node:
  LEX_NODE 'p', 0, 0, 1, 0, 0
    LEX_NODE 'u', 0, 0, 1, 5, 0
      LEX_NODE 's', 0, 0, 1, 0, 0
        LEX_NODE 'h', G_INSTR, I_PUSH, 1, 0, TERM
          LEX_NODE 'a', G_INSTR, I_PUSHA, 0, 1, TERM
          LEX_NODE 'f', G_INSTR, I_PUSHF, 0, 0, TERM
    LEX_NODE 'o', 0, 0, 1, 0, 0
      LEX_NODE 'p', G_INSTR, I_POP, 1, 0, TERM
        LEX_NODE 'a', G_INSTR, I_POPA, 0, 1, TERM
        LEX_NODE 'f', G_INSTR, I_POPF, 0, 0, TERM

.c_node:
  LEX_NODE 'c', 0, 0, 1, 0, 0
    LEX_NODE 's', G_SREG, SR_CS, 1, 2, TERM
      LEX_NODE ':', G_SPREF, SP_CS, 0, 0, TERM
    LEX_NODE 'a', 0, 0, 1, 3, 0
      LEX_NODE 'l', 0, 0, 1, 0, 0
        LEX_NODE 'l', G_INSTR, I_CALL, 0, 0, TERM
    LEX_NODE 'x', G_REG16, R16_CX, 0, 1, TERM
    LEX_NODE 'h', G_REG8, R8_CH, 0, 1, TERM
    LEX_NODE 'l', G_REG8, R8_CL, 1, 6, TERM
      LEX_NODE 'c', G_INSTR, I_CLC, 0, 1, TERM
      LEX_NODE 'd', G_INSTR, I_CLD, 0, 1, TERM
      LEX_NODE 'i', G_INSTR, I_CLI, 0, 1, TERM
      LEX_NODE 't', 0, 0, 1, 0, 0
        LEX_NODE 's', G_EINST, E_CLTS, 0, 0, TERM
    LEX_NODE 'm', 0, 0, 1, 38, 0
      LEX_NODE 'c', G_INSTR, I_CMC, 0, 1, TERM
      LEX_NODE 'p', G_INSTR, I_CMP, 1, 10, TERM
        LEX_NODE 's', 0, 0, 1, 5, 0
          LEX_NODE 'b', G_INSTR, I_CMPSB, 0, 1, TERM
          LEX_NODE 'w', G_INSTR, I_CMPSW, 0, 1, TERM
          LEX_NODE 'd', G_INSTR, I_CMPSD, 0, 1, TERM
          LEX_NODE 'q', G_INSTR, I_CMPSQ, 0, 0, AMD64 + TERM
        LEX_NODE 'x', 0, 0, 1, 0, 0
          LEX_NODE 'c', 0, 0, 1, 0, 0
            LEX_NODE 'h', 0, 0, 1, 0, 0
              LEX_NODE 'g', G_EINST, E_CMPXCHG, 0, 0, TERM
      LEX_NODE 'o', 0, 0, 1, 0, 0
        LEX_NODE 'v', 0, 0, 1, 0, 0
          LEX_NODE 'e', G_EINST, E_CMOVE, 0, 1, TERM
          LEX_NODE 'z', G_EINST, E_CMOVE, 0, 1, TERM
          LEX_NODE 'l', G_EINST, E_CMOVL, 1, 2, TERM
            LEX_NODE 'e', G_EINST, E_CMOVLE, 0, 0, TERM
          LEX_NODE 'g', G_EINST, E_CMOVG, 1, 2, TERM
            LEX_NODE 'e', G_EINST, E_CMOVGE, 0, 0, TERM
          LEX_NODE 'a', G_EINST, E_CMOVA, 1, 2, TERM
            LEX_NODE 'e', G_EINST, E_CMOVB, 0, 0, TERM
          LEX_NODE 'b', G_EINST, E_CMOVB, 1, 2, TERM
            LEX_NODE 'e', G_EINST, E_CMOVBE, 0, 0, TERM
          LEX_NODE 'c', G_EINST, E_CMOVB, 0, 1, TERM
          LEX_NODE 's', G_EINST, E_CMOVS, 0, 1, TERM
          LEX_NODE 'o', G_EINST, E_CMOVO, 0, 1, TERM
          LEX_NODE 'p', G_EINST, E_CMOVPE, 1, 3, TERM
            LEX_NODE 'o', G_EINST, E_CMOVPO, 0, 1, TERM
            LEX_NODE 'e', G_EINST, E_CMOVPE, 0, 0, TERM
          LEX_NODE 'n', 0, 0, 1, 0, 0
            LEX_NODE 'e', G_EINST, E_CMOVNE, 0, 1, TERM
            LEX_NODE 'z', G_EINST, E_CMOVNE, 0, 1, TERM
            LEX_NODE 'c', G_EINST, E_CMOVNB, 0, 1, TERM
            LEX_NODE 'b', G_EINST, E_CMOVNB, 0, 1, TERM
            LEX_NODE 's', G_EINST, E_CMOVNS, 0, 1, TERM
            LEX_NODE 'o', G_EINST, E_CMOVNO, 0, 1, TERM
            LEX_NODE 'p', G_EINST, E_CMOVPO, 0, 0, TERM
    LEX_NODE 'b', 0, 0, 1, 2, 0
      LEX_NODE 'w', G_INSTR, I_CBW, 0, 0, TERM
    LEX_NODE 'w', 0, 0, 1, 3, 0
      LEX_NODE 'd', G_INSTR, I_CWD, 1, 0, TERM
        LEX_NODE 'e', G_INSTR, I_CWDE, 0, 0, TERM
    LEX_NODE 'p', 0, 0, 1, 4, 0
      LEX_NODE 'u', 0, 0, 1, 0, 0
        LEX_NODE 'i', 0, 0, 1, 0, 0
          LEX_NODE 'd', G_EINST, E_CPUID, 0, 0, TERM
    LEX_NODE 'd', 0, 0, 1, 3, 0
      LEX_NODE 'q', G_INSTR, I_CDQ, 1, 0, TERM
        LEX_NODE 'e', G_INSTR, I_CDQE, 0, 0, AMD64 + TERM
    LEX_NODE 'q', 0, 0, 1, 2, 0
      LEX_NODE 'o', G_INSTR, I_CQO, 0, 0, AMD64 + TERM
    LEX_NODE 'r', 0, 0, 1, 0, 0
      LEX_NODE '0', G_CREG, CR_CR0, 0, 1, TERM
      LEX_NODE '1', G_CREG, CR_CR1, 0, 1, TERM
      LEX_NODE '2', G_CREG, CR_CR2, 0, 1, TERM
      LEX_NODE '3', G_CREG, CR_CR3, 0, 1, TERM
      LEX_NODE '4', G_CREG, CR_CR4, 0, 1, TERM
      LEX_NODE '5', G_CREG, CR_CR5, 0, 1, TERM
      LEX_NODE '6', G_CREG, CR_CR6, 0, 1, TERM
      LEX_NODE '7', G_CREG, CR_CR7, 0, 0, TERM

.j_node:
  LEX_NODE 'j', 0, 0, 1, 0, 0
    LEX_NODE 'm', 0, 0, 1, 2, 0
      LEX_NODE 'p', G_INSTR, I_JMP, 0, 0, TERM
    LEX_NODE 'e', G_EINST, E_JE, 0, 1, TERM
    LEX_NODE 'z', G_EINST, E_JZ, 0, 1, TERM
    LEX_NODE 'l', G_EINST, E_JL, 1, 2, TERM
      LEX_NODE 'e', G_EINST, E_JLE, 0, 0, TERM
    LEX_NODE 'g', G_EINST, E_JG, 1, 2, TERM
      LEX_NODE 'e', G_EINST, E_JGE, 0, 0, TERM
    LEX_NODE 'a', G_EINST, E_JA, 1, 2, TERM
      LEX_NODE 'e', G_EINST, E_JAE, 0, 0, TERM
    LEX_NODE 'b', G_EINST, E_JB, 1, 2, TERM
      LEX_NODE 'e', G_EINST, E_JBE, 0, 0, TERM
    LEX_NODE 'c', G_EINST, E_JC, 1, 3, TERM
      LEX_NODE 'x', 0, 0, 1, 0, 0
        LEX_NODE 'z', G_INSTR, I_JCXZ, 0, 0, TERM
    LEX_NODE 's', G_EINST, E_JS, 0, 1, TERM
    LEX_NODE 'o', G_EINST, E_JO, 0, 1, TERM
    LEX_NODE 'p', G_EINST, E_JP, 1, 3, TERM
      LEX_NODE 'o', G_EINST, E_JPO, 0, 1, TERM
      LEX_NODE 'e', G_EINST, E_JPE, 0, 0, TERM
    LEX_NODE 'n', 0, 0, 1, 0, 0
      LEX_NODE 'e', G_EINST, E_JNE, 0, 1, TERM
      LEX_NODE 'z', G_EINST, E_JNZ, 0, 1, TERM
      LEX_NODE 'c', G_EINST, E_JNC, 0, 1, TERM
      LEX_NODE 'b', G_EINST, E_JNC, 0, 1, TERM
      LEX_NODE 's', G_EINST, E_JNS, 0, 1, TERM
      LEX_NODE 'o', G_EINST, E_JNO, 0, 1, TERM
      LEX_NODE 'p', G_EINST, E_JNP, 0, 0, TERM

.t_node:
  LEX_NODE 't', 0, 0, 1, 0, 0
    LEX_NODE 'e', 0, 0, 1, 0, 0
      LEX_NODE 's', 0, 0, 1, 0, 0
        LEX_NODE 't', G_INSTR, I_TEST, 0, 0, TERM

.o_node:
  LEX_NODE 'o', 0, 0, 1, 0, 0
    LEX_NODE 'r', G_INSTR, I_OR, 0, 1, TERM
    LEX_NODE 'u', 0, 0, 1, 0, 0
      LEX_NODE 't', G_INSTR, I_OUT, 1, 0, TERM
        LEX_NODE 's', 0, 0, 1, 0, 0
          LEX_NODE 'b', G_INSTR, I_OUTSB, 0, 1, TERM
          LEX_NODE 'w', G_INSTR, I_OUTSW, 0, 1, TERM
          LEX_NODE 'd', G_INSTR, I_OUTSD, 0, 0, TERM

.a_node:
  LEX_NODE 'a', 0, 0, 1, 0, 0
    LEX_NODE 'h', G_REG8, R8_AH, 0, 1, TERM
    LEX_NODE 'l', G_REG8, R8_AL, 0, 1, TERM
    LEX_NODE 'x', G_REG16, R16_AX, 0, 1, TERM
    LEX_NODE 'n', 0, 0, 1, 2, 0
      LEX_NODE 'd', G_INSTR, I_AND, 0, 0, TERM
    LEX_NODE 'd', 0, 0, 1, 3, 0
      LEX_NODE 'd', G_INSTR, I_ADD, 0, 1, TERM
      LEX_NODE 'c', G_INSTR, I_ADC, 0, 0, TERM
    LEX_NODE 'a', 0, 0, 1, 5, 0
      LEX_NODE 'a', G_INSTR, I_AAA, 0, 1, TERM
      LEX_NODE 's', G_INSTR, I_AAS, 0, 1, TERM
      LEX_NODE 'm', G_INSTR, I_AAM, 0, 1, TERM
      LEX_NODE 'd', G_INSTR, I_AAD, 0, 0, TERM
    LEX_NODE 'r', 0, 0, 1, 0, 0
      LEX_NODE 'p', 0, 0, 1, 0, 0
        LEX_NODE 'l', G_INSTR, I_ARPL, 0, 0, TERM

.x_node:
  LEX_NODE 'x', 0, 0, 1, 0, 0
    LEX_NODE 'o', 0, 0, 1, 2, 0
      LEX_NODE 'r', G_INSTR, I_XOR, 0, 0, TERM
    LEX_NODE 'c', 0, 0, 1, 3, 0
      LEX_NODE 'h', 0, 0, 1, 0, 0
        LEX_NODE 'g', G_INSTR, I_XCHG, 0, 0, TERM
    LEX_NODE 'l', 0, 0, 1, 3, 0
      LEX_NODE 'a', 0, 0, 1, 0, 0
        LEX_NODE 't', G_INSTR, I_XLAT, 0, 0, TERM
    LEX_NODE 'a', 0, 0, 1, 0, 0
      LEX_NODE 'd', 0, 0, 1, 0, 0
        LEX_NODE 'd', G_EINST, E_XADD, 0, 0, TERM

.n_node:
  LEX_NODE 'n', 0, 0, 1, 0, 0
    LEX_NODE 'o', 0, 0, 1, 3, 0
      LEX_NODE 't', G_INSTR, I_NOT, 0, 1, TERM
      LEX_NODE 'p', G_INSTR, I_NOP, 0, 0, TERM
    LEX_NODE 'e', 0, 0, 1, 0, 0
      LEX_NODE 'g', G_INSTR, I_NEG, 0, 0, TERM

.i_node:
  LEX_NODE 'i', 0, 0, 1, 0, 0
    LEX_NODE 'm', 0, 0, 1, 3, 0
      LEX_NODE 'u', 0, 0, 1, 0, 0
        LEX_NODE 'l', G_INSTR, I_IMUL, 0, 0, TERM
    LEX_NODE 'r', 0, 0, 1, 3, 0
      LEX_NODE 'e', 0, 0, 1, 0, 0
        LEX_NODE 't', G_INSTR, I_IRET, 0, 0, TERM
    LEX_NODE 'd', 0, 0, 1, 3, 0
      LEX_NODE 'i', 0, 0, 1, 0, 0
        LEX_NODE 'v', G_INSTR, I_IDIV, 0, 0, TERM
    LEX_NODE 'n', G_INSTR, I_IN, 1, 0, TERM
      LEX_NODE 't', G_INSTR, I_INT, 1, 4, TERM
        LEX_NODE '3', G_INSTR, I_INT3, 0, 1, TERM
        LEX_NODE 'o', G_INSTR, I_INTO, 0, 1, TERM
        LEX_NODE '1', G_INSTR, I_INT1, 0, 0, TERM
      LEX_NODE 'c', G_INSTR, I_INC, 0, 1, TERM
      LEX_NODE 'v', 0, 0, 1, 2, 0
        LEX_NODE 'd', G_EINST, E_INVD, 0, 0, TERM
      LEX_NODE 's', 0, 0, 1, 0, 0
        LEX_NODE 'b', G_INSTR, I_INSB, 0, 1, TERM
        LEX_NODE 'w', G_INSTR, I_INSW, 0, 1, TERM
        LEX_NODE 'd', G_INSTR, I_INSD, 0, 0, TERM

.d_node:
  LEX_NODE 'd', 0, 0, 1, 0, 0
    LEX_NODE 's', G_SREG, SR_DS, 1, 2, TERM
      LEX_NODE ':', G_SPREF, SP_DS, 0, 0, TERM
    LEX_NODE 'l', G_REG8, R8_DL, 0, 1, TERM
    LEX_NODE 'h', G_REG8, R8_DH, 0, 1, TERM
    LEX_NODE 'x', G_REG16, R16_DX, 0, 1, TERM
    LEX_NODE 'i', G_REG16, R16_DI, 1, 3, TERM
      LEX_NODE 'v', G_INSTR, I_DIV, 0, 1, TERM
      LEX_NODE 'l', G_REG8, R8_DIL, 0, 0, AMD64 + TERM
    LEX_NODE 'b', G_DIR, D_DB, 0, 1, TERM
    LEX_NODE 'd', G_DIR, D_DD, 0, 1, TERM
    LEX_NODE 'q', G_DIR, D_DQ, 0, 1, TERM
    LEX_NODE 'w', G_DIR, D_DW, 1, 4, TERM
      LEX_NODE 'o', 0, 0, 1, 0, 0
        LEX_NODE 'r', 0, 0, 1, 0, 0
          LEX_NODE 'd', G_CTRL, C_DWORD, 0, 0, TERM
    LEX_NODE 'e', 0, 0, 1, 2, 0
      LEX_NODE 'c', G_INSTR, I_DEC, 0, 0, TERM
    LEX_NODE 'a', 0, 0, 1, 3, 0
      LEX_NODE 'a', G_INSTR, I_DAA, 0, 1, TERM
      LEX_NODE 's', G_INSTR, I_DAS, 0, 0, TERM
    LEX_NODE 'r', 0, 0, 1, 0, 0
      LEX_NODE '0', G_DREG, DR_DR0, 0, 1, TERM
      LEX_NODE '1', G_DREG, DR_DR1, 0, 1, TERM
      LEX_NODE '2', G_DREG, DR_DR2, 0, 1, TERM
      LEX_NODE '3', G_DREG, DR_DR3, 0, 1, TERM
      LEX_NODE '4', G_DREG, DR_DR4, 0, 1, TERM
      LEX_NODE '5', G_DREG, DR_DR5, 0, 1, TERM
      LEX_NODE '6', G_DREG, DR_DR6, 0, 1, TERM
      LEX_NODE '7', G_DREG, DR_DR7, 0, 0, TERM


.b_node:
  LEX_NODE 'b', 0, 0, 1, 0, 0
    LEX_NODE 'y', 0, 0, 1, 3, 0
      LEX_NODE 't', 0, 0, 1, 0, 0
        LEX_NODE 'e', G_CTRL, C_BYTE, 0, 0, TERM
    LEX_NODE 'x', G_REG16, R16_BX, 0, 1, TERM
    LEX_NODE 'h', G_REG8, R8_BH, 0, 1, TERM
    LEX_NODE 'l', G_REG8, R8_BL, 0, 1, TERM
    LEX_NODE 'p', G_REG16, R16_BP, 1, 2, TERM
      LEX_NODE 'l', G_REG8, R8_BPL, 0, 0, AMD64 + TERM
    LEX_NODE 't', G_EINST, E_BT, 1, 4, TERM
      LEX_NODE 's', G_EINST, E_BTS, 0, 1, TERM
      LEX_NODE 'r', G_EINST, E_BTR, 0, 1, TERM
      LEX_NODE 'c', G_EINST, E_BTC, 0, 0, TERM
    LEX_NODE 's', 0, 0, 1, 6, 0
      LEX_NODE 'f', G_EINST, E_BSF, 0, 1, TERM
      LEX_NODE 'r', G_EINST, E_BSR, 0, 1, TERM
      LEX_NODE 'w', 0, 0, 1, 0, 0
        LEX_NODE 'a', 0, 0, 1, 0, 0
          LEX_NODE 'p', G_EINST, E_BSWAP, 0, 0, TERM
    LEX_NODE 'o', 0, 0, 1, 0, 0
      LEX_NODE 'u', 0, 0, 1, 0, 0
        LEX_NODE 'n', 0, 0, 1, 0, 0
          LEX_NODE 'd', G_INSTR, I_BOUND, 0, 0, TERM

.w_node:
  LEX_NODE 'w', 0, 0, 1, 0, 0
    LEX_NODE 'o', 0, 0, 1, 3, 0
      LEX_NODE 'r', 0, 0, 1, 0, 0
        LEX_NODE 'd', G_CTRL, C_WORD, 0, 0, TERM
    LEX_NODE 'a', 0, 0, 1, 3, 0
      LEX_NODE 'i', 0, 0, 1, 0, 0
        LEX_NODE 't', G_INSTR, I_WAIT, 0, 0, TERM
    LEX_NODE 'r', 0, 0, 1, 4, 0
      LEX_NODE 'm', 0, 0, 1, 0, 0
        LEX_NODE 's', 0, 0, 1, 0, 0
          LEX_NODE 'r', G_EINST, E_WRMSR, 0, 0, TERM
    LEX_NODE 'b', 0, 0, 1, 0, 0
      LEX_NODE 'i', 0, 0, 1, 0, 0
        LEX_NODE 'n', 0, 0, 1, 0, 0
          LEX_NODE 'v', 0, 0, 1, 0, 0
            LEX_NODE 'd', G_EINST, E_WBINVD, 0, 0, TERM

.s_node:
  LEX_NODE 's', 0, 0, 1, 0, 0
    LEX_NODE 's', G_SREG, SR_SS, 1, 2, TERM
      LEX_NODE ':', G_SPREF, SP_SS, 0, 0, TERM
    LEX_NODE 'u', 0, 0, 1, 2, 0
      LEX_NODE 'b', G_INSTR, I_SUB, 0, 0, TERM
    LEX_NODE 'p', G_REG16, R16_SP, 1, 2, TERM
      LEX_NODE 'l', G_REG8, R8_SPL, 0, 0, AMD64 + TERM
    LEX_NODE 'i', G_REG16, R16_SI, 1, 4, TERM
      LEX_NODE 'l', G_REG8, R8_SIL, 0, 1, AMD64 + TERM
      LEX_NODE 'd', 0, 0, 1, 0, 0
        LEX_NODE 't', G_EINST, E_SIDT, 0, 0, TERM
    LEX_NODE 'h', 0, 0, 1, 5, 0
      LEX_NODE 'l', G_INSTR, I_SHL, 1, 2, TERM
        LEX_NODE 'd', G_EINST, E_SHLD, 0, 0, TERM
      LEX_NODE 'r', G_INSTR, I_SHR, 1, 0, TERM
        LEX_NODE 'd', G_EINST, E_SHRD, 0, 0, TERM
    LEX_NODE 'b', 0, 0, 1, 2, 0
      LEX_NODE 'b', G_INSTR, I_SBB, 0, 0, TERM
    LEX_NODE 'a', 0, 0, 1, 6, 0
      LEX_NODE 'l', G_INSTR, I_SAL, 1, 2, TERM
        LEX_NODE 'c', G_INSTR, I_SALC, 0, 0, TERM
      LEX_NODE 'r', G_INSTR, I_SAR, 0, 1, TERM
      LEX_NODE 'h', 0, 0, 1, 0, 0
        LEX_NODE 'f', G_INSTR, I_SAHF, 0, 0, TERM
    LEX_NODE 't', 0, 0, 1, 11, 0
      LEX_NODE 'c', G_INSTR, I_STC, 0, 1, TERM
      LEX_NODE 'i', G_INSTR, I_STI, 0, 1, TERM
      LEX_NODE 'd', G_INSTR, I_STD, 0, 1, TERM
      LEX_NODE 'r', G_EINST, E_STR, 0, 1, TERM
      LEX_NODE 'o', 0, 0, 1, 0, 0
        LEX_NODE 's', 0, 0, 1, 0, 0
          LEX_NODE 'b', G_INSTR, I_STOSB, 0, 1, TERM
          LEX_NODE 'w', G_INSTR, I_STOSW, 0, 1, TERM
          LEX_NODE 'd', G_INSTR, I_STOSD, 0, 1, TERM
          LEX_NODE 'q', G_INSTR, I_STOSQ, 0, 0, AMD64 + TERM
    LEX_NODE 'c', 0, 0, 1, 7, 0
      LEX_NODE 'a', 0, 0, 1, 0, 0
        LEX_NODE 's', 0, 0, 1, 0, 0
          LEX_NODE 'b', G_INSTR, I_SCASB, 0, 1, TERM
          LEX_NODE 'w', G_INSTR, I_SCASW, 0, 1, TERM
          LEX_NODE 'd', G_INSTR, I_SCASD, 0, 1, TERM
          LEX_NODE 'q', G_INSTR, I_SCASQ, 0, 0, AMD64 + TERM
    LEX_NODE 'l', 0, 0, 1, 3, 0
      LEX_NODE 'd', 0, 0, 1, 0, 0
        LEX_NODE 't', G_EINST, E_SLDT, 0, 0, TERM
    LEX_NODE 'e', 0, 0, 1, 26, 0
      LEX_NODE 't', 0, 0, 1, 0, 0
        LEX_NODE 'e', G_EINST, E_SETE, 0, 1, TERM
        LEX_NODE 'z', G_EINST, E_SETE, 0, 1, TERM
        LEX_NODE 'l', G_EINST, E_SETL, 1, 2, TERM
          LEX_NODE 'e', G_EINST, E_SETLE, 0, 0, TERM
        LEX_NODE 'g', G_EINST, E_SETG, 1, 2, TERM
          LEX_NODE 'e', G_EINST, E_SETGE, 0, 0, TERM
        LEX_NODE 'a', G_EINST, E_SETA, 1, 2, TERM
          LEX_NODE 'e', G_EINST, E_SETB, 0, 0, TERM
        LEX_NODE 'b', G_EINST, E_SETB, 1, 2, TERM
          LEX_NODE 'e', G_EINST, E_SETBE, 0, 0, TERM
        LEX_NODE 'c', G_EINST, E_SETB, 0, 1, TERM
        LEX_NODE 's', G_EINST, E_SETS, 0, 1, TERM
        LEX_NODE 'o', G_EINST, E_SETO, 0, 1, TERM
        LEX_NODE 'p', G_EINST, E_SETPE, 1, 3, TERM
          LEX_NODE 'o', G_EINST, E_SETPO, 0, 1, TERM
          LEX_NODE 'e', G_EINST, E_SETPE, 0, 0, TERM
        LEX_NODE 'n', 0, 0, 1, 0, 0
          LEX_NODE 'e', G_EINST, E_SETNE, 0, 1, TERM
          LEX_NODE 'z', G_EINST, E_SETNE, 0, 1, TERM
          LEX_NODE 'c', G_EINST, E_SETNB, 0, 1, TERM
          LEX_NODE 'b', G_EINST, E_SETNB, 0, 1, TERM
          LEX_NODE 's', G_EINST, E_SETNS, 0, 1, TERM
          LEX_NODE 'o', G_EINST, E_SETNO, 0, 1, TERM
          LEX_NODE 'p', G_EINST, E_SETPO, 0, 0, TERM
    LEX_NODE 'y', 0, 0, 1, 17, 0
      LEX_NODE 's', 0, 0, 1, 0, 0
        LEX_NODE 'e', 0, 0, 1, 8, 0
          LEX_NODE 'n', 0, 0, 1, 4, 0
            LEX_NODE 't', 0, 0, 1, 0, 0
              LEX_NODE 'e', 0, 0, 1, 0, 0
                LEX_NODE 'r', G_EINST, E_SYSENTER, 0, 0, TERM
          LEX_NODE 'x', 0, 0, 1, 0, 0
            LEX_NODE 'i', 0, 0, 1, 0, 0
              LEX_NODE 't', G_EINST, E_SYSEXIT, 0, 0, TERM
        LEX_NODE 'c', 0, 0, 1, 4, 0
          LEX_NODE 'a', 0, 0, 1, 0, 0
            LEX_NODE 'l', 0, 0, 1, 0, 0
              LEX_NODE 'l', G_EINST, E_SYSCALL, 0, 0, AMD64 + TERM
        LEX_NODE 'r', 0, 0, 1, 0, 0
          LEX_NODE 'e', 0, 0, 1, 0, 0
            LEX_NODE 't', G_EINST, E_SYSRET, 0, 0, AMD64 + TERM
    LEX_NODE 'g', 0, 0, 1, 3, 0
      LEX_NODE 'd', 0, 0, 1, 0, 0
        LEX_NODE 't', G_EINST, E_SGDT, 0, 0, TERM
    LEX_NODE 'm', 0, 0, 1, 0, 0
      LEX_NODE 's', 0, 0, 1, 0, 0
        LEX_NODE 'w', G_EINST, E_SMSW, 0, 0, TERM

.l_node:
  LEX_NODE 'l', 0, 0, 1, 0, 0
    LEX_NODE 'e', 0, 0, 1, 5, 0
      LEX_NODE 'a', G_INSTR, I_LEA, 1, 3, TERM
        LEX_NODE 'v', 0, 0, 1, 0, 0
          LEX_NODE 'e', G_INSTR, I_LEAVE, 0, 0, TERM
      LEX_NODE 's', G_INSTR, I_LES, 0, 0, TERM
    LEX_NODE 'a', 0, 0, 1, 4, 0
      LEX_NODE 'r', G_EINST, E_LAR, 0, 1, TERM
      LEX_NODE 'h', 0, 0, 1, 0, 0
        LEX_NODE 'f', G_INSTR, I_LAHF, 0, 0, TERM
    LEX_NODE 'o', 0, 0, 1, 16, 0
      LEX_NODE 'c', 0, 0, 1, 2, 0
        LEX_NODE 'k', G_PREF, P_LOCK, 0, 0, TERM
      LEX_NODE 'd', 0, 0, 1, 6, 0
        LEX_NODE 's', 0, 0, 1, 0, 0
          LEX_NODE 'b', G_INSTR, I_LODSB, 0, 1, TERM
          LEX_NODE 'w', G_INSTR, I_LODSW, 0, 1, TERM
          LEX_NODE 'd', G_INSTR, I_LODSD, 0, 1, TERM
          LEX_NODE 'q', G_INSTR, I_LODSQ, 0, 0, AMD64 + TERM
      LEX_NODE 'o', 0, 0, 1, 0, 0
        LEX_NODE 'p', G_INSTR, I_LOOP, 1, 0, TERM
          LEX_NODE 'z', G_INSTR, I_LOOPZ, 0, 1, TERM
          LEX_NODE 'e', G_INSTR, I_LOOPZ, 0, 1, TERM
          LEX_NODE 'n', 0, 0, 1, 0, 0
            LEX_NODE 'z', G_INSTR, I_LOOPNZ, 0, 1, TERM
            LEX_NODE 'e', G_INSTR, I_LOOPNZ, 0, 0, TERM
    LEX_NODE 'd', 0, 0, 1, 2, 0
      LEX_NODE 's', G_INSTR, I_LDS, 0, 0, TERM
    LEX_NODE 'l', 0, 0, 1, 3, 0
      LEX_NODE 'd', 0, 0, 1, 0, 0
        LEX_NODE 't', G_EINST, E_LLDT, 0, 0, TERM
    LEX_NODE 't', 0, 0, 1, 2, 0
      LEX_NODE 'r', G_EINST, E_LTR, 0, 0, TERM
    LEX_NODE 'f', 0, 0, 1, 2, 0
      LEX_NODE 's', G_EINST, E_LFS, 0, 0, TERM
    LEX_NODE 'g', 0, 0, 1, 4, 0
      LEX_NODE 's', G_EINST, E_LGS, 0, 1, TERM
      LEX_NODE 'd', 0, 0, 1, 0, 0
        LEX_NODE 't', G_EINST, E_LGDT, 0, 0, TERM
    LEX_NODE 's', 0, 0, 1, 3, 0
      LEX_NODE 'l', G_EINST, E_LSL, 0, 1, TERM
      LEX_NODE 's', G_EINST, E_LSS, 0, 0, TERM
    LEX_NODE 'i', 0, 0, 1, 3, 0
      LEX_NODE 'd', 0, 0, 1, 0, 0
        LEX_NODE 't', G_EINST, E_LIDT, 0, 0, TERM
    LEX_NODE 'm', 0, 0, 1, 0, 0
      LEX_NODE 's', 0, 0, 1, 0, 0
        LEX_NODE 'w', G_EINST, E_LMSW, 0, 0, TERM

.r_node:
  LEX_NODE 'r', 0, 0, 1, 0, 0
    LEX_NODE 'a', 0, 0, 1, 2, 0
      LEX_NODE 'x', G_REG64, R64_RAX, 0, 0, AMD64 + TERM
    LEX_NODE 'b', G_DIR, D_RB, 1, 3, TERM
      LEX_NODE 'x', G_REG64, R64_RBX, 0, 1, AMD64 + TERM
      LEX_NODE 'p', G_REG64, R64_RBP, 0, 0, AMD64 + TERM
    LEX_NODE 'i', 0, 0, 1, 2, 0
      LEX_NODE 'p', G_REG64, R64_RIP, 0, 0, AMD64 + TERM
    LEX_NODE '8', G_REG64, R64_R8, 1, 4, AMD64 + TERM
      LEX_NODE 'b', G_REG8, R8_R8B, 0, 1, AMD64 + TERM
      LEX_NODE 'w', G_REG16, R16_R8W, 0, 1, AMD64 + TERM
      LEX_NODE 'd', G_REG32, R32_R8D, 0, 0, AMD64 + TERM
    LEX_NODE '9', G_REG64, R64_R9, 1, 4, AMD64 + TERM
      LEX_NODE 'b', G_REG8, R8_R9B, 0, 1, AMD64 + TERM
      LEX_NODE 'w', G_REG16, R16_R9W, 0, 1, AMD64 + TERM
      LEX_NODE 'd', G_REG32, R32_R9D, 0, 0, AMD64 + TERM
    LEX_NODE '1', 0, 0, 1, 25, 0
      LEX_NODE '0', G_REG64, R64_R10, 1, 4, AMD64 + TERM
        LEX_NODE 'b', G_REG8, R8_R10B, 0, 1, AMD64 + TERM
        LEX_NODE 'w', G_REG16, R16_R10W, 0, 1, AMD64 + TERM
        LEX_NODE 'd', G_REG32, R32_R10D, 0, 0, AMD64 + TERM
      LEX_NODE '1', G_REG64, R64_R11, 1, 4, AMD64 + TERM
        LEX_NODE 'b', G_REG8, R8_R11B, 0, 1, AMD64 + TERM
        LEX_NODE 'w', G_REG16, R16_R11W, 0, 1, AMD64 + TERM
        LEX_NODE 'd', G_REG32, R32_R11D, 0, 0, AMD64 + TERM
      LEX_NODE '2', G_REG64, R64_R12, 1, 4, AMD64 + TERM
        LEX_NODE 'b', G_REG8, R8_R12B, 0, 1, AMD64 + TERM
        LEX_NODE 'w', G_REG16, R16_R12W, 0, 1, AMD64 + TERM
        LEX_NODE 'd', G_REG32, R32_R12D, 0, 0, AMD64 + TERM
      LEX_NODE '3', G_REG64, R64_R13, 1, 4, AMD64 + TERM
        LEX_NODE 'b', G_REG8, R8_R13B, 0, 1, AMD64 + TERM
        LEX_NODE 'w', G_REG16, R16_R13W, 0, 1, AMD64 + TERM
        LEX_NODE 'd', G_REG32, R32_R13D, 0, 0, AMD64 + TERM
      LEX_NODE '4', G_REG64, R64_R14, 1, 4, AMD64 + TERM
        LEX_NODE 'b', G_REG8, R8_R14B, 0, 1, AMD64 + TERM
        LEX_NODE 'w', G_REG16, R16_R14W, 0, 1, AMD64 + TERM
        LEX_NODE 'd', G_REG32, R32_R14D, 0, 0, AMD64 + TERM
      LEX_NODE '5', G_REG64, R64_R15, 1, 0, AMD64 + TERM
        LEX_NODE 'b', G_REG8, R8_R15B, 0, 1, AMD64 + TERM
        LEX_NODE 'w', G_REG16, R16_R15W, 0, 1, AMD64 + TERM
        LEX_NODE 'd', G_REG32, R32_R15D, 0, 0, AMD64 + TERM
    LEX_NODE 'e', 0, 0, 1, 9, 0
      LEX_NODE 't', G_INSTR, I_RET, 1, 2, TERM
        LEX_NODE 'f', G_INSTR, I_RETF, 0, 0, TERM
      LEX_NODE 'p', G_PREF, P_REPE, 1, 0, TERM
        LEX_NODE 'e', G_PREF, P_REPE, 0, 1, TERM
        LEX_NODE 'z', G_PREF, P_REPE, 0, 1, TERM
        LEX_NODE 'n', 0, 0, 1, 0, 0
          LEX_NODE 'e', G_PREF, P_REPNE, 0, 1, TERM
          LEX_NODE 'z', G_PREF, P_REPNE, 0, 0, TERM
    LEX_NODE 'o', 0, 0, 1, 3, 0
      LEX_NODE 'l', G_INSTR, I_ROL, 0, 1, TERM
      LEX_NODE 'r', G_INSTR, I_ROR, 0, 0, TERM
    LEX_NODE 's', 0, 0, 1, 4, 0
      LEX_NODE 'i', G_REG64, R64_RSI, 0, 1, TERM
      LEX_NODE 'p', G_REG64, R64_RSP, 0, 1, TERM
      LEX_NODE 'm', G_EINST, E_RSM, 0, 0, TERM
    LEX_NODE 'c', 0, 0, 1, 4, 0
      LEX_NODE 'x', G_REG64, R64_RCX, 0, 1, AMD64 + TERM
      LEX_NODE 'l', G_INSTR, I_RCL, 0, 1, TERM
      LEX_NODE 'r', G_INSTR, I_RCR, 0, 0, TERM
    LEX_NODE 'd', G_DIR, D_RD, 1, 12, TERM
      LEX_NODE 'x', G_REG64, R64_RDX, 0, 1, AMD64 + TERM
      LEX_NODE 'i', G_REG64, R64_RDI, 0, 1, AMD64 + TERM
      LEX_NODE 't', 0, 0, 1, 3, 0
        LEX_NODE 's', 0, 0, 1, 0, 0
          LEX_NODE 'c', G_EINST, E_RDTSC, 0, 0, TERM
      LEX_NODE 'm', 0, 0, 1, 3, 0
        LEX_NODE 's', 0, 0, 1, 0, 0
          LEX_NODE 'r', G_EINST, E_RDMSR, 0, 0, TERM
      LEX_NODE 'p', 0, 0, 1, 0, 0
        LEX_NODE 'm', 0, 0, 1, 0, 0
          LEX_NODE 'c', G_EINST, E_RDPMC, 0, 0, TERM
    LEX_NODE 'w', G_DIR, D_RW, 0, 1, TERM
    LEX_NODE 'q', G_DIR, D_RQ, 0, 0, TERM

.u_node:
  LEX_NODE 'u', 0, 0, 1, 0, 0
    LEX_NODE 'd', 0, 0, 1, 0, 0
      LEX_NODE '2', G_EINST, E_UD2, 0, 0, TERM

.h_node:
  LEX_NODE 'h', 0, 0, 1, 0, 0
    LEX_NODE 'l', 0, 0, 1, 0, 0
      LEX_NODE 't', G_INSTR, I_HLT, 0, 0, TERM

.v_node:
  LEX_NODE 'v', 0, 0, 1, 0, 0
    LEX_NODE 'e', 0, 0, 1, 0, 0
      LEX_NODE 'r', 0, 0, 1, 0, 0
        LEX_NODE 'r', G_EINST, E_VERR, 0, 1, TERM
        LEX_NODE 'w', G_EINST, E_VERW, 0, 0, TERM

.f_node:
  LEX_NODE 'f', 0, 0, 1, 0, 0
    LEX_NODE 's', G_SREG, SR_FS, 1, 0, TERM
      LEX_NODE ':', G_SPREF, SP_FS, 0, 0, TERM

.g_node:
  LEX_NODE 'g', 0, 0, 1, 0, 0
    LEX_NODE 's', G_SREG, SR_GS, 1, 0, TERM
      LEX_NODE ':', G_SPREF, SP_GS, 0, 0, TERM

.q_node:
  LEX_NODE 'q', 0, 0, 1, 0, 0
    LEX_NODE 'w', 0, 0, 1, 0, 0
      LEX_NODE 'o', 0, 0, 1, 0, 0
        LEX_NODE 'r', 0, 0, 1, 0, 0
          LEX_NODE 'd', G_CTRL, C_QWORD, 0, 0, AMD64 + TERM

; token trie
par_trie:
.mov_node:
  PAR_NODE G_REG32, 0x00, 1, 8, 0, 0
    PAR_NODE G_CTRL, 0x8B, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x89, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0xB8, 0, 1, IMM32_BIT, SHORT_OP + TERM
    PAR_NODE G_CTRL, 0xC7, 0, 1, IMM32_BIT, MODRM + TERM
    PAR_NODE G_SREG, 0x8C, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CREG, 0x20, 0, 1, 0, TWOBYTE + MODRM + TERM
    PAR_NODE G_DREG, 0x21, 0, 0, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 4, MEM32_BIT, 0
    PAR_NODE G_REG32, 0x89, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xC7, 0, 1, MEM32_BIT + IMM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_SREG, 0x8C, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE G_REG8, 0x88, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xC6, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 4, MEM16_BIT, 0
    PAR_NODE G_REG16, 0x89, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xC7, 0, 1, MEM16_BIT + IMM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_SREG, 0x8C, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 6, 0, 0
    PAR_NODE G_CTRL, 0x8B, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x89, 0, 1, 0, OPSIZE + MODRM + TERM
    PAR_NODE G_CTRL, 0xB8, 0, 1, IMM16_BIT, OPSIZE + SHORT_OP + TERM
    PAR_NODE G_CTRL, 0xC7, 0, 1, IMM16_BIT, OPSIZE + MODRM + TERM
    PAR_NODE G_SREG, 0x8C, 0, 0, 0, OPSIZE + MODRM + TERM
  PAR_NODE G_REG8, 0x00, 1, 5, 0, 0
    PAR_NODE G_REG8, 0x88, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0x8A, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xB0, 0, 1, IMM8_BIT, SHORT_OP + TERM
    PAR_NODE G_CTRL, 0xC6, 0, 0, IMM8_BIT, MODRM + TERM
  PAR_NODE G_SREG, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG16, 0x8E, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0x8E, 0, 0, MEM16_BIT, MODRM + SIB + TERM
  PAR_NODE G_CREG, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG32, 0x22, 0, 0, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_DREG, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG32, 0x23, 0, 0, 0, TWOBYTE + MODRM + TERM

.mul_node:
  PAR_NODE G_REG32, 0xf7, 0, 1, 0, MODRM + OPNUM5 + TERM
  PAR_NODE G_REG8, 0xf6, 0, 1, 0, OPSIZE + MODRM + OPNUM5 + TERM
  PAR_NODE G_REG16, 0xf7, 0, 1, 0, MODRM + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 1, MEM32_BIT, MODRM + SIB + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0xf6, 0, 1, MEM8_BIT, MODRM + SIB + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + OPNUM5 + TERM

.push_node:
  PAR_NODE G_REG32, 0x50, 0, 1, 0, SHORT_OP + TERM
  PAR_NODE G_REG32, 0xFF, 0, 1, 0, MODRM + OPNUM7 + TERM
  PAR_NODE G_REG16, 0x50, 0, 1, 0, OPSIZE + SHORT_OP + TERM
  PAR_NODE G_REG16, 0xFF, 0, 1, 0, OPSIZE + MODRM + OPNUM7 + TERM
  PAR_NODE G_CTRL, 0x68, 0, 1, IMM32_BIT, TERM
  PAR_NODE G_CTRL, 0xFF, 0, 1, MEM32_BIT, MODRM + SIB + OPNUM7 + TERM
  PAR_NODE G_CTRL, 0xFF, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + OPNUM7 + TERM
  PAR_NODE SR_ES, 0x06, 0, 1, 0, SREG + TERM
  PAR_NODE SR_CS, 0x0E, 0, 1, 0, SREG + TERM
  PAR_NODE SR_SS, 0x16, 0, 1, 0, SREG + TERM
  PAR_NODE SR_DS, 0x1E, 0, 1, 0, SREG + TERM
  PAR_NODE SR_FS, 0xA0, 0, 1, 0, TWOBYTE + SREG + TERM
  PAR_NODE SR_GS, 0xA8, 0, 0, 0, TWOBYTE + SREG + TERM

.pop_node:
  PAR_NODE G_REG32, 0x58, 0, 1, 0, SHORT_OP + TERM
  PAR_NODE G_REG32, 0x8F, 0, 1, 0, MODRM + TERM
  PAR_NODE G_CTRL, 0x8F, 0, 1, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x58, 0, 1, 0, OPSIZE + SHORT_OP + TERM
  PAR_NODE G_REG16, 0x8F, 0, 1, 0, OPSIZE + MODRM + TERM
  PAR_NODE G_CTRL, 0x8F, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
  PAR_NODE SR_ES, 0x07, 0, 1, 0, SREG + TERM
  PAR_NODE SR_SS, 0x17, 0, 1, 0, SREG + TERM
  PAR_NODE SR_DS, 0x1F, 0, 1, 0, SREG + TERM
  PAR_NODE SR_FS, 0xA1, 0, 1, 0, TWOBYTE + SREG + TERM
  PAR_NODE SR_GS, 0xA9, 0, 0, 0, TWOBYTE + SREG + TERM

.call_node:
  PAR_NODE G_CTRL, 0xE8, 1, 2, IMM32_BIT + REL32_BIT, TERM
    PAR_NODE G_CTRL, 0x9A, 0, 0, IMM32_BIT + IMM16_BIT, TERM
  PAR_NODE G_CTRL, 0xFF, 0, 1, MEM32_BIT, MODRM + SIB + OPNUM3 + TERM
  PAR_NODE G_REG32, 0xFF, 0, 0, 0, MODRM + OPNUM3 + TERM

.cmp_node:
  PAR_NODE R8_AL, 0x00, 1, 4, REG8_BIT, 0
    PAR_NODE G_CTRL, 0x3C, 0, 1, IMM8_BIT, TERM
    PAR_NODE G_CTRL, 0x3A, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x38, 0, 0, 0, MODRM + TERM
  PAR_NODE R16_AX, 0x00, 1, 4, REG16_BIT, 0
    PAR_NODE G_CTRL, 0x3D, 0, 1, IMM16_BIT, OPSIZE + TERM
    PAR_NODE G_CTRL, 0x3B, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x39, 0, 0, 0, OPSIZE + MODRM + TERM
  PAR_NODE R32_EAX, 0x00, 1, 4, REG32_BIT, 0
    PAR_NODE G_CTRL, 0x3D, 0, 1, IMM32_BIT, TERM
    PAR_NODE G_CTRL, 0x3B, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x39, 0, 0, 0, MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_REG32, 0x39, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0x81, 0, 0, MEM32_BIT + IMM32_BIT, MODRM + SIB + OPNUM8 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE G_REG8, 0x38, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0x80, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM8 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE G_REG16, 0x39, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0x81, 0, 0, MEM16_BIT + IMM16_BIT, OPSIZE + MODRM + SIB + OPNUM8 + TERM
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x3B, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x39, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0x81, 0, 0, IMM32_BIT, MODRM + OPNUM8 + TERM
  PAR_NODE G_REG8, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x3A, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x38, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0x80, 0, 0, IMM8_BIT, MODRM + OPNUM8 + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x3B, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x39, 0, 1, 0, OPSIZE + MODRM + TERM
    PAR_NODE G_CTRL, 0x81, 0, 0, IMM16_BIT, OPSIZE + MODRM + OPNUM8 + TERM

.jmp_node:
  PAR_NODE G_CTRL, 0xE9, 1, 2, IMM32_BIT + REL32_BIT, TERM
    PAR_NODE G_CTRL, 0xEA, 0, 0, IMM32_BIT + IMM16_BIT, TERM
  PAR_NODE G_CTRL, 0xFF, 0, 1, MEM32_BIT, SIB + MODRM + OPNUM5 + TERM
  PAR_NODE G_REG32, 0xFF, 0, 0, 0, MODRM + OPNUM5 + TERM

.test_node:
  PAR_NODE R8_AL, 0x00, 1, 3, REG8_BIT, 0
    PAR_NODE G_REG8, 0x84, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0xA8, 0, 0, IMM8_BIT, TERM
  PAR_NODE R16_AX, 0x00, 1, 3, REG16_BIT, 0
    PAR_NODE G_REG16, 0x84, 0, 1, 0, OPSIZE + MODRM + TERM
    PAR_NODE G_CTRL, 0xA9, 0, 0, IMM16_BIT, OPSIZE + TERM
  PAR_NODE R32_EAX, 0x00, 1, 3, REG32_BIT, 0
    PAR_NODE G_REG32, 0x85, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0xA9, 0, 0, IMM32_BIT, TERM
  PAR_NODE G_CTRL, 0x00, 1, 2, MEM32_BIT, 0
    PAR_NODE G_REG32, 0x85, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 2, MEM8_BIT, 0
    PAR_NODE G_REG8, 0x84, 0, 0, MEM8_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 2, MEM16_BIT, 0
    PAR_NODE G_REG16, 0x84, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x85, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0xf7, 0, 0, IMM32_BIT, MODRM + OPNUM1 + TERM
  PAR_NODE G_REG8, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG8, 0x84, 0, 1, 0, MODRM + TERM
    PAR_NODE G_CTRL, 0xf7, 0, 0, IMM8_BIT, MODRM + OPNUM1 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG16, 0x84, 0, 1, 0, OPSIZE + MODRM + TERM
    PAR_NODE G_CTRL, 0xf7, 0, 0, IMM16_BIT, OPSIZE + MODRM + OPNUM1 + TERM

.or_node:
  PAR_NODE R8_AL, 0x00, 1, 4, REG8_BIT, 0
    PAR_NODE G_CTRL, 0x0C, 0, 1, IMM8_BIT, TERM
    PAR_NODE G_CTRL, 0x08, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x08, 0, 0, 0, MODRM + TERM
  PAR_NODE R16_AX, 0x00, 1, 4, REG16_BIT, 0
    PAR_NODE G_CTRL, 0x0D, 0, 1, IMM16_BIT, OPSIZE + TERM
    PAR_NODE G_CTRL, 0x0B, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x09, 0, 0, 0, OPSIZE + MODRM + TERM
  PAR_NODE R32_EAX, 0x00, 1, 4, REG32_BIT, 0
    PAR_NODE G_CTRL, 0x0D, 0, 1, IMM32_BIT, TERM
    PAR_NODE G_CTRL, 0x0B, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x09, 0, 0, 0, MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM32_BIT + IMM32_BIT, MODRM + SIB + OPNUM2 + TERM
    PAR_NODE G_REG32, 0x09, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM2 + TERM
    PAR_NODE G_REG8, 0x08, 0, 0, MEM8_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM16_BIT + IMM16_BIT, OPSIZE + MODRM + SIB + OPNUM2 + TERM
    PAR_NODE G_REG16, 0x09, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM32_BIT, MODRM + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0x0B, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x09, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG8, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, IMM8_BIT, MODRM + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0x08, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x08, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM16_BIT, OPSIZE + MODRM + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0x0B, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x09, 0, 0, 0, OPSIZE + MODRM + TERM

.and_node:
  PAR_NODE R8_AL, 0x00, 1, 4, REG8_BIT, 0
    PAR_NODE G_CTRL, 0x24, 0, 1, IMM8_BIT, TERM
    PAR_NODE G_CTRL, 0x20, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x20, 0, 0, 0, MODRM + TERM
  PAR_NODE R16_AX, 0x00, 1, 4, REG16_BIT, 0
    PAR_NODE G_CTRL, 0x25, 0, 1, IMM16_BIT, OPSIZE + TERM
    PAR_NODE G_CTRL, 0x23, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x21, 0, 0, 0, OPSIZE + MODRM + TERM
  PAR_NODE R32_EAX, 0x00, 1, 4, REG32_BIT, 0
    PAR_NODE G_CTRL, 0x25, 0, 1, IMM32_BIT, TERM
    PAR_NODE G_CTRL, 0x23, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x21, 0, 0, 0, MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM32_BIT + IMM32_BIT, MODRM + SIB + OPNUM5 + TERM
    PAR_NODE G_REG32, 0x21, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM5 + TERM
    PAR_NODE G_REG8, 0x20, 0, 0, MEM8_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM16_BIT + IMM16_BIT, OPSIZE + MODRM + SIB + OPNUM5 + TERM
    PAR_NODE G_REG16, 0x21, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM32_BIT, MODRM + OPNUM5 + TERM
    PAR_NODE G_CTRL, 0x23, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x21, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG8, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, IMM8_BIT, MODRM + OPNUM5 + TERM
    PAR_NODE G_CTRL, 0x20, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x20, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM16_BIT, OPSIZE + MODRM + OPNUM5 + TERM
    PAR_NODE G_CTRL, 0x23, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x21, 0, 0, 0, OPSIZE + MODRM + TERM

.add_node:
  PAR_NODE R8_AL, 0x00, 1, 4, REG8_BIT, 0
    PAR_NODE G_CTRL, 0x04, 0, 1, IMM8_BIT, TERM
    PAR_NODE G_CTRL, 0x02, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x00, 0, 0, 0, MODRM + TERM
  PAR_NODE R16_AX, 0x00, 1, 4, REG16_BIT, 0
    PAR_NODE G_CTRL, 0x05, 0, 1, IMM16_BIT, OPSIZE + TERM
    PAR_NODE G_CTRL, 0x03, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x01, 0, 0, 0, OPSIZE + MODRM + TERM
  PAR_NODE R32_EAX, 0x00, 1, 4, REG32_BIT, 0
    PAR_NODE G_CTRL, 0x05, 0, 1, IMM32_BIT, TERM
    PAR_NODE G_CTRL, 0x03, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x01, 0, 0, 0, MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM32_BIT + IMM32_BIT, MODRM + SIB + OPNUM1 + TERM
    PAR_NODE G_REG32, 0x01, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM1 + TERM
    PAR_NODE G_REG8, 0x00, 0, 0, MEM8_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM16_BIT + IMM16_BIT, OPSIZE + MODRM + SIB + OPNUM1 + TERM
    PAR_NODE G_REG16, 0x01, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM32_BIT, MODRM + OPNUM1 + TERM
    PAR_NODE G_CTRL, 0x03, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x01, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG8, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, IMM8_BIT, MODRM + OPNUM1 + TERM
    PAR_NODE G_CTRL, 0x02, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x00, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM16_BIT, OPSIZE + MODRM + OPNUM1 + TERM
    PAR_NODE G_CTRL, 0x03, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x01, 0, 0, 0, OPSIZE + MODRM + TERM

.xor_node:
  PAR_NODE R8_AL, 0x00, 1, 4, REG8_BIT, 0
    PAR_NODE G_CTRL, 0x34, 0, 1, IMM8_BIT, TERM
    PAR_NODE G_CTRL, 0x32, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x30, 0, 0, 0, MODRM + TERM
  PAR_NODE R16_AX, 0x00, 1, 4, REG16_BIT, 0
    PAR_NODE G_CTRL, 0x35, 0, 1, IMM16_BIT, OPSIZE + TERM
    PAR_NODE G_CTRL, 0x33, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x31, 0, 0, 0, OPSIZE + MODRM + TERM
  PAR_NODE R32_EAX, 0x00, 1, 4, REG32_BIT, 0
    PAR_NODE G_CTRL, 0x35, 0, 1, IMM32_BIT, TERM
    PAR_NODE G_CTRL, 0x33, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x31, 0, 0, 0, MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM32_BIT + IMM32_BIT, MODRM + SIB + OPNUM7 + TERM
    PAR_NODE G_REG32, 0x31, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE G_REG8, 0x30, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0x80, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM7 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM16_BIT + IMM16_BIT, OPSIZE + MODRM + SIB + OPNUM7 + TERM
    PAR_NODE G_REG16, 0x31, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM32_BIT, MODRM + OPNUM7 + TERM
    PAR_NODE G_CTRL, 0x33, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x31, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG8, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, IMM8_BIT, MODRM + OPNUM7 + TERM
    PAR_NODE G_CTRL, 0x32, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x30, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM16_BIT, OPSIZE + MODRM + OPNUM7 + TERM
    PAR_NODE G_CTRL, 0x33, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x31, 0, 0, 0, OPSIZE + MODRM + TERM

.not_node:
  PAR_NODE G_REG8, 0xF6, 0, 1, 0, MODRM + OPNUM3 + TERM
  PAR_NODE G_REG32, 0xF7, 0, 1, 0, MODRM + OPNUM3 + TERM
  PAR_NODE G_REG16, 0xF7, 0, 1, 0, OPSIZE + MODRM + OPNUM3 + TERM
  PAR_NODE G_CTRL, 0xF7, 0, 1, MEM8_BIT, MODRM + OPNUM3 + TERM
  PAR_NODE G_CTRL, 0xF7, 0, 1, MEM32_BIT, MODRM + OPNUM3 + TERM
  PAR_NODE G_CTRL, 0xF7, 0, 0, MEM16_BIT, OPSIZE + MODRM + OPNUM3 + TERM

.int_node:
  PAR_NODE G_CTRL, 0xCD, 0, 0, IMM8_BIT, TERM

.inc_node:
  PAR_NODE G_CTRL, 0xFE, 0, 1, MEM8_BIT, SIB + MODRM + OPNUM1 + TERM
  PAR_NODE G_CTRL, 0xFF, 0, 1, MEM32_BIT, SIB + MODRM + OPNUM1 + TERM
  PAR_NODE G_CTRL, 0xFF, 0, 1, MEM16_BIT, OPSIZE + SIB + MODRM + OPNUM1 + TERM
  PAR_NODE G_REG8, 0xFE, 0, 1, 0, MODRM + OPNUM1 + TERM
  PAR_NODE G_REG32, 0xFF, 0, 1, 0, MODRM + OPNUM1 + TERM
  PAR_NODE G_REG16, 0xFF, 0, 0, 0, OPSIZE + MODRM + OPNUM1 + TERM

.dec_node:
  PAR_NODE G_CTRL, 0xFE, 0, 1, MEM8_BIT, SIB + MODRM + OPNUM2 + TERM
  PAR_NODE G_CTRL, 0xFF, 0, 1, MEM32_BIT, SIB + MODRM + OPNUM2 + TERM
  PAR_NODE G_CTRL, 0xFF, 0, 1, MEM16_BIT, OPSIZE + SIB + MODRM + OPNUM2 + TERM
  PAR_NODE G_REG8, 0xFE, 0, 1, 0, MODRM + OPNUM2 + TERM
  PAR_NODE G_REG32, 0xFF, 0, 1, 0, MODRM + OPNUM2 + TERM
  PAR_NODE G_REG16, 0xFF, 0, 0, 0, OPSIZE + MODRM + OPNUM2 + TERM

.sub_node:
  PAR_NODE R8_AL, 0x00, 1, 4, REG8_BIT, 0
    PAR_NODE G_CTRL, 0x2C, 0, 1, IMM8_BIT, TERM
    PAR_NODE G_CTRL, 0x08, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x28, 0, 0, 0, MODRM + TERM
  PAR_NODE R16_AX, 0x00, 1, 4, REG16_BIT, 0
    PAR_NODE G_CTRL, 0x2D, 0, 1, IMM16_BIT, OPSIZE + TERM
    PAR_NODE G_CTRL, 0x2B, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x29, 0, 0, 0, OPSIZE + MODRM + TERM
  PAR_NODE R32_EAX, 0x00, 1, 4, REG32_BIT, 0
    PAR_NODE G_CTRL, 0x2D, 0, 1, IMM32_BIT, TERM
    PAR_NODE G_CTRL, 0x2B, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x29, 0, 0, 0, MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM4 + TERM
    PAR_NODE G_REG8, 0x28, 0, 0, MEM8_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM32_BIT + IMM32_BIT, MODRM + SIB + OPNUM4 + TERM
    PAR_NODE G_REG32, 0x29, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM16_BIT + IMM16_BIT, OPSIZE + MODRM + SIB + OPNUM4 + TERM
    PAR_NODE G_REG16, 0x29, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM32_BIT, MODRM + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0x2B, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x29, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG8, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, IMM8_BIT, MODRM + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0x08, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x28, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM16_BIT, OPSIZE + MODRM + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0x2B, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x29, 0, 0, 0, OPSIZE + MODRM + TERM

.lea_node:
  PAR_NODE G_REG32, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x8D, 0, 0, MEM32_BIT, MODRM + SIB + TERM

.xchg_node:
  PAR_NODE R32_EAX, 0x00, 1, 9, REG32_BIT, 0
    PAR_NODE R32_EAX, 0x90, 0, 1, REG32_BIT, TERM
    PAR_NODE R32_ECX, 0x91, 0, 1, REG32_BIT, TERM
    PAR_NODE R32_EDX, 0x92, 0, 1, REG32_BIT, TERM
    PAR_NODE R32_EBX, 0x93, 0, 1, REG32_BIT, TERM
    PAR_NODE R32_ESP, 0x94, 0, 1, REG32_BIT, TERM
    PAR_NODE R32_EBP, 0x95, 0, 1, REG32_BIT, TERM
    PAR_NODE R32_ESI, 0x96, 0, 1, REG32_BIT, TERM
    PAR_NODE R32_EDI, 0x97, 0, 0, REG32_BIT, TERM
  PAR_NODE R16_AX, 0x00, 1, 9, REG16_BIT, 0
    PAR_NODE R16_AX, 0x90, 0, 1, REG16_BIT, OPSIZE + TERM
    PAR_NODE R16_CX, 0x91, 0, 1, REG16_BIT, OPSIZE + TERM
    PAR_NODE R16_DX, 0x92, 0, 1, REG16_BIT, OPSIZE + TERM
    PAR_NODE R16_BX, 0x93, 0, 1, REG16_BIT, OPSIZE + TERM
    PAR_NODE R16_SP, 0x94, 0, 1, REG16_BIT, OPSIZE + TERM
    PAR_NODE R16_BP, 0x95, 0, 1, REG16_BIT, OPSIZE + TERM
    PAR_NODE R16_SI, 0x96, 0, 1, REG16_BIT, OPSIZE + TERM
    PAR_NODE R16_DI, 0x97, 0, 0, REG16_BIT, OPSIZE + TERM
  PAR_NODE G_REG32, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG32, 0x87, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG8, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG8, 0x86, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG16, 0x87, 0, 0, 0, OPSIZE + MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 2, MEM32_BIT, 0
    PAR_NODE G_REG32, 0x87, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 2, MEM8_BIT, 0
    PAR_NODE G_REG8, 0x86, 0, 0, MEM8_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 0, MEM16_BIT, 0
    PAR_NODE G_REG16, 0x87, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM

.nop_node:
  PAR_NODE G_CTRL, 0x90, 0, 0, NOP_BIT, TERM

.ret_node:
  PAR_NODE G_CTRL, 0xC2, 0, 1, IMM16_BIT, TERM
  PAR_NODE G_CTRL, 0xC3, 0, 0, NOP_BIT, TERM

.pusha_node:
  PAR_NODE G_CTRL, 0x60, 0, 0, NOP_BIT, TERM

.popa_node:
  PAR_NODE G_CTRL, 0x61, 0, 0, NOP_BIT, TERM

.adc_node:
  PAR_NODE R8_AL, 0x00, 1, 4, REG8_BIT, 0
    PAR_NODE G_CTRL, 0x14, 0, 1, IMM8_BIT, TERM
    PAR_NODE G_CTRL, 0x10, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x10, 0, 0, 0, MODRM + TERM
  PAR_NODE R16_AX, 0x00, 1, 4, REG16_BIT, 0
    PAR_NODE G_CTRL, 0x15, 0, 1, IMM16_BIT, OPSIZE + TERM
    PAR_NODE G_CTRL, 0x13, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x11, 0, 0, 0, OPSIZE + MODRM + TERM
  PAR_NODE R32_EAX, 0x00, 1, 4, REG32_BIT, 0
    PAR_NODE G_CTRL, 0x15, 0, 1, IMM32_BIT, TERM
    PAR_NODE G_CTRL, 0x13, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x11, 0, 0, 0, MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM32_BIT + IMM32_BIT, MODRM + SIB + OPNUM3 + TERM
    PAR_NODE G_REG32, 0x11, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM3 + TERM
    PAR_NODE G_REG8, 0x10, 0, 0, MEM8_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM16_BIT + IMM16_BIT, OPSIZE + MODRM + SIB + OPNUM3 + TERM
    PAR_NODE G_REG16, 0x11, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM32_BIT, MODRM + OPNUM3 + TERM
    PAR_NODE G_CTRL, 0x13, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x11, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG8, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, IMM8_BIT, MODRM + OPNUM3 + TERM
    PAR_NODE G_CTRL, 0x10, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x10, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM16_BIT, OPSIZE + MODRM + OPNUM3 + TERM
    PAR_NODE G_CTRL, 0x13, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x11, 0, 0, 0, OPSIZE + MODRM + TERM

.sbb_node:
  PAR_NODE R8_AL, 0x00, 1, 4, REG8_BIT, 0
    PAR_NODE G_CTRL, 0x1C, 0, 1, IMM8_BIT, TERM
    PAR_NODE G_CTRL, 0x18, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x18, 0, 0, 0, MODRM + TERM
  PAR_NODE R16_AX, 0x00, 1, 4, REG16_BIT, 0
    PAR_NODE G_CTRL, 0x1D, 0, 1, IMM16_BIT, OPSIZE + TERM
    PAR_NODE G_CTRL, 0x1B, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x19, 0, 0, 0, OPSIZE + MODRM + TERM
  PAR_NODE R32_EAX, 0x00, 1, 4, REG32_BIT, 0
    PAR_NODE G_CTRL, 0x1D, 0, 1, IMM32_BIT, TERM
    PAR_NODE G_CTRL, 0x1B, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x19, 0, 0, 0, MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM32_BIT + IMM32_BIT, MODRM + SIB + OPNUM4 + TERM
    PAR_NODE G_REG32, 0x19, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM4 + TERM
    PAR_NODE G_REG8, 0x18, 0, 0, MEM8_BIT, MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, MEM16_BIT + IMM16_BIT, OPSIZE + MODRM + SIB + OPNUM4 + TERM
    PAR_NODE G_REG16, 0x19, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM32_BIT, MODRM + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0x1B, 0, 1, MEM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0x19, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG8, 0x00, 1, 4, 0, 0
    PAR_NODE G_CTRL, 0x80, 0, 1, IMM8_BIT, MODRM + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0x18, 0, 1, MEM8_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG8, 0x18, 0, 0, 0, MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x81, 0, 1, IMM16_BIT, OPSIZE + MODRM + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0x1B, 0, 1, MEM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0x19, 0, 0, 0, OPSIZE + MODRM + TERM

.daa_node:
  PAR_NODE G_CTRL, 0x27, 0, 0, NOP_BIT, TERM

.das_node:
  PAR_NODE G_CTRL, 0x2F, 0, 0, NOP_BIT, TERM

.aaa_node:
  PAR_NODE G_CTRL, 0x37, 0, 0, NOP_BIT, TERM

.aas_node:
  PAR_NODE G_CTRL, 0x3F, 0, 0, NOP_BIT, TERM

.bound_node:
  PAR_NODE G_REG32, 0x00, 1, 2, 0, 0
    PAR_NODE G_CTRL, 0x62, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0x62, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM

.arpl_node:
  PAR_NODE G_REG16, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG16, 0x63, 0, 0, 0, MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 0, MEM16_BIT, 0
    PAR_NODE G_REG16, 0x63, 0, 0, 0, MODRM + SIB + TERM

.imul_node:
  PAR_NODE G_REG32, 0xf7, 1, 5, 0, MODRM + OPNUM6 + TERM
    PAR_NODE G_CTRL, 0xAF, 1, 2, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
      PAR_NODE G_CTRL, 0x69, 0, 0, MEM32_BIT + IMM32_BIT, MODRM + SIB + TERM
    PAR_NODE G_REG32, 0xAF, 1, 0, REGFIRST_BIT, TWOBYTE + MODRM + TERM
      PAR_NODE G_CTRL, 0x69, 0, 0, IMM32_BIT + REGFIRST_BIT, MODRM + TERM
  PAR_NODE G_REG16, 0xf7, 1, 5, 0, MODRM + OPNUM6 + TERM
    PAR_NODE G_CTRL, 0xAF, 1, 2, MEM16_BIT, TWOBYTE + OPSIZE + MODRM + SIB + TERM
      PAR_NODE G_CTRL, 0x69, 0, 0, MEM16_BIT + IMM16_BIT, OPSIZE + MODRM + SIB + TERM
    PAR_NODE G_REG16, 0xAF, 1, 0, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
      PAR_NODE G_CTRL, 0x69, 0, 0, IMM16_BIT + REGFIRST_BIT, OPSIZE + MODRM + TERM
  PAR_NODE G_REG8, 0xf6, 0, 1, 0, OPSIZE + MODRM + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 1, MEM32_BIT, MODRM + SIB + OPNUM6 + TERM
  PAR_NODE G_CTRL, 0xf6, 0, 1, MEM8_BIT, MODRM + SIB + OPNUM6 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + OPNUM6 + TERM

.insb_node:
  PAR_NODE G_CTRL, 0x6C, 0, 0, NOP_BIT, TERM

.insw_node:
  PAR_NODE G_CTRL, 0x6D, 0, 0, NOP_BIT, OPSIZE + TERM

.insd_node:
  PAR_NODE G_CTRL, 0x6D, 0, 0, NOP_BIT, TERM

.outsb_node:
  PAR_NODE G_CTRL, 0x6E, 0, 0, NOP_BIT, TERM

.outsw_node:
  PAR_NODE G_CTRL, 0x6F, 0, 0, NOP_BIT, OPSIZE + TERM

.outsd_node:
  PAR_NODE G_CTRL, 0x6F, 0, 0, NOP_BIT, TERM

.cbw_node:
  PAR_NODE G_CTRL, 0x98, 0, 0, NOP_BIT, OPSIZE + TERM

.cwd_node:
  PAR_NODE G_CTRL, 0x99, 0, 0, NOP_BIT, OPSIZE + TERM

.wait_node:
  PAR_NODE G_CTRL, 0x9B, 0, 0, NOP_BIT, TERM

.pushf_node:
  PAR_NODE G_CTRL, 0x9C, 0, 0, NOP_BIT, TERM

.popf_node:
  PAR_NODE G_CTRL, 0x9D, 0, 0, NOP_BIT, TERM

.sahf_node:
  PAR_NODE G_CTRL, 0x9E, 0, 0, NOP_BIT, TERM

.lahf_node:
  PAR_NODE G_CTRL, 0x9F, 0, 0, NOP_BIT, TERM

.movsb_node:
  PAR_NODE G_CTRL, 0xA4, 0, 0, NOP_BIT, TERM

.movsw_node:
  PAR_NODE G_CTRL, 0xA5, 0, 0, NOP_BIT, OPSIZE + TERM

.movsd_node:
  PAR_NODE G_CTRL, 0xA5, 0, 0, NOP_BIT, TERM

.cmpsb_node:
  PAR_NODE G_CTRL, 0xA6, 0, 0, NOP_BIT, TERM

.cmpsw_node:
  PAR_NODE G_CTRL, 0xA7, 0, 0, NOP_BIT, OPSIZE + TERM

.cmpsd_node:
  PAR_NODE G_CTRL, 0xA7, 0, 0, NOP_BIT, TERM

.stosb_node:
  PAR_NODE G_CTRL, 0xAA, 0, 0, NOP_BIT, TERM

.stosw_node:
  PAR_NODE G_CTRL, 0xAB, 0, 0, NOP_BIT, OPSIZE + TERM

.stosd_node:
  PAR_NODE G_CTRL, 0xAB, 0, 0, NOP_BIT, TERM

.lodsb_node:
  PAR_NODE G_CTRL, 0xAC, 0, 0, NOP_BIT, TERM

.lodsw_node:
  PAR_NODE G_CTRL, 0xAD, 0, 0, NOP_BIT, OPSIZE + TERM

.lodsd_node:
  PAR_NODE G_CTRL, 0xAD, 0, 0, NOP_BIT, TERM

.scasb_node:
  PAR_NODE G_CTRL, 0xAE, 0, 0, NOP_BIT, TERM

.scasw_node:
  PAR_NODE G_CTRL, 0xAF, 0, 0, NOP_BIT, OPSIZE + TERM

.scasd_node:
  PAR_NODE G_CTRL, 0xAF, 0, 0, NOP_BIT, TERM

.rol_node:
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM32_BIT + REG8_BIT, MODRM + SIB + OPNUM1 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM32_BIT + IMM8_BIT, MODRM + SIB + OPNUM1 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM16_BIT + REG8_BIT, MODRM + SIB + OPNUM1 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM16_BIT + IMM8_BIT, OPSIZE + MODRM + SIB + OPNUM1 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, MEM8_BIT + REG8_BIT, MODRM + SIB + OPNUM1 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM1 + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, MODRM + OPNUM1 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, MODRM + OPNUM1 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, OPSIZE + MODRM + OPNUM1 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, OPSIZE + MODRM + OPNUM1 + TERM
  PAR_NODE G_REG8, 0x00, 1, 0, 0, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, REG8_BIT, MODRM + OPNUM1 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, IMM8_BIT, MODRM + OPNUM1 + TERM

.ror_node:
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM32_BIT + REG8_BIT, MODRM + SIB + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM32_BIT + IMM8_BIT, MODRM + SIB + OPNUM2 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM16_BIT + REG8_BIT, MODRM + SIB + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM16_BIT + IMM8_BIT, OPSIZE + MODRM + OPNUM2 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, MEM8_BIT + REG8_BIT, MODRM + SIB + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM2 + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, MODRM + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, MODRM + OPNUM2 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, OPSIZE + MODRM + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, OPSIZE + MODRM + OPNUM2 + TERM
  PAR_NODE G_REG8, 0x00, 1, 0, 0, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, REG8_BIT, MODRM + OPNUM2 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, IMM8_BIT, MODRM + OPNUM2 + TERM

.rcl_node:
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM32_BIT + REG8_BIT, MODRM + SIB + OPNUM3 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM32_BIT + IMM8_BIT, MODRM + SIB + OPNUM3 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM16_BIT + REG8_BIT, MODRM + SIB + OPNUM3 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM16_BIT + IMM8_BIT, OPSIZE + MODRM + OPNUM3 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, MEM8_BIT + REG8_BIT, MODRM + SIB + OPNUM3 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM3 + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, MODRM + OPNUM3 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, MODRM + OPNUM3 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, OPSIZE + MODRM + OPNUM3 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, OPSIZE + MODRM + OPNUM3 + TERM
  PAR_NODE G_REG8, 0x00, 1, 0, 0, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, REG8_BIT, MODRM + OPNUM3 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, IMM8_BIT, MODRM + OPNUM3 + TERM

.rcr_node:
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM32_BIT + REG8_BIT, MODRM + SIB + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM32_BIT + IMM8_BIT, MODRM + SIB + OPNUM4 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM16_BIT + REG8_BIT, MODRM + SIB + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM16_BIT + IMM8_BIT, OPSIZE + MODRM + OPNUM4 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, MEM8_BIT + REG8_BIT, MODRM + SIB + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM4 + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, MODRM + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, MODRM + OPNUM4 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, OPSIZE + MODRM + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, OPSIZE + MODRM + OPNUM4 + TERM
  PAR_NODE G_REG8, 0x00, 1, 0, 0, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, REG8_BIT, MODRM + OPNUM4 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, IMM8_BIT, MODRM + OPNUM4 + TERM

.shl_node:
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM32_BIT + REG8_BIT, MODRM + SIB + OPNUM5 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM32_BIT + IMM8_BIT, MODRM + SIB + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM16_BIT + REG8_BIT, MODRM + SIB + OPNUM5 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM16_BIT + IMM8_BIT, OPSIZE + MODRM + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, MEM8_BIT + REG8_BIT, MODRM + SIB + OPNUM5 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM5 + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, MODRM + OPNUM5 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, MODRM + OPNUM5 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, OPSIZE + MODRM + OPNUM5 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, OPSIZE + MODRM + OPNUM5 + TERM
  PAR_NODE G_REG8, 0x00, 1, 0, 0, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, REG8_BIT, MODRM + OPNUM5 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, IMM8_BIT, MODRM + OPNUM5 + TERM

.shr_node:
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM32_BIT + REG8_BIT, MODRM + SIB + OPNUM6 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM32_BIT + IMM8_BIT, MODRM + SIB + OPNUM6 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM16_BIT + REG8_BIT, MODRM + SIB + OPNUM6 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM16_BIT + IMM8_BIT, OPSIZE + MODRM + OPNUM6 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, MEM8_BIT + REG8_BIT, MODRM + SIB + OPNUM6 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM6 + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, MODRM + OPNUM6 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, MODRM + OPNUM6 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, OPSIZE + MODRM + OPNUM6 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, OPSIZE + MODRM + OPNUM6 + TERM
  PAR_NODE G_REG8, 0x00, 1, 0, 0, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, REG8_BIT, MODRM + OPNUM6 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, IMM8_BIT, MODRM + OPNUM6 + TERM

.sal_node:
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM32_BIT + REG8_BIT, MODRM + SIB + OPNUM7 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM32_BIT + IMM8_BIT, MODRM + SIB + OPNUM7 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM16_BIT + REG8_BIT, MODRM + SIB + OPNUM7 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM16_BIT + IMM8_BIT, OPSIZE + MODRM + OPNUM7 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, MEM8_BIT + REG8_BIT, MODRM + SIB + OPNUM7 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM7 + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, MODRM + OPNUM7 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, MODRM + OPNUM7 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, OPSIZE + MODRM + OPNUM7 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, OPSIZE + MODRM + OPNUM7 + TERM
  PAR_NODE G_REG8, 0x00, 1, 0, 0, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, REG8_BIT, MODRM + OPNUM7 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, IMM8_BIT, MODRM + OPNUM7 + TERM

.sar_node:
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM32_BIT + REG8_BIT, MODRM + SIB + OPNUM8 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM32_BIT + IMM8_BIT, MODRM + SIB + OPNUM8 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM16_BIT, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, MEM16_BIT + REG8_BIT, MODRM + SIB + OPNUM8 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, MEM16_BIT + IMM8_BIT, OPSIZE + MODRM + OPNUM8 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM8_BIT, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, MEM8_BIT + REG8_BIT, MODRM + SIB + OPNUM8 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, MEM8_BIT + IMM8_BIT, MODRM + SIB + OPNUM8 + TERM
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, MODRM + OPNUM8 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, MODRM + OPNUM8 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE R8_CL, 0xD3, 0, 1, REG8_BIT, OPSIZE + MODRM + OPNUM8 + TERM
    PAR_NODE G_CTRL, 0xC1, 0, 0, IMM8_BIT, OPSIZE + MODRM + OPNUM8 + TERM
  PAR_NODE G_REG8, 0x00, 1, 0, 0, 0
    PAR_NODE R8_CL, 0xD2, 0, 1, REG8_BIT, MODRM + OPNUM8 + TERM
    PAR_NODE G_CTRL, 0xC0, 0, 0, IMM8_BIT, MODRM + OPNUM8 + TERM

.les_node:
  PAR_NODE G_REG32, 0x00, 1, 2, 0, 0
    PAR_NODE G_CTRL, 0xC4, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0xC4, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM

.lds_node:
  PAR_NODE G_REG32, 0x00, 1, 2, 0, 0
    PAR_NODE G_CTRL, 0xC5, 0, 0, MEM32_BIT, MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0xC5, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + TERM

.enter_node:
  PAR_NODE G_CTRL, 0x00, 1, 0, IMM16_BIT, 0
    PAR_NODE G_CTRL, 0xC8, 0, 0, IMM8_BIT + IMM16_BIT, TERM

.leave_node:
  PAR_NODE G_CTRL, 0xC9, 0, 0, NOP_BIT, TERM

.retf_node:
  PAR_NODE G_CTRL, 0xCA, 0, 1, IMM16_BIT, TERM
  PAR_NODE G_CTRL, 0xCB, 0, 0, NOP_BIT, TERM

.int3_node:
  PAR_NODE G_CTRL, 0xCC, 0, 0, NOP_BIT, TERM

.into_node:
  PAR_NODE G_CTRL, 0xCE, 0, 0, NOP_BIT, TERM

.iret_node:
  PAR_NODE G_CTRL, 0xCF, 0, 0, NOP_BIT, TERM

.aam_node:
  PAR_NODE G_CTRL, 0xD4, 0, 0, IMM8_BIT, TERM

.aad_node:
  PAR_NODE G_CTRL, 0xD5, 0, 0, IMM8_BIT, TERM

.salc_node:
  PAR_NODE G_CTRL, 0xD6, 0, 0, NOP_BIT, TERM

.xlat_node:
  PAR_NODE G_CTRL, 0xD7, 0, 0, NOP_BIT, TERM

.loopnz_node:
  PAR_NODE G_CTRL, 0xE0, 0, 0, IMM8_BIT + REL8_BIT, TERM

.loopz_node:
  PAR_NODE G_CTRL, 0xE1, 0, 0, IMM8_BIT + REL8_BIT, TERM

.loop_node:
  PAR_NODE G_CTRL, 0xE2, 0, 0, IMM8_BIT + REL8_BIT, TERM

.jcxz_node:
  PAR_NODE G_CTRL, 0xE3, 0, 0, IMM8_BIT + REL8_BIT, TERM

.in_node:
  PAR_NODE R8_AL, 0x00, 1, 3, REG8_BIT, 0
    PAR_NODE R16_DX, 0xEC, 0, 1, REG16_BIT, TERM
    PAR_NODE G_CTRL, 0xE4, 0, 0, IMM8_BIT, TERM
  PAR_NODE R16_AX, 0x00, 1, 3, REG16_BIT, 0
    PAR_NODE R16_DX, 0xED, 0, 1, REG16_BIT, OPSIZE + TERM
    PAR_NODE G_CTRL, 0xE5, 0, 0, IMM8_BIT, OPSIZE + TERM
  PAR_NODE R32_EAX, 0x00, 1, 0, REG32_BIT, 0
    PAR_NODE R16_DX, 0xED, 0, 1, REG16_BIT, TERM
    PAR_NODE G_CTRL, 0xE5, 0, 0, IMM8_BIT, TERM

.out_node:
  PAR_NODE G_CTRL, 0x00, 1, 4, IMM8_BIT, 0
    PAR_NODE R8_AL, 0xE6, 0, 1, IMM8_BIT + REG8_BIT, TERM
    PAR_NODE R16_AX, 0xE7, 0, 1, IMM8_BIT + REG16_BIT, OPSIZE + TERM
    PAR_NODE R32_EAX, 0xE7, 0, 0, IMM8_BIT + REG32_BIT, TERM
  PAR_NODE R16_DX, 0x00, 1, 0, REG16_BIT, 0
    PAR_NODE R8_AL, 0xEE, 0, 1, REG8_BIT, TERM
    PAR_NODE R16_AX, 0xEF, 0, 1, REG16_BIT, OPSIZE + TERM
    PAR_NODE R32_EAX, 0xEF, 0, 0, REG32_BIT, TERM

.int1_node:
  PAR_NODE G_CTRL, 0xF1, 0, 0, NOP_BIT, TERM

.hlt_node:
  PAR_NODE G_CTRL, 0xF4, 0, 0, NOP_BIT, TERM

.cmc_node:
  PAR_NODE G_CTRL, 0xF5, 0, 0, NOP_BIT, TERM

.div_node:
  PAR_NODE G_REG32, 0xf7, 0, 1, 0, MODRM + OPNUM7 + TERM
  PAR_NODE G_REG8, 0xf6, 0, 1, 0, OPSIZE + MODRM + OPNUM7 + TERM
  PAR_NODE G_REG16, 0xf7, 0, 1, 0, MODRM + OPNUM7 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 1, MEM32_BIT, MODRM + SIB + OPNUM7 + TERM
  PAR_NODE G_CTRL, 0xf6, 0, 1, MEM8_BIT, MODRM + SIB + OPNUM7 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + OPNUM7 + TERM

.idiv_node:
  PAR_NODE G_REG32, 0xf7, 0, 1, 0, MODRM + OPNUM8 + TERM
  PAR_NODE G_REG8, 0xf6, 0, 1, 0, OPSIZE + MODRM + OPNUM8 + TERM
  PAR_NODE G_REG16, 0xf7, 0, 1, 0, MODRM + OPNUM8 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 1, MEM32_BIT, MODRM + SIB + OPNUM8 + TERM
  PAR_NODE G_CTRL, 0xf6, 0, 1, MEM8_BIT, MODRM + SIB + OPNUM8 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + OPNUM8 + TERM

.neg_node:
  PAR_NODE G_REG32, 0xf7, 0, 1, 0, MODRM + OPNUM4 + TERM
  PAR_NODE G_REG8, 0xf6, 0, 1, 0, OPSIZE + MODRM + OPNUM4 + TERM
  PAR_NODE G_REG16, 0xf7, 0, 1, 0, MODRM + OPNUM4 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 1, MEM32_BIT, MODRM + SIB + OPNUM4 + TERM
  PAR_NODE G_CTRL, 0xf6, 0, 1, MEM8_BIT, MODRM + SIB + OPNUM4 + TERM
  PAR_NODE G_CTRL, 0xf7, 0, 0, MEM16_BIT, OPSIZE + MODRM + SIB + OPNUM4 + TERM

.clc_node:
  PAR_NODE G_CTRL, 0xF8, 0, 0, NOP_BIT, TERM

.stc_node:
  PAR_NODE G_CTRL, 0xF9, 0, 0, NOP_BIT, TERM

.cli_node:
  PAR_NODE G_CTRL, 0xFA, 0, 0, NOP_BIT, TERM

.sti_node:
  PAR_NODE G_CTRL, 0xFB, 0, 0, NOP_BIT, TERM

.cld_node:
  PAR_NODE G_CTRL, 0xFC, 0, 0, NOP_BIT, TERM

.std_node:
  PAR_NODE G_CTRL, 0xFD, 0, 0, NOP_BIT, TERM

.cwde_node:
  PAR_NODE G_CTRL, 0x98, 0, 0, NOP_BIT, TERM

.cdq_node:
  PAR_NODE G_CTRL, 0x99, 0, 0, NOP_BIT, TERM

.cqo_node:
  PAR_NODE G_CTRL, 0x99, 0, 0, NOP_BIT, REXW + TERM

.cdqe_node:
  PAR_NODE G_CTRL, 0x98, 0, 0, NOP_BIT, REXW + TERM

.movsq_node:
  PAR_NODE G_CTRL, 0xA5, 0, 0, NOP_BIT, REXW + TERM

.cmpsq_node:
  PAR_NODE G_CTRL, 0xA7, 0, 0, NOP_BIT, REXW + TERM

.stosq_node:
  PAR_NODE G_CTRL, 0xAB, 0, 0, NOP_BIT, REXW + TERM

.lodsq_node:
  PAR_NODE G_CTRL, 0xAD, 0, 0, NOP_BIT, REXW + TERM

.scasq_node:
  PAR_NODE G_CTRL, 0xAF, 0, 0, NOP_BIT, REXW + TERM

; extended instructions
.je_node:
  PAR_NODE G_CTRL, 0x84, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jz_node:
  PAR_NODE G_CTRL, 0x84, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jl_node:
  PAR_NODE G_CTRL, 0x8C, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jle_node:
  PAR_NODE G_CTRL, 0x8E, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jg_node:
  PAR_NODE G_CTRL, 0x8F, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jge_node:
  PAR_NODE G_CTRL, 0x8D, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.ja_node:
  PAR_NODE G_CTRL, 0x87, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jae_node:
  PAR_NODE G_CTRL, 0x82, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jb_node:
  PAR_NODE G_CTRL, 0x82, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jbe_node:
  PAR_NODE G_CTRL, 0x86, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jc_node:
  PAR_NODE G_CTRL, 0x82, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.js_node:
  PAR_NODE G_CTRL, 0x88, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jo_node:
  PAR_NODE G_CTRL, 0x80, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jp_node:
  PAR_NODE G_CTRL, 0x8A, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jpo_node:
  PAR_NODE G_CTRL, 0x8B, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jpe_node:
  PAR_NODE G_CTRL, 0x8A, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jne_node:
  PAR_NODE G_CTRL, 0x85, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jnz_node:
  PAR_NODE G_CTRL, 0x85, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jnc_node:
  PAR_NODE G_CTRL, 0x83, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jns_node:
  PAR_NODE G_CTRL, 0x89, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jno_node:
  PAR_NODE G_CTRL, 0x81, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.jnp_node:
  PAR_NODE G_CTRL, 0x8B, 0, 0, IMM32_BIT + REL32_BIT, TWOBYTE + TERM

.movzx_node:
  PAR_NODE G_REG32, 0x00, 1, 5, 0, 0
    PAR_NODE G_CTRL, 0xB6, 0, 1, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xB7, 0, 1, MEM16_BIT, TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_REG8, 0xB6, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_REG16, 0xB7, 0, 0, REGFIRST_BIT, TWOBYTE + MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0xB6, 0, 1, MEM8_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_REG8, 0xB6, 0, 0, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM

.movsx_node:
  PAR_NODE G_REG32, 0x00, 1, 5, 0, 0
    PAR_NODE G_CTRL, 0xBE, 0, 1, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBF, 0, 1, MEM16_BIT, TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_REG8, 0xBE, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_REG16, 0xBF, 0, 0, REGFIRST_BIT, TWOBYTE + MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0xBE, 0, 1, MEM8_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_REG8, 0xBE, 0, 0, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM

.cmovo_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x40, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x40, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x40, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x40, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovno_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x41, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x41, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x41, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x41, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovb_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x42, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x42, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x42, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x42, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovnb_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x43, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x43, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x43, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x43, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmove_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x44, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x44, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x44, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x44, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovne_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x45, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x45, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x45, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x45, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovbe_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x46, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x46, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x46, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x46, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmova_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x47, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x47, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x47, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x47, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovs_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x48, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x48, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x48, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x48, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovns_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x49, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x49, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x49, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x49, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovpe_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x4A, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4A, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x4A, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4A, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovpo_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x4B, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4B, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x4B, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4B, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovl_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x4C, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4C, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x4C, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4C, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovge_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x4D, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4D, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x4D, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4D, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovle_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x4E, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4E, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x4E, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4E, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmovg_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0x4F, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4F, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0x4F, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x4F, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.seto_node:
  PAR_NODE G_REG8, 0x90, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x90, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setno_node:
  PAR_NODE G_REG8, 0x91, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x91, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setb_node:
  PAR_NODE G_REG8, 0x92, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x92, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setnb_node:
  PAR_NODE G_REG8, 0x93, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x93, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.sete_node:
  PAR_NODE G_REG8, 0x94, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x94, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setne_node:
  PAR_NODE G_REG8, 0x95, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x95, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setbe_node:
  PAR_NODE G_REG8, 0x96, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x96, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.seta_node:
  PAR_NODE G_REG8, 0x97, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x97, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.sets_node:
  PAR_NODE G_REG8, 0x98, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x98, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setns_node:
  PAR_NODE G_REG8, 0x99, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x99, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setpe_node:
  PAR_NODE G_REG8, 0x9A, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x9A, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setpo_node:
  PAR_NODE G_REG8, 0x9B, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x9B, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setl_node:
  PAR_NODE G_REG8, 0x9C, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x9C, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setge_node:
  PAR_NODE G_REG8, 0x9D, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x9D, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setle_node:
  PAR_NODE G_REG8, 0x9E, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x9E, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.setg_node:
  PAR_NODE G_REG8, 0x9F, 0, 1, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x9F, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.ud2_node:
  PAR_NODE G_CTRL, 0x0B, 0, 0, NOP_BIT, TWOBYTE + TERM

.sldt_node:
  PAR_NODE G_REG32, 0x00, 0, 1, 0, TWOBYTE + MODRM + OPNUM1 + TERM
  PAR_NODE G_REG16, 0x00, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + OPNUM1 + TERM
  PAR_NODE G_CTRL, 0x00, 0, 0, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM1 + TERM

.str_node:
  PAR_NODE G_REG32, 0x00, 0, 1, 0, TWOBYTE + MODRM + OPNUM2 + TERM
  PAR_NODE G_REG16, 0x00, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + OPNUM2 + TERM
  PAR_NODE G_CTRL, 0x00, 0, 0, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM2 + TERM

.lldt_node:
  PAR_NODE G_REG32, 0x00, 0, 1, 0, TWOBYTE + MODRM + OPNUM3 + TERM
  PAR_NODE G_REG16, 0x00, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + OPNUM3 + TERM
  PAR_NODE G_CTRL, 0x00, 0, 0, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM3 + TERM

.ltr_node:
  PAR_NODE G_REG32, 0x00, 0, 1, 0, TWOBYTE + MODRM + OPNUM4 + TERM
  PAR_NODE G_REG16, 0x00, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + OPNUM4 + TERM
  PAR_NODE G_CTRL, 0x00, 0, 0, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM4 + TERM

.verr_node:
  PAR_NODE G_REG32, 0x00, 0, 1, 0, TWOBYTE + MODRM + OPNUM5 + TERM
  PAR_NODE G_REG16, 0x00, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0x00, 0, 0, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM5 + TERM

.verw_node:
  PAR_NODE G_REG32, 0x00, 0, 1, 0, TWOBYTE + MODRM + OPNUM6 + TERM
  PAR_NODE G_REG16, 0x00, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + OPNUM6 + TERM
  PAR_NODE G_CTRL, 0x00, 0, 0, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM6 + TERM

.lar_node:
  PAR_NODE G_REG32, 0x00, 0, 1, 3, 0
    PAR_NODE G_REG16, 0x02, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x02, 0, 0, MEM16_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 0, 1, 0, 0
    PAR_NODE G_REG16, 0x02, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x02, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.lsl_node:
  PAR_NODE G_REG32, 0x00, 0, 1, 3, 0
    PAR_NODE G_REG16, 0x03, 0, 1, REGFIRST_BIT, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x03, 0, 0, MEM16_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 0, 1, 0, 0
    PAR_NODE G_REG16, 0x03, 0, 1, REGFIRST_BIT, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0x03, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.clts_node:
  PAR_NODE G_CTRL, 0x06, 0, 0, NOP_BIT, TWOBYTE + TERM

.invd_node:
  PAR_NODE G_CTRL, 0x08, 0, 0, NOP_BIT, TWOBYTE + TERM

.wbinvd_node:
  PAR_NODE G_CTRL, 0x09, 0, 0, NOP_BIT, TWOBYTE + TERM

.wrmsr_node:
  PAR_NODE G_CTRL, 0x30, 0, 0, NOP_BIT, TWOBYTE + TERM

.rdtsc_node:
  PAR_NODE G_CTRL, 0x31, 0, 0, NOP_BIT, TWOBYTE + TERM

.rdmsr_node:
  PAR_NODE G_CTRL, 0x32, 0, 0, NOP_BIT, TWOBYTE + TERM

.rdpmc_node:
  PAR_NODE G_CTRL, 0x33, 0, 0, NOP_BIT, TWOBYTE + TERM

.sysenter_node:
  PAR_NODE G_CTRL, 0x34, 0, 0, NOP_BIT, TWOBYTE + TERM

.sysexit_node:
  PAR_NODE G_CTRL, 0x35, 0, 0, NOP_BIT, TWOBYTE + TERM

.cpuid_node:
  PAR_NODE G_CTRL, 0xA2, 0, 0, NOP_BIT, TWOBYTE + TERM

.bt_node:
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_REG32, 0xA3, 0, 1, 0, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xA3, 0, 1, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, TWOBYTE + MODRM + OPNUM5 + TERM
  PAR_NODE G_REG16, 0x00, 1, 4, 0, 0
    PAR_NODE G_REG16, 0xA3, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xA3, 0, 1, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_REG32, 0xA3, 0, 1, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM5 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 0, MEM16_BIT, 0
    PAR_NODE G_REG16, 0xA3, 0, 1, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM5 + TERM

.shld_node:
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_REG32, 0x00, 1, 0, 0, 0
      PAR_NODE G_CTRL, 0xA4, 0, 1, IMM8_BIT, TWOBYTE + MODRM + TERM
      PAR_NODE R8_CL, 0xA5, 0, 0, REG8_BIT, TWOBYTE + MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 4, 0, 0
    PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
      PAR_NODE G_CTRL, 0xA4, 0, 1, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + TERM
      PAR_NODE R8_CL, 0xA5, 0, 0, REG8_BIT, OPSIZE + TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 4, MEM32_BIT, 0
    PAR_NODE G_REG32, 0x00, 1, 0, 0, 0
      PAR_NODE G_CTRL, 0xA4, 0, 1, IMM8_BIT + MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
      PAR_NODE R8_CL, 0xA5, 0, 0, MEM32_BIT + REG8_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 0, MEM16_BIT, 0
    PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
      PAR_NODE G_CTRL, 0xA4, 0, 1, IMM8_BIT + MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
      PAR_NODE R8_CL, 0xA5, 0, 0, MEM16_BIT + REG8_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.rsm_node:
  PAR_NODE G_CTRL, 0xAA, 0, 0, NOP_BIT, TWOBYTE + TERM

.bts_node:
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_REG32, 0xAB, 0, 1, 0, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xAB, 0, 1, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, TWOBYTE + MODRM + OPNUM6 + TERM
  PAR_NODE G_REG16, 0x00, 1, 4, 0, 0
    PAR_NODE G_REG16, 0xAB, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xAB, 0, 1, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM6 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_REG32, 0xAB, 0, 1, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM6 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 0, MEM16_BIT, 0
    PAR_NODE G_REG16, 0xAB, 0, 1, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM6 + TERM

.shrd_node:
  PAR_NODE G_REG32, 0x00, 1, 4, 0, 0
    PAR_NODE G_REG32, 0x00, 1, 0, 0, 0
      PAR_NODE G_CTRL, 0xAC, 0, 1, IMM8_BIT, TWOBYTE + MODRM + TERM
      PAR_NODE R8_CL, 0xAD, 0, 0, REG8_BIT, TWOBYTE + MODRM + TERM
  PAR_NODE G_REG16, 0x00, 1, 4, 0, 0
    PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
      PAR_NODE G_CTRL, 0xAC, 0, 1, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + TERM
      PAR_NODE R8_CL, 0xAD, 0, 0, REG8_BIT, OPSIZE + TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 4, MEM32_BIT, 0
    PAR_NODE G_REG32, 0x00, 1, 0, 0, 0
      PAR_NODE G_CTRL, 0xAC, 0, 1, IMM8_BIT + MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
      PAR_NODE R8_CL, 0xAD, 0, 0, MEM32_BIT + REG8_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_CTRL, 0x00, 1, 0, MEM16_BIT, 0
    PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
      PAR_NODE G_CTRL, 0xAC, 0, 1, IMM8_BIT + MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
      PAR_NODE R8_CL, 0xAD, 0, 0, MEM16_BIT + REG8_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.cmpxchg_node:
  PAR_NODE G_REG8, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG8, 0xB0, 0, 0, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 2, MEM8_BIT, 0
    PAR_NODE G_REG8, 0xB0, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG32, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG32, 0xB1, 0, 0, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 2, MEM32_BIT, 0
    PAR_NODE G_REG32, 0xB1, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG16, 0xB1, 0, 0, 0, OPSIZE + TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 0, MEM16_BIT, 0
    PAR_NODE G_REG16, 0xB1, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.lss_node:
  PAR_NODE G_REG32, 0x00, 1, 2, 0, 0
    PAR_NODE G_CTRL, 0xB2, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0xB2, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.btr_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0xB3, 0, 1, 0, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, TWOBYTE + MODRM + OPNUM7 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG16, 0xB3, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM7 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_REG32, 0xB3, 0, 1, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM7 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 0, MEM16_BIT, 0
    PAR_NODE G_REG16, 0xB3, 0, 1, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + SIB + OPNUM7 + TERM

.lfs_node:
  PAR_NODE G_REG32, 0x00, 1, 2, 0, 0
    PAR_NODE G_CTRL, 0xB4, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0xB4, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.lgs_node:
  PAR_NODE G_REG32, 0x00, 1, 2, 0, 0
    PAR_NODE G_CTRL, 0xB5, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_CTRL, 0xB5, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.btc_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0xBB, 0, 1, 0, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, TWOBYTE + MODRM + OPNUM8 + TERM
  PAR_NODE G_REG16, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG16, 0xBB, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM8 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 3, MEM32_BIT, 0
    PAR_NODE G_REG32, 0xBB, 0, 1, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM8 + TERM
  PAR_NODE G_CTRL, 0x00, 1, 0, MEM16_BIT, 0
    PAR_NODE G_REG16, 0xBB, 0, 1, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
    PAR_NODE G_CTRL, 0xBA, 0, 0, IMM8_BIT, OPSIZE + TWOBYTE + MODRM + OPNUM8 + TERM

.bsf_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0xBC, 0, 1, 0, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xBC, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0xBC, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xBC, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.bsr_node:
  PAR_NODE G_REG32, 0x00, 1, 3, 0, 0
    PAR_NODE G_REG32, 0xBD, 0, 1, 0, TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xBD, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 0, 0, 0
    PAR_NODE G_REG16, 0xBD, 0, 1, 0, OPSIZE + TWOBYTE + MODRM + TERM
    PAR_NODE G_CTRL, 0xBD, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM

.xadd_node:
  PAR_NODE G_REG32, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG32, 0xC1, 0, 0, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 2, MEM32_BIT, 0
    PAR_NODE G_REG32, 0xC1, 0, 0, MEM32_BIT, TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG16, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG16, 0xC1, 0, 0, 0, OPSIZE + TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 2, MEM16_BIT, 0
    PAR_NODE G_REG16, 0xC1, 0, 0, MEM16_BIT, OPSIZE + TWOBYTE + MODRM + SIB + TERM
  PAR_NODE G_REG8, 0x00, 1, 2, 0, 0
    PAR_NODE G_REG8, 0xC0, 0, 0, 0, TWOBYTE + MODRM + TERM
  PAR_NODE G_CTRL, 0x00, 1, 0, MEM8_BIT, 0
    PAR_NODE G_REG8, 0xC0, 0, 0, MEM8_BIT, TWOBYTE + MODRM + SIB + TERM

.bswap_node:
  PAR_NODE G_REG32, 0xC8, 0, 0, 0, TWOBYTE + SHORT_OP + TERM

.sgdt_node:
  PAR_NODE G_CTRL, 0x01, 0, 1, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM1 + TERM
  PAR_NODE G_REG16, 0x01, 0, 0, 0, TWOBYTE + MODRM + OPNUM1 + TERM

.sidt_node:
  PAR_NODE G_CTRL, 0x01, 0, 1, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM2 + TERM
  PAR_NODE G_REG16, 0x01, 0, 0, 0, TWOBYTE + MODRM + OPNUM2 + TERM

.lgdt_node:
  PAR_NODE G_CTRL, 0x01, 0, 1, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM3 + TERM
  PAR_NODE G_REG16, 0x01, 0, 0, 0, TWOBYTE + MODRM + OPNUM3 + TERM

.lidt_node:
  PAR_NODE G_CTRL, 0x01, 0, 1, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM4 + TERM
  PAR_NODE G_REG16, 0x01, 0, 0, 0, TWOBYTE + MODRM + OPNUM4 + TERM

.smsw_node:
  PAR_NODE G_CTRL, 0x01, 0, 1, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM5 + TERM
  PAR_NODE G_REG16, 0x01, 0, 0, 0, TWOBYTE + MODRM + OPNUM5 + TERM

.lmsw_node:
  PAR_NODE G_CTRL, 0x01, 0, 1, MEM16_BIT, TWOBYTE + MODRM + SIB + OPNUM7 + TERM
  PAR_NODE G_REG16, 0x01, 0, 0, 0, TWOBYTE + MODRM + OPNUM7 + TERM

.syscall_node:
  PAR_NODE G_CTRL, 0x05, 0, 0, NOP_BIT, TWOBYTE + TERM

.sysret_node:
  PAR_NODE G_CTRL, 0x07, 0, 0, NOP_BIT, TWOBYTE + TERM
