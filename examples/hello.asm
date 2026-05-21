.text
  jmp       14

.rodata
#msg
  db "Hello, World!", 10

.text
  mov       eax, 4
  mov       ebx, 1
  mov       ecx, @msg
  mov       edx, 14
  int       128

  mov       eax, 1
  xor       ebx, ebx
  int       128
