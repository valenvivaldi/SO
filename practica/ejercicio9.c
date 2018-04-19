#include <sys/wait.h>

// int main(int argc, char* argv[],char* varEnv[])
// {
//
//     int i;
//     for(i=0;i<argc;i++)
//     {
//
//       printf("%s\n",argv[i] );
//     }
//     i=0;
//     while(varEnv[i])
//     {
//
//       printf("%s\n",varEnv[i++] );
//
//     }
//     printf("hay %d variables de ambiente\n",i-1 );
// }
#include <unistd.h>
#include <stdio.h>

int systemALTERNATIVO(char const * argv[]){
    int isFather=fork();
    if(isFather==-1){printf("HUBO UN ERROR EN EL FORK!\n");}
    if(isFather){
      printf("el proceso hijo tiene ppid=%d \n",isFather );
      wait(0);
		printf("termino el hijo %d \n",isFather );

    }else{
	
      execv(argv[1],(char* const*)argv+1);
    }
	return 0;
  }
  
int main(int argc, char const *argv[]) {
  systemALTERNATIVO(argv);

  return 0;
}
