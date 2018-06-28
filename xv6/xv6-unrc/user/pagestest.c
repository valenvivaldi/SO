
#include "types.h"
#include "stat.h"
#include "user.h"

#define N  300

int array[100];

void
printf(int fd, char *s, ...)
{
  write(fd, s, strlen(s));
}

void
pagestest(int a)
{
  if(a==0){
    printf(1,"caso base de la recursion!\n");
  }else{
    int b,c,d,e,f,g,h,i  ;
    b=a;
    c=a+b;
    d=a+c;
    e=a+d;
    f=a+e;
    g=a+f;
    h=a+g;
    i=a+h;
    i++;
    printf(1,"llamada recusiva!\n");
    pagestest(a-1);
  }
}




int
main(void)
{
  array[0]=1;

  printf(1, "pages test started!\n");
  pagestest(N);
  printf(1, "pages test finished!\n");
  exit();
}
