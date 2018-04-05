#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <fcntl.h>

#include <string.h> 
#include <sys/wait.h>



int main( int argc, char *argv[] )
{
  printf("%s\n",argv[0]);
  printf("%s\n",argv[1]);
  printf("%s\n",argv[2]); //operador del medio
  printf("%s\n",argv[3]);

  if(strcmp(argv[2],";")==0){
    if(fork()==0){
      execlp(argv[1],argv[1],NULL);
      printf("se acaba de ejecutar el comando 1\n");
      }else{
        wait(0);
        if(fork()==0){
          execlp(argv[3],argv[3],NULL);
          printf("se acaba de ejecutar el comando 2\n");
          }else{
            wait(0);
            }
        }
    }
  if(strcmp(argv[2],"|")==0){
    if(fork()==0){
      execlp(argv[1],argv[1],NULL);
      printf("se acaba de ejecutar el comando 1\n");
      }else{
        if(fork()==0){
          execlp(argv[3],argv[3],NULL);
          printf("se acaba de ejecutar el comando 2\n");
          }else{
            wait(0);
            wait(0);
            }
        }
    }
    exit(0);
}

