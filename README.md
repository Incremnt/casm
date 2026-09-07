# Cool Assembler v2.2.3
A small learning x86 assembler written in FASM.

## License
This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.
See the [`LICENSE`](LICENSE) file for the full text.

## Dependencies
To build the CASM, you need **FASM** ([build from the source](https://github.com/tgrysztar/fasm) or [download from the official website](https://flatassembler.net)).

## Usage
  ```bash
  casm [OPTIONS] <SOURCE> <OUTPUT>
    -n, --noelf    don't generate ELF header, error on PHDR directives
    -a, --amd64    generate 64-bit code
    -b, --bytes    show output file size in bytes
    -s, --style    show your rank and style points percentage
  ```
