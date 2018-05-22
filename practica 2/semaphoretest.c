//test that executes the scheduler with multilevel table. 
//If it has aging ends, if not it stays in infinite cycles.
#include "types.h"
#include "stat.h"
#include "user.h"
static int l = 0;

void
semaphoretest(void)
{
  printf(1, "semaphoretest Test\n");
  int pid1,pid2,pid3;
  int semempty =  semget(-1,0);
  int semfull =  semget(-1,5);
  int sembin =  semget(-1,1);
  pid1 = fork();
  if (pid1==0){ 
    int i;
    for(i=0;i<10;i++){
      sleep(40);
      semdown(semempty);
      semdown (sembin);
        l--;
        printf(1,"elemento consumido por consumidor 1. Cantidad Actual: %d\n", l);
      semup (sembin);
      semup(semfull);
    }
    //////////////////////////////////
    semdown (sembin);
      printf(1,"FIN CONSUMIDOR 1 %d\n", l);
    semup  (sembin);
    semfree(sembin);
    semfree(semfull);
    semfree(semempty);
  }
  else{
    pid2 = fork();
    if (pid2==0){
      int i;
      for(i=0;i<10;i++){
        sleep(30);
        semdown(semempty);
        semdown (sembin);
          l--;
          printf(1,"elemento consumido por consumidor 2. Cantidad Actual: %d\n", l);
        semup  (sembin);
        semup (semfull);
      }
      ///////////////////////////////////////
      semdown (sembin);
          printf(1,"FIN CONSUMIDOR 2 %d\n", l);
      semup  (sembin);      
      semfree(sembin);
      semfree(semfull);
      semfree(semempty);
    }
    else{
      pid3 = fork();
      if (pid3==0){
        int i;
        for(i=0;i<10;i++){
          sleep(40);
          semdown(semfull);
          semdown (sembin);
            l++;
            printf(1,"elemento producido por productor 1. Cantidad Actual: %d\n", l);
          semup  (sembin);
          semup(semempty);
        }
        semdown (sembin);
          printf(1,"FIN PRODUCTOR 1 %d\n", l);
        semup  (sembin);
        semfree(sembin);
        semfree(semfull);
        semfree(semempty);
      }
      else{
        int i;
        for(i=0;i<10;i++){
          sleep(10);
          semdown(semfull);
          semdown (sembin);
            l++;
            printf(1,"elemento producido por productor 2. Cantidad Actual: %d\n", l);
          semup (sembin);
          semup(semempty);
        }
        semdown (sembin);
          printf(1,"FIN PRODUCTOR 2 %d\n", l);
        semup  (sembin);
        semfree(sembin);
        semfree(semfull);
        semfree(semempty);
        wait();
        wait();
        wait();
      }
    }
  }  
}

int
main(void)
{
  semaphoretest();
  exit();
}