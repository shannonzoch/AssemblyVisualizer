; ---
; add_and_print.asm (32-bit x86)
; A program to add 5 + 3, convert the result to a character,
; and print it to standard output.
; ---

section .data
    result_char db 0  ; One byte to store the resulting character
    newline     db 10 ; The newline character (ASCII 10)

section .text
    global _start

_start:
    ; 1. Perform the calculation
    mov eax, 5  ; Move the number 5 into eax
    mov ebx, 3  ; Move the number 3 into ebx
    add eax, ebx  ; Add ebx to eax. eax now holds the number 8

    ; 2. Convert the numeric result to an ASCII character
    ;    ASCII '0' is 48. '8' is 48 + 8 = 56.
    add eax, '0'  ; eax now holds 56, which is the character '8'

    ; 3. Store the character in our data section
    ;    We only want the 8-bit character, so we use 'al'
    mov [result_char], al

    ; 4. Print the result character (syscall 4: write)
    mov eax, 4          ; System call 4: write
    mov ebx, 1          ; File descriptor 1: stdout
    mov ecx, result_char ; Address of the character to write
    mov edx, 1          ; Length: 1 byte
    int 0x80            ; Make the system call

    ; 5. Print the newline (syscall 4: write)
    mov eax, 4          ; System call 4: write
    mov ebx, 1          ; File descriptor 1: stdout
    mov ecx, newline    ; Address of the newline character
    mov edx, 1          ; Length: 1 byte
    int 0x80            ; Make the system call

    ; 6. Exit the program (syscall 1: exit)
    mov eax, 1          ; System call 1: exit
    xor ebx, ebx        ; Exit code 0
    int 0x80            ; Make the system call
