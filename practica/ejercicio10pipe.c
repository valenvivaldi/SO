//https://www.programacion.com.py/escritorio/c/pipes-en-c-linux
//https://www.driverlandia.com/programacion-c-avanzada-forks-pipes-y-como-comunicar-programa-padre-con-hijo/
#include <stdlib.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h> 
#include <sys/wait.h>
#define SIZE 512
 
int main( int argc, char **argv )
{
  pid_t pid;
  int pipePaH[2], pipeHaP[2], readbytes;
  char buffer[SIZE]="";
 
  pipe( pipePaH );
  pipe( pipeHaP );

  if ( (pid=fork()) == 0 )
  { // proceso hijo

	close(pipePaH[1]); // Cerramos el canal de escritura de Padre -> Hijo (recuerda que estamos en el hijo!)		
	close(pipeHaP[0]); // Cerramos el canal de lectura de Hijo -> Padre (recuerda que estamos en el hijo!)

    //Lee msj del pipe
    while( (readbytes=read( pipePaH[0], buffer, SIZE ) ) > 0)
		  // write( 1, buffer, readbytes );
    close( pipePaH[0] );

    printf("Soy el hijo (pid: %i) y recibi: %s\n",pid,buffer );
 
    // **********invierto cadena**********
    int c_long = strlen(buffer);
    char cad [20];
    char auxiliar [c_long];
 
    for (int i=0; i<= c_long; i++){
      auxiliar[i]=  buffer[c_long-i-1];
    }
    //************************************

    printf("Soy el hijo (pid: %i) y envio: %s\n",pid,auxiliar);
    //Envia menseje por el pipe 
    write( pipeHaP[1], auxiliar, strlen( buffer ) );
    close( pipeHaP[1] );
  }
  else
  { // proceso padre

    close( pipePaH[0] ); /* cerramos el lado de lectura del pipe */
    close( pipeHaP[1] ); /* cerramos el lado de escritura del pipe */

		strcpy( buffer, "HOLA MUNDO" );		
    printf("\nSoy padre (pid:%i) y envio: %s\n",getpid(),buffer );

    //Envia msj por el  pipe
    write( pipePaH[1], buffer, strlen( buffer ) );
    close( pipePaH[1]);

    //Lee msj del pipe
    while( (readbytes=read( pipeHaP[0], buffer, SIZE )) > 0)
		  //write( 1, buffer, readbytes );
    close( pipeHaP[0]);
    printf("Soy padre (pid:%i) y recibi: %s\n\n",getpid(),buffer);
  }
  wait(0);
  exit( 0 );
}