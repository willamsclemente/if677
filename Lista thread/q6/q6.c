#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>
#include<time.h>
#define N 100    //N�mero de esteiras
#define S 80    //N�mero de sensores
#define M 200 //N�mero de bagagens
#define BUFFER_SIZE 5


typedef struct Node{
int num;
struct Node *prox;
}node; //Estrutura da fila

node *FILA[S];
int tam[S];
int bloqueado[S],menorFILA=N*M, nFILA;
int contsensor=0, contsair=0, sair=0, contesteira=0, contfinal=0, chave=0;

pthread_mutex_t mutex;//Mutexes  e condicionais que ser�o utilizados no decorrer do c�digo
pthread_cond_t fill[S];
pthread_cond_t empty;
pthread_cond_t sairmanutencao;
pthread_cond_t manutencaofinal;
pthread_cond_t condcontrole1;
pthread_cond_t condcontrole2;
pthread_cond_t condcontrole3;


void *controle(void *threadid);//Fun��o que ir� controlar quando os sensor deve sair da manuten��o
void *controlefim(void *threadid);//Fun��o que ir� controlar o fim do programa
void *sensor(void *threadid);//Fun��o do sensor
int analisar(int tid);//Fun��o de analise das bagagens
void *esteira(void *threadid);//Fun��o da esteira
void distribuir(int bagagem);//Fun��o de distribui��o das bagagens
int manutencao(int tid);//Fun��o da manunte��o dos sensores
node *aloca();//Fun��o que aloca c�lulas para fila
void insereFim(node *FILA, int bagagem);//Fun��o que insere uma c�lula no fim da fila
void insereInicio(node *FILA, int bagagem);//Fun��o que insere uma c�lula no inicio da fila
node *retiraInicio(node *FILA);//Fun��o que retira uma c�lula do inicio da fila


int main(){

int i, rc, *tidS[S];

for(i=0; i<S; i++){
  FILA[i]=(node*)malloc(sizeof(node));
  FILA[i]->prox=NULL;
  tam[i]=0;
  bloqueado[i]=0;
}

pthread_t threadcontrole;
pthread_t threadcontrolefim;
pthread_t threadesteira[N];
pthread_t threadsensor[S];


pthread_mutex_init(&mutex, NULL);//Inicializando o mutex e todas as condicionais
pthread_cond_init(&empty, NULL);
pthread_cond_init(&sairmanutencao, NULL);
pthread_cond_init(&manutencaofinal, NULL);
pthread_cond_init(&condcontrole1, NULL);
pthread_cond_init(&condcontrole2, NULL);
pthread_cond_init(&condcontrole3, NULL);
for(i=0; i<S; i++)
pthread_cond_init(&fill[i], NULL);

rc=pthread_create(&threadcontrole, NULL, controle, NULL);   //Criando todas as threads do programa
  if (rc){
  printf("ERRO; c�digo de retorno � %d\n", rc);
  exit(1);
  }

rc=pthread_create(&threadcontrolefim, NULL, controlefim, NULL);
  if (rc){
  printf("ERRO; c�digo de retorno � %d\n", rc);
  exit(1);
  }

for(i=0; i<N; i++){
    rc=pthread_create(&threadesteira[i], NULL, esteira, NULL);

    if (rc){
    printf("ERRO; c�digo de retorno � %d\n", rc);
    exit(1);
    }
}

for(i=0; i<S; i++){
    tidS[i]=(int*)malloc(sizeof(int));
    *tidS[i]=i;
    rc=pthread_create(&threadsensor[i], NULL, sensor, (void*)tidS[i]);

    if (rc){
    printf("ERRO; c�digo de retorno � %d\n", rc);
    exit(1);
    }
}


for(i=0; i<N; i++){ //Esperando todas as threads terminarem
    pthread_join(threadesteira[i], NULL);
}
for(i=0; i<S; i++){
    pthread_join(threadsensor[i], NULL);
}

pthread_join(threadcontrole, NULL);
pthread_join(threadcontrolefim, NULL);



   pthread_mutex_destroy(&mutex);//Destruindo o mutex e todas as variaveis de condi��o
   pthread_cond_destroy(&empty);
   for(i=0; i<S; i++)
   pthread_cond_destroy(&fill[i]);
   pthread_cond_destroy(&sairmanutencao);
   pthread_cond_destroy(&manutencaofinal);
   pthread_cond_destroy(&condcontrole1);
   pthread_cond_destroy(&condcontrole2);
   pthread_cond_destroy(&condcontrole3);



   pthread_exit((void*)NULL);



}

void *controle(void *threadid){
int i;
while(1){

    pthread_mutex_lock(&mutex);
    pthread_cond_wait(&condcontrole1, &mutex);//Quando todos os sensores entrarem em manuten��o ou programa chega ao fim a thread recebe o sinal na condicional

    if(chave == 0){//Se o sinal n�o � de fim de programa
    sair=1;//A thread de controle de manuten��o abre a chave sair para os sensores se prepararem pra sair da manunte��o
    pthread_cond_wait(&condcontrole2, &mutex);//Quando todos os sensor est�o prontos pra sair da manuten��o a thread recebe um sinal nessa condicional

    for(i=0; i<S; i++)
        bloqueado[i]=0;//Desbloquea todos os sensores
    sair=0;//zera todos contadores
    contsensor=0;
    contsair=0;
    pthread_cond_broadcast(&sairmanutencao);//Manda um sinal para todos os sensores voltarem a funcionar
    printf("\nAviso: Todos os sensores receberam manutencao.");
    pthread_mutex_unlock(&mutex);
    }
    else{//A chave de fim for 1 a thread de controle de manunte��o termina
        break;
    }



}


pthread_exit((void*)NULL);


}

void *controlefim(void *threadid){
int i, res=0;
pthread_mutex_lock(&mutex);
pthread_cond_wait(&condcontrole3, &mutex);//Esparando todas as esteiras terminarem
pthread_mutex_unlock(&mutex);

while(1){

    pthread_mutex_lock(&mutex);
    for(i=0; i<S; i++){//Quando todas a esteiras terminarem , ela espera que todos os sensores fiquem com fila vazia
       if(tam[i]> 0)
          res=1;
    }

    if(res == 0){//Quandos o sensores ficarem com fila fazia, ela a chave de fim de programa
        chave=1;
        pthread_mutex_unlock(&mutex);
        break;
    }
    else{
        res=0;
        pthread_mutex_unlock(&mutex);
    }

}

while(1){

     for(i=0; i<S; i++)
     pthread_cond_signal(&fill[i]);//Apartir dair a thread de controle de fim de programa mandara sinais para os sensores que est�o dormindo ou em manuten��o irem para a manuten��o final
     pthread_cond_broadcast(&sairmanutencao);

     pthread_mutex_lock(&mutex);

     if(contfinal == S){//Quando todos os sensores estiverem na manunten��o final, a thread mandara um sinal para eles terminarem
        pthread_cond_broadcast(&manutencaofinal);
        pthread_cond_signal(&condcontrole1);//E mandaram um sinal para a thread de controle tamb�m terminar
        pthread_mutex_unlock(&mutex);
        break;//E sair�
     }
     pthread_mutex_unlock(&mutex);




}



pthread_exit((void*)NULL);

}

void *sensor(void *threadid){
int tid=*((int*)threadid);
int i, v=0, t=0;

for(i=0; i<200; i++){
    v=analisar(tid);

    if(v == 1){//Se v igual a 1 o a thread sensor deve ir para manuten��o final
        break;
    }

    if(i == 199){//Thread vai para manutencao
        pthread_mutex_lock(&mutex);
        bloqueado[tid]=1;//Bloquendo para nenhuma thread esteira nem thread sensor colocar baganges nessa fila
        contsensor++;//Incrementando a variavel que conta o n�mero de senspres em manuten��o

        if(contsensor == S){//Se o n�mero de sensores em manuten��o for igual ao total de n�meros de sensor acorda a thread de controle
            pthread_cond_signal(&condcontrole1);
        }

        pthread_mutex_unlock(&mutex);
        printf("\nSensor %d: Manutencao.", tid);
        t=manutencao(tid);

        if(t == 1)//Se o retorno da manuten��o do sensor for 1 ele deve sair pois � fim de programa
           break;
        i=-1;//Se n�o ele volta a funcionar
        }
}

pthread_mutex_lock(&mutex);
contfinal++;//Incrementando o contador que conta o n�mero de sensor que chegar�o na manunte��o final

if(contfinal == S)
printf("\nAviso: Manutencao final dos sensores.");
pthread_cond_wait(&manutencaofinal, &mutex);//Esparando um sinal para todos os sensores sairem da manuten��o final
pthread_mutex_unlock(&mutex);

pthread_exit((void*)NULL);

}

int analisar(int tid){
node *tmp;
pthread_mutex_lock(&mutex);

while((tam[tid] == 0)&&(chave == 0)){//Se a fila do sensor for 0 ou chave de fim de programa estiver fechada durma
pthread_cond_wait(&fill[tid], &mutex);

}
if(chave == 0){//Se chave de fim de c�digo ler e analisar um bagagem do come�o da fila
tmp=retiraInicio(FILA[tid]);
//SLEEP
tam[tid]--;//Decrementado o contador de numero de bagagens na fila

if(tam[tid] == (BUFFER_SIZE-1))
    pthread_cond_broadcast(&empty);

pthread_mutex_unlock(&mutex);
return 0;//retorne 0 se a chave de fim de programa for 0
}
else{//se n�o retorne 1 pois � fim de programa
pthread_mutex_unlock(&mutex);
    return 1;
}

}

void *esteira(void *threadid){
int bagagem;

for(bagagem=0; bagagem <M; bagagem++){
    distribuir(bagagem);
}
pthread_mutex_lock(&mutex);
contesteira++;//Contador que conta o numero de esteiras que terminaram

if(contesteira == N)//Se todas as esterias terminaram mande um sinal para thread de controle de fim de programa
 pthread_cond_signal(&condcontrole3);

pthread_mutex_unlock(&mutex);


pthread_exit((void*)NULL);

}

void distribuir(int bagagem){
int i;

   pthread_mutex_lock(&mutex);

    for(i=0; i<S; i++){//Procurando em a menor fila nos sensores que n�o est�o bloqueados
      if((tam[i] < menorFILA) &&(bloqueado[i] == 0)){
        menorFILA=tam[i];
        nFILA=i;
        }

    }

    while(menorFILA == BUFFER_SIZE){//Se a menor fila for igual ao n�mero m�ximo de bagagens na fila, todas filas est�o cheias
      pthread_cond_wait(&empty, &mutex);//E a esteria deve durmir

        for(i=0; i<S; i++){// quando ela acorda ela calcula a fila de novo e se for buffer_size a esteira pode colocar a bagagem l�
          if((tam[i] < menorFILA) &&(bloqueado[i] == 0)){
           menorFILA=tam[i];
           nFILA=i;
          }
       }

    }

    insereFim(FILA[nFILA],bagagem);//Inserindo a bagagem na menor fila
    tam[nFILA]++;//Incrementado o contador dessa fila

    if(tam[nFILA]== 1)//Se ele for igual a 1 acordar o sensor
       pthread_cond_signal(&fill[nFILA]);

     menorFILA=N*M;//Depois colocar o menor fila no m�ximo para que outra esteira possa usa lo

    pthread_mutex_unlock(&mutex);

}

int manutencao(int tid){
int i;
node *tmp;
while(1){

pthread_mutex_lock(&mutex);
if((tam[tid] == 0)||(sair == 1)){//Se o n�mero de bagagens na fila do sensor for igual a zero ou chave sair de for 1
contsair++;                      //Incremente a variavel de sensor em manuten��o para sair

  if(contsair == S)//Se o contador for igual ao n�mero total de sensores, todos os sensores est�o prontos para sair da manunte��o, avisar o thread de controle de manunte��o
   pthread_cond_signal(&condcontrole2);

   pthread_cond_wait(&sairmanutencao, &mutex);//Esperar um sinal da thread de manuten��o para todos os sensores sairem da manunten��o

  if(chave == 0){//Se a chave de fim de c�digo for zero, os sensores devem retornar ao funcionamento
   pthread_mutex_unlock(&mutex);
   return 0;
  }
  else{//Se n�o retorne 1 e os sensores v�o para a manunten��o final
    pthread_mutex_unlock(&mutex);
    return 1;
  }
}
else{//Se a fila da bagagem n�o estiver vazia alocar as bagagens nos sensores com menor fila

     for(i=0; i<S; i++){
        if((tam[i] < menorFILA) &&(bloqueado[i] == 0)){
        menorFILA=tam[i];
        nFILA=i;
        }

     }

     if(menorFILA < BUFFER_SIZE){

       tmp=retiraInicio(FILA[tid]);//Retirando a bagagem da fila do senor
       insereInicio(FILA[nFILA],tmp->num);//Inserindo no come�o da fila de outro sensor(prioridade)
       tam[tid]--;
       tam[nFILA]++;
        if(tam[nFILA]== 1)
        pthread_cond_signal(&fill[nFILA]);

     menorFILA=N*M;
     }
     else{
        menorFILA=N*M;
     }

}
pthread_mutex_unlock(&mutex);

}


}
node *aloca(){//Aloca c�lula nas filas dos sensores
node *novo=(node*)malloc(sizeof(node));
if(!novo)
    exit(1);
return novo;

}

void insereFim(node *FILA, int bagagem){//Inserindo bagagem no final da fila dos sensores
node *novo=aloca();
novo->num=bagagem;
novo->prox=NULL;
if(FILA->prox ==NULL)
    FILA->prox=novo;
else{
  node *tmp=FILA->prox;

  while(tmp->prox != NULL)
    tmp=tmp->prox;

  tmp->prox=novo;

}

}

void insereInicio(node *FILA, int bagagem){//Inserindo bagagem no inicio da fila dos sensores

node *novo=aloca();
novo->num=bagagem;
node *tmp=FILA->prox;

FILA->prox=novo;
novo->prox=tmp;

}

node *retiraInicio(node *FILA){//retirando bagagem no inicio da fila dos sensores

if(FILA->prox == NULL){
    printf("\nFILA vazia");
    return NULL;
}
else{
node *tmp=FILA->prox;
FILA->prox=tmp->prox;
return tmp;
}


}

