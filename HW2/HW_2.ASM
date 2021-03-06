format PE console

include 'win32a.inc'

entry start

section '.data' data readable writable

        strVecSize      db 'size of vector?', 10, 0
        strIncorSize    db 'Incorrect size of vector = %d', 10, 0
        strVecElemI     db '[%d]? ', 0
        strScanInt      db '%d', 0
        strVecElemOut   db '[%d] = %d', 10, 0
        strVecBracketS  db '[', 0
        strVecBracketE  db ']', 10, 0
        strDigit        db '%d ', 0
        strArrA         db 'Array A: ', 0

        arrA_size       dd 0
        arrA            rd 100
        i               dd ?
        tmp             dd ?
        stackPointer    dd ?
        a               dd ?

        NULL = 0


section '.code' code readable executable

;____________________READ_ARR_______________
        readArr:
                ;��������� �������� ��������� � �����
                ;����� �� ��������� ��
                push eax
                mov  eax, esp ;���������� �������� ��������� ����� � ������� eax
                push ecx
                push edx

                xor  ecx, ecx ;ecx = 0
                mov  edx, [ss:eax+8+0] ; mov edx, arrA (�������� ������ �� ������
                ;�� ����� ��������� � ������������������ �������� 8 (�� ���� ����������
                ;�� ��� ������� ����))

        inputArrLoop:
                ;��������� �������� ��������� � ���������� �� �������
                mov  [stackPointer], eax
                mov  [tmp], edx

                cmp  ecx, [ss:eax+8+4]
                jge  endInputArrLoop

                ;��������� �������
                mov  [i], ecx
                push ecx
                push strVecElemI
                call [printf]
                ;����� ������ printf �������� ��������� ��������

                push [tmp]
                push strScanInt
                call [scanf]
                ;��� ��� ���� ��������

                ;����� ������ printf � scanf �������� �������� �������
                ;��������������� ������ �������� ��������� �� ����������
                ;� ������� �� �������� �������� �� �����
                mov  ecx, [i]
                inc  ecx
                mov  edx, [tmp]
                add  edx, 4
                mov  eax, [stackPointer]
                jmp  inputArrLoop

        endInputArrLoop:
                ;�������� ��������� ���� �� ��� ������� �����
                sub  eax, 8
                mov  esp, eax
                ;���������� ��������� �� �������� �� �������������
                ;���������
                pop  edx
                pop  ecx
                pop  eax

        ret
;___________________END_READ_ARR____________

;____________________PRINT_ARR______________

        printArr:

                ;��������� �������� ��������� � �����
                push eax
                mov  eax, esp
                push ecx
                push edx

                ;��������� ������� eax � ���������� �� �������
                mov  [stackPointer], eax

                push strVecBracketS
                call [printf]

                ;� ��� �� ����� �������, printf �������� ��� ��� �������
                ;� ��� �� ��� ���������������
                mov  eax, [stackPointer]

                xor  ecx, ecx ;ecx = 0
                mov  edx, [ss:eax+8+0] ;mov edx, arr (���������� � edx ������ �� ������)

        printArrLoop:
                ;��������� �������� ��������� � ����������
                mov  [tmp], edx
                mov  [i], ecx

                cmp  ecx, [ss:eax+8+4];���������� ����� ������� � ecx, ������ �������� ��� �������
                jge  endPrintArrLoop

                mov  ecx, [edx]
                push ecx
                push strDigit
                call [printf]

                ;����� �� ��������������� �������� ��������� ��� ���
                ;����� printf ��� �����������
                mov  edx, [tmp]
                add  edx, 4
                mov  ecx, [i]
                inc  ecx
                mov  eax, [stackPointer]
                jmp  printArrLoop

        endPrintArrLoop:
                ;������� ������ ������
                push strVecBracketE
                call [printf]

                ;��������������� �������� �������� eax ����� printf
                mov  eax, [stackPointer]

                ;�������� ��������� ���� �� ��� ������� �����
                sub  eax, 8
                mov  esp, eax
                ;���������� ��������� �� �������� �� �������������
                ;���������
                pop  edx
                pop  ecx
                pop  eax

        ret

;__________________END_PRINT_ARR____________

;__________________NEW STUFF________________
VectorOut:
        mov [stackPointer], esp
        xor ecx, ecx
        mov ebx, arrA            ; ebx = &vec
        add ebx, [arrA_size]
        add ebx, [arrA_size]
        add ebx, [arrA_size]
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [arrA_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        sub ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [stackPointer]
        ret
;______________________MAIN_________________
        start:
                push strVecSize
                call [printf]

                push arrA_size
                push strScanInt
                call [scanf]

                mov  eax, [arrA_size]
                cmp  eax, 0
                jg  successInput

                ;Incorrect arr size
                push strIncorSize
                push [arrA_size]
                call [printf]

                jmp finish

        successInput:
                ;��������� ������ �
                push [arrA_size]
                push arrA
                call readArr

                ;������� ������ B ��� ������������ ��������
                call VectorOut


        finish:
                call [getch]

                push NULL
                call ExitProcess

;_________________END_MAIN_________________

section '.idata' data readable import

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'
