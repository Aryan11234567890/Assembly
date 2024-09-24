include windows.inc
include user32.inc
include kernel32.inc
include masm32.inc

.data
    className db "CalcClass", 0
    windowTitle db "Simple Calculator", 0
    resultMsg db "The result is: ", 0
    errMsg db "Error: Division by zero", 0
    prompt1 db "Enter first number: ", 0
    prompt2 db "Enter second number: ", 0
    promptOp db "Enter operation (+, -, *, /): ", 0

    num1 db 10 dup(0)
    num2 db 10 dup(0)
    operation db 1 dup(0)
    result db 10 dup(0)

    hwndEdit1 dd ?
    hwndEdit2 dd ?
    hwndOp dd ?
    hwndButton dd ?
    hwndResult dd ?

    ten dd 10

.code
start:
    invoke GetModuleHandle, NULL
    invoke RegisterClass, addr wndClass

    invoke CreateWindowEx, 0, addr className, addr windowTitle, WS_OVERLAPPEDWINDOW, \
                           CW_USEDEFAULT, CW_USEDEFAULT, 300, 200, NULL, NULL, \
                           eax, NULL
    mov eax, [esp+4]
    mov [hwndEdit1], eax
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, addr "EDIT", NULL, WS_CHILD or WS_VISIBLE or ES_NUMBER, \
                           10, 10, 100, 20, eax, 1, NULL, NULL
    mov eax, [esp+4]
    mov [hwndEdit2], eax
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, addr "EDIT", NULL, WS_CHILD or WS_VISIBLE or ES_NUMBER, \
                           10, 40, 100, 20, eax, 2, NULL, NULL
    mov eax, [esp+4]
    mov [hwndOp], eax
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, addr "EDIT", NULL, WS_CHILD or WS_VISIBLE or ES_LEFT, \
                           10, 70, 100, 20, eax, 3, NULL, NULL
    mov eax, [esp+4]
    mov [hwndButton], eax
    invoke CreateWindowEx, 0, addr "BUTTON", addr "Calculate", WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, \
                           10, 100, 100, 30, eax, 4, NULL, NULL
    mov eax, [esp+4]
    mov [hwndResult], eax
    invoke ShowWindow, eax, SW_SHOWNORMAL
    invoke UpdateWindow, eax

msg_loop:
    invoke GetMessage, addr msg, NULL, 0, 0
    .break .if eax == 0
    invoke TranslateMessage, addr msg
    invoke DispatchMessage, addr msg
    jmp msg_loop

wndProc proc hwnd:DWORD, msg:DWORD, wparam:DWORD, lparam:DWORD
    .if msg == WM_DESTROY
        invoke PostQuitMessage, 0
        ret
    .elseif msg == WM_COMMAND
        .if LOWORD(wparam) == 4
            invoke GetWindowText, [hwndEdit1], addr num1, 10
            invoke GetWindowText, [hwndEdit2], addr num2, 10
            invoke GetWindowText, [hwndOp], addr operation, 1

            ; Convert ASCII to integer
            invoke atoi, addr num1
            mov eax, eax
            invoke atoi, addr num2
            mov ebx, eax

            ; Perform operation
            mov al, [operation]
            .if al == '+'
                add eax, ebx
            .elseif al == '-'
                sub eax, ebx
            .elseif al == '*'
                imul eax, ebx
            .elseif al == '/'
                .if ebx == 0
                    invoke MessageBox, hwnd, addr errMsg, addr windowTitle, MB_OK
                    jmp exit_calculation
                .endif
                xor edx, edx
                div ebx
            .endif

            ; Convert result to ASCII
            invoke itoa, eax, addr result
            invoke SetWindowText, [hwndResult], addr result
        .endif
    .endif
    invoke DefWindowProc, hwnd, msg, wparam, lparam
    ret
wndProc endp

atoi proc str:DWORD
    xor eax, eax
    xor ebx, ebx
    xor edx, edx
atoi_loop:
    mov bl, byte ptr [str]
    cmp bl, 0
    je atoi_done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc str
    jmp atoi_loop
atoi_done:
    ret

itoa proc value:DWORD, str:DWORD
    mov eax, value
    mov ecx, str
    add ecx, 10
    mov byte ptr [ecx], 0
    dec ecx
itoa_loop:
    xor edx, edx
    div dword ptr [ten]
    add dl, '0'
    mov byte ptr [ecx], dl
    dec ecx
    test eax, eax
    jnz itoa_loop
    ret

end start
