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
;  stays at $C000-$FFFF, CHR is two 4 KiB banks. Each PRG bank and each
;  CHR bank is its own file. Bank 00 is prg/bank00.asm.
;  Bank 01 is prg/bank01.asm. Bank 02 is prg/bank02.asm.
;  Bank 03 is prg/bank03.asm. Bank 04 is prg/bank04.asm.
;  Bank 05 is prg/bank05.asm. Bank 06 is prg/bank06.asm.
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
    .include "prg/bank00.asm"
    .segment "PRG1"
    .include "prg/bank01.asm"
    .segment "PRG2"
    .include "prg/bank02.asm"
    .segment "PRG3"
    .include "prg/bank03.asm"
    .segment "PRG4"
    .include "prg/bank04.asm"
    .segment "PRG5"
    .include "prg/bank05.asm"
    .segment "PRG6"
    .include "prg/bank06.asm"
    .segment "PRG7"
    .include "prg/bank07.asm"

; --- CHR ----------------------------------------------------------------
    .segment "CHR0"
    .include "chr/bank00.asm"
    .segment "CHR1"
    .include "chr/bank01.asm"
    .segment "CHR2"
    .include "chr/bank02.asm"
    .segment "CHR3"
    .include "chr/bank03.asm"
    .segment "CHR4"
    .include "chr/bank04.asm"
    .segment "CHR5"
    .include "chr/bank05.asm"
    .segment "CHR6"
    .include "chr/bank06.asm"
    .segment "CHR7"
    .include "chr/bank07.asm"
    .segment "CHR8"
    .include "chr/bank08.asm"
    .segment "CHR9"
    .include "chr/bank09.asm"
    .segment "CHR10"
    .include "chr/bank10.asm"
    .segment "CHR11"
    .include "chr/bank11.asm"
    .segment "CHR12"
    .include "chr/bank12.asm"
    .segment "CHR13"
    .include "chr/bank13.asm"
    .segment "CHR14"
    .include "chr/bank14.asm"
    .segment "CHR15"
    .include "chr/bank15.asm"
