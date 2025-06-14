; runtime.asm
; Instituto Tecnológico de Costa Rica
; Compiladores e intérpretes
; Rutinas de E/S y conversión de tipos en ensamblador x86 (DOS)
; Mauro Navarro Obando

.MODEL SMALL

; =========================
; === DATA SEGMENT ========
; =========================
DATA SEGMENT
    ; Mensajes generales
    msg_newline    DB 13,10,'$'
    msg_error      DB 'Error: Entrada inválida$', 13,10,'$'

    ; Para caracteres
    msg_char_in    DB 'Ingresa un carácter: $'
    msg_char_out   DB 'Carácter ingresado: $'
    char_buffer    DB ?

    ; Para enteros
    msg_int_in     DB 'Ingresa un número: $'
    msg_int_out    DB 'Número ingresado: $'
    int_buffer     DB 6 DUP(?)
    int_value      DW ?

    ; Para cadenas
    msg_str_in     DB 'Ingresa una cadena: $'
    msg_str_out    DB 'Cadena ingresada: $'
    str_buffer     DB 30, ?, 30 DUP(?)

    ; Para conversiones
    msg_conv_in    DB 'Ingrese una cadena de caracteres: $'
    msg_conv_str   DB 0Dh, 0Ah, 'La cadena de caracteres ingresada es: $'
    msg_conv_float DB 0Dh, 0Ah, 'La cadena representa el siguiente valor flotante: $'
    msg_conv_bool  DB 0Dh, 0Ah, 'La cadena representa un valor booleano equivalente a: $'
    conv_buffer    DB 10, 0, 10 DUP(0)
    conv_num       DW 0
    conv_ascii     DB 10 DUP('$')

    ; Para booleanos
    msg_bool1      DB 'Ingrese un valor booleano (true/false): $'
    msg_bool2      DB 10, 13, 'Ingrese el segundo valor booleano (true/false): $'
    msg_bool_menu  DB 10, 13, 'Seleccione la operacion:', 10, 13
                   DB '1. NOT (primer valor)', 10, 13
                   DB '2. AND', 10, 13
                   DB '3. OR', 10, 13
                   DB '4. XOR', 10, 13
                   DB 'Opcion: $'
    msg_bool_res   DB 10, 13, 'El resultado es: $'
    msg_bool_true  DB 'true$'
    msg_bool_false DB 'false$'
    bool_val1      DB 0
    bool_val2      DB 0
    bool_result    DB 0

    ; Para operaciones aritméticas
    msg_op1        DB 'Ingrese el primer numero (0-65535): $'
    msg_op2        DB 10, 13, 'Ingrese el segundo numero (0-65535): $'
    msg_op_menu    DB 10, 13, 'Seleccione la operacion:', 10, 13
                   DB '1. Suma', 10, 13
                   DB '2. Resta', 10, 13
                   DB '3. Multiplicacion', 10, 13
                   DB '4. Division', 10, 13
                   DB 'Opcion: $'
    msg_op_res     DB 10, 13, 'El resultado es: $'
    msg_op_div0    DB 10, 13, 'Error: Division por cero$'
    op_buffer      DB 6, 0, 6 DUP(0)
    op_num1        DW 0
    op_num2        DW 0
    op_result      DW 0
DATA ENDS

; =========================
; === STACK SEGMENT =======
; =========================
STACKSEG SEGMENT STACK
             DW 100h DUP(?)
STACKSEG ENDS

; =========================
; === CODE SEGMENT ========
; =========================
CODE SEGMENT
                    ASSUME CS:CODE, DS:DATA, SS:STACKSEG

    ; =========================
    ; === MAIN (DEMO) =========
    ; =========================
    START:          
                    MOV    AX, DATA
                    MOV    DS, AX
                    MOV    AX, STACKSEG
                    MOV    SS, AX
                    MOV    SP, 100h

    ; Aquí puedes probar las rutinas llamando a los procedimientos
    ; Ejemplo: call ReadChar, call ReadInt, call ReadString, etc.

    ; Demo: Leer y mostrar un carácter
                    CALL   ReadChar
                    CALL   PrintNewline
                    CALL   PrintChar

    ; Demo: Leer y mostrar un entero
                    CALL   ReadInt
                    CALL   PrintNewline
                    CALL   PrintInt

    ; Demo: Leer y mostrar una cadena
                    CALL   ReadString
                    CALL   PrintNewline
                    CALL   PrintString

    ; Demo: Operaciones booleanas
    ; CALL BooleanMenu

    ; Demo: Operaciones aritméticas
    ; CALL ArithmeticMenu

    ; Demo: Conversiones
    ; CALL ConvertToChar
    ; CALL ConvertToInt
    ; CALL ConvertToString

    ; Fin del programa
                    MOV    AH, 4Ch
                    INT    21h

    ; =========================
    ; === FUNCIONES DE E/S ====
    ; =========================

    ; Leer un carácter y guardarlo en char_buffer
ReadChar PROC
                    MOV    DX, OFFSET msg_char_in
                    MOV    AH, 09h
                    INT    21h

                    MOV    AH, 01h
                    INT    21h
                    MOV    char_buffer, AL
                    RET
ReadChar ENDP

    ; Imprimir el carácter guardado en char_buffer
PrintChar PROC
                    MOV    DX, OFFSET msg_char_out
                    MOV    AH, 09h
                    INT    21h

                    MOV    DL, char_buffer
                    MOV    AH, 02h
                    INT    21h
                    RET
PrintChar ENDP

    ; Leer un entero (como string), convertirlo y guardarlo en int_value
ReadInt PROC
                    MOV    DX, OFFSET msg_int_in
                    MOV    AH, 09h
                    INT    21h

                    MOV    SI, OFFSET int_buffer
                    MOV    CX, 0

    readint_loop:   
                    MOV    AH, 01h
                    INT    21h
                    CMP    AL, 13
                    JE     readint_convert
                    MOV    [SI], AL
                    INC    SI
                    INC    CX
                    CMP    CX, 5
                    JL     readint_loop

    readint_convert:
                    MOV    [SI], '$'
                    MOV    SI, OFFSET int_buffer
                    MOV    BX, 0

    parse_digits:   
                    MOV    AL, [SI]
                    CMP    AL, '$'
                    JE     readint_show
                    SUB    AL, '0'
                    MOV    AH, 0
                    MOV    DX, 10
                    MUL    DX
                    ADD    BX, AX
                    INC    SI
                    JMP    parse_digits

    readint_show:   
                    MOV    int_value, BX
                    RET
ReadInt ENDP

    ; Imprimir el entero guardado en int_value
PrintInt PROC
                    MOV    DX, OFFSET msg_int_out
                    MOV    AH, 09h
                    INT    21h

                    MOV    AX, int_value
                    CALL   PrintNumber
                    RET
PrintInt ENDP

    ; Leer una cadena y guardarla en str_buffer
ReadString PROC
                    MOV    DX, OFFSET msg_str_in
                    MOV    AH, 09h
                    INT    21h

                    MOV    DX, OFFSET str_buffer
                    MOV    AH, 0Ah
                    INT    21h
                    RET
ReadString ENDP

    ; Imprimir la cadena guardada en str_buffer
PrintString PROC
                    MOV    DX, OFFSET msg_str_out
                    MOV    AH, 09h
                    INT    21h

                    LEA    DX, str_buffer+2
                    MOV    AH, 09h
                    INT    21h
                    RET
PrintString ENDP

    ; Imprimir salto de línea
PrintNewline PROC
                    MOV    DX, OFFSET msg_newline
                    MOV    AH, 09h
                    INT    21h
                    RET
PrintNewline ENDP

    ; =========================
    ; === CONVERSIONES ========
    ; =========================

    ; Convertir string a char (promedio de ASCII)
ConvertToChar PROC
                    MOV    DX, OFFSET msg_conv_in
                    MOV    AH, 09h
                    INT    21h

                    MOV    AH, 0Ah
                    LEA    DX, conv_buffer
                    INT    21h

    ; Calcular promedio de ASCII
                    MOV    SI, OFFSET conv_buffer
                    ADD    SI, 2
                    XOR    AX, AX
                    XOR    CX, CX

    convchar_sum:   
                    MOV    BL, [SI]
                    CMP    BL, '$'
                    JE     convchar_avg
                    ADD    AX, BX
                    INC    SI
                    INC    CX
                    JMP    convchar_sum

    convchar_avg:   
                    XOR    DX, DX
                    TEST   CX, CX
                    JZ     convchar_end
                    DIV    CL
    ; AX ahora tiene el promedio
    ; Mostrar resultado
                    LEA    DI, conv_ascii
                    MOV    [DI], AL
                    MOV    DX, OFFSET msg_conv_str
                    MOV    AH, 09h
                    INT    21h
                    LEA    DX, conv_ascii
                    INT    21h

    convchar_end:   
                    RET
ConvertToChar ENDP

    ; Convertir string a int (solo dígitos)
ConvertToInt PROC
                    MOV    DX, OFFSET msg_conv_in
                    MOV    AH, 09h
                    INT    21h

                    MOV    AH, 0Ah
                    LEA    DX, conv_buffer
                    INT    21h

                    MOV    SI, OFFSET conv_buffer
                    ADD    SI, 2
                    XOR    AX, AX

    convint_loop:   
                    MOV    BL, [SI]
                    CMP    BL, '$'
                    JE     convint_done
                    SUB    BL, '0'
                    MOV    BH, 0
                    MOV    CX, AX
                    MOV    AX, 10
                    MUL    CX
                    ADD    AX, BX
                    INC    SI
                    JMP    convint_loop

    convint_done:   
                    MOV    conv_num, AX
    ; Mostrar resultado
                    MOV    DX, OFFSET msg_conv_str
                    MOV    AH, 09h
                    INT    21h
    ; Convertir AX a ASCII y mostrar
                    CALL   PrintNumber
                    RET
ConvertToInt ENDP

    ; Convertir string a string (solo muestra la entrada)
ConvertToString PROC
                    MOV    DX, OFFSET msg_conv_in
                    MOV    AH, 09h
                    INT    21h

                    MOV    AH, 0Ah
                    LEA    DX, conv_buffer
                    INT    21h

                    MOV    DX, OFFSET msg_conv_str
                    MOV    AH, 09h
                    INT    21h

                    LEA    DX, conv_buffer+2
                    MOV    AH, 09h
                    INT    21h
                    RET
ConvertToString ENDP

    ; =========================
    ; === BOOLEANOS ===========
    ; =========================

    ; Leer booleano (true/false) y devolver en AL (1=true, 0=false)
ReadBoolean PROC
                    PUSH   BX
                    PUSH   CX
                    PUSH   DX
                    PUSH   SI

                    LEA    DX, conv_buffer
                    MOV    AH, 0Ah
                    INT    21h

                    MOV    BL, conv_buffer[1]
                    CMP    BL, 4
                    JE     rb_true
                    CMP    BL, 5
                    JE     rb_false
                    JMP    rb_invalid

    rb_true:        
                    LEA    SI, conv_buffer
                    ADD    SI, 2
                    MOV    AL, [SI]
                    CMP    AL, 't'
                    JNE    rb_false
                    MOV    AL, [SI+1]
                    CMP    AL, 'r'
                    JNE    rb_invalid
                    MOV    AL, [SI+2]
                    CMP    AL, 'u'
                    JNE    rb_invalid
                    MOV    AL, [SI+3]
                    CMP    AL, 'e'
                    JNE    rb_invalid
                    MOV    AL, 1
                    JMP    rb_end

    rb_false:       
                    LEA    SI, conv_buffer
                    ADD    SI, 2
                    MOV    AL, [SI]
                    CMP    AL, 'f'
                    JNE    rb_invalid
                    MOV    AL, [SI+1]
                    CMP    AL, 'a'
                    JNE    rb_invalid
                    MOV    AL, [SI+2]
                    CMP    AL, 'l'
                    JNE    rb_invalid
                    MOV    AL, [SI+3]
                    CMP    AL, 's'
                    JNE    rb_invalid
                    MOV    AL, [SI+4]
                    CMP    AL, 'e'
                    JNE    rb_invalid
                    MOV    AL, 0
                    JMP    rb_end

    rb_invalid:     
                    MOV    AL, 0

    rb_end:         
                    POP    SI
                    POP    DX
                    POP    CX
                    POP    BX
                    RET
ReadBoolean ENDP

    ; Menú de operaciones booleanas
BooleanMenu PROC
                    LEA    DX, msg_bool1
                    MOV    AH, 09h
                    INT    21h
                    CALL   ReadBoolean
                    MOV    bool_val1, AL

                    LEA    DX, msg_bool2
                    MOV    AH, 09h
                    INT    21h
                    CALL   ReadBoolean
                    MOV    bool_val2, AL

                    LEA    DX, msg_bool_menu
                    MOV    AH, 09h
                    INT    21h

                    MOV    AH, 01h
                    INT    21h
                    SUB    AL, '0'

                    CMP    AL, 1
                    JE     bm_not
                    CMP    AL, 2
                    JE     bm_and
                    CMP    AL, 3
                    JE     bm_or
                    CMP    AL, 4
                    JE     bm_xor
                    JMP    bm_exit

    bm_not:         
                    MOV    AL, bool_val1
                    XOR    AL, 1
                    MOV    bool_result, AL
                    JMP    bm_show

    bm_and:         
                    MOV    AL, bool_val1
                    AND    AL, bool_val2
                    MOV    bool_result, AL
                    JMP    bm_show

    bm_or:          
                    MOV    AL, bool_val1
                    OR     AL, bool_val2
                    MOV    bool_result, AL
                    JMP    bm_show

    bm_xor:         
                    MOV    AL, bool_val1
                    XOR    AL, bool_val2
                    MOV    bool_result, AL
                    JMP    bm_show

    bm_show:        
                    LEA    DX, msg_bool_res
                    MOV    AH, 09h
                    INT    21h
                    CMP    bool_result, 1
                    JE     bm_true
                    LEA    DX, msg_bool_false
                    MOV    AH, 09h
                    INT    21h
                    JMP    bm_exit

    bm_true:        
                    LEA    DX, msg_bool_true
                    MOV    AH, 09h
                    INT    21h

    bm_exit:        
                    RET
BooleanMenu ENDP

    ; =========================
    ; === ARITMÉTICA ==========
    ; =========================

    ; Menú de operaciones aritméticas
ArithmeticMenu PROC
                    LEA    DX, msg_op1
                    MOV    AH, 09h
                    INT    21h
                    CALL   ReadNumber
                    MOV    op_num1, AX

                    LEA    DX, msg_op2
                    MOV    AH, 09h
                    INT    21h
                    CALL   ReadNumber
                    MOV    op_num2, AX

                    LEA    DX, msg_op_menu
                    MOV    AH, 09h
                    INT    21h

                    MOV    AH, 01h
                    INT    21h
                    SUB    AL, '0'

                    CMP    AL, 1
                    JE     am_sum
                    CMP    AL, 2
                    JE     am_sub
                    CMP    AL, 3
                    JE     am_mul
                    CMP    AL, 4
                    JE     am_div
                    JMP    am_exit

    am_sum:         
                    MOV    AX, op_num1
                    ADD    AX, op_num2
                    MOV    op_result, AX
                    JMP    am_show

    am_sub:         
                    MOV    AX, op_num1
                    SUB    AX, op_num2
                    MOV    op_result, AX
                    JMP    am_show

    am_mul:         
                    MOV    AX, op_num1
                    MUL    op_num2
                    MOV    op_result, AX
                    JMP    am_show

    am_div:         
                    MOV    AX, op_num1
                    MOV    BX, op_num2
                    OR     BX, BX
                    JZ     am_div0
                    XOR    DX, DX
                    DIV    BX
                    MOV    op_result, AX
                    JMP    am_show

    am_div0:        
                    LEA    DX, msg_op_div0
                    MOV    AH, 09h
                    INT    21h
                    JMP    am_exit

    am_show:        
                    LEA    DX, msg_op_res
                    MOV    AH, 09h
                    INT    21h
                    MOV    AX, op_result
                    CALL   PrintNumber

    am_exit:        
                    RET
ArithmeticMenu ENDP

    ; Leer número (para ArithmeticMenu)
ReadNumber PROC
                    LEA    DX, op_buffer
                    MOV    AH, 0Ah
                    INT    21h

                    XOR    AX, AX
                    XOR    BX, BX
                    MOV    BL, op_buffer[1]
                    MOV    CX, 0

    rn_convert:     
                    CMP    CX, BX
                    JE     rn_end
                    MOV    AX, 10
                    MUL    WORD PTR [op_result]
                    MOV    WORD PTR [op_result], AX
                    LEA    SI, op_buffer
                    ADD    SI, CX
                    ADD    SI, 2
                    MOV    AL, [SI]
                    SUB    AL, '0'
                    XOR    AH, AH
                    ADD    WORD PTR [op_result], AX
                    INC    CX
                    JMP    rn_convert

    rn_end:         
                    MOV    AX, WORD PTR [op_result]
                    MOV    WORD PTR [op_result], 0
                    RET
ReadNumber ENDP

    ; =========================
    ; === UTILIDADES ==========
    ; =========================

    ; Imprimir número en AX
PrintNumber PROC
                    PUSH   AX
                    PUSH   BX
                    PUSH   CX
                    PUSH   DX

                    MOV    CX, 0
                    MOV    BX, 10

    pn_divide:      
                    XOR    DX, DX
                    DIV    BX
                    ADD    DL, '0'
                    PUSH   DX
                    INC    CX
                    TEST   AX, AX
                    JNZ    pn_divide

    pn_print:       
                    POP    DX
                    MOV    AH, 02h
                    INT    21h
                    LOOP   pn_print

                    POP    DX
                    POP    CX
                    POP    BX
                    POP    AX
                    RET
PrintNumber ENDP

CODE ENDS

END START