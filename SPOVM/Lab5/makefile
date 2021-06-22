all:
	clear
	gcc -fPIC -c lib.c
	gcc -shared  -nostartfiles -o lib.so lib.o -lrt
	gcc -g -c main.c
	gcc -g -rdynamic main.o  -o main -ldl -lpthread
	clear
	./main
	
