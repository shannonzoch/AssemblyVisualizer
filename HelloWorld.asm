; -----------------------------------------------------------------------------
; A classic "Hello, World!" program in 32-bit x86 assembly for Linux.
;
; To compile and run this program:
; 1. Assemble with NASM: nasm -f elf32 -o hello.o hello_world.asm
; 2. Link with ld:       ld -m elf_i386 -o hello hello.o
; 3. Execute:            ./hello
; -----------------------------------------------------------------------------

section .data
    ; This section holds the data that our program will use.
    ; 'db' stands for 'define byte'.
    msg db 'Hello, World!', 0xa  ; The string to print. 0xa is the ASCII code for a newline character.
    len equ $ - msg             ; The length of the message. '$' is the current address,
                                ; so this calculates the length automatically.

section .text
    ; This section contains the actual code to be executed.
    global _start               ; The '_start' label must be declared global to be seen by the linker.

_start:
    ; This is the entry point of our program.

    ; --- Print the message to the screen ---
    ; To do this, we need to make a system call. In Linux, system calls
    ; are invoked using the 'int 0x80' instruction. We must first load
    ; the required values into the general-purpose registers.

    ; syscall number for 'sys_write' is 4
    mov eax, 4

    ; file descriptor for stdout (standard output) is 1
    mov ebx, 1

    ; pointer to the message to write
    mov ecx, msg

    ; length of the message
    mov edx, len

    ; Make the system call to write the message
    int 0x80

    ; --- Exit the program ---
    ; Now we make another system call to exit the program cleanly.

    ; syscall number for 'sys_exit' is 1
    mov eax, 1

    ; exit code 0 (which means success)
    mov ebx, 0

    ; Make the system call to exit
    int 0x80
