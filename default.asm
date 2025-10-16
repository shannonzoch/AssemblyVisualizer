section .data
    msg db 'Function call successful!', 0x0a
    len equ $ - msg

section .text
    global _start

; Function to add two numbers from the stack
; Expects: [EBP+8] = first argument, [EBP+12] = second argument
; Returns: Result in EAX
add_two:
    PUSH EBP           ; Save old base pointer
    MOV EBP, ESP       ; Set up new stack frame for this function
    
    MOV EAX, [EBP+8]   ; Get first parameter (pushed last)
    ADD EAX, [EBP+12]  ; Add second parameter (pushed first)
    
    MOV ESP, EBP       ; Tear down stack frame
    POP EBP            ; Restore old base pointer
    RET                ; Return to caller

_start:
    ; Set up the stack frame for _start, not strictly necessary but good practice
    PUSH EBP
    MOV EBP, ESP

    ; -- Part 1: Call a function with stack parameters --
    PUSH 35            ; Push second argument for add_two
    PUSH 21            ; Push first argument for add_two
    CALL add_two       ; Call the function. Result will be in EAX (56)
    ADD ESP, 8         ; Clean up the stack (2 args * 4 bytes)

    ; -- Part 2: Use the result and print a message --
    ; EAX now holds 56. We'll just print the success message.
    MOV EAX, 4         ; syscall: sys_write
    MOV EBX, 1         ; stdout
    MOV ECX, msg       ; message address
    MOV EDX, len       ; message length
    INT 0x80

    ; -- Part 3: Exit the program cleanly --
    MOV EAX, 1         ; syscall: sys_exit
    XOR EBX, EBX       ; exit code 0
    INT 0x80
