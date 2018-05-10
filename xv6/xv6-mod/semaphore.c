#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "spinlock.h"
#include "semaphore.h"
#include "proc.h"

struct {
  struct spinlock lock;
  struct semaphore sem[MAXSEM];
} semtable;


void
semtableinit(void)
{
  initlock(&semtable.lock, "semtable");
}

int semsearch(int semid);
int semObtained(int semid);
void printsemaphores();

int
semget(int semid,int initvalue)
{
  int i;
  struct semaphore* s;
  acquire(&semtable.lock);
  s = &semtable.sem[semsearch(semid)];
  if(semid>=0 && s->counter==0){
    return -1;    //el semaforo no esta en uso
  }


  if(semid == -1){
        s->id=s-semtable.sem;
        s->counter++;
        s->value = initvalue;
  }else{
    s->counter++;
  }

  for(i=0;i<MAXPROCSEM;i++){
    if(proc->osemaphore[i]==0){
      proc->osemaphore[i]=s;
      break;
    }
  }
  //printsemaphores();

  if(i==MAXPROCSEM){
    return -2;
  }
  release(&semtable.lock);
  return s->id;
}

int
semfree(int semid)
{

  struct semaphore * s;
  int indexofsem;
  acquire(&semtable.lock);
  indexofsem = semObtained(semid);
  if(indexofsem==-1){
    release(&semtable.lock);
    return -1;
  }
  s=proc->osemaphore[indexofsem];
  s->counter--;
  release(&semtable.lock);
  proc->osemaphore[indexofsem]=0;


  return 0;
}

int
semdown(int semid)
{
  struct semaphore * s;
  int indexofsem;
  int res;
  acquire(&semtable.lock);
  indexofsem=semObtained(semid);
  if(indexofsem==-1){
    res= -1;
  }else{
    s=proc->osemaphore[indexofsem];
    while (s->value==0){
      cprintf("quiero bajar el sem %d y no puedo! me voy a dormir!\n",s->id);
      sleep(s,&semtable.lock);
    }
    cprintf("pude bajar el sem %d\n",s->id);
    s->value--;
//    printsemaphores();
  }
  cprintf("semdown del semaforo! %d\n",s->value);
  release(&semtable.lock);
  res= 0;
  return res;
}

int
semup(int semid)
{
  struct semaphore * s;
  int indexofsem;
  int res;
  acquire(&semtable.lock);
  indexofsem=semObtained(semid);
  if(indexofsem!=-1){
    s=proc->osemaphore[indexofsem];
    s->value++;
    wakeup(s);
    res =0;
  }else{
    res= -1;
  }
  //printsemaphores();
  release(&semtable.lock);
  return res;
}



//returns of the semaphore in the table.
// If the id is -1, then it returns a pointer to the first unused semaphoro (counter 0)
//return -2 if there are no more semaphore available
int
semsearch(int semid){

  int i;
  for(i=0; i < MAXSEM; i++){
    if(semtable.sem[i].id==semid){
      return i;
    }
    if(semid==-1 && semtable.sem[i].counter==0){
      return i;
    }
  }
  if(semid<0){
    return -2;  //not avaible semaphores
  }
  return -1;
}

//Check if the semaphore belongs to the current process
//returns the position in the semaphore arrangement of the process or -1 if it was not found
int
semObtained(int semid){
  int i;
  for(i=0;i<MAXPROCSEM;i++){
    if(proc->osemaphore[i]!=0&&proc->osemaphore[i]->id==semid){
      return i;
    }
  }


    return -1;

}

struct semaphore*
semaphoredup(struct semaphore* s){
  acquire(&semtable.lock);
  if(s->counter<0){
    panic("error al duplicar el semaforo");
  }
  s->counter++;
  release(&semtable.lock);
  return s;
}


void
printsemaphores()
{
  cprintf("SEMAFOROS DEL PROCESO!!!\n");
  int i;
  for(i=0;i<MAXPROCSEM;i++){
    if(proc->osemaphore[i]!=0){
      cprintf("semaforo id=%d value=%d\n",proc->osemaphore[i]->id,proc->osemaphore[i]->value);
    }
  }




}
