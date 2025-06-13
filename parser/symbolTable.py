class SymbolTable:
    def __init__(self):
        self._table = {}
        
        #Creacion de Flags y pilas para manejar las dinamicas de reconocimiento de contexto
        self.inFunction = False
        self.inVarSect = False
        self.inConstSect = False
        self.inProtoSect = False
        self.inRoutSect = False
        
        self.typeTemp = None
        self.currIdentifier = None
        
        #Type codifications
        self.generalData = {"name":None, "category":None}
        self.constOrVar = {"type":None,"val":None}
        
    def insert(self, lexema, category):
        match category:
            case 'C':
                self._table[lexema] = {"name":lexema, "category":category, "type":None, "value":None}
            case _:
                print("\n [WARNING]: Category NOT recognized \n")
            
        
    def contains(self, key):
        return key in self._table

    def getData(self, key):
        return self._table.get(key, None)

    def modify(self, key, attribute, value):
        self._table[key][attribute] = value
        
    def directModify(self, attribute, value):
        self._table[self.currIdentifier][attribute] = value

    def destroyTb(self):
        self._table.clear()
        del self._table
        
    def display(self):
        if not hasattr(self, '_table'):
            print("Symbol table has been destroyed.")
            return
        if not self._table:
            print("Symbol table is empty.")
            return
        print("Symbol Table Contents:")
        for key, value in self._table.items():
            print(f"{key}: {value}")