void lock(boolean *var)
{

}

void unlock(boolean *var)
{

}

int TestAndSet(int * v)
{
  int tmp = *v;
  if (*v==0) *v = 1;
  return tmp;
}

int Swap(int * v1, int * v2)
{
  int tmp = *v1;
  *v1 = *v2;
  *v2 = tmp;
  return tmp;
}
