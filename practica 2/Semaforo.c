#include <sys/types.h>
      #include <sys/ipc.h>
      #include <sys/sem.h>


typedef struct semaphore{
  int counter;
  int key;
}s;

union Semun {
               int              val;    /* Value for SETVAL */
               struct semid_ds *buf;    /* Buffer for IPC_STAT, IPC_SET */
               unsigned short  *array;  /* Array for GETALL, SETALL */
               struct seminfo  *__buf;  /* Buffer for IPC_INFO
                                           (Linux-specific) */
           }semun;

struct sembuf buffer;

int sem_init(struct semaphore * s, int init_value)
{
  s->key=semget(IPC_PRIVATE, 1,0666|IPC_CREAT);
  if(s->key>=0){
    semun.val=init_value;
    semctl(s->key, 0,SETVAL,semun);
  }else{
    printf("ERROR EN CREACION DE SEMAFORO\n" );
  }
  return 0;
}

int sem_wait(struct semaphore * s)
{

  buffer.sem_num=0;
  buffer.sem_op=-1;
  buffer.sem_flg=0;
  semop(s->key,&buffer,1);
}

int sem_signal(struct semaphore * s)
 {
   buffer.sem_num=0;
   buffer.sem_op=1;
   buffer.sem_flg=0;
   semop(s->key,&buffer,1);
 }

int sem_close(struct semaphore * s)
{
  //printf("cierra sem\n" );
semctl(s->key, 0,IPC_RMID);
}
