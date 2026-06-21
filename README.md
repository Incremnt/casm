# Cool Assembler v2.1.3
A small learning x86 assembler written in FASM.

## License
This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.
See the [`LICENSE`](LICENSE) file for the full text.

## Dependencies
To build the CASM, you need **FASM** ([build from the source](https://github.com/tgrysztar/fasm) or [download from the official website](https://flatassembler.net)).

## Usage
At the moment, CASM supports only GNU/Linux x86/x86-64, you need a x86-64 machine to build CASM.
  ```bash
  casm [OPTIONS] <SOURCE> <OUTPUT>
    -n, --noelf    don't generate ELF header, error on PHDR directives
    -a, --amd64    generate 64-bit code
    -b, --bytes    show output file size in bytes
    -s, --style    show your rank and style points percentage
  ```

## Syntax quirks
CASM uses basic intel syntax, no AT&T support.
1.  **Decimal numbers only (will be fixed in the future I guess)**
2.  **Labels define as "#label", not "label:"**
3.  **Label references define as "@label", not "label"**
4.  **Memory expressions always need a size keyword (byte/word/dword/qword)**
5.  **No expression calculations (calculations exist only in memory expressions, you can multiply registers only)**
6.  **All control directives start with . (.text/.data/.rodata/.entry/.org)**
7.  **Code generation controls with usage flags (see above)**
