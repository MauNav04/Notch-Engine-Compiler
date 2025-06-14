from scanner.scanner_main import scanner as sc
from scanner import tokens
from parser.parser_main import parser as pc

# Here we are going to design the command line interface that we will be
# using to interact with the user

front_page = ''' 
Instituto Tecnológico de Costa Rica
Ingeniería en Computación
Compiladores e intérpretes
Semestre I 2025
Etapa 4
Autor: 
Mauro Navarro Obando

==============================================
Compilador para archivos Notch Engine [.ne]
==============================================
'''


cli_banner = '''
Comandos:
    1. Para inicializar el scanner
    2. Para finalizar el compilador
    3. Para recibir el siguiente token DemeToken()
    4. Para aceptar el token TomeToken()
    5. Escanear todo el archivo
    6. Iniciar Parseo
'''

def main():

    print(front_page) # Here we show the banner with the explanation on how to interact
    
    while(True):
        
        print(cli_banner) # Where it requests input from the user

        response = input()

        match response:
            case "1":
                print("Ingrese el directorio del archivo")
                path = input()                              # Request the path from the user
                newScanner = sc(path)                       # We instance the Scanner as a new object
                newScanner.InicializarScanner()             # In this function we check if the path is valid and it loads it

            case "2":
                print("Finalizando el compilador...")
                newScanner.FinalizarScanner()
            case "3":
                print("El token actual es: " + newScanner.DemeToken().get('familia') )
                # It reads the token and it identifies what familiy belongs to
                # then it shows to the user the family code, token, translated
                # value, line and column, and error line if necessary
            case "4":
                print("Aceptamos el token")
                newScanner.TomeToken()
                # Here we decide if the token is going to be accepted or not
            case "5":
                # This is a case to scan the whole file at once and accept it

                token = ""
                while(token!="EOF"):
                    token = newScanner.DemeToken().get('familia')
                    print(f'El token actual es: {token}')
                    newScanner.TomeToken()

                print(newScanner.result)
                newScanner.getStats()
                newScanner.WallOfBricks()
            
            case "6":
                
                newParser = pc(newScanner.result)

            case _:
                print("Opción no válida. Por favor, ingrese una opción válida.")

if __name__ == "__main__":
    main()