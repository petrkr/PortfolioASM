; Address decoder test program

name        ADDRDEC

            assume cs:cseg

LF          equ     0aH
CR          equ     0dH

DOSX        equ     055aaH

cseg        segment

            org 0H

xrom_main   label   near
bixt_type   dw      DOSX
bixt_size   db      0 ; num 512 byte blocks in ROM

            org 3H
bixt_gdos   label   byte
            jmp     genx_vect


            org 40H
bixt_user   label   byte
            db      'ADDR DEC ROM'

xrom_proc   proc    FAR

genx_vect   label   near
            push    bp
            push    ax
            push    bx
            push    cx
            push    dx
            push    es

            mov     bp,offset   entry_text   ; Entry text
            call    disp_text

            call    get_mem
            
            mov     bp,offset   crlf_text    ; CR LF
            call    disp_text

            mov     bp,offset   end_text     ; End text
            call    disp_text

            pop     es
            pop     dx
            pop     cx
            pop     bx
            pop     ax
            pop     bp

            ret
xrom_proc   endp



get_mem     proc    near
            ; Work with memory segment starting at 0x9f000
            push    ds
            mov     ds, 0af00h

            mov     bx, 20h      ; Set base (starting) address
            xor     cx, cx       ; clear counter

loop1:      nop
            mov		dl, [bx]    ; Read content of segmented address ds*16 + BX
	    	mov		ah, 02h     ; DOS Service to write char
    		int		21h         ; DOS Interrupt

            ;inc     bx          ; Increment address

            inc     cx          ; Increment counter
            cmp     cx, 500
            jle     loop1            

            pop ds
            ret
get_mem     endp


disp_text   proc    near
            xor     bh, bh
            mov     ah, 3
            int     10H

            push    cs
            pop     es

            xor     ch, ch
            mov     cl, es:[bp]
            inc     bp

            mov     ax, 1301H
            int     10H

            ret
disp_text   endp


entry_text  db      end_text-$-1
            db      'Address Decoder Example ROM Code', CR, LF

end_text    db      crlf_text-$-1
            db      'Return to system', CR, LF

crlf_text   db      2,CR,LF

cseg        ends
            end     xrom_main
