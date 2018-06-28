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

#define N 10000





int ql;

void
printf(int fd, char *s, ...)
{
  write(fd, s, strlen(s));
}






int
main(void)
{
  cantcola=0;
  ql = semget(-1,1);
  semtest();
  exit();
}
