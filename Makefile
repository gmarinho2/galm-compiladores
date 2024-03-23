all:
	mkdir -p output
	lex -o output/lexico.yy.c src/lexico.l
	yacc -d src/sintatico.y -o output/parser.tab.c -Wcounterexamples
	g++ -o output/compiler.exe output/parser.tab.c -ll
	./output/compiler.exe < examples/main.galm

compile:
	mkdir -p output
	lex -o output/lexico.yy.c src/lexico.l
	yacc -d src/sintatico.y -o output/parser.tab.c -Wcounterexamples
	g++ -o output/compiler.exe output/parser.tab.c -ll

scanner:
	mkdir -p output
	lex -o output/lexico.yy.c src/lexico.l
	gcc -o output/scanner.out output/lexico.yy.c -lfl
	./output/scanner.out