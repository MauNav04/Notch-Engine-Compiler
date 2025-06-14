from parser.ParsingTable import ParsingTable
from parser.Rules import Rules
from parser.Stack import Stack
from parser.Terminals import Terminals
from parser.Buffer import Buffer
from parser.symbolTable import SymbolTable
from parser.FileHandler import FileHandler

# Requirements
# Parsing table, Terminals, Buffer for the input, Stack, Definition of the rules

class parser:
    def __init__(self, result):

        tokenList = []
        for item in result:
            tokenList.append(item)

        # The token list attribute, contains all the tokens as dictionaries, each token contains family,lexema,ln#,startCol#,endCol#
        self.tokenList = tokenList
        
        print(f"\n RESULT: {result} \n")
        
        self.ParsingTable = ParsingTable()
        self.pTable = self.ParsingTable.getTable()
        print(f"ptable: {self.pTable}")
        
        self.Rules = Rules()
        self.rules = self.Rules.getRules()
        print(f"rules: {self.rules}")
        
        
        self.Terminals = Terminals()
        self.terminals = self.Terminals.getTerminals()
        print(f"terminals: {self.terminals}")
        
        self.Buffer = Buffer()
        
        self.Stack = Stack()
        
        # [PENDING] The buffer should be initialized automatically 
        self.Buffer.load([])
        
        #Initilize the stack
        self.firstRule = self.rules[0]
        self.Stack.stack_insertion(self.firstRule)
        self.Stack.show()
        
        #init buffer
        self.Buffer.calcBufferLoads(self.tokenList)
        self.firstBufferLoad()
        
        #get the output file ready
        self.ResFileHandler = FileHandler("results/ASMCompiledFile.txt")
        
        #get the literalPool file ready
        self.PLTFileHandler = FileHandler("results/PoolLiteral.plt")
        
        
        self.loop()

    def loop(self):
        # We need to compare the first elements in the stack and buffer
        currentBElement = self.Buffer.current()
        currentStackElement = self.Stack.peek()

        print(f"\n[Loop]")
        print(f"Len: {self.Buffer.length()}")
        
        while self.Stack.size() > 0:
            print(f"Buffer current: {currentBElement}")
            print(f"Stack top: {currentStackElement}")
            
            # Check if the element on the stack is a terminal or a non terminal
            
            #If the  top is a non terminal we need to pop curr and push new rule
            if currentStackElement[0] == '<':
                # WARNING: Here we suppose that the terminal given by the user is
                # properly written and it is in the Terminals list, exceptions must be handeled properly
                
                print(f"pRule row: {self.pTable[currentStackElement]}")
                index = self.terminals.index(currentBElement.get("familia"))
                parsingRuleIndex = self.pTable[currentStackElement][index]
                print(f"pRule index: {parsingRuleIndex}")
                
                if parsingRuleIndex < 1: 
                    #ERROR case if there is no rule after reading a non terminal
                    print(f"Syntax Error: {currentBElement.get("familia")} is not supposed to be after {self.Stack.peekPopped()}")
                    break
                else:
                    parsingRule = self.rules[parsingRuleIndex]
                    print(f"pRule {parsingRule}")
                    self.nonTerminalSubsuitution(parsingRule)
                
            else:
                 #We check if it the top of the stack reads a semantic symbol
                if currentStackElement[0] == '#':
                        match currentStackElement:
                            
                            # ===================================
                            # SEMANTIC SYMBOLS
                            # ===================================
                            
                            case "#crearTSG":
                                print("=============\n      Creating Global Symbol table ...\n=============")
                                self.GlobalSymbolTable = SymbolTable()
                                self.GlobalSymbolTable.display()                                
                                self.Stack.pop()
                                self.Stack.show()
                            case "#rit1":
                                if self.GlobalSymbolTable.inFunction:
                                    print("Error: No se puede definir una función dentro otra.")
                                else:
                                    self.GlobalSymbolTable.inFunction = True
                                    print("[CTXT]: inFunction = TRUE")
                                    self.Stack.pop()
                                    self.Stack.show()
                            case "#crearTSL":
                                if self.GlobalSymbolTable.inFunction:
                                    print("=============\n      Creating Local Symbol table ...\n=============")
                                    self.LocalSymbolTable = SymbolTable()                               
                                    self.Stack.pop()
                                    self.Stack.show()
                                else:
                                    self.Stack.pop()
                                    self.Stack.show()
                            case "#eliminarTSL":
                                if self.GlobalSymbolTable.inFunction:
                                    self.LocalSymbolTable.destroyTb()
                                    print("The Local Symbol Table has been deleted")
                                    self.Stack.pop()
                                else:
                                    self.Stack.pop()
                                    self.Stack.show()
                                
                            case "#rit2":
                                self.GlobalSymbolTable.inFunction = False
                                print("[CTXT]: inFunction = False \n")
                                self.Stack.pop()
                                    
                            case "#eliminarTSG":
                                self.GlobalSymbolTable.destroyTb()
                                print("The Global Symbol Table has been deleted")
                                self.Stack.pop()
                                if self.Stack.size() == 0:
                                    print("\n ! The input has been parsed succesfully !")
                            
                            # Marks the beggining of a Constant section        
                            case "#const1":
                                self.GlobalSymbolTable.inConstSect = True
                                print("[CTXT]: inConstSect = True \n")
                                self.Stack.pop()
                            
                            # Marks the end of a constant section
                            case "#const2":
                                if self.GlobalSymbolTable.inConstSect == True:
                                    self.GlobalSymbolTable.inConstSect = False
                                    print("[CTXT]: inConstSect = False \n")
                                    self.Stack.pop()
                                else:
                                    print("[CTXT]: A ConstSection wasn't closed properly \n")
                              
                            # Loads a constant to the table if requirements are fullfilled        
                            case "#const3":
                                if self.GlobalSymbolTable.inConstSect == True:
                                    self.GlobalSymbolTable.insert(currentBElement.get("lexema"), "C")
                                    self.GlobalSymbolTable.currIdentifier = currentBElement.get("lexema")
                                    print(f"[CTXT]: Constant \"{self.GlobalSymbolTable.currIdentifier}\" Inserted In the ST \n")
                                    self.GlobalSymbolTable.directModify("type", self.GlobalSymbolTable.typeTemp)
                                    self.GlobalSymbolTable.display()
                                    self.Stack.pop()
                                else:
                                    print("[ERROR]: Constant declared outside of a constant section \n")
                                    
                            case "#const4":
                                if self.GlobalSymbolTable.inConstSect == True:
                                    self.GlobalSymbolTable.directModify("value", currentBElement.get("lexema"))
                                    print(f"[CTXT]: Constant \"{self.GlobalSymbolTable.currIdentifier}\" Modified In the ST \n")
                                    self.GlobalSymbolTable.display()
                                    self.Stack.pop()
                                else:
                                    print("[ERROR]: Constant declared outside of a constant section \n")
                            
                            # Marks the beggining of a Variable section        
                            case "#var1":
                                self.GlobalSymbolTable.inVarSect = True
                                print("[CTXT]: inVarSect = True \n")
                                self.Stack.pop()
                            
                            # Marks the end of a Variable section
                            case "#var2":
                                if self.GlobalSymbolTable.inVarSect == True:
                                    self.GlobalSymbolTable.inVarSect = False
                                    print("[CTXT]: inVarSect = False \n")
                                    self.Stack.pop()
                                else:
                                    print("[CTXT]: A VarSection wasn't closed properly \n")
                            
                            # Loads a variable into the table if requirements are fullfilled        
                            case "#var3":
                                if self.GlobalSymbolTable.inVarSect == True:
                                    self.GlobalSymbolTable.insert(currentBElement.get("lexema"), "V")
                                    self.GlobalSymbolTable.currIdentifier = currentBElement.get("lexema")
                                    print(f"[CTXT]: Variable \"{self.GlobalSymbolTable.currIdentifier}\" Inserted In the ST \n")
                                    self.GlobalSymbolTable.directModify("type", self.GlobalSymbolTable.typeTemp)
                                    self.GlobalSymbolTable.display()
                                    self.Stack.pop()
                                else:
                                    print("[ERROR]: Constant declared outside of a constant section \n")
                            
                            case "#var4":
                                if self.GlobalSymbolTable.inVarSect == True:
                                    self.GlobalSymbolTable.directModify("value", currentBElement.get("lexema"))
                                    print(f"[CTXT]: Variable \"{self.GlobalSymbolTable.currIdentifier}\" Modified In the ST \n")
                                    self.GlobalSymbolTable.display()
                                    self.Stack.pop()
                                else:
                                    print("[ERROR]: Variable declared outside of a constant section \n")
                            
                            case "#exp1":
                                if (self.GlobalSymbolTable.inFunction == False):
                                    #print("[ERROR]: Expresión declarada fuera de una rutina \n")
                                    #break
                                    self.Stack.pop()
                                else:
                                    self.Stack.pop()
                            
                            case "#checkExist":
                                if (self.GlobalSymbolTable.contains(currentBElement.get("lexema"))):
                                    self.Stack.pop()
                                else:
                                    print(f"[ERROR]: Identificador inválido - {currentBElement.get("lexema")} no se encuentra declarado dentro del progrma. \n")
                                    break
                                
                            # References the type in a temporary variable so that it can be loaded later 
                            case "#type1":
                                self.GlobalSymbolTable.typeTemp = currentBElement.get("familia")
                                self.Stack.pop()
                                
                            # ===================================
                            # CODE GENERATION SYMBOLS
                            # ===================================
                            
                            case "#genOF":
                                self.ResFileHandler.open()
                                self.Stack.pop()

                            case "#slice1":
                                self.ResFileHandler.write(f"{self.ResFileHandler.prop1}")
                                self.Stack.pop()
                                
                            case "#genPLT":
                                self.PLTFileHandler.open()
                                self.Stack.pop()
                                
                            case "#closeOF":
                                self.ResFileHandler.close()
                                self.Stack.pop()
                                
                            case "#closePLT":
                                self.PLTFileHandler.close()
                                self.Stack.pop()
                            
                            case _: # basically this is default
                                print("\n [WARNING]: Semantic Symbol NOT recognized \n")
                                break
                else:
                    #if top of the stack contains a terminal, compare with the first element in the buffer
                    if currentBElement.get("familia") == currentStackElement:
                        print("Match found!")
                        print(self.Buffer)
                        buffNext = self.Buffer.next()
                        if buffNext == None:
                            self.nextBufferLoad()
                        
                        self.Stack.pop()
                        self.Stack.show()
                        currentBElement = self.Buffer.current()
                            
                        if self.Stack.size() == 0:
                            print("\n ! The input has been parsed succesfully !")
                    else:                    
                        #ERROR case if there is no rule after reading a terminal
                        print(f"Syntax Error: {currentBElement.get("familia")} is not supposed to be after {self.Stack.peekPopped()}")
                        break
                    
            currentStackElement = self.Stack.peek()
            print("\n")
    
    def nonTerminalSubsuitution (self, rulesRightSide):
        self.Stack.pop()
        print(self.Stack.show())
        self.Stack.stack_insertion(rulesRightSide)
        print(self.Stack.show())
        return
    
    def firstBufferLoad (self):
        if len(self.tokenList) == 0:
            print("There is no program to parse. Please introduce a program.")
        else:
            self.Buffer.load(self.tokenList)
        
    def nextBufferLoad (self):
        print("\n ==New Load==")
        print(f"Loads: {self.Buffer.getBufferLoads()}")
        print(f"last Load: {self.Buffer.getCurrentLoad()}")
        
        # Lets suppose there is a load program and we already checked if the program is less than eight instructions
        self.Buffer.incCurrentLoad()
        print(f"current Load: {self.Buffer.getCurrentLoad()}")
        self.tokenList = self.tokenList[8:]
        print(f"updated Us Input: {self.tokenList}")
        self.Buffer.flush()
        self.Buffer.load(self.tokenList)
        print(f"updated {self.Buffer}")