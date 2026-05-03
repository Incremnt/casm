.text
  mov       eax, 4
  mov       ebx, 1
  mov       ecx, 134512787
  mov       edx, 14
  int       128

  mov       eax, 1
  xor       ebx, ebx
  int       128

.rodata
db "Hello, World!", 10
