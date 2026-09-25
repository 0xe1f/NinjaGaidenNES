; ===========================================================================
;  NINJA GAIDEN  -  Tecmo, 1988  -  NES (USA), MMC1, 256 KiB
; ===========================================================================
;
;  Assembler : ca65 / ld65 (cc65 V2.19, see tools/).
;              Build:  make        -> NinjaGaiden.nes
;              Verify: make verify (byte-exact against NinjaGaiden.sha1)
;
;  --- Cartridge ----------------------------------------------------------
;  iNES mapper 1 (MMC1). 128 KiB PRG + 128 KiB CHR. No trainer, no battery.
;  US board is SLROM (MMC1B2). The header mirroring bit is horizontal;
;  MMC1 can change mirroring at runtime.
;
;  File image (after the 16-byte header):
;    PRG file banks 00-07   8 x 16 KiB
;    CHR file banks 00-15  16 x  8 KiB
;  Reset stores MMC1 control $1E: PRG banks 00-06 switch at $8000, bank 07
;  stays at $C000-$FFFF, CHR is two 4 KiB banks. One file per PRG bank
;  until a switched bank is disassembled. Bank 02 is prg/bank02.asm.
;  Bank 07 is prg/bank07.asm.
;
;  Vectors (bank 07): NMI $F91A, RESET $FFDA, IRQ $FA1F.
; ===========================================================================

    .setcpu "6502"

; --- iNES header (16 bytes, matches the dump) ---------------------------
    .segment "HEADER"
    .byte "NES", $1A
    .byte $08          ; 8 x 16 KiB PRG
    .byte $10          ; 16 x 8 KiB CHR
    .byte $10          ; mapper 1, horizontal mirroring, no trainer/battery
    .byte $00, $00, $00, $00, $00, $00, $00, $00

; --- PRG ----------------------------------------------------------------
    .segment "PRG0"
    .incbin "prg/bank00.bin"
    .segment "PRG1"
    .incbin "prg/bank01.bin"
    .segment "PRG2"
    .include "prg/bank02.asm"
    .segment "PRG3"
    .incbin "prg/bank03.bin"
    .segment "PRG4"
    .incbin "prg/bank04.bin"
    .segment "PRG5"
    .incbin "prg/bank05.bin"
    .segment "PRG6"
    .incbin "prg/bank06.bin"
    .segment "PRG7"
    .include "prg/bank07.asm"

; --- CHR ----------------------------------------------------------------
    .segment "CHR0"
    .incbin "chr/bank00.bin"
    .segment "CHR1"
    .incbin "chr/bank01.bin"
    .segment "CHR2"
    .incbin "chr/bank02.bin"
    .segment "CHR3"
    .incbin "chr/bank03.bin"
    .segment "CHR4"
    .incbin "chr/bank04.bin"
    .segment "CHR5"
    .incbin "chr/bank05.bin"
    .segment "CHR6"
    .incbin "chr/bank06.bin"
    .segment "CHR7"
    .incbin "chr/bank07.bin"
    .segment "CHR8"
    .incbin "chr/bank08.bin"
    .segment "CHR9"
    .incbin "chr/bank09.bin"
    .segment "CHR10"
    .incbin "chr/bank10.bin"
    .segment "CHR11"
    .incbin "chr/bank11.bin"
    .segment "CHR12"
    .incbin "chr/bank12.bin"
    .segment "CHR13"
    .incbin "chr/bank13.bin"
    .segment "CHR14"
    .incbin "chr/bank14.bin"
    .segment "CHR15"
    .incbin "chr/bank15.bin"
