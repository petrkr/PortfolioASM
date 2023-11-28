name        XROM

            assume cs:cseg
            ASSUME DS:DATA_SEG

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

            call    get_rtc

            mov     bp,offset   crlf_text    ; CR LF
            call    disp_text

            call    get_dosclk
            
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


get_dosclk  proc    near
            mov     bp,offset   dost_text    ; DOS Time:
            call    disp_text

	    	mov		ah, 2ch     ; Get system time
    		int		21h         ; DOS Interrupt
                                ; Retrun:
                                ; ch - hours
                                ; cl - minutes
                                ; dh - seconds
                                ; dl - hunreths of seconds

            mov al, ch          ; Take hours
            mov ah, 0
            call    disp_dosclk

            mov  dl, 3Ah        ; Display :
            int  21h

            mov al, cl          ; Take mins
            mov ah, 0
            call    disp_dosclk

            mov  dl, 3Ah        ; Display :
            int  21h

            mov al, dh          ; Take secs
            mov ah, 0
            call    disp_dosclk

            ret
get_dosclk  endp


disp_dosclk proc    near
            push dx
            mov bl, 10          ; Divide by 10
            div bl              ; Divide, results to ax

            add  ax, 3030h      ; Convert together
            push ax

            mov  dl, al         ; Display tens
            mov  ah, 02h
            int  21h

            pop  dx
            mov  dl, dh         ; Display number
            int  21h

            pop dx
            ret
disp_dosclk  endp


get_rtc     proc    near
            ; Work with memory segment starting at 0xc0000
            push    ds
            mov     ds, 0c000h

            ; RTC starts here
            mov     bx, 1FFFh
		    mov		dl, [bx] ; copy BCD code

            mov  al, 00h
            mov  ah, 02h
            int  21h

            pop ds
            ret
get_rtc     endp

; Convert BCD to Binary AH input, AL Output
bcd_conv    proc    near
            push bx
            inc     bx

            push cx

            mov bh, ah       ; Copy BCD to BH
            and bh, 0Fh      ; Mask low byte
            and ah, 0F0h     ; Mask high byte
            ;ror ah, 4        ; Rotate

            mov al, AH       ; Move high byte to low
            and ax, 00FFh    ; Maskp
            mov cl, 10       ; Multplier 10
            mul cl           ; Multiply
            add al, bh       ; Substitute results to AL

            pop cx
            pop bx
            ret
bcd_conv    endp


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
            db      'RTC ROM Code', CR, LF

rtc_text    db      dost_text-$-1
            db      'RTC: '

dost_text   db      end_text-$-1
            db      'DOS TIME: '

end_text    db      crlf_text-$-1
            db      'Return to system', CR, LF

crlf_text   db      2,CR,LF

cseg        ends
            end     xrom_main
