class LabelGeneraator:
    def __init__(self, base="Et"):
        self.base = base
        self.contador = 0
    
    def obtener_etiqueta(self):
        etiqueta = f"{self.base}{self.contador:05}"
        self.contador += 1
        return etiqueta