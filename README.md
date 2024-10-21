# Linguagem Galm
Compilador da linguagem **Galm**. Feito para a disciplina de Compiladores da UFRRJ.

# Declaração de variáveis

Para declarar uma variável, é necessário que use uma das palavras chaves propostas pela linguagem: const ou let

Sendo assim, ao usar a palavra chave **const**, a variável é definida como imutável e, após sua inicialização, não é mais permitido alteração de seu valor. Por outro lado, ao usar **let** a variável não possui a característica de ser imutável.

Vejamos um exemplo:

```ts
// Declaração de teste como constante
const teste1: number = 1

// Declaração de teste como constante (com inferência de tipo)
const teste2 = 1

// Declaração de teste
let teste3: number = 1

// Declaração de teste (com inferência de tipo)
let teste4 = 1
```

# Tipos de Dados

* Number (números reais e inteiros)

O suporte para números binários, octais e hexadecimais também estão inclusos:

```ts
let binary = 0b1010 // 10
let octal = 0o12 // 10
let hex = 0xA // 10
```

* Boolean (valores booleanos true e false)
* Char (caracteres)

# Operadores Aritméticos

* Operador de Soma (+)

O operador de soma irá fazer a soma de dois operandos, sendo que, caso um dos dois operando seja real, o retorno será um número na sua representação em ponto flutuante.

```ts
let a = 1 + 1 // retornará 2
```

* Operador de Subtração (-)

O operador de subtração irá fazer a subtração de dois operandos, sendo que, caso um dos dois operando seja real, o retorno será um número na sua representação em ponto flutuante.

```ts
let a = 1 + 1 // retornará 2
```

* Operador de Multiplicação (*)

O operador de multiplicação irá fazer a multiplicar de dois operandos, sendo que, caso um dos dois operando seja real, o retorno será um número na sua representação em ponto flutuante.

```ts
let a = 1 + 1 // retornará 2
```

* Operador de Divisão Floating-point (/)

```ts
let a = 3 / 2 // retornará 1.5
```

* Operador de Divisão Inteira (//)

O operador de divisão inteira retorna o piso da divisão de dois números inteiros.

```ts
let a = 3 / 2 // retornará 1
```

* Operador módulo (%)

O operador módulo retorna o resto da divisão de dois números inteiros.

```ts
let a = 3 % 2 // retornará 1
```

* Operador absolute (||)

O operador absolute retorna o valor absoluto de um número.

```ts
let a = |-3| // retornará 3
```

# Operadores booleanos

* Operador de E Lógico (and)

O operador **and** retornará um resultado booleano (consideramos valores booleanos como inteiros, sendo 0 para falso e 1 para verdadeiro).
Dados operandso X e Y, o resultado de X and Y retornará *verdadeiro* somente nos casos que X e Y forem considerados valores verdadeiros, para qualquer outro caso o resultado será falso.

```ts
let a = true and true   // retornará verdadeiro
let b = false and true  // retornará falso
let c = true and false  // retornará falso
let d = false and false // retornará falso
```

* Operador de OU Lógico (or)

No mesmo sentido, o **or** também retornará um resultado booleano. Sendo que, dados operando X e Y, o resultado de X and Y retornará *verdadeiro* para qualquer caso que pelo menos um dos dois operandos for considerado um valor verdadeiro, caso contrário o resultado será falso.

```ts
let a = true or true   // retornará verdadeiro
let b = false or true  // retornará verdadeiro
let c = true or false  // retornará verdadeiro
let d = false or false // retornará falso
```
* Operador de Negação Lógica (!)

O operador not faz o papel da negação lógica, retornando o valor lógico negado.

```ts
let a = true
let b = !t1    // t2 será false
```
Além disso, vale dizer que os operadores **and** e **or** não são estritamente booleanos, então, operandos de qualquer tipo serão válidos e eles seram convertidos para booleanos.
Exemplo básico é o caso de dois operandos numéricos:

```ts
let a = 1 and 1 // retornará o resultado de true and true
let b = 1 or 1 // retornará o resultado de true or true
```

# Operadores Bitwise
O operador Bit a Bit é utilizado para realizar operações de manipulação de bits em números inteiros.

* AND Bit-a-Bit (&)

Retorna um 1 em cada posição para a qual os bits correspondentes de ambos os operandos são 1.

```ts
let a = 5 & 6; // resultado: 4
```

* OR Bit-a-Bit (|)

Retorna um 1 em cada posição para a qual há pelo menos um 1 nos bits correspondentes de um ou ambos os operandos.

```ts
let a = 1 | 2; // resultado: 3
```
* XOR Bit-a-Bit (^)

Retorna um 1 em cada posição para a qual há um 1 em exatamente um dos bits correspondentes de um ou ambos os operandos.

```ts
let a = 1 ^ 3; // resultado: 2
```

* NOT Bit-a-Bit (~)

Inverte todos os bits de um número.

```ts
let a = ~1; // resultado: -2
```

* Left Shift (<<)

Desloca os bits de um número para a esquerda, preenchendo os bits à direita com zeros.

```ts
let a = 1 << 2; // resultado: 4
```

* Right Shift (>>)

Desloca os bits de um número para a direita, preenchendo os bits à esquerda com zeros.

```ts
let a = 4 >> 1; // resultado: 2
```

# Operadores de Comparação

* Igual (==)

O operador de igualdade compara dois valores e retorna verdadeiro se eles forem iguais, caso contrário, retorna falso.

```ts
let a = 1 == 1 // retornará verdadeiro
```

* Diferente (!=)

O operador de diferença compara dois valores e retorna verdadeiro se eles forem diferentes, caso contrário, retorna falso.

```ts
let a = 1 != 2 // retornará verdadeiro
```

* Maior que (>)

O operador de maior que compara dois valores e retorna verdadeiro se o primeiro valor for maior que o segundo, caso contrário, retorna falso.

```ts
let a = 2 > 1 // retornará verdadeiro
```

* Menor que (<)

O operador de menor que compara dois valores e retorna verdadeiro se o primeiro valor for menor que o segundo, caso contrário, retorna falso.

```ts
let a = 1 < 2 // retornará verdadeiro
```

* Maior ou igual que (>=)

O operador de maior ou igual que compara dois valores e retorna verdadeiro se o primeiro valor for maior ou igual ao segundo, caso contrário, retorna falso.

```ts
let a = 2 >= 1 // retornará verdadeiro
let b = 1 >= 1 // retornará verdadeiro
```

* Menor ou igual que (<=)

O operador de menor ou igual que compara dois valores e retorna verdadeiro se o primeiro valor for menor ou igual ao segundo, caso contrário, retorna falso.

```ts
let a = 1 <= 2 // retornará verdadeiro
let b = 1 <= 1 // retornará verdadeiro
```

# Conversão Explícita de Tipo

Para fazer conversão de tipo, é necessário somente faz um cast (igual outras linguagens de programação like C).
Por exemplo:

Iremos criar uma variável "teste" do tipo number, mas o expressão que dará o valor a declaração dessa variável é booleano, para criarmos precisamos que o valor seja convertido para number. Podemos fazer isso como o exemplo abaixo:

```ts
let g: number = (number) true
```

Dessa forma, true será convertido para um valor numérico (no caso dos valores booleanos, é 1 para true e 0 para false). 

# Tabela de Conversão de Tipo

Lê-se da seguinte forma:

Para cada linha i e coluna j, T[i][j] = valor resultado da conversão.
Caso o valor resultado esteja sendo representado por um **X** significa que a conversão não é aceita pela linguagem.

|\-              |   Number           | Boolean      | Character|
|    :------:    |   :------:         | :------:     | :------: |
|**Number**      |   Number           | Boolean      | Character|
|**Boolean**     |   Number (0 ou 1)  | Boolean      | **X**    |
|**Character**   |   Number           | Boolean      | Character|

# Testes

Foi projetado um ambiente de testes para que possamos fazer testes de regressão.
A principal ideia é colocar alguns testes gerais em relação aos comportamentos do nosso compilador e a, cada alteração, verificar se nenhum comportamente quebrou por erro nosso.

Sendo assim, criamos a pasta examples que possui exemplos de códigos em **GALM** e a pasta *\_\_tests\_\_* possui um programa em Python que executa **TODOS** os exemplos (compilando o YACC/LEX, usando o compiler para criar o código intermediário e, por fim, executando o código para saber se tudo ocorreu da forma que deveria).
