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

; lexer tables
delimiter_tbl    db 256 dup(0)
valid_char_tbl   db 256 dup(0)
lex_trie_tbl     dw 256 dup(0)

; jump tables
del_jmp_tbl:
  dq handle_del.ignore_del
  dq handle_del.comment_del
  dq handle_del.label_del
  dq handle_del.number_del
  dq handle_del.string_del
  dq handle_del.lbracket_del
  dq handle_del.rbracket_del
  dq handle_del.plus_del
  dq handle_del.minus_del
  dq handle_del.multiply_del
  dq handle_del.comma_del
  dq handle_del.newline_del
  dq handle_del.address_del

group_jmp_tbl:
  dq ctrl_group
  dq instr_group
  dq einst_group
  dq invalid_expression_err
  dq invalid_expression_err
  dq invalid_expression_err
  dq dir_group
  dq pref_group
  dq invalid_expression_err
  dq invalid_expression_err
  dq invalid_expression_err
  dq invalid_expression_err
  dq invalid_expression_err
  dq macro_group

ctrl_jmp_tbl:
  dq ctrl_group.handle_eof
  dq ctrl_group.handle_num
  dq ctrl_group.handle_str
  dq ctrl_group.handle_label
  dq ctrl_group.handle_address
  dq invalid_expression_err
  dq invalid_expression_err
  dq invalid_expression_err
  dq invalid_expression_err
  dq invalid_expression_err
  dq invalid_expression_err
  dq ctrl_group.handle_lf
  dq ctrl_group.handle_byte
  dq ctrl_group.handle_word
  dq ctrl_group.handle_dword
  dq ctrl_group.handle_qword

dir_jmp_tbl:
  dq dir_group.handle_db
  dq dir_group.handle_dw
  dq dir_group.handle_dd
  dq dir_group.handle_text
  dq dir_group.handle_data
  dq dir_group.handle_rodata
  dq dir_group.handle_entry
  dq dir_group.handle_org
  dq dir_group.handle_dq
  dq dir_group.handle_rb
  dq dir_group.handle_rw
  dq dir_group.handle_rd
  dq dir_group.handle_rq
  dq dir_group.handle_bss

macro_jmp_tbl:
  dq macro_group.handle_repeat

instr_node_tbl:
  dq par_trie.mov_node
  dq par_trie.mul_node
  dq par_trie.push_node
  dq par_trie.pop_node
  dq par_trie.call_node
  dq par_trie.cmp_node
  dq par_trie.jmp_node
  dq par_trie.test_node
  dq par_trie.or_node
  dq par_trie.and_node
  dq par_trie.add_node
  dq par_trie.xor_node
  dq par_trie.not_node
  dq par_trie.int_node
  dq par_trie.inc_node
  dq par_trie.dec_node
  dq par_trie.sub_node
  dq par_trie.lea_node
  dq par_trie.xchg_node
  dq par_trie.nop_node
  dq par_trie.ret_node
  dq par_trie.pusha_node
  dq par_trie.popa_node
  dq par_trie.adc_node
  dq par_trie.sbb_node
  dq par_trie.daa_node
  dq par_trie.das_node
  dq par_trie.aaa_node
  dq par_trie.aas_node
  dq par_trie.bound_node
  dq par_trie.arpl_node
  dq par_trie.imul_node
  dq par_trie.insb_node
  dq par_trie.insw_node
  dq par_trie.insd_node
  dq par_trie.outsb_node
  dq par_trie.outsw_node
  dq par_trie.outsd_node
  dq par_trie.cbw_node
  dq par_trie.cwd_node
  dq par_trie.wait_node
  dq par_trie.pushf_node
  dq par_trie.popf_node
  dq par_trie.sahf_node
  dq par_trie.lahf_node
  dq par_trie.movsb_node
  dq par_trie.movsw_node
  dq par_trie.movsd_node
  dq par_trie.cmpsb_node
  dq par_trie.cmpsw_node
  dq par_trie.cmpsd_node
  dq par_trie.stosb_node
  dq par_trie.stosw_node
  dq par_trie.stosd_node
  dq par_trie.lodsb_node
  dq par_trie.lodsw_node
  dq par_trie.lodsd_node
  dq par_trie.scasb_node
  dq par_trie.scasw_node
  dq par_trie.scasd_node
  dq par_trie.rol_node
  dq par_trie.ror_node
  dq par_trie.rcl_node
  dq par_trie.rcr_node
  dq par_trie.shl_node
  dq par_trie.shr_node
  dq par_trie.sal_node
  dq par_trie.sar_node
  dq par_trie.les_node
  dq par_trie.lds_node
  dq par_trie.enter_node
  dq par_trie.leave_node
  dq par_trie.retf_node
  dq par_trie.int3_node
  dq par_trie.into_node
  dq par_trie.iret_node
  dq par_trie.aam_node
  dq par_trie.aad_node
  dq par_trie.salc_node
  dq par_trie.xlat_node
  dq par_trie.loopnz_node
  dq par_trie.loopz_node
  dq par_trie.loop_node
  dq par_trie.jcxz_node
  dq par_trie.in_node
  dq par_trie.out_node
  dq par_trie.int1_node
  dq par_trie.hlt_node
  dq par_trie.cmc_node
  dq par_trie.div_node
  dq par_trie.idiv_node
  dq par_trie.neg_node
  dq par_trie.clc_node
  dq par_trie.stc_node
  dq par_trie.cli_node
  dq par_trie.sti_node
  dq par_trie.cld_node
  dq par_trie.std_node
  dq par_trie.cwde_node
  dq par_trie.cdq_node
  dq par_trie.cqo_node
  dq par_trie.cdqe_node
  dq par_trie.movsq_node
  dq par_trie.cmpsq_node
  dq par_trie.stosq_node
  dq par_trie.lodsq_node
  dq par_trie.scasq_node

einst_node_tbl:
  dq par_trie.je_node
  dq par_trie.jz_node
  dq par_trie.jl_node
  dq par_trie.jle_node
  dq par_trie.jg_node
  dq par_trie.jge_node
  dq par_trie.ja_node
  dq par_trie.jae_node
  dq par_trie.jb_node
  dq par_trie.jbe_node
  dq par_trie.jc_node
  dq par_trie.js_node
  dq par_trie.jo_node
  dq par_trie.jp_node
  dq par_trie.jpo_node
  dq par_trie.jpe_node
  dq par_trie.jne_node
  dq par_trie.jnz_node
  dq par_trie.jnc_node
  dq par_trie.jns_node
  dq par_trie.jno_node
  dq par_trie.jnp_node
  dq par_trie.movzx_node
  dq par_trie.movsx_node
  dq par_trie.cmovo_node
  dq par_trie.cmovno_node
  dq par_trie.cmovb_node
  dq par_trie.cmovnb_node
  dq par_trie.cmove_node
  dq par_trie.cmovne_node
  dq par_trie.cmovbe_node
  dq par_trie.cmova_node
  dq par_trie.cmovs_node
  dq par_trie.cmovns_node
  dq par_trie.cmovpe_node
  dq par_trie.cmovpo_node
  dq par_trie.cmovl_node
  dq par_trie.cmovge_node
  dq par_trie.cmovle_node
  dq par_trie.cmovg_node
  dq par_trie.seto_node
  dq par_trie.setno_node
  dq par_trie.setb_node
  dq par_trie.setnb_node
  dq par_trie.sete_node
  dq par_trie.setne_node
  dq par_trie.setbe_node
  dq par_trie.seta_node
  dq par_trie.sets_node
  dq par_trie.setns_node
  dq par_trie.setpe_node
  dq par_trie.setpo_node
  dq par_trie.setl_node
  dq par_trie.setge_node
  dq par_trie.setle_node
  dq par_trie.setg_node
  dq par_trie.ud2_node
  dq par_trie.sldt_node
  dq par_trie.str_node
  dq par_trie.lldt_node
  dq par_trie.ltr_node
  dq par_trie.verr_node
  dq par_trie.verw_node
  dq par_trie.lar_node
  dq par_trie.lsl_node
  dq par_trie.clts_node
  dq par_trie.invd_node
  dq par_trie.wbinvd_node
  dq par_trie.wrmsr_node
  dq par_trie.rdtsc_node
  dq par_trie.rdmsr_node
  dq par_trie.rdpmc_node
  dq par_trie.sysenter_node
  dq par_trie.sysexit_node
  dq par_trie.cpuid_node
  dq par_trie.bt_node
  dq par_trie.shld_node
  dq par_trie.rsm_node
  dq par_trie.bts_node
  dq par_trie.shrd_node
  dq par_trie.cmpxchg_node
  dq par_trie.lss_node
  dq par_trie.btr_node
  dq par_trie.lfs_node
  dq par_trie.lgs_node
  dq par_trie.btc_node
  dq par_trie.bsf_node
  dq par_trie.bsr_node
  dq par_trie.xadd_node
  dq par_trie.bswap_node
  dq par_trie.sgdt_node
  dq par_trie.sidt_node
  dq par_trie.lgdt_node
  dq par_trie.lidt_node
  dq par_trie.smsw_node
  dq par_trie.lmsw_node
  dq par_trie.syscall_node
  dq par_trie.sysret_node
