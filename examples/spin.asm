.text
  xor       ebp, ebp
  mov       eax, 4
  mov       ebx, 1
  mov       ecx, 134512831
  add       ecx, ebp
  add       ebp, 4
  cmp       ebp, 16
  jne       2
  xor       ebp, ebp
  mov       edx, 4
  int       128

  mov       eax, 162
  mov       ebx, 134512823
  mov       ecx, ebx
  int       128

  mov       edi, 134512758
  jmp       edi

.rodata
dd 1
dd 0
db '|', 27, "[D"
db '/', 27, "[D"
db '-', 27, "[D"
db '\', 27, "[D"
