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
    include PoolLiteral.plt

    indice_plt        DB 0 ; Indice para saber por dónde se va llenando el pool de literales

'''
            
        self.prop2 = '''
data endS

code segment
            assume cs:code, ds:data, ss:pile'''

        self.prop3 = '''
code endS
end main'''
            
    def open(self):
        self.file = open(self.filename, self.mode, encoding='utf-8')

    def write(self, text):        
        if self.file is not None:
            self.file.write(text)
        else:
            raise ValueError("El archivo no está abierto. Usa el método open() primero.")

    def close(self):
        if self.file is not None:
            self.file.close()
            self.file = None