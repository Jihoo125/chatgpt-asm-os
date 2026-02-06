BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    call clear_screen

    mov si, banner
    call print_string

main_loop:
    mov si, prompt
    call print_string
    call read_line
    call handle_command
    mov si, newline
    call print_string
    jmp main_loop

print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp print_string
.done:
    ret

clear_screen:
    mov ax, 0x0600
    mov bh, 0x1F
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0000
    int 0x10
    ret

read_line:
    mov di, line_buffer
.read_char:
    xor ah, ah
    int 0x16
    cmp al, 0x0D
    je .done
    cmp al, 0x08
    je .backspace
    cmp di, line_buffer_end - 1
    jae .read_char
    stosb
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp .read_char
.backspace:
    cmp di, line_buffer
    jbe .read_char
    dec di
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .read_char
.done:
    mov al, 0
    stosb
    ret

handle_command:
    mov si, line_buffer
    mov di, cmd_help
    call string_equals
    cmp al, 1
    je .help

    mov si, line_buffer
    mov di, cmd_clear
    call string_equals
    cmp al, 1
    je .clear

    mov si, line_buffer
    mov di, cmd_ver
    call string_equals
    cmp al, 1
    je .ver

    mov si, line_buffer
    mov di, cmd_fdisk
    call string_equals
    cmp al, 1
    je .fdisk

    mov si, line_buffer
    mov di, cmd_edit
    call string_equals
    cmp al, 1
    je .edit

    mov si, unknown_text
    call print_string
    ret

.help:
    mov si, help_text
    call print_string
    ret

.clear:
    call clear_screen
    mov si, banner
    call print_string
    ret

.ver:
    mov si, version_text
    call print_string
    ret

.fdisk:
    mov si, fdisk_text
    call print_string
    ret

.edit:
    mov si, edit_text
    call print_string
    ret

string_equals:
    push si
    push di
.compare:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
    inc si
    inc di
    jmp .compare
.not_equal:
    pop di
    pop si
    mov al, 0
    ret
.equal:
    pop di
    pop si
    mov al, 1
    ret

banner db "ChatGPT Codex ASM OS Ver0.1b4 Build 5 (C)2026 OpenAI", 0x0D, 0x0A, 0
version_text db "Ver0.1b4 Build 5", 0x0D, 0x0A, 0
help_text db "help clear ver fdisk edit", 0x0D, 0x0A, 0
fdisk_text db "FDISK: N/A", 0x0D, 0x0A, 0
edit_text db "EDIT: N/A", 0x0D, 0x0A, 0
unknown_text db "?", 0x0D, 0x0A, 0
cmd_help db "help", 0
cmd_clear db "clear", 0
cmd_ver db "ver", 0
cmd_fdisk db "fdisk", 0
cmd_edit db "edit", 0
prompt db "> ", 0
newline db 0x0D, 0x0A, 0
line_buffer times 64 db 0
line_buffer_end:

TIMES 510-($-$$) db 0
DW 0xAA55
