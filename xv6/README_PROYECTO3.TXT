Alumno: Valentin Vivaldi

Se implementaron semaforos en el SO xv6!

Se creo un test llamado "semaphoretest", el cual toma un archivo y en cada produccion
le escribe "+1", de la misma manera se escribe "-1" cuando consume. Esto se escribe
en un archivo llamado "logProdCons" el cual se puede observar mediante el
comando "cat logProdCons"..


-Esto permite poder copiar el texto impreso en la pantalla
y (pegandolo en la calculadora) observar las producciones que no llegan a ser consumida
(esto en el caso de que se cierre el test antes de que finalice solo!)..



-Si se deja que el test finalice solo (en realidad, deja de producir
y se cuelga porque trata de seguir consumiendo), siempre deberia imprimir 0 ya que
el consumidor consume todas las producciones, vaciando el buffer.

El test tiene las siguientes constantes, que permiten modificar el comportamiento del
mismo :
- Cantidad de productores (cada uno es hijo del proceso padre)
- Cantidad de consumidores (cada uno es hijo del proceso padre)
- Cantidad de Producciones por productor (cuantos "+1" escribe cada hijo productor)
- Tamaño del buffer


Adicionalmente el programa imprime cada vez que ocurre una produccion y cada vez que
ocurre una cosumicion! Tambien avisa cuando un proceso que trata de producir o consumir se
duerme debido a que no puede hacer semdown del semaforo que precise!
