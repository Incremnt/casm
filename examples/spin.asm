.text
  xor       ebp, ebp
  jmp       24

.rodata
#time
  dd 1
  dd 0

#frames
  db '|', 27, "[D"
  db '/', 27, "[D"
  db '-', 27, "[D"
  db '\', 27, "[D"

.text
#_start
  mov       eax, 4
  mov       ebx, 1
  lea       ecx, dword [@frames + ebp]
  add       ebp, 4
  cmp       ebp, 16
  jne       2
  xor       ebp, ebp
  mov       edx, 4
  int       128

  mov       eax, 162
  mov       ebx, @time
  mov       ecx, ebx
  int       128

  mov       edi, @_start
  jmp       edi
