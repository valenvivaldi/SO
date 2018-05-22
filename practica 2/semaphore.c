#include "types.h"
#include "defs.h"
#include "param.h"
#include "mmu.h"
#include "proc.h"
#include "fs.h"
#include "spinlock.h"
#include "semaphore.h"

struct {
  struct spinlock lock;
  struct semaphore semaphore[MAXSEM];
} stable;

void
sinit(void)
{
  initlock(&stable.lock, "stable");
}

int 
semget(int semid, int initvalue){
  int ret = 0;
  int i =0;
  struct semaphore *s;
  struct semaphore *sem;
  acquire(&stable.lock);
  if ((semid>=MAXSEM) || (semid<(-1))){
    ret = (-4);
    goto end;
  }
  if (semid == (-1)){
    ret = -3;
    for (i = 0; i < MAXSEM; i++){
      s = &stable.semaphore[i];
      if (s->reference==0){
        s->value=initvalue;
        ret = i;
        goto enlace;
      }
    }
    goto end;
  }

  if (semid>=0){
    // Check if the process has aquired this semaphore.
    for(i = 0; i < MAXPROCSEM; i++){
      sem = proc->sem[i];
      if(sem == &stable.semaphore[semid]){
        ret = semid; 
        goto end; 
      }
    }

    ret = (-1);
    s = &stable.semaphore[semid];
    if (s->reference!=0){
      ret = semid;
      goto enlace;
    }
    goto end;
  }

enlace:
  for(i = 0; i < MAXPROCSEM; i++){
    if(!(proc->sem[i])){
      s->reference++;
      proc->sem[i] = s;
      goto end; 
    }
  }
  ret= (-2);
end:
  release(&stable.lock);
  return ret;
}

// Releases the semaphore
// Params: semid (semaphore identifier)
// Returns: -1 if the process did not get that semaphore, 0 otherwise.
// -2 if there is no semaphore with that identifier. 
int 
semfree(int semid)
{  
  struct semaphore *sem;
  int i;
  int ret;
  acquire(&stable.lock);
  if ((semid>=MAXSEM) || (semid<0)){
    ret = (-2);
    goto end1;
  }
  for(i = 0; i < MAXPROCSEM; i++){
    sem = proc->sem[i];
    if((sem) == &stable.semaphore[semid]){
      sem->reference--;
      sem = 0; 
      ret = 0;
      goto end1; 
    }
  }
  ret = (-1);
end1:
  release(&stable.lock);
  return ret;
}

// Decrements the semaphore value or locks the process in case that value is 0
// Params: semid (semaphore identifier)
// Returns: -1 if the process did not get that semaphore, 0 otherwise.
// -2 if there is no semaphore with that identifier. 
int 
semdown(int semid)
{
  struct semaphore *sem;
  int i = 0;
  int ret = (-1);
  acquire(&stable.lock);
  if ((semid>=MAXSEM) || (semid<0)){
    ret = (-2);
    goto end2;
  }
  for(i = 0; i < MAXPROCSEM; i++){
    sem = proc->sem[i];
    if((sem) == &(stable.semaphore[semid])){
      while (sem->value<=0){
        sleep(sem,&stable.lock);
      }
      sem->value--;
      ret=0;
      goto end2;
    }
  }
  ret=(-1);
end2:
  release(&stable.lock);
  return ret;
}

// Increments the semaphore value or locks the process in case that value is 0
// Params: semid (semaphore identifier)
// Returns: -1 if the process did not get that semaphore, 0 otherwise.
// -2 if there is no semaphore with that identifier.
int 
semup(int semid)
{
  struct semaphore *sem;
  int i = 0;
  int ret = (-1);
  acquire(&stable.lock);
  if ((semid>=MAXSEM) || (semid<0)){
    ret = (-2);
    goto end3;
  }
  for(i = 0; i < MAXPROCSEM; i++){
    sem = proc->sem[i];
    if((sem) == &stable.semaphore[semid]){
      sem->value++;
      wakeup (sem);
      ret=0;
      break;
    }
  }
end3:
  release(&stable.lock);
  return ret;
}


// Releases all the semaphores of the process
// Returns: 
int
semfreeproc(void)
{  
  struct semaphore *sem;
  int i;
  acquire(&stable.lock);
  for(i = 0; i < MAXPROCSEM; i++){
    sem = proc->sem[i];
    if((sem)){
      sem->reference--;
      sem = 0; 
    }
  }
  release(&stable.lock);
  return 0;
}


//up the references ofthe semaphore and returns the semaphore
struct semaphore*
semupfork(struct semaphore *s)
{
  acquire(&stable.lock);
    s->reference++;
  release(&stable.lock);
  return s;
}
