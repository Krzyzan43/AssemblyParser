# AssemblyParser

This is a program that reads assemlby instructions, checks if they conain any errors and writes them back in reversed order.

# Running
  Unfortunately, code is too complex for online assembly runners. The easiest way to run it is from 'MARS MIPS Simulator', which can be downloaded from https://courses.missouristate.edu/kenvollmar/mars/. In order to ru the program, you just need to open the assemblyParser.asm file in mars and run it.

# Supported operations:
  - ADD register1 register2 register3
  - ADDI register1 register2 someNumber
  - J label
  - NOOP
  - MULT register1 register2
  - JR register
  - JAL label

Register must be in format "$register_num", where register_num is a number from 0-31.  
Label can consist of lowercase and uppercase letters.  
If user enters an instruction that doesn't exist (such as DIV), or enters wrong number of arguments for a given operation, or any argument is invalid (for example $54 as register), an error message will appear and user will be asked to type instruction again.

# Example
This is an example of how program runs:
```
Podaj liczbe instrukcji (1-5): 
4

Podaj instrukcje: 
ADD $0 $30 $25

Podaj instrukcje: 
ADD $45 $50 $55   // Register too big

Nieprawidlowa instrukcja 

Podaj instrukcje: 
J someLabel

Podaj instrukcje: 
JAL someInvalid43$Label  // Illegal characters in label name

Nieprawidlowa instrukcja 

Podaj instrukcje: 
NOOP

Podaj instrukcje: 
ADDI $5 $3 243



Pamiec zaalokowana na stosie: 
60

--------------------------------------------
ADDI
$5
$3
243
--------------------------------------------
NOOP
--------------------------------------------
J
someLabel
--------------------------------------------
ADD
$0
$30
$25
```
