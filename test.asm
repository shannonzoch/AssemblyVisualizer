; -----------------------------------------------------------------------------
; A complete x86 32-bit NASM assembly program for Linux.
;
; This program will:
; 1. Prompt the user to enter 5 integer numbers.
; 2. Store these numbers in a 5-element array.
; 3. Print the entire contents of the array to the console.
; 4. Enter a loop that allows the user to select an array element by its
;    index (1-5) and prints the corresponding value.
; 5. The user can type '0' to exit the program.
;
; To assemble and link this program on a 32-bit Linux system:
; nasm -f elf32 -o array_program_x86.o array_program_x86.asm
; ld -m elf_i386 -o array_program_x86 array_program_x86.o
; ./array_program_x86
; -----------------------------------------------------------------------------

section .data
    ; --- String constants for prompts and messages ---
    prompt_enter_nums   db "Please enter 5 numbers, pressing Enter after each:", 0x0A, 0
    prompt_array_is     db 0x0A, "The array contains the following values:", 0x0A, 0
    prompt_select_idx   db 0x0A, "Enter an index (1-5) to view an element (0 to exit): ", 0
    msg_element_is      db "The element at index "
    msg_is              db " is: "
    msg_invalid_idx     db "Invalid index. Please try again.", 0x0A, 0
    space               db " "
    newline             db 0x0A

section .bss
    ; --- Buffers for runtime data ---
    input_buffer resb 16          ; Buffer to read user input as a string
    output_buffer resb 16         ; Buffer to hold a number converted to a string for printing
    num_array resd 5              ; Reserve space for 5 doublewords (32-bit numbers)

section .text
    global _start

_start:
    ; --- Part 1: Populate the array with user input ---
    mov edi, prompt_enter_nums
    call _print_string

    mov ecx, 5                      ; Loop counter for 5 numbers
    mov esi, num_array              ; esi will be our pointer to the current array element
.populate_loop:
    call _read_integer              ; Reads a number from stdin, returns in eax
    mov [esi], eax                  ; Store the number in the current array position
    add esi, 4                      ; Move pointer to the next doubleword (4 bytes)
    loop .populate_loop

    ; --- Part 2: Print the entire array ---
    mov edi, prompt_array_is
    call _print_string

    mov ecx, 5                      ; Loop counter
    mov esi, num_array              ; Reset pointer to the start of the array
.print_loop:
    mov edi, [esi]                  ; Load the number from the array into edi
    call _print_integer             ; Print the integer
    call _print_space               ; Print a space for separation
    add esi, 4                      ; Move to the next element
    loop .print_loop
    call _print_newline

    ; --- Part 3: Interactive element selection ---
.selection_loop:
    mov edi, prompt_select_idx
    call _print_string

    call _read_integer              ; Read the user's chosen index into eax
    
    push eax                        ; Save the original index for printing later
    mov edi, eax                    ; Move the index to edi for checking

    ; Check if the user wants to exit
    cmp edi, 0
    je _exit                        ; If index is 0, jump to exit

    ; Check if the index is valid (1 <= index <= 5)
    cmp edi, 1
    jl .invalid_index               ; If index < 1, it's invalid
    cmp edi, 5
    jg .invalid_index               ; If index > 5, it's invalid

    ; If we reach here, the index is valid.
    dec edi                         ; Convert 1-based index to 0-based for array access
    mov eax, edi                    ; Move index into eax for multiplication
    mov ebx, 4                      ; Size of a doubleword
    mul ebx                         ; eax = index * 4 (calculate offset in bytes)
    mov ebx, num_array              ; Get base address of the array
    add ebx, eax                    ; ebx = base_address + offset

    ; Print the result message: "The element at index X is: Y"
    mov edi, msg_element_is
    call _print_string
    
    pop edi                         ; Restore the original 1-based index into edi
    push edi                        ; Push it back on the stack in case we need it
    call _print_integer             ; Print the index number

    mov edi, msg_is
    call _print_string

    mov edi, [ebx]                  ; Load the value from the array for printing
    call _print_integer             ; Print the value
    call _print_newline
    
    pop eax                         ; Clean up the stack
    jmp .selection_loop             ; Loop back to ask for another index

.invalid_index:
    pop eax                         ; Pop the invalid index off the stack before looping
    mov edi, msg_invalid_idx
    call _print_string
    jmp .selection_loop             ; Loop back

_exit:
    mov eax, 1                      ; exit syscall
    xor ebx, ebx                    ; Exit code 0 (success)
    int 0x80                        ; Kernel interrupt

; -----------------------------------------------------------------------------
; _print_string: Prints a null-terminated string to stdout.
; IN: edi = address of the string
; -----------------------------------------------------------------------------
_print_string:
    push edi                        ; Save string address
    mov esi, edi                    ; Use esi to find the length
    xor edx, edx                    ; edx will hold the length
.count_loop:
    cmp byte [esi], 0
    je .do_print
    inc edx
    inc esi
    jmp .count_loop
.do_print:
    mov eax, 4                      ; write syscall
    mov ebx, 1                      ; stdout
    pop ecx                         ; string address into ecx
    int 0x80
    ret

; -----------------------------------------------------------------------------
; _read_integer: Reads a string from stdin and converts it to an integer.
; OUT: eax = the converted integer
; -----------------------------------------------------------------------------
_read_integer:
    ; Read from stdin using the read syscall
    mov eax, 3                      ; read syscall
    mov ebx, 0                      ; stdin
    mov ecx, input_buffer           ; Buffer to store input
    mov edx, 16                     ; Max bytes to read
    int 0x80

    ; Convert ASCII string to integer (atoi)
    mov esi, input_buffer
    xor eax, eax                    ; Clear eax (our result)
.atoi_loop:
    movzx ecx, byte [esi]
    inc esi
    cmp ecx, '0'
    jb .atoi_done
    cmp ecx, '9'
    ja .atoi_done

    sub ecx, '0'                    ; Convert ASCII digit to integer value
    imul eax, 10
    add eax, ecx
    jmp .atoi_loop
.atoi_done:
    ret

; -----------------------------------------------------------------------------
; _print_integer: Converts an integer to a string and prints it to stdout.
; IN: edi = the integer to print
; -----------------------------------------------------------------------------
_print_integer:
    mov eax, edi                    ; Move number to eax for division
    mov esi, output_buffer + 15     ; Point to the end of the buffer
    mov byte [esi], 0               ; Null terminator
    dec esi
    mov ebx, 10                     ; Divisor
.itoa_loop:
    xor edx, edx                    ; Clear edx for division
    div ebx                         ; eax = eax / 10, edx = remainder
    add edx, '0'                    ; Convert remainder to ASCII digit
    mov [esi], dl                   ; Store digit in buffer
    dec esi                         ; Move buffer pointer left
    test eax, eax                   ; Is the quotient zero?
    jnz .itoa_loop                  ; If not, repeat
.itoa_print:
    inc esi                         ; Point to the first digit of the number
    mov edi, esi
    call _print_string
    ret

; -----------------------------------------------------------------------------
; Utility print functions
; -----------------------------------------------------------------------------
_print_space:
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    ret

_print_newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
