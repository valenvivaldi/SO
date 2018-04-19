int main(int argc, char const *argv[]) {
        int isFather=fork();
        if(isFather==-1) {printf("HUBO UN ERROR EN EL FORK!\n"); } //si hay un error en la ejecucion del codigo
        if(isFather>0) {
                printf("el proceso hijo tiene ppid=%d \n",isFather );
                waitpid(isFather);
                printf("termino el hijo %d \n",isFather );
        }
        if(isFather==0) {
                
        }
        return 0;
}
