void lock(int *var)
{
  while(TestAndSet(var)){
  };
}


void unlock(int *var)
{
    *var=0;
}

int TestAndSet(int * v)
{
  int tmp = *v;
  if (*v==0){
    *v = 1;
  }
  return tmp;
}
