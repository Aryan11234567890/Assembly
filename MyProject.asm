section .data
    prompt1 db "Enter first number: ", 0
    prompt2 db "Enter second number: ", 0
    promptOp db "Enter operation (+, -, *, /): ", 0
    resultMsg db "The result is: ", 0
    errMsg db "Error: Division by zero", 10, 0
    newline db 10
    ten dq 10.0

section .bss
    num1 resq 1
    num2 resq 1
    operation resb 2
    input_buffer resb 20
    output_buffer resb 50

section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt1
    mov rdx, 20
    syscall

    call read_number
    movsd [num1], xmm0

    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, 20
    syscall

    call read_number
    movsd [num2], xmm0

    mov rax, 1
    mov rdi, 1
    mov rsi, promptOp
    mov rdx, 30
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, operation
    mov rdx, 2
    syscall

    movzx rax, byte [operation]
    cmp al, '+'
    je do_addition
    cmp al, '-'
    je do_subtraction
    cmp al, '*'
    je do_multiplication
    cmp al, '/'
    je do_division
    jmp exit_program

do_addition:
    movsd xmm0, [num1]
    addsd xmm0, [num2]
    jmp output_result

do_subtraction:
    movsd xmm0, [num1]
    subsd xmm0, [num2]
    jmp output_result

do_multiplication:
    movsd xmm0, [num1]
    mulsd xmm0, [num2]
    jmp output_result

do_division:
    movsd xmm1, [num2]
    xorpd xmm2, xmm2
    ucomisd xmm1, xmm2
    je division_error
    movsd xmm0, [num1]
    divsd xmm0, xmm1
    jmp output_result

division_error:
    mov rax, 1
    mov rdi, 1
    mov rsi, errMsg
    mov rdx, 26
    syscall
    jmp exit_program

output_result:
    mov rax, 1
    mov rdi, 1
    mov rsi, resultMsg
    mov rdx, 15
    syscall

    call float_to_string
    mov rax, 1
    mov rdi, 1
    mov rsi, output_buffer
    mov rdx, 50
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

exit_program:
    mov rax, 60
    xor rdi, rdi
    syscall

read_number:
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 20
    syscall

    call string_to_float
    ret

string_to_float:
    pxor xmm0, xmm0
    pxor xmm1, xmm1
    mov rcx, 10
    cvtsi2sd xmm2, rcx
    mov r9, input_buffer
    xor r8, r8
    xor rax, rax

.loop:
    movzx rax, byte [r9]
    cmp al, 0
    je .done
    cmp al, '.'
    je .set_fraction
    cmp al, 10
    je .done
    sub al, '0'
    js .done
    cmp al, 9
    ja .done

    cvtsi2sd xmm3, rax

    test r8, r8
    jnz .handle_fraction

    mulsd xmm0, xmm2
    addsd xmm0, xmm3
    jmp .next

.handle_fraction:
    mulsd xmm1, xmm2
    divsd xmm3, xmm1
    addsd xmm0, xmm3

.next:
    inc r9
    jmp .loop

.set_fraction:
    mov r8, 1
    inc r9
    jmp .loop

.done:
    ret

float_to_string:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    mov rdi, output_buffer
    mov rcx, 50
    mov al, 0
    rep stosb

    mov rdi, output_buffer

    pxor xmm1, xmm1
    comisd xmm0, xmm1
    jae .positive

    mov byte [rdi], '-'
    inc rdi
    subsd xmm0, xmm1

.positive:
    cvttsd2si rax, xmm0
    cvtsi2sd xmm1, rax
    subsd xmm0, xmm1

    mov rbx, 10
    xor rcx, rcx
    test rax, rax
    jnz .int_to_string
    mov byte [rdi], '0'
    inc rdi
    jmp .fraction

.int_to_string:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rsp
    mov [rsp], dl
    inc rcx
    test rax, rax
    jnz .int_to_string

.write_int:
    mov al, [rsp]
    inc rsp
    mov [rdi], al
    inc rdi
    loop .write_int

.fraction:
    mov byte [rdi], '.'
    inc rdi

    mov rcx, 5

.fraction_loop:
    mulsd xmm0, [ten]
    cvttsd2si rax, xmm0
    add al, '0'
    mov [rdi], al
    inc rdi
    cvtsi2sd xmm1, rax
    subsd xmm0, xmm1

    comisd xmm0, xmm1
    ucomisd xmm0, xmm1
    jae .fraction_loop

    mov byte [rdi], 0

    mov rsp, rbp
    pop rbp
    ret































; section .data
;     prompt1 db "Enter first number: ", 0
;     prompt2 db "Enter second number: ", 0
;     promptOp db "Enter operation (+, -, *, /, %, ^, sqrt): ", 0
;     resultMsg db "The result is: ", 0
;     errMsg db "Error: Division by zero", 0
;     newline db 0xA
;     buffer db 0

; section .bss
;     num1 resb 10
;     num2 resb 10
;     operation resb 5
;     result resb 10

; section .text
;     global _start

; _start:
;     mov eax, 4
;     mov ebx, 1
;     mov ecx, prompt1
;     mov edx, 20
;     int 0x80

;     mov eax, 3
;     mov ebx, 0
;     mov ecx, num1
;     mov edx, 10
;     int 0x80

;     mov ecx, num1
;     call ascii_to_int
;     mov [num1], eax

;     mov eax, 4
;     mov ebx, 1
;     mov ecx, promptOp
;     mov edx, 30
;     int 0x80

;     mov eax, 3
;     mov ebx, 0
;     mov ecx, operation
;     mov edx, 5
;     int 0x80

;     mov al, byte [operation]
;     cmp al, 's'
;     je do_sqrt

;     mov eax, 4
;     mov ebx, 1
;     mov ecx, prompt2
;     mov edx, 20
;     int 0x80

;     mov eax, 3
;     mov ebx, 0
;     mov ecx, num2
;     mov edx, 10
;     int 0x80

;     mov ecx, num2
;     call ascii_to_int
;     mov [num2], eax

;     mov al, byte [operation]
;     cmp al, '+'
;     je do_addition
;     cmp al, '-'
;     je do_subtraction
;     cmp al, '*'
;     je do_multiplication
;     cmp al, '/'
;     je do_division
;     cmp al, '%'
;     je do_modulus
;     cmp al, '^'
;     je do_power
;     jmp exit_program

; do_addition:
;     mov eax, [num1]
;     mov ebx, [num2]
;     add eax, ebx
;     jmp output_result

; do_subtraction:
;     mov eax, [num1]
;     mov ebx, [num2]
;     sub eax, ebx
;     jmp output_result

; do_multiplication:
;     mov eax, [num1]
;     mov ebx, [num2]
;     imul eax, ebx
;     jmp output_result

; do_division:
;     mov eax, [num2]
;     cmp eax, 0
;     je division_error
;     mov eax, [num1]
;     xor edx, edx
;     div dword [num2]
;     jmp output_result

; do_modulus:
;     mov eax, [num1]
;     mov ebx, [num2]
;     xor edx, edx
;     div ebx
;     mov eax, edx
;     jmp output_result

; do_power:
;     mov ecx, [num2]
;     mov eax, [num1]
;     mov ebx, eax

; power_loop:
;     dec ecx
;     jz output_result
;     imul eax, ebx
;     jmp power_loop

; do_sqrt:
;     fld dword [num1]
;     fsqrt
;     fistp dword [result]
;     jmp output_result

; division_error:
;     mov eax, 4
;     mov ebx, 1
;     mov ecx, errMsg
;     mov edx, 23
;     int 0x80
;     jmp exit_program

; output_result:
;     call int_to_ascii
;     mov eax, 4
;     mov ebx, 1
;     mov ecx, resultMsg
;     mov edx, 14
;     int 0x80

;     mov eax, 4
;     mov ebx, 1
;     mov ecx, result
;     mov edx, 10
;     int 0x80

; exit_program:
;     mov eax, 1
;     xor ebx, ebx
;     int 0x80

; ascii_to_int:
;     xor eax, eax
;     xor ebx, ebx
; convert_loop:
;     mov bl, byte [ecx]
;     cmp bl, 0xA
;     je done_convert
;     sub bl, '0'
;     imul eax, eax, 10
;     add eax, ebx
;     inc ecx
;     jmp convert_loop
; done_convert:
;     ret

; int_to_ascii:
;     mov esi, result
;     mov ecx, 10
; convert_int:
;     xor edx, edx
;     div ecx
;     add dl, '0'
;     mov [esi], dl
;     inc esi
;     cmp eax, 0
;     jne convert_int
;     mov byte [esi], 0xA
;     ret
