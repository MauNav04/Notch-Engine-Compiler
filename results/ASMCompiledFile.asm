
; Instituto Tecnológico de Costa Rica
; Ingeniería en Computación
; Compiladores e intérpretes
; Semestre I 2025
; Etapa 4
; Autor: 
; Mauro Navarro Obando

; ====================================================================
;   Generado por Compilador para archivos Notch Engine [.ne] -> ASM
; ====================================================================

pile segment stack 'stack'
    dw 4096 dup(?)
pile endS

data segment
    include PoolLiteral.plt

    indice_plt        DB 0 ; Indice para saber por dónde se va llenando el pool de literales

initial DW 'e'
num1 DW 49

data endS

code segment
            assume cs:code, ds:data, ss:pile
code endS
end main