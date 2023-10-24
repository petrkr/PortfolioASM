org 100h

jmp start       ; jump over data declaration

msg:    db      "PID: ",  24h
nopid:  db      "No PID", 24h
crlf:   db      0Dh, 0Ah, 24h

start:  mov     dx, msg  ; load offset of msg into dx.
        mov     ah, 09h  ; print function is 9.
        int     21h      ; do it!

        mov     ah, 1Ah
        int     61h

        or      al,al
        jz      no_pid

		mov		dl, ah
		mov		ah, 02h
		int		21h

        jmp     show_text

no_pid: mov     dx, nopid  ; load offset of msg into dx.
        mov     ah, 09h  ; print function is 9.
        int     21h      ; do it!

show_text:
		mov     dx, crlf  ; load offset of msg into dx.
        mov     ah, 09h  ; print function is 9.
        int     21h

exit:
    ret

ret ; return to operating system.
