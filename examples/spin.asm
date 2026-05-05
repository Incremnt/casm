.text
  xor       ebp, ebp
  call      24

.rodata
dd 1
dd 0
db '|', 27, "[D"
db '/', 27, "[D"
db '-', 27, "[D"
db '\', 27, "[D"

.text
  pop       esi
  mov       eax, 4
  mov       ebx, 1
  mov       ecx, esi
  add       ecx, 8
  add       ecx, ebp
  add       ebp, 4
  cmp       ebp, 16
  jne       2
  xor       ebp, ebp
  mov       edx, 4
  int       128

  mov       eax, 162
  mov       ebx, esi
  mov       ecx, ebx
  int       128

  mov       edi, 134512790
  jmp       edi
