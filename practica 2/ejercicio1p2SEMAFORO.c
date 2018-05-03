#include <stdio.h>
#include <sys/file.h>
#include <sys/types.h>
#include <unistd.h>
#include "Semaforo.c"
#include <sys/wait.h>
struct semaphore sem;

void  main(void) {
        int i;
        int n;
        int ret;
        int pid;
        int aaaaa =10;
        sem_init(&sem,1);
        FILE * f = fopen("number.txt","r+");
        for(i=0;i<aaaaa;i++) {
          pid =fork();
          if(pid==0){break;}
        }
        if(pid==0){
          printf("soy un hijo y empiezo!");
          for (i=0; i < 10; i++) {
            //ret =flock(fileno(f),LOCK_EX);
            sem_wait(&sem);
            // if(i%100==0) {
            //         printf("el flock devolvio %d pid= %d\n",ret,getpid());
            // }                                                           //REGION CRITICA
            fscanf(f,"%d",&n);                                                  //    |
            rewind(f);                                                          //    |
            fprintf(f,"%d",++n);                                                //    |
            rewind(f);                                                          //REGION CRITICA
            sem_signal(&sem);

            // flock(fileno(f),LOCK_UN);
          }
        }
        fclose(f);
        if(pid!=0){
          for(i=0;i<aaaaa;i++) {
            wait(0);
          }

          sem_close(&sem);
        }

}
