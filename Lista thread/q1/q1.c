#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>
#define N 3   //Número de arquivos
#define T 10 //Número de threads
#define P 10 //Número de produtos

int cont=0;//variaveis globais utilizadadas no código
float total_produtos[P+1];

pthread_mutex_t mutex;//mutexes utilizados no codigo
pthread_mutex_t mutexprod[P+1];

void *ler_arquivo(void *threadid);//função que vai ler os arquivos


int main(){

   int rc, i;
   float total=0; //irá armezenar o total de produtos lido
   pthread_t thread[T];


   for(i=0; i<=P; i++){//zerando cada posicao do vetor de produtos
     total_produtos[i]=0;
   }

   pthread_mutex_init(&mutex, NULL);//inicializando o mutex das variaveis globais

   for(i=0; i<=P; i++){//inicializando os mutexes do vetor de produtos
        pthread_mutex_init(&mutexprod[i], NULL);
   }

   for(i=0; i<T; i++){//criando e as threads para lerem os arquivos
      rc=pthread_create(&thread[i], NULL, ler_arquivo, NULL);

      if (rc){
      printf("ERRO; código de retorno é %d\n", rc);
      exit(1);
      }

   }


   for(i=0; i<T; i++){//esperando as threads terminarem
    pthread_join(thread[i], NULL);
   }

   for(i=0; i<=P; i++){//contabilizando o total de produtos lidos para calcular a porcetagem
     total+=total_produtos[i];
   }


   for(i=0; i<=P; i++){//imprimindo o resultado: tipo de produto, quantidade desse tipo de produto, porcetagem desse produto
     printf("\n| | Produto (%d) | Quantidade (%.f unid) |  Porcetagem (%.1f) | |",i, total_produtos[i], (total_produtos[i]/total)*100);
   }

   pthread_mutex_destroy(&mutex);//destruindo os mutexes utilizados na questão
   for(i=0; i<=P; i++){
        pthread_mutex_destroy(&mutexprod[i]);
   }

   pthread_exit((void*)NULL);






}



void *ler_arquivo(void *threadid){
int id_arq, cont1=0, y;
int i=0 ,j=0;
char arquivo[1000];//armenara o nome de arquivo de leitura
 FILE *p;

while(1){

    pthread_mutex_lock(&mutex);//thread que conseguir fechar o mutex, incrementará o contador que é um numero de arquivo para ler
    cont++;                    //cada thread ira ler um arquivo e quando terminadar a leitura podera ler outro arquivo
    id_arq=cont;
    pthread_mutex_unlock(&mutex);

    if(id_arq <= N){// se o arquivo para ler pegado na variavel cont for menor ou igual ao numero total de arquivos a thread vai ler o arquivo, se não ela sairá da função

         sprintf(arquivo, "%i", id_arq);//tranformando o numero adquirido na variavel cont(int) para (char)
         for(i = 0; arquivo[i] != '\0'; i++)//contabilizando quantas posições o numero irá o ocupar na variavel arquivo
             cont1++;

         arquivo[cont1]='.';//colocando os caracteres necessarios depois da variavel cont1 para completar o nome do arquivo de leitura
         arquivo[cont1+1]='i';
         arquivo[cont1+2]='n';
         arquivo[cont1+3]='.';
         arquivo[cont1+4]='t';
         arquivo[cont1+5]='x';
         arquivo[cont1+6]='t';
         arquivo[cont1+7]='\0';
         cont1=0;


         p=fopen(arquivo, "r");//abrindo o arquivo para leitura
         if(p == NULL){
            printf("\nErro ao abrir o arquivo");
         }
         else{
             while( (fscanf(p,"%d\n", &y))!= EOF ){//contabilizando os tipos de produtos e incremetando a posição deles no vetor produto
             pthread_mutex_lock(mutexprod+y);
             (total_produtos[y])+=1;
             pthread_mutex_unlock(mutexprod+y);


             }
         }



    }
    else{// se o cont que a thread pegou for maior que o número total de arquivos ela sai da função

        break;
    }
}

pthread_exit((void*)NULL);



}


