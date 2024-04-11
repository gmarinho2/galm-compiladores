# Compilador Galm
Compilador da linguagem Galm feito para a disciplina de Compiladores da UFRRJ.

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
* Boolean (valores booleanos true e false)
* Char (caracteres)

# Operadores Aritméticos

* Operador de Soma (+)

O operador

# Operadores booleanos

* Operador de E Lógico (and)

O operador **and** retornará um resultado booleano (consideramos valores booleanos como inteiros, sendo 0 para falso e 1 para verdadeiro).
Dados operandso X e Y, o resultado de X and Y retornará *verdadeiro* somente nos casos que X e Y forem considerados valores verdadeiros, para qualquer outro caso o resultado será falso.

```ts
let t1 = true and true   // retornará verdadeiro
let t2 = false and true  // retornará falso
let t3 = true and false  // retornará falso
let t4 = false and false // retornará falso
```

* Operador de OU Lógico (or)

No mesmo sentido, o **or** também retornará um resultado booleano. Sendo que, dados operando X e Y, o resultado de X and Y retornará *verdadeiro* para qualquer caso que pelo menos um dos dois operandos for considerado um valor verdadeiro, caso contrário o resultado será falso.

```ts
let t1 = true or true   // retornará verdadeiro
let t2 = false or true  // retornará verdadeiro
let t3 = true or false  // retornará verdadeiro
let t4 = false or false // retornará falso
```

Além disso, vale dizer que os operadores **and** e **or** não são estritamente booleanos, então, operandos de qualquer tipo serão válidos e eles seram convertidos para booleanos.
Exemplo básico é o caso de dois operandos numéricos:

```ts
let t1 = 1 and 1
let t2 = 1 or 1
```

Caso os 

# Conversão Explícita de Tipo

Para fazer conversão de Tipo, é necessário somente faz um cast (igual outras linguagens de programação like C).
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

\-              |   Number           | Boolean      | Character
:------         |   :------:         | :------:     | :------:
**Number**      |   Number           | Boolean      | Character
**Boolean**     |   Number (0 ou 1)  | Boolean      | **X**
**Character**   |   Number           | Boolean      | Character

# Testes

Foi projetado um ambiente de testes para que possamos fazer testes de regressão.
A principal ideia é colocar alguns testes gerais em relação aos comportamentos do nosso compilador e a, cada alteração, verificar se nenhum comportamente quebrou por erro nosso.

Sendo assim, criamos a pasta examples que possui exemplos de códigos em **GALM** e a pasta *\_\_tests\_\_* possui um programa em Python que executa **TODOS** os exemplos (compilando o YACC/LEX, usando o compiler para criar o código intermediário e, por fim, executando o código para saber se tudo ocorreu da forma que deveria).