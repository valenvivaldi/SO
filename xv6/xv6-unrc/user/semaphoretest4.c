// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.
#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"
#include "memlayout.h"

#define N 1
#define CANTCONSUMIDORES 1
#define CANTPRODUCTORES 1



int cola[N];
int cantcola=0;

int ql;
int empty;
int full;

void
printf(int fd, char *s, ...)
{
  write(fd, s, strlen(s));
}



void
encolar (int nuevo)
{
  semdown(ql);
  if(cantcola==0){
    printf(1,"productor:encola en el indice0\n" );
  }
  if(cantcola==1){
    printf(1,"productor:encola en el indice 1\n" );
  }
  if(cantcola==2){
    printf(1,"productor:encola en el indice 2\n" );
  }
   cola[cantcola]=nuevo;

   cantcola++;
   if(cantcola==0){
     printf(1,"productor:aumente cantcola a 0\n" );
   }
   if(cantcola==1){
     printf(1,"productor:aumente cantcola a 1\n" );
   }
   if(cantcola==2){
     printf(1,"productor:aumente cantcola a 2\n" );
   }
  semup(ql);
}

int
desencolar()
{
   int res;
   int i;
  //int fd;
  semdown(ql);
  if(cantcola==0){
    printf(1,"desencola cuando la cola no tiene elementos\n" );
  }
  if(cantcola==1){
    printf(1,"desencola cuando la cola  tiene 1 elementos\n" );
  }
  if(cantcola==2){
    printf(1,"desencola cuando la cola  tiene 1 elementos\n" );
  }
   res =cola[0];
   cantcola--;
   for(i=0;i<cantcola;i++){
     cola[i]=cola[i+1];
   }
  // fd =open("archivo", O_CREATE|O_RDWR);
  // printf(fd, "1 \n", res);
  // close(fd);

  semup(ql);

   return res;
  return 0;
}


void
consumidor(void)
{
  for(;;) {
    semdown(full);
    printf(1,"RESTE UNO EN FULL\n");
    desencolar();
    printf(1,"SUME UNO EN EMPTY\n");
    printf(1,"-------\n");
    semup(empty);
  }
}

void
productor(void)
{
  int item=0;
  for(;;) {
    semdown(empty);
    item=item+1;
    printf(1,"RESTE UNO EN EMPTY\n");
    encolar(item);
    printf(1,"SUME UNO EN FULL\n");
    printf(1,"--------------------\n");
    semup(full);
  }
}

void
semtest(void)
{
  int i;
  int pid=1;
  for(i=0;i<CANTPRODUCTORES;i++){

    pid=fork();

    if(pid==0){
      printf(1,"SOY PRODUCTOR\n" );
      break;
    }

  }
  if(pid==0){
    productor();
  }

  for(i=0;i<CANTCONSUMIDORES;i++){
    pid=fork();
    if(pid==0){
      printf(1,"SOY CONSUMIDOR\n" );
      break;
    }

  }
  if(pid==0){
    consumidor();
  }


}


int
main(void)
{

  ql = semget(-1,1);
  full= semget(-1,0);
  empty= semget(-1,N);
  semtest();
  exit();
}
