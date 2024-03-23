compile:
	mkdir -p output
	lex -o output/lexico.yy.c src/lexico.l
	yacc -d src/sintatica.y -o output/parser.tab.c -Wcounterexamples
	g++ -o glf output/parser.tab.c -ll

scanner:
	mkdir -p output
	lex -o output/lexico.yy.c src/lexico.l
	gcc -o output/scanner.out output/lexico.yy.c -lfl
	./output/scanner.out