Alumno: Valentin Vivaldi

Se implemento una Planificacion mediante MLF en el SO xv6!

Ademas se agregó un campo mas a la estructura de proceso (proc): el campo priority que
especifica el nivel de prioridad en el cual se debe encolar el proceso cuando entre en
estado RUNNEABLE

AGING

Se implementó un sistema de incremento de prioridad mediante "aging", que consiste en aumentar
la prioridad a los procesos que pasen mucho tiempo en un nivel de prioridad sin ser
planificado

-Se agregó un campo a proc, llamado age que cuenta la "antiguedad" del proceso
(cantidad de tiempo que esta el proceso sin que lo planifiquen)
- se agregaron 3 macros al param.h :
    AGEFORSCALING  : la edad a la que se considera que el proceso esta viejo y
                      se le sube la prioridad

    TICKSFORAGING  : cada cuanos ticks se le suma 1 a la edad de los procesos que
                    estan RUNNABLE

    ACTIVATEAGING : este macro activa y desactiva el incremento de prioridad cuando
                    la edad llega a "AGEFORSCALING". si esta en 1, hace procdump,
                    ejecuta el aumento de prioridad y vuelve a hacer procdump para
                    poder visualizar el aumento de prioridad. si esta en 0 los procesos
                    envejeceran pero nunca subiran de prioridad.

- para visualizar se creo el test llamado "prioritytest", el cual crea 2 procesos que se
hacen setpriority(0) constantemente, para mantenerse en el nivel 0 de prioridad, 2 procesos
que se hacen setprioriy(2) constntemente y 2 procesos que solo ciclan sin hacer nada

activando y desactivando el aging mediante el macro se puede observar como desactivandolo
los 2 procesos que se hacen setpriority(0), evitan que el resto sea planificado.En cambio
al estar activado el aging, si bien estos 2 procesos siguen acaparando la cpu al ponerse
la maxima prioridad, los otros procesos mediante el aging tienen oportunidad para(
cada tanto) ser planificados

NOTAS:
- se agrego un campo mas a "proc", en el que se cuenta la cantidad de veces que
un proceso fue planificado, y poder ver en el procdump() cuantas veces se planificó
el cual fue modificado para mostrar tambien la prioridad y la edad

- Se adjuntaron 2 imagenes donde se puede observar el comportamiento del prioritytest
con el aging activado y desactivado
