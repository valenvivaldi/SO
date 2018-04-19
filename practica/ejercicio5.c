/*
gcc ejercicio5.c -o ejercicio5.out; ./ejercicio5.out >f1.txt 2>f2.txt ; cat f1.txt f2.txt >f3.txt

compila, ejecuta redireccionando la salida estandar al archivo f1.txt y la salida estandar de errores a el archivo f2.txt

cat concatena los archivos y redirecciono la salida al archivo f3.txt





*/



int main() {
	write(1,"Hola \n",5);
	write(2,"mundo \n",6);
	return 0;
	}
