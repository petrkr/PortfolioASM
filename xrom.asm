name        XROM

            assume cs:cseg

LF          equ     0aH
CR          equ     0dH

BIOX        equ     0aa55H
DOSX        equ     055aaH
BIDO        equ     05555H

cseg        segment

            org 0H

xrom_main   label   near
bixt_type   dw      BIOX
bixt_size   db      0 ; num 512 byte blocks in ROM

            org 3H
bixt_gbio   label   byte
bixt_gdos   label   byte
            jmp     genx_vect


            org 40H
bixt_user   label   byte
            db      'Test ROM'

            org 50H
bixt_preb:  jmp     preb_vect ; Pre-bios jmo vector

            org 55H
bixt_bext:  jmp     bext_vect ; Bios-ext jmp vector

            org 5aH
bixt_pdos:  jmp     pdos_vect ; Pre-dos jmp vector

            org 5fH
bixt_dext:  jmp     dext_vect ; Dos-ext jmp vector

            org 64H
bixt_ados:  jmp     ados_vect ; Post-dos jmp vector

            org 69H
bixt_pwdn:  jmp     pwdn_vect ; Power down jmp vector

            org 6eH
bixt_pwup:  jmp     pwup_vect ; Power up jmp vector

xrom_proc   proc    FAR

            ; Determine extension type

genx_vect   label   near
            push    bp

            cmp     cs:[0],BIOX                ; BIOS extension?
            jne     not_genb                   ; No

            mov     bp,offset   gbio_text
            jmp     short       xrom_disp

not_genb:
            cmp     cs:[0],DOSX                 ; DOS Extension?
            jne     not_gend                    ; No

            mov     bp,offset   gdos_text
            jmp     short       xrom_disp

not_gend:
            mov     bp,offset   invl_text       ; Invalid text
            jmp     short       xrom_disp


preb_vect   label   near
            jmp     dword ptr cs:preb_retn ; Pre-BIOS extension

preb_retn   dw      0
            dw      0fffeH

bext_vect   label   near
            push    bp
            mov     bp,offset   bext_text
            jmp     short xrom_disp

pdos_vect   label   near
            push    bp
            mov     bp,offset   pdos_text
            jmp     short xrom_disp

dext_vect   label   near
            push    bp
            mov     bp,offset   dext_text
            jmp     short xrom_disp

ados_vect   label   near
            push    bp
            mov     bp,offset   ados_text
            jmp     short xrom_disp


pwdn_vect   label   near
            push    bp
            mov     bp,offset   pwdn_text
            jmp     short xrom_disp


pwup_vect   label   near
            push    bp
            mov     bp,offset   pwup_text
            jmp     short xrom_disp


xrom_disp   label   near
            push    ax
            push    bx
            push    cx
            push    dx
            push    es

            call    disp_text

            mov     ax,2400H
            int     61H

            or      dl,dl

            jnz     not_norm        ; No, so skip

            mov     bp,offset   norm_text
            jmp     short stat_disp

not_norm:
            dec     dl
            jnz     not_drva

            mov     bp,offset   drva_text   ; Get Drive A text
            jmp     short stat_disp

not_drva:
            dec     dl
            jnz     not_drvb

            mov     bp,offset   drvb_text   ; Get Drive B text
            jmp     short stat_disp

not_drvb:
            dec     dl
            jnz     not_xrom

            mov     bp,offset   drvb_text   ; Get Drive A text
            jmp     short stat_disp

not_xrom:
            mov     bp,offset   invl_text   ; Get Drive A text

stat_disp:
            call    disp_text

            mov     bp,offset   crlf_text
            call    disp_text

            pop     es
            pop     dx
            pop     cx
            pop     bx
            pop     ax
            pop     bp

            ret

xrom_proc   endp

disp_text   proc    near
            xor     bh, bh
            mov     ah, 3
            int     10H

            push    cs
            pop     es

            xor     ch, ch
            mov     cl, es:[bp]
            inc     bp

            mov     ax,1301H
            int     10H


            ret
disp_text   endp

gbio_text   db      gdos_text-$-1
            db      'Spec BIOS Extension - '

gdos_text   db      bext_text-$-1
            db      'Spec DOS Extension - '

bext_text   db      pdos_text-$-1
            db      'Com BIOS Extension - '

pdos_text   db      dext_text-$-1
            db      'Pre-DOS Extension - '

dext_text   db      ados_text-$-1
            db      'Com DOS Extension - '

ados_text   db      pwdn_text-$-1
            db      'Post-DOS Extension - '

pwdn_text   db      pwup_text-$-1
            db      'Power Down Extension - '

pwup_text   db      norm_text-$-1
            db      'Power Up Extension - '

norm_text   db      drva_text-$-1
            db      'Normal ROM'

drva_text   db      drvb_text-$-1
            db      'CCM Drive A'

drvb_text   db      xrom_text-$-1
            db      'CCM Drive B'

xrom_text   db      invl_text-$-1
            db      'Extn ROM'

invl_text   db      crlf_text-$-1
            db      'Invalid'

crlf_text   db      2,CR,LF

cseg        ends
            end     xrom_main
