class FileHandler:
    def __init__(self, filename, mode='w'):
        """
        Inicializa el manejador de archivos.
        :param filename: Nombre del archivo a manejar.
        :param mode: Modo de apertura ('w' para escribir, 'a' para agregar, etc.).
        """
        self.filename = filename
        self.mode = mode
        self.file = None
        
        self.prop1 = '''
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
indice_plt        DB 0 ; Indice para saber por dónde se va llenando el pool de literales

mensaje_entrada   DB 'Ingrese una cadena de caracteres: $'
mensaje_invalido  DB 'Solo puede ingresar valores numericos$'
mensaje_string    DB 0Dh, 0Ah, 'La cadena de caracteres ingresada es: $'
mensaje_float     DB 0Dh, 0Ah, 'La cadena representa el siguiente valor flotante: $'
mensaje_bool      DB 0Dh, 0Ah, 'La cadena representa un valor booleano equivalente a: $'
buffer            DB 10                                                                     ; Tamaño máximo del buffer (5 caracteres + 1 byte para la longitud real)
                DB 0                                                                      ; Número de caracteres leídos (se llenará automáticamente)
numero            DB 10 dup(0)                                                              ; Espacio para los caracteres ingresados y el terminador
numero_convertido DW 0
resultado_ascii   DB 10 dup('$')                                                            ; Buffer para el número convertido a texto

data endS

code segment
            assume cs:code, ds:data, ss:pile'''

    def open(self):
        self.file = open(self.filename, self.mode, encoding='utf-8')

    def write(self, text):
        #Escribe un string en el archivo.
        
        if self.file is not None:
            self.file.write(text)
        else:
            raise ValueError("El archivo no está abierto. Usa el método open() primero.")

    def close(self):
        if self.file is not None:
            self.file.close()
            self.file = None