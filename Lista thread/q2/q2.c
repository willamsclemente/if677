#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>
#define N_THREADS 10


char busca[11];//variavel que ir� ler a senha do arquivo de teste, foi preferido ler a senha de um arquivo de teste e n�o inicializa-la estaticamente, j� que a quest�o dava margem para isso
char resultado[11];//variavel que ir� armenazar a senha depois de descoberta
int cont=N_THREADS;

pthread_mutex_t mutex[10];//mutex utilizados na quest�o
pthread_mutex_t mutex1;


void *lersenha(void *threadid);//fun��o que ir� ler a senha do arquivo
void *forcabruta(void *threadid);//fun��o que descrobir� senha

int main(){
   int rc, i, *tid[N_THREADS];
   pthread_t p;
   pthread_t thread[N_THREADS];

   rc=pthread_create(&p, NULL, lersenha, NULL);//Lendo a senha do arquivo
   if(rc){
   printf("\nErro: %d\n", rc);
   exit(1);
   }
   pthread_join(p, NULL);//esparando a thread ler o arquivo


   for(i=0; i< 10; i++){//inicializando o mutexes
   pthread_mutex_init(&mutex[i], NULL);
   }
   pthread_mutex_init(&mutex1, NULL);


   for(i=0; i<N_THREADS; i++){//Descobrindo a senha
     tid[i]=(int*)malloc(sizeof(int));
     *tid[i]=i;
     rc=pthread_create(&thread[i], NULL, forcabruta, (void*)tid[i]);

     if (rc){
     printf("ERRO; c�digo de retorno � %d\n", rc);
     exit(1);
     }

   }

   for(i=0; i<N_THREADS; i++){//Esperando as threads que est�o procurando a senha terminar
    pthread_join(thread[i], NULL);
   }

   printf("Senha:%s\n", resultado);//imprimindo senha descoberta

   for(i=0; i<10; i++){//Destruindo os mutexes
   pthread_mutex_destroy(&mutex[i]);
   }
   pthread_mutex_destroy(&mutex1);


   pthread_exit((void *)NULL);



}

void *lersenha(void *threadid){//Lendo a senha do arquivo teste
  char url[]="senha.txt";
	FILE *arq;

	arq = fopen(url, "r");
	if(arq == NULL)
			printf("Erro, nao foi possivel abrir o arquivo\n");
	else
		while( (fgets(busca, sizeof(busca), arq))!=NULL )

	fclose(arq);
  pthread_exit((void *)NULL);

}


void *forcabruta(void *threadid){//Fun��o que ir� descrobrir a senha

int tid=*((int*)threadid), i;

while(1){
     for(i=0; i<= 255; i++){//Cada thread ir� procurar um caractere da senha paralelamente, comparando com os caracteres da tabela ascii por at� 255

        if(busca[tid] == i){
        pthread_mutex_lock(&mutex[tid]);
        resultado[tid]=i;
        pthread_mutex_unlock(&mutex[tid]);

        break;//Quando a thread acha o caractere ela sa�
       }

   }
   pthread_mutex_lock(&mutex1);
   if(cont > 9){//Se o numero de threads utizadas na quest�o for menor que 10, as threads que acharem um caractere da senha primeiro ir�o retorna para procurar outro caractere
    pthread_mutex_unlock(&mutex1);
    break;//quando cont vir� 10, ou seja todos os caracteres foram encontrados, as threads que ainda estavam procurando carecteres sair�o da funn��o
   }
   else{//Para o caso de n�o serem 10 threads alguns n�o sair�o e retornaram para procura o caractere que falta
     tid=cont;
     cont++;
     pthread_mutex_unlock(&mutex1);
   }


}
pthread_exit((void*)NULL);


}

