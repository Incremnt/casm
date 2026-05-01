.text
  xor       ebp, ebp
  call      8
dd 1
dd 0
  call      16
db '|', 27, "[D"
db '/', 27, "[D"
db '-', 27, "[D"
db '\', 27, "[D"

  mov       eax, 4
  mov       ebx, 1
  pop       ecx
  add       ecx, ebp
  add       ebp, 4
  cmp       ebp, 16
  jne       2
  xor       ebp, ebp
  mov       edx, 4
  int       128

  mov       eax, 162
  pop       ebx
  mov       ecx, ebx
  int       128

  mov       edi, 134512726
  jmp       edi
