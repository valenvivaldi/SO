#include "types.h"
#include "x86.h"
#include "defs.h"




int
sys_semget(void)
{
  int initvalue;
  int semid;
  argint(0, &semid);
  argint(1, &initvalue);
  return semget(semid,initvalue);
}

int
sys_semfree(void)
{
  int semid;
  argint(0, &semid);
  return semfree(semid);

}

int
sys_semdown(void)
{
  int semid;
  argint(0, &semid);
  return semdown(semid);
}

int
sys_semup(void)
{
  int semid;
  argint(0, &semid);
  return semup(semid);
}
