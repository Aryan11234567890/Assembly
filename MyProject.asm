section .data
    prompt0 db "Hi and Welcome!!!!!"
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
    mov rsi, prompt0
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, prompt1
    mov rdx, 40
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
    movsd xmm1, xmm2  
    inc r9
    jmp .loop

.done:
    ret


float_to_string:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    
    mov rdi, output_buffer
    
    pxor xmm1, xmm1
    comisd xmm0, xmm1
    jae .positive
    
    mov byte [rdi], '-'
    inc rdi
    subsd xmm0, xmm1
    subsd xmm0, xmm1  

.positive:
    cvttsd2si rax, xmm0
    push rax
    
    mov rbx, 10
    xor rcx, rcx 
.integer_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc rcx
    test rax, rax
    jnz .integer_loop

    mov rsi, rdi
    mov rdi, output_buffer
    test byte [rdi], '-'
    jz .copy_integer
    inc rdi
.copy_integer:
    rep movsb
    
    mov byte [rdi], '.'
    inc rdi
    
    
    pop rax
    cvtsi2sd xmm1, rax
    subsd xmm0, xmm1 
    
    mov rcx, 8
.fraction_loop:
    mulsd xmm0, [ten]
    cvttsd2si rax, xmm0
    add al, '0'
    mov [rdi], al
    inc rdi
    cvtsi2sd xmm1, rax
    subsd xmm0, xmm1
    loop .fraction_loop

    dec rdi
.remove_zeros:
    cmp byte [rdi], '0'
    jne .done
    mov byte [rdi], 0
    dec rdi
    jmp .remove_zeros

.done:
    
    cmp byte [rdi], '.'
    jne .finish
    inc rdi
    mov byte [rdi], '0'
    inc rdi

.finish:
    mov byte [rdi], 0  
    mov rsp, rbp
    pop rbp
    ret