.rodata
#msg
  db "Hello, World!", 10

.text
#_start
  mov       eax, 4
  mov       ebx, 1
  mov       ecx, @msg
  mov       edx, 14
  int       128

  mov       eax, 1
  xor       ebx, ebx
  int       128

.entry @_start
