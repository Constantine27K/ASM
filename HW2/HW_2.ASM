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
                ;сохраняем значения регистров в стеке
                ;чтобы не испортить их
                push eax
                mov  eax, esp ;записываем значения указателя стека в регистр eax
                push ecx
                push edx

                xor  ecx, ecx ;ecx = 0
                mov  edx, [ss:eax+8+0] ; mov edx, arrA (получаем ссылку на массив
                ;из стека прибавляя к нашемусохраненному значению 8 (то есть спускаемся
                ;на две позиции вниз))

        inputArrLoop:
                ;сохраняем значения регистров в переменные на будущее
                mov  [stackPointer], eax
                mov  [tmp], edx

                cmp  ecx, [ss:eax+8+4]
                jge  endInputArrLoop

                ;считываем элемент
                mov  [i], ecx
                push ecx
                push strVecElemI
                call [printf]
                ;после вызова printf значения регистров портятся

                push [tmp]
                push strScanInt
                call [scanf]
                ;тут они тоже портятся

                ;после вызова printf и scanf регистры портятся поэтому
                ;восстанавливаем нужные значения регистров из переменных
                ;в которые мы записали значения до этого
                mov  ecx, [i]
                inc  ecx
                mov  edx, [tmp]
                add  edx, 4
                mov  eax, [stackPointer]
                jmp  inputArrLoop

        endInputArrLoop:
                ;сдвигаем указатель кучи на две позиции вверх
                sub  eax, 8
                mov  esp, eax
                ;возвращаем регистрам их значения до использования
                ;процедуры
                pop  edx
                pop  ecx
                pop  eax

        ret
;___________________END_READ_ARR____________

;____________________PRINT_ARR______________

        printArr:

                ;сохраняем значения регистров в стеке
                push eax
                mov  eax, esp
                push ecx
                push edx

                ;сохраняем регистр eax в переменной на будущее
                mov  [stackPointer], eax

                push strVecBracketS
                call [printf]

                ;а вот то самое будущее, printf попортил нам наш регистр
                ;и тут мы его восстанавливаем
                mov  eax, [stackPointer]

                xor  ecx, ecx ;ecx = 0
                mov  edx, [ss:eax+8+0] ;mov edx, arr (записываем в edx ссылку на массив)

        printArrLoop:
                ;сохраняем значения регистров в переменные
                mov  [tmp], edx
                mov  [i], ecx

                cmp  ecx, [ss:eax+8+4];сравниваем длину массива с ecx, регист хранящий наш счетчик
                jge  endPrintArrLoop

                mov  ecx, [edx]
                push ecx
                push strDigit
                call [printf]

                ;опять же восстанавливаем значения регистров так как
                ;после printf они попортились
                mov  edx, [tmp]
                add  edx, 4
                mov  ecx, [i]
                inc  ecx
                mov  eax, [stackPointer]
                jmp  printArrLoop

        endPrintArrLoop:
                ;выводим правую скобку
                push strVecBracketE
                call [printf]

                ;восстанавливаем значения регистра eax после printf
                mov  eax, [stackPointer]

                ;сдвигаем указатель кучи на две позиции вверх
                sub  eax, 8
                mov  esp, eax
                ;возвращаем регистрам их значения до использования
                ;процедуры
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
                ;считываем массив А
                push [arrA_size]
                push arrA
                call readArr

                ;создаем массив B без минимального элемента
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
