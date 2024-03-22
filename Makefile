compile:
	clear
	lex -o output/lex.yy.c src/lexical.l

scanner:
	lex -o output/lex.yy.c src/lexical.l
	gcc -o output/scanner.out output/lex.yy.c -lfl
	./output/scanner.out