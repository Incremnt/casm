.text
  call      14

.rodata
db "Hello, World!", 10

.text
  mov       eax, 4
  mov       ebx, 1
  pop       ecx
  mov       edx, 14
  int       128

  mov       eax, 1
  xor       ebx, ebx
  int       128
