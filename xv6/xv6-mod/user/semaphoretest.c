//original
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

#define N 2
#define CANTPRODUCTORES 5
#define CANTCONSUMIDORES 1


int fd=0;
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
  write(fd, &nuevo, sizeof(nuevo));
  semup(ql);

}

int
desencolar()
{

  semdown(ql);

  semup(ql);

  return 0;
}


void
consumidor(void)
{
  for(;;) {
    semdown(empty);
    printf(1,"RESTE UNO EN EMPTY\n");
    desencolar();
    semup(full);
    printf(1,"SUME UNO EN FULL\n");
    printf(1,"-------\n");
  }
}

void
productor(void)
{
  int item=0;
  for(;;) {
    item=item+1;
    semdown(full);
    printf(1,"RESTE UNO EN FULL\n");
    encolar(item);
    semup(empty);
    printf(1,"SUME UNO EN EMPTY\n");
    printf(1,"--------------------\n");
  }
}

void
semtest(void)
{
  int i;
  int pid=1;
  fd=open("archivo", O_CREATE|O_RDWR);

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
  full= semget(-1,N);
  empty= semget(-1,0);

  semtest();
  exit();
}
