; CHR file bank 11.
; MMC1 switches 4 KiB at a time. This file is banks $16 and $17.
; Cutscene pictures use $17 as their sprites.
; A one-color tile is binary, one row per line. The left pixel is the high bit.

        .byte $00, $00, $00, $01, $03, $03, $07, $0F
        .byte $00, $00, $00, $00, $00, $01, $01, $03

        .byte $3F, $7F, $7F, $FF, $FF, $FF, $FF, $FF
        .byte $07, $0D, $0C, $18, $18, $18, $0C, $06

        .byte $07, $3F, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $00, $06, $1C, $70, $E4, $E4, $CC, $CC

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11001110
        .byte %11000110
        .byte %11100111
        .byte %01110011
        .byte %00111111
        .byte %00001111
        .byte %00000000
        .byte %00000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00111111
        .byte %10000001
        .byte %10000000
        .byte %11000000
        .byte %11100001
        .byte %01100000
        .byte %01110000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00111100
        .byte %00001111
        .byte %00000000
        .byte %10000000
        .byte %11100000
        .byte %11110000
        .byte %01111000
        .byte %00011111

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %11000011
        .byte %11111111
        .byte %01111000
        .byte %00011110
        .byte %11111111
        .byte %00111111
        .byte %00000001

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %10000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %10000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %01111111
        .byte %01111111
        .byte %00111111
        .byte %00001111
        .byte %00000001
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $00, $00, $00, $00, $00, $00, $01, $03
        .byte $00, $00, $00, $00, $00, $00, $00, $01

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111110
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000001
        .byte %00000000

        .byte $4F, $E7, $22, $70, $7F, $FF, $FF, $FF
        .byte $30, $18, $1D, $3F, $3F, $7F, $FF, $FF

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11100000
        .byte %00110000
        .byte %11000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00011111
        .byte %11001111
        .byte %00111111

        .byte $E1, $E3, $8F, $7F, $FF, $FF, $FF, $FF
        .byte $9F, $DF, $FF, $FF, $FF, $FF, $FF, $FF

        .byte $FF, $FF, $FF, $FF, $FF, $3F, $19, $16
        .byte $00, $00, $00, $00, $00, $C0, $E6, $EF

        .byte $C5, $E9, $FD, $FB, $FE, $FD, $FF, $FF
        .byte $FB, $F7, $F3, $F5, $FB, $FE, $FC, $FE

        .byte $F8, $FE, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $00, $E0, $F8, $1E, $03, $F8, $9C, $C7

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %01100001
        .byte %00110000
        .byte %00010000
        .byte %00011000
        .byte %00011000
        .byte %00001000
        .byte %00001000
        .byte %00001000

        .byte $00, $00, $00, $80, $C0, $C0, $E0, $E0
        .byte $00, $00, $00, $00, $00, $80, $00, $00

        .byte $E0, $E0, $F0, $F0, $F0, $F0, $F0, $F0
        .byte $80, $C0, $C0, $60, $60, $20, $20, $20

        .byte $00, $01, $07, $07, $0F, $0F, $03, $03
        .byte $00, $02, $04, $08, $03, $04, $04, $02

        .byte %11000001
        .byte %11000001
        .byte %00000001
        .byte %11111000
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00111110
        .byte %00111110
        .byte %11111110
        .byte %00000111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $00, $00, $F0, $FF, $FF, $FF, $FF, $FF
        .byte $00, $00, $FF, $00, $FF, $00, $00, $00

        .byte $F9, $0F, $0F, $07, $03, $01, $00, $00
        .byte $FE, $00, $08, $04, $00, $00, $00, $00

        .byte $FE, $FE, $FE, $FE, $FE, $FC, $FC, $FC
        .byte $01, $01, $01, $01, $01, $02, $02, $02

        .byte $F8, $F8, $F0, $F0, $E0, $C0, $C0, $80
        .byte $04, $04, $08, $08, $10, $20, $20, $40

        .byte $F8, $F8, $FC, $FC, $FC, $FE, $FE, $FF
        .byte $A0, $B0, $90, $D8, $68, $38, $1C, $1C

        .byte $FF, $FF, $FF, $FF, $FE, $FE, $FC, $F8
        .byte $0E, $0E, $0C, $1C, $18, $30, $20, $20

        .byte $00, $00, $01, $FF, $35, $FA, $FD, $FF
        .byte $00, $01, $FE, $00, $CA, $05, $02, $00

        .byte $11, $FF, $FF, $FF, $FF, $FF, $0F, $07
        .byte $EE, $00, $FF, $FF, $7F, $07, $07, $03

        .byte $00, $80, $C0, $C0, $60, $B0, $5E, $FF
        .byte $00, $00, $00, $20, $90, $40, $A0, $06

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte %00000001
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00001111
        .byte %11110000
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %11110000
        .byte %00001111
        .byte %00000000
        .byte %00000000

        .byte $9F, $5F, $3F, $37, $0F, $1F, $1F, $17
        .byte $7F, $3F, $3F, $0F, $1F, $0F, $0F, $0F

        .byte $08, $07, $00, $00, $00, $00, $00, $00
        .byte $07, $00, $00, $00, $00, $00, $00, $00

        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FE, $CC
        .byte $FF, $FF, $FF, $FF, $FF, $FE, $FD, $F3

        .byte $34, $C2, $01, $00, $00, $00, $00, $01
        .byte $C3, $01, $00, $00, $00, $00, $00, $00

        .byte $FF, $FF, $FF, $DF, $9F, $3F, $3F, $3F
        .byte $FF, $FF, $DF, $BF, $7F, $FF, $FF, $FF

        .byte $3F, $3F, $3F, $BF, $9F, $5F, $DF, $DF
        .byte $FF, $FF, $FF, $7F, $7F, $3F, $3E, $39

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %10000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $C0, $E0, $F0, $F8, $FC, $FE, $FF, $FF
        .byte $80, $C0, $E0, $F0, $F8, $FC, $FE, $FF

        .byte %00000001
        .byte %00000001
        .byte %00000001
        .byte %00000011
        .byte %00000011
        .byte %00000011
        .byte %00000111
        .byte %00000111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %00000111
        .byte %00000111
        .byte %00000111
        .byte %00000111
        .byte %00000111
        .byte %00000111
        .byte %00000111
        .byte %10000011
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $03, $07, $07, $0F, $0F, $1E, $1E, $3E
        .byte $00, $04, $00, $08, $08, $10, $10, $20

        .byte $3F, $7F, $7F, $7E, $FE, $FC, $FC, $F8
        .byte $20, $41, $43, $03, $87, $07, $0F, $0F

        .byte $FC, $F8, $98, $18, $0C, $0C, $1E, $1E
        .byte $07, $1F, $0F, $07, $27, $03, $0B, $0D

        .byte $3F, $F7, $E7, $03, $07, $07, $0F, $0F
        .byte $1D, $3E, $FE, $FC, $F8, $F8, $F0, $F0

        .byte $FF, $FF, $FF, $FF, $FF, $FB, $FB, $F3
        .byte $00, $80, $C0, $E0, $E0, $F4, $F4, $EC

        .byte $F3, $E3, $E3, $C3, $C7, $87, $07, $0F
        .byte $EC, $DC, $DC, $BC, $B8, $78, $F8, $F0

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111110
        .byte %11111110
        .byte %11111110
        .byte %11111101
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000001
        .byte %00000001
        .byte %00000001
        .byte %00000010

        .byte %11111101
        .byte %11111101
        .byte %11111011
        .byte %11111011
        .byte %11111011
        .byte %11110111
        .byte %11110111
        .byte %11101111
        .byte %00000010
        .byte %00000010
        .byte %00000100
        .byte %00000100
        .byte %00000100
        .byte %00001000
        .byte %00001000
        .byte %00010000

        .byte $00, $C0, $E0, $FC, $FF, $FF, $FF, $FF
        .byte $00, $00, $C0, $60, $3C, $1F, $73, $19

        .byte $FF, $FF, $FF, $7F, $9F, $E7, $F9, $FE
        .byte $0C, $06, $02, $82, $60, $18, $06, $01

        .byte $00, $00, $00, $00, $00, $80, $C0, $C0
        .byte $00, $00, $00, $00, $00, $00, $80, $80

        .byte $C0, $E0, $E0, $F0, $F0, $F0, $F0, $F0
        .byte $80, $C0, $40, $60, $20, $20, $20, $00

        .byte $0F, $1F, $1F, $3F, $3F, $7F, $7F, $FF
        .byte $F0, $F0, $E0, $E0, $C0, $C0, $80, $80

        .byte %11111101
        .byte %11111101
        .byte %11111011
        .byte %11111011
        .byte %11111011
        .byte %11110111
        .byte %00001111
        .byte %11111111
        .byte %00000010
        .byte %00000010
        .byte %00000100
        .byte %00000100
        .byte %00000100
        .byte %00001000
        .byte %11110000
        .byte %00000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000001
        .byte %00000010
        .byte %00000100

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00001000
        .byte %00010000
        .byte %00010000
        .byte %00100000
        .byte %00100000
        .byte %00100000
        .byte %01000000
        .byte %01000000

        .byte $80, $00, $00, $00, $80, $80, $80, $80
        .byte $40, $80, $80, $80, $40, $40, $40, $40

        .byte $80, $80, $80, $00, $00, $00, $00, $00
        .byte $40, $40, $40, $80, $80, $80, $80, $80

        .byte $70, $A0, $C0, $E0, $E0, $F0, $F0, $F8
        .byte $80, $40, $20, $10, $10, $08, $08, $04

        .byte $F8, $FC, $FC, $FC, $FC, $FE, $FE, $FE
        .byte $04, $02, $02, $02, $02, $01, $01, $01

        .byte $F8, $F8, $F0, $F0, $F0, $F0, $E0, $E0
        .byte $0F, $1F, $1F, $1F, $1F, $3F, $3F, $3F

        .byte $E0, $F9, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $3F, $3E, $3E, $3E, $3E, $3E, $3E, $3E

        .byte %00011111
        .byte %00011111
        .byte %00111111
        .byte %00111111
        .byte %01111111
        .byte %01111111
        .byte %11111111
        .byte %11111111
        .byte %11100000
        .byte %11100000
        .byte %11000000
        .byte %11000000
        .byte %10000000
        .byte %10000000
        .byte %00000000
        .byte %00000000

        .byte %11111101
        .byte %11111101
        .byte %11111101
        .byte %11111101
        .byte %11111101
        .byte %11111101
        .byte %11111101
        .byte %11111101
        .byte %00000010
        .byte %00000010
        .byte %00000010
        .byte %00000010
        .byte %00000010
        .byte %00000010
        .byte %00000010
        .byte %00000010

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111110
        .byte %11111110
        .byte %11111110
        .byte %11111110
        .byte %11111110
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000001
        .byte %00000001
        .byte %00000001
        .byte %00000001
        .byte %00000001

        .byte $02, $01, $01, $00, $00, $00, $00, $00
        .byte $01, $00, $00, $00, $00, $00, $00, $00

        .byte %01111111
        .byte %01111111
        .byte %01111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %10000000
        .byte %10000000
        .byte %10000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $FF, $7F, $3F, $8F, $40, $3F, $00, $00
        .byte $FF, $FF, $FF, $7F, $3F, $00, $00, $00

        .byte $FF, $FF, $FF, $FE, $FC, $FC, $08, $08
        .byte $FF, $FF, $FE, $FD, $FB, $0B, $07, $07

        .byte $08, $09, $05, $03, $03, $01, $00, $00
        .byte $07, $06, $02, $00, $00, $00, $00, $00

        .byte $E3, $9F, $0F, $1F, $3F, $7F, $FF, $FF
        .byte $80, $60, $F0, $E0, $C0, $80, $00, $00

        .byte $FF, $DF, $8F, $DF, $FF, $FF, $FF, $3F
        .byte $00, $20, $70, $20, $00, $00, $00, $00

        .byte $00, $55, $2A, $05, $00, $00, $00, $00
        .byte $00, $2A, $15, $0A, $01, $00, $00, $00

        .byte $00, $55, $A8, $55, $AB, $15, $00, $00
        .byte $00, $AA, $54, $A9, $53, $25, $00, $00

        .byte $40, $60, $A8, $4E, $AA, $45, $A0, $F8
        .byte $40, $60, $28, $8E, $4A, $A5, $50, $F8

        .byte $00, $16, $8E, $4D, $B8, $28, $70, $20
        .byte $00, $86, $4E, $8D, $38, $A8, $70, $20

        .byte $00, $14, $AA, $55, $A2, $55, $88, $FF
        .byte $00, $EB, $55, $AA, $5D, $AA, $77, $FF

        .byte $00, $13, $AE, $4D, $A6, $55, $88, $FF
        .byte $00, $E3, $4D, $AA, $55, $AA, $77, $FF

        .byte $00, $14, $9A, $4D, $A6, $53, $89, $F8
        .byte $00, $8B, $55, $AA, $55, $AA, $75, $FC

        .byte $00, $00, $80, $40, $A0, $50, $A8, $F8
        .byte $00, $80, $40, $A0, $50, $A8, $54, $FC

        .byte $00, $15, $1A, $0D, $06, $03, $01, $00
        .byte $00, $0A, $15, $0A, $05, $02, $01, $00

        .byte $00, $15, $9A, $4D, $26, $13, $09, $80
        .byte $00, $8A, $55, $AA, $55, $2A, $05, $80

        .byte $60, $45, $22, $01, $A8, $54, $A9, $FE
        .byte $60, $42, $21, $80, $48, $A4, $51, $FE

        .byte $00, $22, $9C, $48, $A4, $50, $A9, $FE
        .byte $00, $A2, $5C, $A8, $54, $A0, $51, $FE

        .byte $00, $55, $AA, $55, $AA, $50, $8E, $98
        .byte $00, $AA, $55, $AA, $54, $A0, $4E, $98

        .byte $00, $55, $A8, $50, $A0, $54, $A4, $E8
        .byte $00, $A9, $50, $A8, $50, $A4, $54, $E8

        .byte $00, $55, $AA, $50, $8E, $18, $80, $40
        .byte $00, $AA, $55, $A0, $4E, $98, $00, $40

        .byte $00, $55, $82, $1F, $76, $0C, $04, $02
        .byte $00, $A9, $42, $1F, $76, $0C, $04, $02

        .byte $00, $55, $AA, $55, $AA, $54, $A1, $E2
        .byte $00, $AA, $55, $AA, $54, $A8, $51, $E6

        .byte %00001100
        .byte %01101100
        .byte %10111000
        .byte %01010000
        .byte %01110000
        .byte %10101000
        .byte %11010000
        .byte %01000001
        .byte %00001100
        .byte %01101100
        .byte %10111000
        .byte %01010000
        .byte %01110000
        .byte %10101000
        .byte %11010000
        .byte %01000001

        .byte $00, $15, $9A, $05, $01, $7C, $01, $00
        .byte $00, $8A, $55, $82, $00, $7C, $03, $00

        .byte $00, $55, $AA, $55, $AA, $55, $2A, $07
        .byte $00, $AA, $55, $AA, $55, $2A, $15, $07

        .byte $00, $55, $2A, $50, $21, $06, $18, $08
        .byte $00, $AA, $54, $28, $11, $06, $18, $08

        .byte $00, $11, $86, $4C, $30, $F8, $04, $02
        .byte $00, $81, $46, $8C, $30, $F8, $04, $02

        .byte %10110011
        .byte %00010100
        .byte %00101100
        .byte %00011100
        .byte %00011000
        .byte %00011000
        .byte %00001000
        .byte %00001100
        .byte %10110011
        .byte %00010100
        .byte %00101100
        .byte %00011100
        .byte %00011000
        .byte %00011000
        .byte %00001000
        .byte %00001100

        .byte %00001000
        .byte %00000100
        .byte %00000110
        .byte %00000010
        .byte %00000000
        .byte %00000001
        .byte %00000000
        .byte %00000000
        .byte %00001000
        .byte %00000100
        .byte %00000110
        .byte %00000010
        .byte %00000000
        .byte %00000001
        .byte %00000000
        .byte %00000000

        .byte $00, $13, $92, $44, $93, $21, $01, $00
        .byte $00, $8B, $52, $A4, $13, $A1, $01, $00

        .byte %01110000
        .byte %11001100
        .byte %10000100
        .byte %00000010
        .byte %00000000
        .byte %00000001
        .byte %00000000
        .byte %00000000
        .byte %01110000
        .byte %11001100
        .byte %10000100
        .byte %00000010
        .byte %00000000
        .byte %00000001
        .byte %00000000
        .byte %00000000

        .byte %11000000
        .byte %00100000
        .byte %00000000
        .byte %11110000
        .byte %01001110
        .byte %10011101
        .byte %00010000
        .byte %10010000
        .byte %11000000
        .byte %00100000
        .byte %00000000
        .byte %11110000
        .byte %01001110
        .byte %10011101
        .byte %00010000
        .byte %10010000

        .byte $FF, $FF, $FF, $FD, $FD, $FD, $F5, $F5
        .byte $FF, $FF, $FF, $FF, $FA, $FA, $FA, $EA

        .byte $FF, $FF, $FF, $EF, $A7, $A3, $24, $24
        .byte $FF, $FF, $FF, $FF, $D7, $DB, $C8, $C8

        .byte $FF, $FE, $FE, $FE, $FE, $FF, $ED, $E9
        .byte $FF, $FF, $FF, $FF, $FF, $FE, $F6, $F2

        .byte $FF, $FF, $FF, $FF, $FF, $DF, $1F, $13
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $EF, $63

        .byte $F5, $D5, $CE, $CE, $9E, $9E, $17, $17
        .byte $EA, $6A, $31, $31, $21, $21, $28, $28

        .byte $7F, $3F, $3F, $3F, $1C, $14, $04, $04
        .byte $7F, $3F, $3F, $3F, $1B, $1B, $1B, $1B

        .byte $00, $04, $04, $05, $05, $01, $01, $01
        .byte $0F, $0B, $0B, $02, $02, $02, $00, $00

        .byte $FF, $F4, $E4, $E4, $E4, $C0, $C2, $C2
        .byte $FC, $FA, $DA, $DB, $1B, $1F, $1D, $1D

        .byte $C3, $C3, $86, $C6, $8C, $CE, $8C, $8E
        .byte $0C, $0C, $08, $08, $00, $00, $00, $00

        .byte $FF, $C7, $C7, $BE, $7D, $2A, $E3, $FD
        .byte $FF, $3E, $3A, $41, $82, $D5, $DC, $FF

        .byte $FF, $FF, $FF, $FF, $FD, $AF, $FF, $94
        .byte $FF, $FF, $FF, $FF, $D3, $D5, $80, $EB

        .byte $E6, $F8, $BE, $7F, $C9, $85, $7F, $FF
        .byte $FF, $D7, $41, $80, $36, $7F, $FF, $FF

        .byte $FC, $CE, $D7, $ED, $FD, $FB, $FF, $EA
        .byte $FF, $F1, $F8, $FE, $FE, $6C, $00, $15

        .byte $80, $DD, $C2, $81, $15, $27, $FF, $FF
        .byte $FF, $27, $3F, $7F, $FF, $FF, $FF, $FF

        .byte $FF, $D7, $A8, $02, $19, $DF, $EA, $35
        .byte $7F, $2F, $57, $FF, $E6, $20, $15, $FF

        .byte $FF, $9F, $1F, $3F, $C9, $85, $FF, $FF
        .byte $FE, $F0, $E0, $C0, $F6, $FF, $FF, $FF

        .byte $FF, $B4, $D0, $FF, $EF, $8B, $1D, $27
        .byte $FF, $FF, $FF, $7F, $3F, $77, $E3, $FF

        .byte $A6, $96, $D6, $D7, $DD, $99, $B1, $B3
        .byte $49, $69, $29, $28, $22, $26, $06, $04

        .byte $B0, $90, $94, $D0, $C2, $C2, $C2, $80
        .byte $04, $04, $00, $00, $00, $00, $00, $00

        .byte $91, $D5, $94, $96, $16, $16, $1E, $0F
        .byte $61, $01, $00, $40, $40, $40, $40, $50

        .byte $CF, $EA, $FA, $F2, $B0, $B0, $B0, $A0
        .byte $10, $10, $00, $00, $00, $00, $00, $00

        .byte $52, $32, $93, $CB, $CB, $CB, $CE, $26
        .byte $2C, $0C, $0C, $04, $04, $04, $00, $80

        .byte $FF, $BF, $A7, $67, $65, $7C, $7C, $2C
        .byte $FF, $DF, $CB, $0B, $09, $00, $00, $10

        .byte $26, $2A, $0A, $18, $18, $1C, $1C, $16
        .byte $18, $10, $10, $00, $00, $00, $00, $08

        .byte $32, $1A, $9A, $9B, $CB, $C9, $D1, $50
        .byte $08, $00, $00, $00, $00, $00, $00, $00

        .byte $E9, $F9, $F9, $F1, $95, $95, $95, $31
        .byte $F2, $E2, $E2, $EA, $CA, $CA, $CA, $CE

        .byte $51, $53, $13, $13, $B7, $A7, $65, $65
        .byte $AE, $AC, $EC, $E4, $40, $40, $00, $00

        .byte $67, $67, $76, $76, $6E, $6C, $AC, $AC
        .byte $18, $18, $09, $09, $11, $13, $13, $13

        .byte $AC, $8E, $0B, $1B, $0B, $03, $01, $01
        .byte $13, $11, $10, $00, $00, $00, $00, $00

        .byte $FF, $FF, $7F, $3F, $1F, $4F, $4F, $4F
        .byte $FF, $FF, $7F, $3F, $1F, $0F, $0F, $0F

        .byte $07, $06, $C0, $E2, $61, $61, $20, $30
        .byte $07, $07, $03, $01, $00, $00, $00, $00

        .byte $FF, $3F, $2D, $25, $21, $03, $0D, $08
        .byte $FF, $FE, $5E, $56, $06, $04, $00, $00

        .byte $23, $2B, $0B, $9B, $AF, $2D, $58, $50
        .byte $CC, $C4, $E4, $64, $50, $50, $00, $00

        .byte %01000010
        .byte %01001010
        .byte %01001010
        .byte %00000010
        .byte %00000010
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $22, $22, $76, $36, $54, $50, $40, $40
        .byte $4C, $4C, $08, $08, $00, $00, $00, $00

        .byte %10000001
        .byte %00000000
        .byte %00000010
        .byte %00000010
        .byte %00001010
        .byte %00001000
        .byte %00001000
        .byte %00001000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $01, $01, $03, $07, $06, $0C, $09, $01
        .byte $01, $01, $03, $07, $06, $0C, $08, $00

        .byte %00000000
        .byte %00000001
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00001111
        .byte %00111111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $07, $03, $7B, $FF, $3E, $7B, $F4, $E7
        .byte $01, $00, $03, $0F, $3F, $7F, $FF, $FC

        .byte $DF, $BF, $7B, $77, $E7, $CF, $9F, $BE
        .byte $F9, $E3, $83, $07, $07, $07, $07, $0F

        .byte $7F, $7D, $5D, $DA, $8B, $8F, $0B, $03
        .byte $0F, $2F, $6F, $EF, $EE, $CC, $88, $00

        .byte $00, $00, $44, $99, $7E, $FD, $F9, $F6
        .byte $00, $14, $7F, $FF, $FF, $FF, $FF, $FF

        .byte $FC, $FD, $FE, $FF, $FF, $FF, $FF, $FF
        .byte $FB, $FF, $F7, $C3, $42, $8A, $20, $F8

        .byte $00, $00, $00, $20, $A4, $7A, $FC, $FE
        .byte $00, $00, $00, $60, $FE, $FF, $FF, $FF

        .byte $7F, $F3, $BD, $FF, $FF, $FF, $FF, $FF
        .byte $BF, $3F, $7F, $77, $62, $40, $42, $09

        .byte $03, $03, $02, $AE, $3B, $71, $FF, $FF
        .byte $00, $00, $39, $FD, $FF, $FF, $FF, $FF

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %01111111
        .byte %01111111
        .byte %00010111
        .byte %00010011
        .byte %10101011

        .byte $00, $F8, $7D, $3E, $1E, $0F, $C9, $EE
        .byte $00, $08, $05, $02, $02, $01, $06, $81

        .byte $F1, $DE, $C1, $F2, $D5, $E6, $EF, $FF
        .byte $4F, $FF, $FF, $FF, $BF, $7F, $7F, $FF

        .byte $FF, $FF, $FF, $FF, $FF, $FE, $FE, $FF
        .byte $F9, $FB, $F3, $F7, $FF, $FF, $FF, $FF

        .byte $FF, $FD, $FF, $FB, $FF, $FF, $FF, $FF
        .byte $FE, $FE, $FC, $FD, $F9, $FD, $FB, $F3

        .byte $DF, $FF, $7F, $7F, $FF, $FF, $FF, $FF
        .byte $70, $F2, $9B, $BB, $3F, $BF, $FF, $7F

        .byte $00, $00, $00, $00, $80, $E0, $F0, $F8
        .byte $00, $00, $00, $00, $00, $00, $00, $80

        .byte $EF, $EF, $EF, $FF, $FF, $FF, $FF, $FF
        .byte $B8, $9C, $DC, $CE, $EE, $EF, $FF, $FF

        .byte $FC, $FE, $E2, $78, $1C, $0E, $66, $F7
        .byte $40, $C0, $E0, $C0, $E0, $F0, $F8, $7C

        .byte $00, $00, $00, $C0, $CF, $FF, $FF, $FF
        .byte $00, $00, $00, $C0, $CF, $70, $61, $3A

        .byte $FF, $BF, $43, $EC, $C3, $FE, $C7, $C3
        .byte $FF, $FF, $FF, $FF, $7F, $7D, $FE, $7E

        .byte $F7, $F3, $D9, $E5, $B3, $DB, $AF, $CF
        .byte $FB, $FC, $FE, $FA, $EC, $E4, $F0, $F0

        .byte $7F, $3F, $E7, $C7, $C7, $8F, $8F, $8E
        .byte $E0, $C0, $82, $00, $00, $04, $04, $0C

        .byte $25, $F5, $FE, $FF, $FF, $FD, $FE, $FE
        .byte $FE, $BE, $7F, $BF, $7F, $5F, $3F, $3F

        .byte $FE, $FD, $FE, $FF, $FD, $7D, $7F, $77
        .byte $1F, $5F, $4F, $2E, $66, $36, $36, $30

        .byte $FB, $FD, $FD, $FF, $FF, $FF, $FE, $FF
        .byte $DE, $2E, $5E, $36, $0B, $09, $05, $03

        .byte $DF, $C7, $C3, $C1, $C1, $80, $80, $80
        .byte $00, $02, $00, $00, $00, $00, $00, $00

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %10000000
        .byte %10000000
        .byte %11000000
        .byte %11000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %11000000
        .byte %11000000
        .byte %11100000
        .byte %11100000
        .byte %11100000
        .byte %11100000
        .byte %01100000
        .byte %00100000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $0F, $1F, $7F, $03, $00, $0F, $3F, $7F
        .byte $00, $00, $00, $00, $00, $00, $00, $01

        .byte $FF, $0F, $3F, $7E, $78, $F2, $EA, $DA
        .byte $01, $0F, $1F, $6F, $3F, $DF, $77, $F5

        .byte $FF, $FF, $FF, $FF, $FF, $FB, $FD, $F1
        .byte $00, $38, $0F, $03, $01, $07, $3F, $FF

        .byte $E3, $82, $2A, $3E, $AE, $BC, $FD, $FD
        .byte $FF, $FD, $FD, $F1, $F1, $C3, $43, $03

        .byte $71, $9E, $9E, $E1, $FE, $E2, $81, $02
        .byte $0E, $01, $01, $DE, $FD, $FF, $FF, $FF

        .byte $0E, $1B, $3D, $6F, $F7, $7F, $BD, $EF
        .byte $FD, $FE, $F6, $D8, $A8, $C6, $DF, $3F

        .byte $AB, $3F, $BF, $FF, $FF, $FF, $FF, $FF
        .byte $F4, $E0, $C0, $80, $41, $83, $86, $8E

        .byte $FF, $FF, $FF, $FF, $F7, $F7, $EF, $EF
        .byte $18, $30, $30, $61, $C9, $D8, $B9, $F9

        .byte $97, $3F, $7F, $FF, $FF, $FF, $FF, $FF
        .byte $7D, $F5, $F1, $E9, $FB, $F3, $F3, $F3

        .byte $FF, $DF, $DF, $FF, $FF, $FF, $FF, $FF
        .byte $C3, $E3, $E7, $D7, $D7, $8F, $8F, $8F

        .byte $67, $63, $A3, $FF, $FF, $FF, $FF, $FF
        .byte $30, $10, $90, $CE, $EE, $EF, $FF, $FF

        .byte $BF, $BF, $BF, $FF, $FF, $FF, $FF, $FF
        .byte $CF, $EF, $CF, $8F, $8F, $5F, $9F, $9F

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00011111
        .byte %11011111
        .byte %10011111
        .byte %10011111
        .byte %11011111
        .byte %11011111
        .byte %10011111
        .byte %00011111

        .byte %11111110
        .byte %00011111
        .byte %00000111
        .byte %00000011
        .byte %00000001
        .byte %00000001
        .byte %00000000
        .byte %11111000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $03, $07, $06, $0C, $0A, $87, $E7, $EF
        .byte $03, $07, $07, $0F, $85, $EC, $FB, $F7

        .byte $A0, $A8, $F5, $FE, $FE, $FF, $7F, $7F
        .byte $20, $08, $05, $06, $02, $03, $01, $01

        .byte $FD, $FF, $FF, $FE, $FC, $FE, $FB, $F9
        .byte $02, $38, $C2, $FD, $0B, $FB, $17, $77

        .byte $F0, $E4, $E3, $89, $C4, $C6, $A3, $97
        .byte $AF, $5F, $9E, $77, $3B, $B9, $5C, $68

        .byte $83, $A3, $11, $49, $25, $93, $4B, $A7
        .byte $7F, $7D, $FE, $FE, $FA, $EC, $F4, $D8

        .byte $DF, $6F, $3F, $FF, $FF, $FF, $FF, $FF
        .byte $E0, $D0, $E0, $00, $80, $00, $60, $E0

        .byte $CF, $8F, $BF, $FF, $FF, $FF, $FF, $FF
        .byte $70, $70, $41, $01, $C3, $C3, $C3, $C7

        .byte $DF, $DF, $DF, $DF, $DF, $FF, $FF, $FF
        .byte $E7, $E7, $EF, $EF, $EF, $FF, $FF, $FF

        .byte $FF, $FF, $FF, $FF, $FF, $DF, $DF, $BF
        .byte $E0, $E0, $E0, $E0, $D0, $F1, $B1, $F9

        .byte $FF, $FF, $FF, $BF, $BF, $BF, $FF, $BF
        .byte $99, $A3, $93, $C3, $F3, $F3, $B3, $E3

        .byte $DF, $CF, $DF, $FF, $FF, $FF, $FF, $FF
        .byte $F9, $F3, $EF, $DE, $FC, $FD, $FF, $FF

        .byte $00, $00, $80, $C0, $60, $71, $FF, $FF
        .byte $00, $00, $80, $C0, $60, $71, $BE, $B8

        .byte $90, $A0, $F4, $FC, $0E, $7E, $C7, $7F
        .byte $E0, $D8, $08, $C0, $F0, $E0, $FC, $F0

        .byte $00, $00, $00, $00, $00, $F8, $FE, $FF
        .byte $00, $00, $00, $00, $00, $F8, $00, $00

        .byte $F8, $7C, $7A, $FB, $C7, $0B, $8F, $EB
        .byte $3F, $8F, $8F, $FF, $3B, $F5, $F0, $7C

        .byte $DB, $B0, $FF, $DF, $9D, $3C, $7A, $BA
        .byte $7E, $7F, $74, $F3, $FB, $F3, $ED, $5D

        .byte $3F, $0F, $83, $81, $F8, $E0, $FC, $FF
        .byte $C0, $F0, $FC, $FE, $FF, $FF, $FF, $FF

        .byte $FE, $FF, $FF, $FF, $FE, $3C, $FC, $18
        .byte $3F, $07, $00, $80, $87, $CF, $E3, $E7

        .byte $F7, $EF, $DB, $B7, $EF, $DF, $FF, $FC
        .byte $2D, $5E, $3E, $5E, $5B, $37, $2B, $17

        .byte $F9, $F3, $F7, $FE, $FD, $FB, $FE, $FF
        .byte $0F, $0D, $0B, $07, $06, $05, $03, $01

        .byte $FE, $4D, $3F, $06, $9F, $87, $C7, $DF
        .byte $E1, $F3, $F3, $F9, $70, $78, $B8, $B8

        .byte $C7, $CF, $6F, $E7, $EF, $6F, $EF, $EF
        .byte $B8, $B0, $D8, $D8, $D0, $D8, $D8, $D0

        .byte $F3, $BF, $73, $FF, $F0, $EF, $DC, $F7
        .byte $FE, $FE, $FE, $EF, $5F, $3F, $37, $0F

        .byte $EE, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $1D, $09, $03, $86, $81, $C0, $C0, $E0

        .byte $80, $80, $AC, $FC, $FE, $FF, $FF, $FF
        .byte $40, $7C, $7E, $3F, $9F, $1F, $9F, $9F

        .byte $7F, $FF, $7F, $FF, $3F, $FF, $BF, $FF
        .byte $CF, $8F, $C7, $C7, $C7, $C7, $43, $43

        .byte $E0, $F4, $FA, $FC, $7E, $3F, $DF, $2B
        .byte $3F, $9F, $CF, $EF, $F3, $F9, $FC, $FE

        .byte %01100101
        .byte %00101000
        .byte %11010010
        .byte %00111001
        .byte %10001100
        .byte %01010010
        .byte %10000001
        .byte %11001001
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte $65, $28, $D2, $39, $8D, $53, $87, $CF
        .byte $FF, $FF, $FF, $FE, $FE, $FC, $F8, $F1

        .byte $98, $B0, $70, $60, $C0, $C0, $80, $00
        .byte $70, $60, $E0, $C0, $80, $80, $00, $00

        .byte $80, $C0, $E0, $70, $38, $9C, $AE, $CF
        .byte $00, $00, $80, $C0, $E0, $F0, $78, $3C

        .byte $E5, $FA, $FE, $3D, $9E, $5F, $87, $CB
        .byte $1E, $0D, $83, $C3, $E1, $F0, $F8, $FC

        .byte $F3, $6C, $39, $19, $0F, $06, $03, $01
        .byte $7F, $3F, $1F, $0F, $07, $03, $01, $00

        .byte $FE, $88, $C9, $A5, $0A, $A0, $15, $7F
        .byte $FF, $FF, $FF, $FF, $FF, $DF, $EF, $80

        .byte $ED, $F3, $39, $3C, $1E, $07, $AF, $FF
        .byte $9E, $CF, $E7, $F3, $F9, $F8, $F0, $00

        .byte $05, $05, $02, $03, $01, $01, $00, $00
        .byte $03, $03, $01, $01, $00, $00, $00, $00

        .byte $A7, $EB, $F1, $FD, $3E, $3E, $AF, $E7
        .byte $7D, $3E, $9F, $CF, $F7, $DB, $79, $1C

        .byte $E0, $F4, $FA, $FC, $7E, $7F, $BF, $4F
        .byte $3F, $9F, $4F, $AF, $D3, $E9, $F4, $FA

        .byte $FE, $88, $C9, $A5, $1A, $78, $9D, $BF
        .byte $FF, $FF, $FF, $FF, $FF, $9F, $6F, $60

        .byte $7D, $38, $F2, $39, $CC, $52, $81, $C9
        .byte $E7, $EF, $DF, $DF, $BF, $BF, $7F, $7F

        .byte $68, $58, $3C, $2C, $12, $16, $0D, $0B
        .byte $30, $30, $18, $18, $0C, $0C, $06, $06

        .byte $3F, $1F, $3E, $2E, $7C, $5C, $F8, $B8
        .byte $00, $0E, $05, $1D, $13, $3B, $37, $57

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %10000001
        .byte %11000000
        .byte %11001000
        .byte %11000000
        .byte %11001000
        .byte %11000100
        .byte %11001000
        .byte %11000100

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11100010
        .byte %11100100
        .byte %11110010
        .byte %11110010
        .byte %11110010
        .byte %11111010
        .byte %11111001
        .byte %11111001

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11010000
        .byte %11000000
        .byte %11000000
        .byte %01000001
        .byte %01000001
        .byte %01000001
        .byte %00000001
        .byte %10000011

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11000011
        .byte %11000011
        .byte %11000011
        .byte %11100111
        .byte %11100111
        .byte %11101111
        .byte %11111111
        .byte %11111111

        .byte $BF, $BF, $FF, $FF, $DF, $DF, $FF, $DF
        .byte $D0, $DC, $9E, $CF, $EF, $EF, $CF, $EF

        .byte $FF, $FF, $DF, $FF, $FF, $FE, $FE, $FF
        .byte $CF, $CF, $EF, $CF, $E7, $E7, $E7, $E2

        .byte $FF, $FF, $FF, $FF, $BF, $BF, $BF, $FF
        .byte $03, $03, $03, $03, $C3, $D3, $DB, $9F

        .byte $FF, $7F, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $9F, $9F, $3F, $3F, $3F, $3F, $7F, $7F

        .byte $C0, $E0, $F0, $F8, $FC, $0E, $00, $30
        .byte $00, $00, $00, $00, $00, $80, $80, $C0

        .byte $E1, $F7, $FF, $FE, $7E, $3C, $F9, $79
        .byte $3E, $9C, $C8, $E1, $F1, $E3, $C7, $86

        .byte $77, $79, $FA, $3D, $9E, $5F, $87, $CB
        .byte $8E, $8F, $87, $C3, $E1, $F0, $F8, $FC

        .byte $E0, $F4, $FB, $FD, $7F, $3F, $DF, $2F
        .byte $3F, $9F, $CF, $EF, $F2, $F8, $FC, $F8

        .byte $F6, $F6, $EC, $CC, $98, $B0, $70, $60
        .byte $4C, $1C, $98, $38, $70, $60, $E0, $C0

        .byte $E0, $C0, $80, $80, $00, $00, $00, $00
        .byte $C0, $80, $00, $00, $00, $00, $00, $00

        .byte $EE, $7E, $F9, $7D, $7F, $E6, $EE, $DC
        .byte $31, $83, $C7, $E7, $CE, $9C, $1C, $38

        .byte $65, $2B, $DF, $3E, $8E, $5F, $99, $FB
        .byte $FE, $FC, $F8, $F9, $F1, $E3, $E7, $CE

        .byte $01, $01, $03, $02, $07, $05, $0F, $0B
        .byte $00, $00, $00, $01, $01, $03, $02, $04

        .byte $1F, $1F, $3E, $2E, $7C, $5C, $F8, $B8
        .byte $00, $0E, $05, $1D, $13, $3B, $37, $57

        .byte $81, $81, $43, $C2, $E7, $65, $F7, $D9
        .byte $00, $00, $80, $81, $C1, $C3, $63, $76

        .byte $7B, $5B, $3E, $2E, $3C, $5C, $F8, $B8
        .byte $26, $2E, $0D, $1D, $13, $3B, $37, $57

        .byte $F1, $72, $E2, $E7, $D4, $CF, $88, $8C
        .byte $6E, $CD, $DD, $9B, $BB, $37, $77, $77

        .byte $F0, $D4, $FA, $BC, $7E, $7F, $DF, $AB
        .byte $EF, $EF, $DF, $CF, $B3, $B9, $7C, $7E

        .byte $F1, $F5, $E2, $E2, $C6, $C7, $8F, $8B
        .byte $EE, $EE, $DD, $1D, $BB, $B9, $74, $76

        .byte %00000000
        .byte %01111110
        .byte %01000010
        .byte %01000010
        .byte %01000010
        .byte %01000010
        .byte %01111110
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte $00, $00, $01, $02, $07, $08, $08, $10
        .byte $00, $00, $00, $01, $00, $07, $07, $0F

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte $00, $00, $F0, $18, $0C, $06, $06, $07
        .byte $00, $00, $00, $E0, $F0, $F8, $F8, $F8

        .byte $0F, $7C, $B0, $E8, $7C, $BA, $FC, $6F
        .byte $00, $0F, $5F, $1F, $0F, $47, $07, $13

        .byte $5E, $AF, $BB, $7C, $2F, $79, $3F, $00
        .byte $21, $70, $64, $03, $11, $07, $00, $00

        .byte $E0, $7C, $1A, $2E, $7C, $BA, $7E, $EC
        .byte $00, $E0, $F4, $F0, $E0, $C4, $C0, $90

        .byte $F4, $EA, $BA, $7C, $F0, $3C, $F8, $00
        .byte $08, $1C, $4C, $80, $20, $C0, $00, $00

        .byte $00, $00, $00, $01, $03, $06, $08, $1C
        .byte $00, $00, $00, $00, $00, $01, $07, $03

        .byte $3F, $7F, $7F, $FF, $FF, $FF, $FF, $FF
        .byte $1C, $3E, $3F, $7F, $7F, $7F, $7F, $7F

        .byte $10, $10, $70, $F0, $D4, $DF, $7B, $2C
        .byte $0F, $0F, $0F, $0F, $2B, $20, $84, $D3

        .byte $3C, $9E, $9B, $CD, $CC, $CE, $CF, $EF
        .byte $C3, $61, $64, $32, $B3, $B1, $B0, $94

        .byte %00000111
        .byte %00000011
        .byte %00110011
        .byte %00000011
        .byte %00001111
        .byte %11111111
        .byte %11111111
        .byte %11111011
        .byte %11111000
        .byte %11111100
        .byte %11001100
        .byte %11111100
        .byte %11110000
        .byte %00000000
        .byte %00000000
        .byte %00000100

        .byte %00000111
        .byte %00100111
        .byte %00001111
        .byte %10011111
        .byte %11111110
        .byte %01110110
        .byte %10011110
        .byte %11111101
        .byte %11111000
        .byte %11011000
        .byte %11110000
        .byte %01100000
        .byte %00000001
        .byte %10001001
        .byte %01100001
        .byte %00000010

        .byte $00, $00, $C0, $F0, $F8, $D6, $AF, $BF
        .byte $00, $00, $00, $00, $00, $28, $5E, $5C

        .byte $3B, $7F, $7F, $7E, $7F, $FC, $F3, $DF
        .byte $FF, $BF, $BF, $BF, $BC, $23, $0C, $20

        .byte $00, $00, $00, $00, $00, $00, $01, $07
        .byte $00, $00, $00, $00, $00, $00, $00, $01

        .byte $1F, $3F, $7F, $FF, $C7, $03, $01, $00
        .byte $07, $1F, $3F, $07, $03, $01, $00, $00

        .byte $01, $03, $03, $03, $01, $01, $00, $00
        .byte $00, $01, $01, $01, $00, $00, $00, $00

        .byte %00000000
        .byte %00000000
        .byte %00000001
        .byte %00000001
        .byte %00000001
        .byte %00000001
        .byte %00000001
        .byte %00000001
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $FE, $FF, $FF, $F8, $FE, $FF, $FF, $FF
        .byte $00, $FE, $FF, $FF, $FF, $FF, $4F, $1F

        .byte $FF, $FF, $FF, $FF, $FE, $FE, $FF, $FF
        .byte $7F, $7F, $FF, $FF, $FF, $FF, $FF, $FF

        .byte $00, $F0, $FF, $31, $0C, $03, $C0, $E0
        .byte $00, $00, $F0, $FF, $FF, $FF, $FF, $FF

        .byte %11110000
        .byte %11111000
        .byte %11100000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %10000000
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %10000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $E0, $D0, $F8, $9C, $7A, $FE, $FE, $FE
        .byte $80, $E0, $80, $60, $84, $00, $00, $00

        .byte $01, $07, $0F, $3F, $7F, $FF, $FF, $FF
        .byte $00, $01, $07, $07, $37, $7B, $FB, $7D

        .byte $FF, $FD, $FE, $BE, $9F, $CF, $EF, $E7
        .byte $BD, $DE, $EF, $F7, $F7, $FB, $FB, $7D

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %01111111
        .byte %01111100
        .byte %01111100
        .byte %01111100
        .byte %01110110
        .byte %10111111
        .byte %10110111

        .byte $FF, $FF, $FF, $FF, $7F, $77, $BB, $DB
        .byte $D7, $D3, $6B, $6B, $B1, $B8, $DC, $EC

        .byte $FC, $FF, $FF, $FF, $FF, $FE, $F8, $E0
        .byte $FF, $FF, $FF, $7C, $00, $00, $00, $80

        .byte $BF, $80, $C1, $C0, $C0, $C1, $E1, $FF
        .byte $F0, $FF, $FE, $FF, $FF, $FF, $7F, $3F

        .byte $FF, $FF, $BE, $DF, $FF, $FF, $7F, $7F
        .byte $3F, $3F, $5F, $7C, $7F, $7F, $37, $3F

        .byte $7F, $7F, $7B, $3D, $2B, $3F, $17, $3F
        .byte $37, $37, $3F, $1E, $1C, $08, $08, $00

        .byte $E7, $57, $D7, $EB, $E3, $FC, $F0, $FF
        .byte $9A, $AB, $29, $94, $DC, $C3, $CF, $C0

        .byte $FF, $BF, $FF, $9F, $4F, $F7, $FB, $FD
        .byte $C0, $C0, $80, $60, $B0, $08, $04, $02

        .byte $FD, $FB, $F7, $EE, $9D, $3F, $FF, $FB
        .byte $02, $05, $CB, $17, $67, $C5, $03, $05

        .byte %11110011
        .byte %11110111
        .byte %11111110
        .byte %11101111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00001100
        .byte %00001000
        .byte %00000001
        .byte %00010000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $FF, $FF, $FF, $FF, $FF, $FF, $F3, $F0
        .byte $C0, $E0, $E0, $E0, $C0, $C0, $AC, $CF

        .byte %11000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %10000000
        .byte %11000001
        .byte %11111111
        .byte %00111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %01111111
        .byte %00111110
        .byte %00000000

        .byte $3F, $37, $33, $30, $38, $38, $38, $18
        .byte $00, $08, $0C, $0F, $07, $07, $07, $07

        .byte $1C, $1C, $1E, $7E, $FF, $7F, $00, $00
        .byte $03, $03, $01, $01, $00, $00, $00, $00

        .byte $FF, $FF, $FF, $FF, $0F, $03, $01, $01
        .byte $00, $00, $00, $01, $F1, $FD, $FE, $FE

        .byte $00, $00, $00, $01, $83, $FF, $00, $00
        .byte $FF, $FF, $FF, $FE, $7C, $00, $00, $00

        .byte $FF, $FF, $FF, $FF, $DF, $FF, $FF, $FF
        .byte $00, $00, $C0, $F0, $F8, $EC, $F8, $F8

        .byte $FF, $FF, $FF, $FF, $FF, $FF, $00, $00
        .byte $70, $60, $00, $00, $00, $00, $00, $00

        .byte $FA, $F6, $F4, $E8, $F0, $D0, $E0, $E0
        .byte $04, $08, $08, $10, $00, $20, $00, $00

        .byte %11110000
        .byte %11110000
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %11111110
        .byte %11111100
        .byte %11111000
        .byte %00000000
        .byte %10000000
        .byte %10000000
        .byte %11000000
        .byte %11000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $C0, $40, $40, $40, $C0, $80, $80, $00
        .byte $00, $80, $80, $80, $00, $00, $00, $00

        .byte $77, $33, $1B, $09, $0D, $04, $06, $06
        .byte $3D, $1E, $0E, $07, $07, $03, $03, $03

        .byte $07, $07, $0F, $1F, $3F, $3F, $7F, $FF
        .byte $03, $03, $03, $07, $07, $0F, $0F, $0F

        .byte $CD, $E6, $E3, $F1, $F8, $FC, $FC, $7E
        .byte $F6, $FB, $FD, $7E, $7F, $BF, $DF, $EF

        .byte $3F, $1F, $0F, $07, $07, $03, $03, $01
        .byte $F7, $FB, $FD, $FE, $FF, $FF, $FF, $FF

        .byte $FF, $FF, $7F, $BF, $FF, $7F, $9A, $66
        .byte $00, $03, $83, $C7, $37, $CF, $FF, $FF

        .byte $1C, $80, $C0, $F1, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $3E, $00, $81, $C1

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte %00000000
        .byte %00000000
        .byte %10000000
        .byte %11111000
        .byte %11111110
        .byte %11110000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $FF, $BF, $3F, $3F, $3F, $1F, $1F, $0F
        .byte $1F, $1F, $0F, $0F, $07, $03, $01, $00

        .byte %00001111
        .byte %00000111
        .byte %00000111
        .byte %00000111
        .byte %00000111
        .byte %00000111
        .byte %00000111
        .byte %00000111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $01, $80, $80, $C0, $E0, $F0, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00111111
        .byte %00001111
        .byte %00000011
        .byte %00011111
        .byte %00111111
        .byte %01111111
        .byte %01111111
        .byte %01111111

        .byte $FF, $FF, $7F, $7F, $3F, $3F, $FF, $FF
        .byte $C1, $C1, $E1, $E1, $E3, $F3, $F3, $F3

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111011
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte $00, $00, $80, $E0, $30, $10, $88, $08
        .byte $00, $00, $00, $80, $E0, $E0, $F0, $F0

        .byte $04, $04, $22, $12, $21, $11, $0A, $12
        .byte $F8, $F8, $FC, $FC, $FE, $FE, $FC, $FC

        .byte $00, $00, $00, $00, $01, $03, $06, $0C
        .byte $00, $00, $00, $00, $00, $00, $01, $03

        .byte $0C, $18, $30, $30, $60, $60, $60, $60
        .byte $03, $07, $0F, $0F, $1F, $1F, $1F, $1F

        .byte $00, $00, $00, $00, $00, $30, $7C, $FE
        .byte $00, $00, $00, $00, $38, $FC, $FE, $FF

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %01111111
        .byte %01111111
        .byte %01111111
        .byte %01111111
        .byte %01111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte $00, $80, $C0, $C0, $E0, $E0, $F0, $F0
        .byte $80, $C0, $E0, $F0, $F0, $F8, $F8, $F8

        .byte $F0, $D0, $80, $80, $00, $00, $00, $00
        .byte $F8, $F8, $F0, $E0, $C0, $C0, $80, $00

        .byte $14, $24, $FC, $FC, $FC, $3E, $1D, $38
        .byte $F8, $F8, $F8, $00, $00, $00, $0A, $17

        .byte $FF, $3F, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $17, $EF, $6F, $DF, $DF, $BF, $BF, $7F

        .byte $60, $60, $60, $60, $60, $30, $30, $38
        .byte $1F, $1F, $1F, $1F, $1F, $0F, $0F, $07

        .byte $3C, $38, $7C, $6E, $6D, $C6, $C3, $C1
        .byte $03, $07, $03, $11, $12, $39, $3C, $3E

        .byte %01111111
        .byte %01111111
        .byte %01111111
        .byte %01111111
        .byte %00111111
        .byte %00111110
        .byte %00111100
        .byte %00111100
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte $19, $03, $05, $0A, $10, $10, $00, $85
        .byte $FE, $FC, $FA, $F5, $EF, $EF, $FF, $7B

        .byte %11111100
        .byte %11111111
        .byte %11111110
        .byte %11111111
        .byte %11111110
        .byte %11111111
        .byte %11111010
        .byte %11111111
        .byte %11111100
        .byte %11111111
        .byte %11111110
        .byte %11111111
        .byte %11111110
        .byte %11111111
        .byte %11111010
        .byte %11111111

        .byte $00, $03, $0F, $1F, $1F, $3F, $3F, $1F
        .byte $00, $00, $00, $00, $02, $06, $0E, $0F

        .byte $00, $00, $00, $00, $00, $00, $C0, $C0
        .byte $00, $40, $C0, $C0, $C0, $E0, $E0, $F0

        .byte $E0, $E0, $F0, $F0, $F0, $F0, $E0, $E0
        .byte $F0, $F8, $F8, $F8, $F8, $F8, $F8, $F8

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte $00, $00, $00, $00, $00, $00, $01, $07
        .byte $00, $00, $00, $00, $00, $01, $07, $1F

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte $00, $00, $00, $00, $00, $80, $80, $C0
        .byte $00, $00, $00, $00, $00, $C0, $E0, $C0

        .byte $02, $07, $0B, $09, $09, $05, $02, $3E
        .byte $00, $02, $06, $06, $06, $02, $00, $00

        .byte $47, $83, $63, $1A, $66, $83, $43, $3A
        .byte $3E, $7E, $1E, $04, $1C, $7E, $3E, $04

        .byte %10000100
        .byte %00100000
        .byte %10011100
        .byte %01000001
        .byte %10001100
        .byte %10110010
        .byte %01000000
        .byte %11111111
        .byte %10000100
        .byte %00100000
        .byte %10011100
        .byte %01000001
        .byte %10001100
        .byte %10110010
        .byte %01000000
        .byte %11111111

        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FE
        .byte $00, $04, $09, $62, $62, $E8, $F9, $FB

        .byte %00001000
        .byte %11000000
        .byte %00001011
        .byte %01010100
        .byte %00000000
        .byte %10000110
        .byte %01000000
        .byte %11111111
        .byte %00001000
        .byte %11000000
        .byte %00001011
        .byte %01010100
        .byte %00000000
        .byte %10000110
        .byte %01000000
        .byte %11111111

        .byte $E0, $F8, $FC, $FE, $FE, $FF, $FF, $FF
        .byte $00, $00, $60, $30, $18, $1C, $8A, $92

        .byte %00000000
        .byte %01000000
        .byte %00000000
        .byte %00010000
        .byte %00000000
        .byte %01000000
        .byte %00000000
        .byte %11110101
        .byte %00000000
        .byte %01000000
        .byte %00000000
        .byte %00010000
        .byte %00000000
        .byte %01000000
        .byte %00000000
        .byte %11110101

        .byte %00010000
        .byte %00000011
        .byte %11010000
        .byte %00101010
        .byte %00000000
        .byte %01100001
        .byte %00000010
        .byte %11111111
        .byte %00010000
        .byte %00000011
        .byte %11010000
        .byte %00101010
        .byte %00000000
        .byte %01100001
        .byte %00000010
        .byte %11111111

        .byte %00000000
        .byte %00000010
        .byte %00000000
        .byte %00001000
        .byte %00000000
        .byte %00000010
        .byte %00000000
        .byte %10101111
        .byte %00000000
        .byte %00000010
        .byte %00000000
        .byte %00001000
        .byte %00000000
        .byte %00000010
        .byte %00000000
        .byte %10101111

        .byte %00111111
        .byte %11111111
        .byte %01111111
        .byte %11111111
        .byte %01111111
        .byte %11111111
        .byte %01011111
        .byte %11111111
        .byte %00111111
        .byte %11111111
        .byte %01111111
        .byte %11111111
        .byte %01111111
        .byte %11111111
        .byte %01011111
        .byte %11111111

        .byte $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F
        .byte $BF, $BF, $BF, $BF, $BF, $BF, $BF, $BF

        .byte $7F, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $BF, $3F, $7F, $7F, $FF, $FF, $FF, $FF

        .byte $C0, $C0, $C0, $60, $60, $60, $30, $30
        .byte $3F, $3F, $3F, $1F, $1F, $1F, $0F, $0F

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte $0B, $1F, $37, $2F, $7F, $6F, $5F, $F7
        .byte $F7, $E7, $CF, $DF, $8F, $9F, $AF, $0F

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte $1F, $0F, $1F, $3F, $3F, $3F, $7F, $7F
        .byte $01, $04, $00, $10, $1D, $0B, $09, $00

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000011
        .byte %00001100
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $00, $00, $00, $00, $00, $00, $C0, $30
        .byte $00, $00, $00, $00, $00, $00, $00, $C0

        .byte $88, $E4, $F2, $FD, $FE, $FF, $FF, $FF
        .byte $F0, $F8, $FC, $FE, $FF, $FF, $FF, $FF

        .byte $00, $00, $00, $00, $00, $01, $03, $02
        .byte $00, $00, $00, $00, $00, $00, $01, $01

        .byte $07, $0F, $1B, $3A, $72, $66, $EC, $CB
        .byte $03, $06, $0C, $0F, $2F, $3F, $7F, $7F

        .byte $13, $2F, $2F, $5F, $DF, $FF, $75, $CF
        .byte $0F, $17, $13, $21, $22, $A6, $8E, $BE

        .byte $BF, $F0, $31, $21, $63, $42, $DF, $FF
        .byte $E7, $4F, $DF, $FF, $FF, $FF, $F9, $39

        .byte $FF, $FF, $FF, $7F, $7F, $7F, $FF, $FE
        .byte $00, $00, $00, $80, $80, $80, $8C, $99

        .byte $FE, $FB, $91, $E3, $64, $F8, $98, $1C
        .byte $01, $1F, $7E, $DE, $BF, $FF, $F7, $E7

        .byte $FE, $FE, $FE, $FE, $BE, $3E, $B8, $F8
        .byte $43, $8C, $82, $C2, $E6, $FE, $FC, $F8

        .byte $FD, $FF, $FF, $3F, $9F, $AF, $97, $BF
        .byte $00, $78, $1E, $0F, $07, $03, $02, $08

        .byte $FF, $FF, $F7, $6B, $6B, $7B, $FF, $FF
        .byte $22, $28, $1C, $9C, $9C, $9C, $1C, $28

        .byte $FF, $FF, $FF, $FF, $FF, $FE, $FC, $FB
        .byte $10, $4A, $39, $3C, $14, $B4, $90, $A0

        .byte $00, $1F, $0F, $00, $03, $01, $00, $00
        .byte $3F, $1F, $0F, $04, $03, $01, $01, $01

        .byte $00, $80, $C0, $40, $60, $F0, $DC, $63
        .byte $00, $00, $00, $80, $80, $80, $B0, $BC

        .byte $00, $FF, $FF, $00, $FF, $FF, $00, $00
        .byte $FF, $FF, $FF, $00, $FF, $FF, $00, $00

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %10000000
        .byte %10000000
        .byte %10000000
        .byte %10000000
        .byte %10000000
        .byte %10000000
        .byte %10000000
        .byte %10000000

        .byte $FF, $FF, $FF, $F8, $F6, $BF, $7F, $FF
        .byte $00, $00, $00, $01, $10, $20, $00, $00

        .byte $FE, $FB, $91, $E3, $64, $F8, $98, $1C
        .byte $00, $1B, $10, $C2, $24, $F8, $90, $04

        .byte $F3, $C6, $CC, $79, $31, $7A, $EC, $CF
        .byte $0C, $3F, $FF, $FE, $4E, $4C, $78, $06

        .byte $53, $E5, $86, $CE, $EE, $7C, $39, $73
        .byte $01, $44, $04, $CA, $E2, $74, $29, $53

        .byte $CF, $F8, $B0, $CD, $1E, $63, $8F, $31
        .byte $BF, $6F, $5F, $CF, $19, $63, $80, $01

        .byte $C0, $C0, $C0, $E7, $7F, $FC, $F0, $B0
        .byte $80, $41, $C1, $E7, $5F, $8D, $D0, $B0

        .byte $80, $C0, $20, $F0, $10, $80, $F0, $80
        .byte $00, $80, $C0, $E0, $F0, $F8, $0C, $C0

        .byte $80, $00, $80, $E0, $00, $00, $00, $00
        .byte $80, $00, $80, $80, $80, $00, $80, $00

        .byte $E0, $E0, $E7, $E6, $C5, $CE, $CD, $CA
        .byte $FF, $F0, $F7, $F6, $E5, $EE, $ED, $EA

        .byte $8D, $9B, $97, $9F, $1E, $3D, $3F, $00
        .byte $CD, $DB, $D7, $DF, $9E, $BD, $BF, $FF

        .byte $01, $00, $FC, $BC, $78, $F9, $79, $F1
        .byte $FF, $02, $FE, $BE, $7C, $FD, $7D, $F5

        .byte $F1, $D2, $A2, $52, $A2, $E4, $E4, $04
        .byte $F9, $DA, $AA, $5A, $B2, $F4, $F4, $F4

        .byte $3F, $7F, $7F, $7F, $FF, $FF, $FF, $FF
        .byte $00, $02, $00, $00, $07, $0F, $1F, $1D

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000001
        .byte %00111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $FF, $FF, $FF, $7D, $79, $F1, $FB, $FF
        .byte $1D, $26, $02, $0F, $1E, $3F, $27, $22

        .byte $FF, $FF, $FF, $7F, $7F, $7F, $FF, $FF
        .byte $37, $3F, $22, $2F, $11, $1F, $1F, $1F

        .byte $00, $03, $0F, $1F, $1F, $1F, $0F, $0F
        .byte $00, $00, $00, $09, $09, $09, $04, $02

        .byte $0F, $1F, $1F, $3F, $3F, $7F, $7F, $FF
        .byte $01, $00, $08, $18, $0C, $20, $10, $01

        .byte $FF, $F7, $EF, $7F, $FF, $FF, $FF, $FF
        .byte $12, $4C, $90, $A1, $21, $40, $40, $40

        .byte $FF, $FF, $F7, $FC, $FF, $FF, $CF, $F7
        .byte $80, $0E, $3F, $47, $00, $00, $F8, $9F

        .byte $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $0B, $00, $80, $00, $80, $C0, $43, $24

        .byte $FF, $FF, $FC, $F9, $FF, $FF, $FF, $F3
        .byte $00, $03, $FF, $BE, $00, $00, $07, $FC

        .byte $FD, $F9, $FB, $EF, $FF, $FF, $FF, $FF
        .byte $06, $0E, $1C, $71, $06, $F8, $A0, $00

        .byte $FF, $FF, $7F, $FF, $FF, $FF, $FF, $FF
        .byte $14, $E2, $F8, $3E, $07, $00, $E0, $7D

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %01110000
        .byte %11111111
        .byte %01011110
        .byte %00000111
        .byte %01110011
        .byte %01111011
        .byte %10111001
        .byte %11111100

        .byte $80, $E0, $F0, $F8, $FC, $FC, $FE, $FE
        .byte $00, $80, $60, $C0, $E0, $F8, $DC, $78

        .byte $FF, $FD, $FF, $FD, $FD, $F9, $F8, $F0
        .byte $0C, $76, $1E, $0E, $FE, $36, $F7, $EF

        .byte $F0, $F0, $F0, $F2, $E7, $EF, $DE, $BE
        .byte $2F, $BF, $FF, $BF, $BC, $F9, $F1, $C3

        .byte $FF, $FF, $FF, $EF, $D7, $F7, $F7, $6E
        .byte $E8, $C0, $E0, $D0, $A8, $28, $48, $D0

        .byte $2E, $9C, $7F, $1E, $5F, $4F, $DF, $BF
        .byte $F0, $60, $80, $E1, $B0, $B0, $31, $60

        .byte $00, $00, $00, $80, $C0, $F8, $FE, $A3
        .byte $00, $00, $00, $00, $00, $00, $00, $FC

        .byte $00, $00, $00, $00, $01, $03, $03, $07
        .byte $00, $00, $00, $00, $00, $01, $03, $03

        .byte $7F, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $8B, $17, $24, $48, $40, $91, $83, $8C

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11110000
        .byte %01100000
        .byte %00000000
        .byte %00000001
        .byte %00001000
        .byte %10000000
        .byte %00001101
        .byte %00011000

        .byte $F8, $FE, $CF, $BF, $FF, $FF, $FF, $FF
        .byte $EF, $01, $30, $4F, $30, $C0, $00, $00

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000111
        .byte %00111110
        .byte %01110000
        .byte %00000000
        .byte %11111110
        .byte %01111000
        .byte %00000111
        .byte %11111100

        .byte $C6, $2D, $DD, $FF, $FF, $FF, $FE, $FE
        .byte $00, $C2, $26, $C6, $26, $02, $00, $00

        .byte $C3, $81, $F9, $FE, $E3, $81, $F9, $FE
        .byte $3C, $7E, $1E, $04, $1C, $7E, $3E, $04

        .byte $0F, $0F, $1F, $1F, $1F, $3F, $3F, $3F
        .byte $07, $07, $0F, $0E, $0F, $1F, $1F, $1F

        .byte $7F, $7F, $7F, $7F, $7F, $7F, $3F, $3F
        .byte $3D, $3F, $3F, $3F, $3F, $3F, $1F, $1D

        .byte $01, $02, $31, $48, $00, $B7, $79, $6F
        .byte $01, $01, $30, $48, $8F, $8F, $37, $13

        .byte $38, $1F, $03, $48, $30, $00, $00, $00
        .byte $07, $00, $00, $48, $30, $00, $00, $00

        .byte $FF, $7C, $FF, $7F, $0F, $F7, $43, $FB
        .byte $C1, $83, $00, $00, $F0, $F8, $FD, $FD

        .byte $03, $0F, $FF, $7D, $33, $E1, $E0, $00
        .byte $FE, $F0, $00, $02, $00, $00, $00, $00

        .byte $EF, $3C, $FF, $9F, $BF, $F6, $EF, $FF
        .byte $F0, $C3, $00, $60, $40, $89, $10, $20

        .byte $EE, $E0, $DF, $FC, $C0, $40, $E0, $40
        .byte $51, $1F, $20, $00, $00, $A0, $40, $A0

        .byte $F8, $04, $FC, $C0, $7F, $FF, $3F, $00
        .byte $00, $F8, $00, $00, $FF, $04, $FF, $FF

        .byte $03, $7C, $80, $00, $00, $00, $00, $00
        .byte $FC, $80, $00, $00, $00, $00, $00, $00

        .byte $00, $00, $00, $00, $00, $00, $03, $05
        .byte $00, $00, $00, $00, $00, $00, $00, $02

        .byte $1F, $3B, $7B, $7F, $FF, $FF, $FF, $7F
        .byte $04, $0C, $1C, $18, $48, $44, $20, $31

        .byte $00, $01, $0F, $1F, $7F, $FF, $FF, $FF
        .byte $00, $00, $00, $00, $10, $69, $91, $02

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000011
        .byte %00000101
        .byte %01000110
        .byte %10010101
        .byte %10000110
        .byte %10101110
        .byte %11101100
        .byte %01010100

        .byte $3F, $F3, $E6, $E5, $E1, $F2, $71, $F8
        .byte $00, $0C, $19, $1A, $5E, $AD, $CE, $87

        .byte $00, $00, $C0, $E0, $F0, $F8, $F8, $F8
        .byte $00, $00, $00, $00, $00, $C0, $00, $00

        .byte $F7, $EF, $CF, $9F, $9F, $BF, $3F, $7F
        .byte $08, $10, $30, $62, $60, $42, $C2, $81

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00100001
        .byte %00000000
        .byte %00100000
        .byte %01100000
        .byte %11010000
        .byte %00110000
        .byte %00011000
        .byte %00010110

        .byte $00, $18, $3C, $7C, $FE, $FE, $FF, $1C
        .byte $00, $18, $3C, $64, $FE, $FE, $C0, $E0

        .byte %11110000
        .byte %01100000
        .byte %00011000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $3F, $3F, $1E, $1E, $1E, $0E, $0E, $06
        .byte $1F, $1E, $0D, $05, $0D, $05, $01, $01

        .byte %00000111
        .byte %00000011
        .byte %00000001
        .byte %00000000
        .byte %00000001
        .byte %00000011
        .byte %00011111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00011111
        .byte %11001001
        .byte %11110000
        .byte %11111000
        .byte %11110000
        .byte %00000011

        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FE
        .byte $C0, $E0, $F8, $F1, $F1, $C1, $13, $FB

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11100011
        .byte %11100011
        .byte %11110001
        .byte %01110010
        .byte %10111100
        .byte %00110000
        .byte %00010000
        .byte %00001000

        .byte $FF, $FF, $FF, $EF, $4F, $4F, $0F, $1F
        .byte $C2, $00, $D8, $B3, $B7, $B7, $FF, $E7

        .byte $01, $0F, $3F, $FF, $FF, $FF, $FF, $FF
        .byte $00, $00, $00, $0F, $78, $F0, $E0, $F3

        .byte %11100000
        .byte %11111000
        .byte %11111100
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00011100
        .byte %00000110
        .byte %10000011

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %11000000
        .byte %11100000
        .byte %11100000
        .byte %11100000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $FE, $7C, $7C, $38, $B8, $F8, $F0, $F0
        .byte $77, $A7, $97, $D7, $47, $47, $2F, $AF

        .byte $70, $71, $71, $B9, $F8, $F8, $F8, $BC
        .byte $BF, $FF, $DE, $5F, $3F, $2F, $6F, $67

        .byte $07, $03, $07, $1F, $7F, $1F, $3F, $7F
        .byte $FC, $FF, $FF, $E3, $98, $FC, $E0, $C0

        .byte $1F, $07, $00, $80, $C1, $61, $13, $03
        .byte $F9, $FF, $FF, $7F, $7F, $9E, $FE, $FD

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00111000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $54, $BA, $FE, $BE, $F6, $7E, $5E, $5A
        .byte $28, $54, $30, $58, $48, $20, $28, $24

        .byte $00, $07, $11, $5B, $BF, $FF, $DB, $DF
        .byte $00, $00, $0F, $2D, $69, $49, $65, $6F

        .byte $DB, $DB, $FB, $DF, $DD, $EE, $74, $22
        .byte $6D, $64, $4C, $29, $6E, $70, $00, $00

        .byte $EE, $39, $BC, $FD, $F9, $BB, $BB, $5F
        .byte $00, $EE, $EF, $8A, $4E, $EC, $FE, $EF

        .byte $7D, $BB, $1B, $BD, $FF, $82, $84, $44
        .byte $E6, $4C, $EE, $E6, $00, $00, $00, $00

        .byte $00, $C0, $30, $E4, $BA, $BA, $BE, $F6
        .byte $00, $00, $E0, $F8, $DC, $4C, $D8, $9C

        .byte $DE, $B2, $BE, $BE, $D6, $FE, $5C, $88
        .byte $BC, $5C, $48, $D0, $FC, $0C, $00, $00

        .byte $7E, $3C, $38, $28, $08, $10, $10, $00
        .byte $08, $00, $00, $00, $00, $00, $00, $00

        .byte %01010100
        .byte %00111000
        .byte %00010000
        .byte %00110000
        .byte %00100000
        .byte %01010000
        .byte %01000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %00010010
        .byte %00001001
        .byte %00000100
        .byte %00000010
        .byte %00000001
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte %01001000
        .byte %01001001
        .byte %10001010
        .byte %11000101
        .byte %01001010
        .byte %10110100
        .byte %01001000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %01010100
        .byte %00111000
        .byte %00010000
        .byte %00110000
        .byte %00100000
        .byte %01010000
        .byte %01000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %00010000
        .byte %00100000
        .byte %01000000
        .byte %10000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte $9C, $9E, $DF, $DF, $CF, $EF, $EF, $FF
        .byte $73, $73, $29, $28, $3C, $14, $14, $06

        .byte $FF, $BD, $FF, $FF, $FB, $FD, $FF, $FF
        .byte $82, $43, $C1, $71, $3C, $0E, $02, $03

        .byte $0A, $02, $00, $82, $C0, $F0, $FC, $FF
        .byte $FD, $FF, $FF, $7D, $3F, $1F, $07, $01

        .byte $FF, $FF, $FF, $FF, $FF, $FD, $FB, $FF
        .byte $00, $00, $00, $00, $00, $03, $07, $0E

        .byte $FF, $9F, $3F, $7F, $7F, $7F, $3F, $3F
        .byte $C7, $7E, $F2, $C6, $FE, $FE, $F4, $E0

        .byte $FF, $FF, $FF, $FF, $DF, $7F, $FF, $FF
        .byte $00, $00, $01, $06, $3C, $F0, $80, $00

        .byte $00, $00, $00, $00, $00, $80, $E0, $F8
        .byte $00, $00, $00, $00, $00, $00, $00, $A0

        .byte $FE, $FF, $E5, $FF, $FF, $FF, $FF, $FF
        .byte $00, $00, $1A, $60, $80, $82, $0C, $18

        .byte $C0, $FC, $E3, $F8, $BC, $F0, $C7, $3F
        .byte $00, $00, $1C, $07, $43, $0F, $38, $C0

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000001
        .byte %10000010
        .byte %10000111
        .byte %00100111
        .byte %00000110
        .byte %00001100
        .byte %00001110

        .byte $00, $00, $C0, $78, $3F, $FF, $FF, $FF
        .byte $00, $00, $00, $80, $C0, $00, $1F, $6C

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11010000
        .byte %11000000
        .byte %10000000
        .byte %00000010
        .byte %00001000
        .byte %00010001
        .byte %00110001
        .byte %00101000

        .byte $FF, $FF, $FF, $FF, $F7, $E5, $E6, $F3
        .byte $C0, $3F, $E0, $80, $1A, $38, $98, $EC

        .byte %11111111
        .byte %11111111
        .byte %11000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %11111111
        .byte %11111111
        .byte %11000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $FF, $FF, $FF, $7F, $EF, $E7, $E7, $DF
        .byte $01, $E0, $19, $84, $12, $59, $99, $24

        .byte $FB, $E3, $03, $07, $07, $0F, $0F, $0F
        .byte $FB, $E3, $03, $07, $07, $0E, $0F, $0E

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000001
        .byte %00000011
        .byte %00000111
        .byte %00000101
        .byte %00001010
        .byte %00111100
        .byte %11010000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000001
        .byte %00000011
        .byte %00000111
        .byte %10011111
        .byte %10111111
        .byte %10111111
        .byte %11011100
        .byte %11111111

        .byte %11110000
        .byte %11110000
        .byte %11110000
        .byte %11110000
        .byte %11110000
        .byte %11111000
        .byte %11111000
        .byte %11111000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte $F8, $F8, $F8, $F8, $F0, $F0, $F0, $F0
        .byte $00, $00, $00, $80, $80, $80, $80, $C0

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111011
        .byte %11111100
        .byte %11111100
        .byte %11111110
        .byte %11111111
        .byte %11111111

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte $FC, $FF, $FF, $C0, $FF, $FF, $FF, $FF
        .byte $FC, $FF, $C0, $3F, $00, $00, $9F, $C0

        .byte $F8, $F8, $FE, $FF, $FF, $FF, $FE, $FC
        .byte $F8, $F8, $9E, $C0, $E0, $F0, $FE, $FC

        .byte $FF, $FF, $FF, $FF, $FF, $FF, $EF, $E7
        .byte $FF, $FB, $DE, $D8, $30, $30, $5C, $FB

        .byte $C6, $87, $23, $43, $DF, $FF, $FF, $3F
        .byte $BB, $7F, $FD, $BC, $33, $03, $E7, $FB

        .byte $F0, $E0, $E0, $E0, $E0, $C0, $C0, $C0
        .byte $C0, $80, $00, $80, $00, $00, $80, $00

        .byte $C0, $C0, $C0, $C0, $80, $E0, $FC, $FF
        .byte $80, $80, $80, $80, $00, $00, $00, $00

        .byte $00, $F0, $F8, $0F, $FF, $FE, $FC, $F0
        .byte $00, $F0, $00, $F0, $01, $02, $C4, $00

        .byte $00, $00, $38, $F0, $C0, $80, $00, $00
        .byte $00, $00, $20, $00, $00, $00, $00, $00

        .byte $00, $E0, $FF, $F0, $00, $00, $3C, $F8
        .byte $00, $E0, $F0, $00, $00, $00, $30, $00

        .byte %11110000
        .byte %11000000
        .byte %10000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111000
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte $FC, $FF, $FF, $FF, $FC, $F0, $F0, $FF
        .byte $FC, $FF, $7F, $C0, $FC, $F0, $B0, $C0

        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FC
        .byte $E0, $E0, $F8, $FF, $FF, $FF, $FE, $FC

        .byte $FF, $FF, $FF, $FE, $EF, $CB, $CD, $F7
        .byte $00, $8F, $70, $C1, $94, $30, $31, $48

        .byte %11111111
        .byte %01111111
        .byte %01111111
        .byte %00111111
        .byte %00111111
        .byte %00011111
        .byte %00011111
        .byte %00011111
        .byte %11111111
        .byte %01111111
        .byte %01111111
        .byte %00111111
        .byte %00111111
        .byte %00011111
        .byte %00011111
        .byte %00011111

        .byte $FF, $FE, $FC, $FC, $DE, $CF, $C6, $9C
        .byte $0F, $F2, $0C, $00, $30, $B8, $38, $7C

        .byte %11110000
        .byte %11100000
        .byte %11000000
        .byte %11000000
        .byte %10000000
        .byte %10000000
        .byte %10000000
        .byte %00000000
        .byte %11110000
        .byte %11100000
        .byte %11000000
        .byte %11000000
        .byte %10000000
        .byte %10000000
        .byte %10000000
        .byte %00000000

        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111

        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %11111111
