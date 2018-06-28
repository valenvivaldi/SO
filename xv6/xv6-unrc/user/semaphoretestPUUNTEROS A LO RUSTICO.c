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
encolar (int nuevo,int* colap,int* cantcolap)
{
  semdown(ql);
  if((*cantcolap)==0){
    printf(1,"productor:encola en el indice0\n" );
  }
  if((*cantcolap)==1){
    printf(1,"productor:encola en el indice 1\n" );
  }
  if((*cantcolap)==2){
    printf(1,"productor:encola en el indice 2\n" );
  }
   *(colap+(*cantcolap))=nuevo;

   (*cantcolap)=(*cantcolap)+1;
   if((*cantcolap)==0){
     printf(1,"productor:aumente cantcola a 0\n" );
   }
   if((*cantcolap)==1){
     printf(1,"productor:aumente cantcola a 1\n" );
   }
   if((*cantcolap)==2){
     printf(1,"productor:aumente cantcola a 2\n" );
   }
  semup(ql);
}

int
desencolar(int* colap,int* cantcolap)
{
   int res;
   int i;
  //int fd;
  semdown(ql);
  
   res =*(cola);
   *cantcolap=(*cantcolap)-1;
   for(i=0;i<(*cantcolap);i++){
     *(cola+i)=*(cola+i+1);
   }
  // fd =open("archivo", O_CREATE|O_RDWR);
  // printf(fd, "1 \n", res);
  // close(fd);

  semup(ql);

   return res;
  return 0;
}


void
consumidor(int* colap,int* cantcolap)
{
  int i;
  for(i=0;i<2;i++) {
    semdown(empty);
    printf(1,"RESTE UNO EN EMPTY\n");
    desencolar(colap,cantcolap);
    semup(full);
    printf(1,"SUME UNO EN FULL\n");
    printf(1,"-------\n");
  }
}

void
productor(int* colap,int* cantcolap)
{
  int item=0;
  int i;
  for(i=0;i<2;i++) {
    item=item+1;
    semdown(full);
    printf(1,"RESTE UNO EN FULL\n");
    encolar(item,colap,cantcolap);
    semup(empty);
    printf(1,"SUME UNO EN EMPTY\n");
    printf(1,"--------------------\n");
  }
}

void
semtest(int *colap, int* cantcolap)
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
    productor(colap,cantcolap);
  }

  for(i=0;i<CANTCONSUMIDORES;i++){
    pid=fork();
    if(pid==0){
      printf(1,"SOY CONSUMIDOR\n" );
      break;
    }

  }
  if(pid==0){
    consumidor(colap,cantcolap);
  }


}


int
main(void)
{

  ql = semget(-1,1);
  full= semget(-1,N);
  empty= semget(-1,0);
  semtest(cola,&cantcola);
  exit();
}
