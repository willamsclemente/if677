#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>
#define NUM_THREADS 4      //Numeros de threads usadas
#define LINHAS 4          //Numero de linhas da matriz e do vetor
#define COLUNASMATRIZ 4   //Numero de colunas da matriz
#define COLUNASVETOR 1    //Numero de colunas do vetor

typedef struct Node{//Estrutura que representara a matriz esparsa
int indice;
float valor;
struct Node *prox;
}node;

node *matrizesparsa[4];//Variaveis utizadas para as operações
node *matrizesparsa1[4];
float matrizdensa[4][4]={ {1.0, 2.0, 5.0, 4.0}, {3.0, 4.0, 2.0, 1.0}, {5.0, 6.0, 1.0, 2.0}, {2.0, 5.0 ,1.0 ,6.0} };
float vetordenso[4][1]={ {1.0}, {2.0}, {5.0},{4.0} };
float matrizR[4][4]={ {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},{0.0, 0.0, 0.0, 0.0},{0.0, 0.0, 0.0 , 0.0} };
float matrizR2[4][4]={ {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},{0.0, 0.0, 0.0, 0.0},{0.0, 0.0, 0.0 , 0.0} };
float matrizR1[4][1]={ {0.0}, {0.0}, {0.0}, {0.0} };

void inicializando();
node *aloca();
void insereFim(node *matrizesparsa, int indice, float valor);
void *MesparsaVdenso(void *threadid);
void *MesparsaMesparsa(void *threadid);
void *MesparsaMdensa(void *threadid);
void imprimeresultado();

int main(){

int i, j, rc;
pthread_t thread[NUM_THREADS];
int *tid[NUM_THREADS];

inicializando();//Inicializando as matrizes esparsas


for(i=0; i<NUM_THREADS; i++){// Realizando a operação da matriz esparsa pelo vetor denso
  tid[i]=(int*)malloc(sizeof(int));
  *tid[i]=i;
  rc=pthread_create(&thread[i], NULL, MesparsaVdenso,(void*)tid[i]);

  if (rc){
  printf("ERRO; código de retorno é %d\n", rc);
  exit(1);
  }
}

for(i=0; i<NUM_THREADS; i++){//Esparando as threads terminarem
    pthread_join(thread[i], NULL);
}

for(i=0; i<NUM_THREADS; i++){// Realizando a operação da matriz esparsa por uma matriz esparsa
  tid[i]=(int*)malloc(sizeof(int));
  *tid[i]=i;
  rc=pthread_create(&thread[i], NULL, MesparsaMesparsa,(void*)tid[i]);

  if (rc){
  printf("ERRO; código de retorno é %d\n", rc);
  exit(1);
  }
}

for(i=0; i<NUM_THREADS; i++){//Esparando as threads terminarem
    pthread_join(thread[i], NULL);
}

for(i=0; i<NUM_THREADS; i++){// Realizando a operação da matriz esparsa por uma matriz densa
  tid[i]=(int*)malloc(sizeof(int));
  *tid[i]=i;
  rc=pthread_create(&thread[i], NULL, MesparsaMdensa,(void*)tid[i]);

  if (rc){
  printf("ERRO; código de retorno é %d\n", rc);
  exit(1);
  }
}

for(i=0; i<NUM_THREADS; i++){//Esparando as threads terminarem
    pthread_join(thread[i], NULL);
}

  imprimeresultado();//Imprimindo o resultado
  pthread_exit((void*)NULL);

}


void inicializando(){
int i;

for(i=0; i< 4; i++){
matrizesparsa[i]=(node*)malloc(sizeof(node));
matrizesparsa1[i]=(node*)malloc(sizeof(node));
matrizesparsa[i]->prox=NULL;
matrizesparsa1[i]->prox=NULL;

}
insereFim(matrizesparsa[0], 0,2);
insereFim(matrizesparsa[1], 0,-1);
insereFim(matrizesparsa[1], 1,2);
insereFim(matrizesparsa[1], 2,-1);
insereFim(matrizesparsa[2], 2,2);
insereFim(matrizesparsa[2], 3,-1);
insereFim(matrizesparsa[3], 3,2);


insereFim(matrizesparsa1[0], 0,1);
insereFim(matrizesparsa1[1], 0,1);
insereFim(matrizesparsa1[1], 3,1);
insereFim(matrizesparsa1[2], 2,1);
insereFim(matrizesparsa1[2], 3,1);
insereFim(matrizesparsa1[3], 3,1);


}

node *aloca(){//Criando uma célula para a matriz esparsa
node *novo=(node*)malloc(sizeof(node));
if(!novo)
    exit(1);
return novo;

}

void insereFim(node *matrizesparsa, int indice, float valor){//Inserindo a célula no fim lista que representa a matriz esparsa
node *novo=aloca();//Alocando memória para célula da lista
novo->valor=valor;
novo->indice=indice;
novo->prox=NULL;
if(matrizesparsa->prox ==NULL)//Se a lista que representa a matriz esparsa estiver vazia a célula entra no final
    matrizesparsa->prox=novo;
else{//Se não
  node *tmp=matrizesparsa->prox;//O final da lista é procurado para inserir a célula

  while(tmp->prox != NULL)
    tmp=tmp->prox;

  tmp->prox=novo;

}

}

void *MesparsaVdenso(void *threadid){
  int tid=*((int*)threadid), i,j;
  node *tmp=matrizesparsa[tid]->prox;//Apontando para o primeira célula da lista que representa a matriz esparsa

  for(i=tid; i<LINHAS; i=i+NUM_THREADS){

    for(j=0; j<COLUNASVETOR; j++){

        while(tmp != NULL){//Cada thread vai multiplacar uma linha da matriz esparsa pela coluna do vetor denso
            matrizR1[i][j]=matrizR1[i][j]+ tmp->valor * vetordenso[tmp->indice][j];//Só vai a ver multiplicação de termos do vetor denso que tem mesmo
            tmp=tmp->prox;                                                         //indice que a matriz esparsa, evitando computação desnecessária

        }

    }
  }

  pthread_exit((void*)NULL);

}


void *MesparsaMesparsa(void *threadid){
  int tid=*((int*)threadid), i,j;
  node *tmp=matrizesparsa[tid]->prox;//Apontando para o começo da lista que representa a matriz esparsa
  node *tmp1;
  for(i=tid; i<LINHAS; i=i+NUM_THREADS){//Cada thread irar tratar um linha linha da matriz
    for(j=0; j<COLUNASMATRIZ; j++){
        while(tmp != NULL){
            tmp1=matrizesparsa1[tmp->indice]->prox;//Apontando para o começo da lista que representa a matriz esparsa 1 na linha que tem o mesmo indice
            while(tmp1 != NULL){                   //do termo da outra matriz esparsa
            if(tmp1->indice == j){//Se o termo da matriz esparsa 1 tiver o mesmo indice de j(que representa a coluna naquele momento) multiplique com o termo da outra matriz esparsa
            matrizR2[i][j]=matrizR2[i][j]+ tmp->valor * tmp1->valor;//E adicione a matriz resultante
            break;
            }
            else{//Se não
               tmp1=tmp1->prox;//Desloque o ponteiro na lista daquela linha da matriz esparsa 1
             }

            }
            tmp=tmp->prox;//Fazendo o mesmo para o próximo termo
        }
      tmp=matrizesparsa[tid]->prox;//Apontando para o começo da lista da matriz esparsa para fazer as mesmas operações
    }


  }
    pthread_exit((void*)NULL);


}

void *MesparsaMdensa(void *threadid){
  int tid=*((int*)threadid), i,j;
  node *tmp=matrizesparsa[tid]->prox;//Apontando para o primeira célula da lista que representa a matriz esparsa

  for(i=tid; i<LINHAS; i=i+NUM_THREADS){
    for(j=0; j<COLUNASMATRIZ; j++){

        while(tmp != NULL){//Cada thread vai multiplacar uma linha da matriz esparsa por todas coluna do vetor denso
            matrizR[i][j]=matrizR[i][j]+ tmp->valor * matrizdensa[tmp->indice][j];//Só vai a ver multiplicação de termos da matriz densa que tem o mesmo
                                                                                 //indice que a matriz esparsa, evitando computação desnecessária
            tmp=tmp->prox;
        }
      tmp=matrizesparsa[tid]->prox;//Apontando de novo para o inicio da lista para multiplicar de novo pela próxima coluna
    }


  }

    pthread_exit((void*)NULL);


}

void imprimeresultado(){
int i, j;

printf("\nA matriz resultante da Multiplicacao da matriz esparsa pelo vetor denso:\n");
for(i=0; i<LINHAS; i++){
   for(j=0; j<COLUNASVETOR; j++) {
    printf("%.1f ", matrizR1[i][j]);
   }
   printf("\n");
}
printf("\n");

printf("\nA matriz resultante da Multiplicacao da matriz esparsa pela outra matriz esparsa:\n");
for(i=0; i<LINHAS; i++){
   for(j=0; j<COLUNASMATRIZ; j++) {
    printf("%.1f ", matrizR2[i][j]);
   }
   printf("\n");
}
printf("\n");

printf("\nA matriz resultante da Multiplicacao da matriz esparsa pela matriz densa:\n");
for(i=0; i<LINHAS; i++){
   for(j=0; j<COLUNASMATRIZ; j++) {
    printf("%.1f ", matrizR[i][j]);
   }
   printf("\n");
}


}


