#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include "MutexB.c"
#include "Semaforo.c"
#define N_THREADS 100
int n = 0;
int lockflag=0;
struct semaphore sem;

void *task(void *arg) {
  int i,j;

  for (i=0; i<10; i++){
    for (j=0; j<10; j++){
      sem_wait(&sem);
      //lock(&lockflag);
      n++;
      //unlock(&lockflag);
      sem_signal(&sem);
    }
  }
  sem_close(&sem);
  return NULL;
}

int main() {
  sem_init(&sem,1);
  pthread_t t[N_THREADS];
  int i;

  for (i=0; i<N_THREADS; i++)
    if ( pthread_create(&(t[i]), NULL, task, NULL) != 0 ) {
      printf("pthread_create() error, i=%d\n",i);
      exit(-1);
    }

  for (i=0; i<N_THREADS; i++)
    pthread_join(t[i],NULL);

  printf("n=%d\n", n);
}
