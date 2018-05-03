#include <stdio.h>
#include <sys/file.h>
#include <sys/types.h>
#include <unistd.h>
#include "Semaforo.c"
struct semaphore sem;

void  main(void) {
        int i;
        int n;
        int ret;
        sem_init(&sem,1);
        FILE * f = fopen("number.txt","r+");
        printf("AHORA ES MIO!\n");
        for (i=0; i < 10000; i++) {
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
        sem_close(&sem);

        fclose(f);
}
