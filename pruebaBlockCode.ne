$$ No fuciona ya que un bloque de código no puede estar fuera de una función o ritual

WorldName  numberGuess :

Bedrock  $$ Aqui tenemos las constantes

ResourcePack $$ En esta seccion se crea tipos
    Anvil example -> Stack;
    Anvil value -> Spider;

Inventory $$ Declaracion de variables
    Stack guess = 20
    Stack userValue = 0

Recipe
    PolloCrudo

        target userValue is guess craft hit 
            dropperSpider ("Correct") ;
            creeper;
        miss 
            dropperSpider ("Incorrect");
    
    PolloAsado

worldSave 