// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.

#include "types.h"
#include "stat.h"
#include "user.h"

#define N 100
#define CANTCONSUMIDORES 1
#define CANTPRODUCTORES 1



int cola[N];
int cantcola;

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
  //printf(1,"antes semdownql de encolar\n" );
  semdown(ql);
  //printf(1,"despues semdownql de encolar\n" );
  cola[cantcola]=nuevo;

  cantcola++;
  //printf(1,"antes semupql de encolar\n" );
  semup(ql);
  //printf(1,"depsues semupql de encolar\n" );
}

int
desencolar()
{
  int res;
  int i;
  //printf(1,"antes semdownql de desencolar\n" );
  semdown(ql);
  //printf(1,"despues semdownql de desencolar\n" );
  res =cola[0];
  for(i=0;i<cantcola-1;i++){
    cola[i]=cola[i+1];
  }
  //printf(1,"antes semupql de desencolar\n" );
  semup(ql);
  //printf(1,"depsues semupql de desencolar\n" );
  return res;
  //printf(1,"fin del desencolar\n" );
}


void
consumidor(void)
{
  for(;;) {
  //  printf(1,"antes semudownempty de consumidor\n" );
    semdown(empty);
  //  printf(1,"depsues semudownempty de consumidor\n" );
    printf(1,"%d\n",desencolar() );
  //  printf(1,"antes semupfull de consumidor\n" );
    semup(full);
  //  printf(1,"depsues semupfull de consumidor\n" );
  }
}

void
productor(void)
{
  int item=0;
  for(;;) {
    item=item+1;
    //printf(1,"produje %i \n",item );
    semdown(full);
    encolar(item);
    semup(empty);
  }
}

void
semtest(void)
{
  int i;
  int pid;
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
  cantcola=0;
  ql = semget(-1,1);
  full= semget(-1,N);
  empty= semget(-1,0);
  semtest();
  exit();
}
