org 100h

jmp start       ; jump over data declaration

msg:    db      "Hello, World!", 24h
crlf:   db      0Dh, 0Ah, 24h

start:  mov     dx, msg  ; load offset of msg into dx.
        mov     ah, 09h  ; print function is 9.
        int     21h      ; do it!
        
		mov		dl, 41h
		mov		ah, 02h
		int		21h

		mov     dx, crlf  ; load offset of msg into dx.
        mov     ah, 09h  ; print function is 9.
        int     21h

        mov     ah, 0 
        int     16h      ; wait for any key....

exit:
    ret

ret ; return to operating system.
