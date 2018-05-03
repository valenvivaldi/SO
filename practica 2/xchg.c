static inline unsigned int xchg(volatile unsigned int * addr, unsigned int newval)
{ unsigned int result;
 asm volatile ("xchg %0, %1":
               "+m" (* addr),"=a" (result):
              "1" (newval) );
        return result ;
}

