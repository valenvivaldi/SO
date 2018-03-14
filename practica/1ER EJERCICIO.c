#include <stdio.h>
int g=3,z=4;

int f (int * x, int y){

  static int c=5;

  int a = *(x+1);
  int a1 =y;
  int a2 =c++;
  printf("valor de C=%d \n",c );
  printf("DIR DE VARIABLE GLOB c=%p\n",&c );
  printf("x= %p x+1 =%p x+2=%p x3=%p a=%d a1=%d a2=%d",x,x+1,x+2,x+4,a,a1,a2);
  printf("retorno %d\n",a+a1+a2);

  return a; //(1)
}

int main(void){
  int b[3]= {1,2,3};
  int m =5;
  int a[5]= {1,2,3,4,5};



  printf("\n\n\n &b =%p &m =%p &a =%p\n\n\n",&b,&m,&a);



  printf("dir de a =%p dir de a[0]=%p\n",&a,&a[0]);

  printf("\n\n &a=%p \n  a=%p\n\n\n",&a,a);

  int r = f(a,a[0])+ f(&a,a[g]);


  printf("\n\n\nDIR DE VARIABLE GLOB g=%p DIR DE VARIABLE GLOB z=%p \n\n",&g,&z );
  printf("r=%d %p\n",r,&r);
  return r;
}
