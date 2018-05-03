static inline unsigned int xchg(volatile unsigned int * addr, unsigned int newval);

void lock(int *var)
{
  int a=1;
  while (xchg(var,a)) {
  }

}

void unlock(int *var)
{
  *var=0;
}
// int swap(int * v1, int * v2)
// {
//   int tmp = *v1;
//   *v1 = *v2;
//   *v2 = tmp;
//   return tmp;
// }

static inline unsigned int xchg(volatile unsigned int * addr, unsigned int newval)
{
  unsigned int result;
 asm volatile ("xchg %0, %1":
               "+m" (* addr),"=a" (result):
              "1" (newval) );
        return result ;
}
