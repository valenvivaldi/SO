// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.

#include "types.h"
#include "stat.h"
#include "user.h"

void
printf(int fd, char *s, ...)
{
  write(fd, s, strlen(s));
}

void
setprioritytest(void)
{
  int pid;

  printf(1, "fork priotity\n");
  pid = fork();
  if (pid==0){
    for (;;){
      setpriority(0); 
    }
  }
  else{
    for(;;){

    }
  }  
}

int
main(void)
{
  setprioritytest();
  exit();
}
