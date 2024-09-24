section .data
    prompt1 db "Enter first number: ", 0
    prompt2 db "Enter second number: ", 0
    promptOp db "Enter operation (+, -, *, /): ", 0
    resultMsg db "The result is: ", 0
    errMsg db "Error: Division by zero", 0
    newline db 0xA
    buffer db 0

section .bss
    num1 resb 10        
    num2 resb 10        
    operation resb 1    
    result resb 10     

section .text
    global _start

_start:
    mov eax, 4          
    mov ebx, 1          
    mov ecx, prompt1     
    mov edx, 20        
    int 0x80            
    mov eax, 3     
    mov ebx, 0       
    mov ecx, num1      
    mov edx, 10     
    int 0x80             

    mov ecx, num1
    call ascii_to_int
    mov [num1], eax   
    mov eax, 4          
    mov ebx, 1       
    mov ecx, prompt2     
    mov edx, 20          
    int 0x80          
    mov eax, 3        
    mov ebx, 0           
    mov ecx, num2       
    mov edx, 10       
    int 0x80            

    mov ecx, num2
    call ascii_to_int
    mov [num2], eax    

    mov eax, 4          
    mov ebx, 1           
    mov ecx, promptOp     
    mov edx, 30          
    int 0x80            

    mov eax, 3          
    mov ebx, 0           
    mov ecx, operation   
    mov edx, 1           
    int 0x80             

    mov al, byte [operation]
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
    mov eax, [num1]      
    mov ebx, [num2]      
    add eax, ebx         
    jmp output_result    

do_subtraction:
    mov eax, [num1]      
    mov ebx, [num2]      
    sub eax, ebx         
    jmp output_result    

do_multiplication:
    mov eax, [num1]      
    mov ebx, [num2]      
    imul eax, ebx        
    jmp output_result    

do_division:
    mov eax, [num2]      
    cmp eax, 0           
    je division_error    
    mov eax, [num1]      
    xor edx, edx         
    div dword [num2]     
    jmp output_result    

division_error:
    mov eax, 4           
    mov ebx, 1           
    mov ecx, errMsg      
    mov edx, 23          
    int 0x80             
    jmp exit_program     

output_result:
    mov ecx, result     
    call int_to_ascii  

    mov eax, 4           
    mov ebx, 1           
    mov ecx, resultMsg   
    mov edx, 14          
    int 0x80             

    mov eax, 4           
    mov ebx, 1           
    mov ecx, result     
    mov edx, 10         
    int 0x80             

exit_program:
    mov eax, 1           
    xor ebx, ebx         
    int 0x80

ascii_to_int:
    xor eax, eax        
    xor ebx, ebx        
    xor edx, edx        
    mov esi, ecx     

atoi_loop:
    mov bl, byte [esi]  
    cmp bl, 0xA         
    je atoi_done       
    sub bl, '0'        
    imul eax, eax, 10   
    add eax, ebx       
    inc esi            
    jmp atoi_loop   

atoi_done:
    ret
int_to_ascii:
    mov esi, ecx        
    add esi, 9          
    mov [esi], byte 0   
    dec esi             
    xor edx, edx        

itoa_loop:
    xor edx, edx      
    div dword [ten]     
    add dl, '0'         
    mov [esi], dl       
    dec esi             
    test eax, eax       
    jnz itoa_loop      
    ret
section .data
ten dd 10             





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
