name        ADDRROM

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
            db      'PID ROM'

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
            ; Work with memory segment starting at 0xc0000
            push    ds
            mov     ds, 0c000h

            ; Data in EPROM starts here (0x1000) and they are accessible at 0xC1000
            mov     bx, 1000h   ; Set base (starting) address
            mov		dl, [bx]    ; Read content of segmented address 0xC000*16 + BX
	    	mov		ah, 02h     ; DOS Service to write char
    		int		21h         ; DOS Interrupt

            inc     bx          ; Increment address
            mov		dl, [bx]    ; Read content of segmented address 0xC000*16 + BX
	    	mov		ah, 02h     ; DOS Service to write char
    		int		21h         ; DOS Interrupt

            inc     bx
            mov		dl, [bx]
	    	mov		ah, 02h
    		int		21h

            inc     bx
            mov		dl, [bx]
	    	mov		ah, 02h
    		int		21h

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


entry_text  db      rtc_text-$-1
            db      'Addressing Example ROM Code', CR, LF

rtc_text    db      end_text-$-1
            db      'RTC: '

end_text    db      crlf_text-$-1
            db      'Return to system', CR, LF

crlf_text   db      2,CR,LF

cseg        ends
            end     xrom_main
