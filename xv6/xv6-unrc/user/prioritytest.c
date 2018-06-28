// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.

#include "types.h"
#include "stat.h"
#include "user.h"

#define N  1000

void
printf(int fd, char *s, ...)
{
  write(fd, s, strlen(s));
}

void
prioritytest(void)
{
  int i;
  int pid;
  printf(1, "prioritytest\n");
    fork();
    for (i=0;i<2;i++){
      pid=fork();

      if(pid==0){
        break;
      }
    }

    if(pid != 0){
      for(;;){
        setpriority(0);
      }
    }
    if(pid == 0){
        //setpriority(3);
        for(;;){
          if(i %2==0){
            setpriority(2);
          }
        }
      }
    }






int
main(void)
{
  prioritytest();
  exit();
}
