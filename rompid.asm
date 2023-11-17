name        XROM

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

            mov     bp,offset   hello_text   ; Hello text
            call    disp_text

            mov     bp,offset   pid_text   ; Hello text
            call    disp_text

            call    get_pid

            mov     bp,offset   crlf_text
            call    disp_text

            mov     bp,offset   end_text
            call    disp_text

            pop     es
            pop     dx
            pop     cx
            pop     bx
            pop     ax
            pop     bp

            ret

xrom_proc   endp


get_pid     proc    near
            mov     ah, 1Ah
            int     61h

            or      al, al
            jz      no_pid

		    mov		dl, ah
	    	mov		ah, 02h
    		int		21h

            jmp     pid_rtn

no_pid:     mov     bp,offset   nopid_text
            call    disp_text

pid_rtn:    ret
get_pid     endp

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


hello_text  db      pid_text-$-1
            db      'Hello from ROM Code', CR, LF

pid_text    db      end_text-$-1
            db      'PID: '

end_text    db      nopid_text-$-1
            db      'End ROM code, Return to system', CR, LF

nopid_text  db      crlf_text-$-1
            db      'No PID attached', CR, LF

crlf_text   db      2,CR,LF

cseg        ends
            end     xrom_main
