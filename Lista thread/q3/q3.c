#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>
#include<time.h>
#define BUFFER_SIZE 5
#define NUM_CLIENTES 20//Número de clientes



typedef struct Node{//BUFFER
int page;
int id_cliente;
struct Node *prox;
}node;

int n_pagebuffer=0;//Contador de páginas no buffer
int semaforo=0;//Contador de sinais para esvaziar o buffer

node *BUFFER;
pthread_mutex_t mutex;
pthread_cond_t fill;
pthread_cond_t empty;
pthread_cond_t waitpage[NUM_CLIENTES];//Condicional para o cliente esperar a página requisitada


void *servidor(void *threadid);//Função do servidor
void *clientes(void *threadid);//Função dos clientes
node *aloca();//
void insereFim(node *BUFFER, int page, int tid);//Função que insere página no buffer
node *retiraInicio(node *LISTA);//Função que retira página do buffer


int main(){
int i, rc;
BUFFER=(node*)malloc(sizeof(node));//Inicializando buffer
BUFFER->prox=NULL;

pthread_mutex_init(&mutex, NULL);
pthread_cond_init(&fill, NULL);//Inicializando o mutex e as variaveis de condição
pthread_cond_init(&empty, NULL);
for(i=0; i<NUM_CLIENTES; i++)
  pthread_cond_init(&waitpage[i], NULL);


pthread_t thread_cliente[NUM_CLIENTES];
pthread_t thread_servidor;
int *tid[NUM_CLIENTES];


for(i=0; i<NUM_CLIENTES; i++){
    tid[i]=(int*)malloc(sizeof(int));
    *tid[i]=i;
    rc=pthread_create(&thread_cliente[i], NULL, clientes, (void*)tid[i]);
    if(rc){
        printf("ERRO; código de retorno é %d\n", rc);
        exit(1);
    }


}
pthread_create(&thread_servidor, NULL, servidor, NULL);


for(i=0; i<NUM_CLIENTES; i++){
pthread_join(thread_cliente[i], NULL);
}
pthread_join(thread_servidor, NULL);

pthread_mutex_destroy(&mutex);//Destruindo clientes e variaveis de condição
pthread_cond_destroy(&fill);
pthread_cond_destroy(&empty);
for(i=0; i<NUM_CLIENTES; i++)
  pthread_cond_destroy(&waitpage[i]);


pthread_exit((void*)NULL);




}

void *servidor(void *threadid){
node *tmp;
while(1){

pthread_mutex_lock(&mutex);
while((n_pagebuffer-semaforo) == 0){//Se não houver requições no buffer o servidor deve dormir
    pthread_cond_wait(&fill, &mutex);
}

if(semaforo > 0){//Se houver sinais para esvaziar o buffer o servidor irá esvaziar o buffer, diminuindo os sinais
    while(semaforo > 0){
        n_pagebuffer--;
        semaforo--;

    }
}

if((n_pagebuffer-semaforo)== (BUFFER_SIZE -1))//Acordando os cliente se a diferença de paginas no buffer e sinais no semaforo for igual a 4
    pthread_cond_broadcast(&empty);

tmp=retiraInicio(BUFFER);//Lendo uma requisição do buffer
pthread_cond_signal(&waitpage[tmp->id_cliente]);//Atendendo a requisição do cliente
printf("\nCLIENTE %d recebeu a pagina %d", tmp->id_cliente, tmp->page);


tmp=NULL;
pthread_mutex_unlock(&mutex);

}

pthread_exit((void*)NULL);
}

void *clientes(void *threadid){
srand( (unsigned)time(NULL) );//Para não repetir a sequencia de páginas requisitadas

int tid=*((int*)threadid);
int page;
while(1){

pthread_mutex_lock(&mutex);
while((n_pagebuffer-semaforo) == BUFFER_SIZE){//Se a subtração do numero de paginas no buffer com o de sinal para zerar o buffer for o máximo
    pthread_cond_wait(&empty, &mutex);        //Ou seja o buffer está cheio e não tem nenhum sinal para esvazia lo, o cliente irá dormir
}

page=rand()%101;//Escolhendo uma página alétoria para requisitar
insereFim(BUFFER, page, tid);//Inserindo página no buffer
n_pagebuffer++;
pthread_cond_wait(&waitpage[tid], &mutex);//O cliente espera a página requisitado
semaforo++;

if((n_pagebuffer-semaforo== 1))//Nesse caso, acordar o servidor, pois existe requisições
    pthread_cond_signal(&fill);

pthread_mutex_unlock(&mutex);

}

pthread_exit((void*)NULL);
}

node *aloca(){
node *novo=(node*)malloc(sizeof(node));//Alocando célula no buffer
if(!novo)
    exit(1);
return novo;

}

void insereFim(node *BUFFER, int page, int tid){//Inserindo pagina no buffer
node *novo=aloca();
novo->page=page;
novo->id_cliente= tid;
novo->prox=NULL;

if(BUFFER->prox ==NULL)
    BUFFER->prox=novo;
else{
  node *tmp=BUFFER->prox;

  while(tmp->prox != NULL)
    tmp=tmp->prox;

  tmp->prox=novo;

}

}

node *retiraInicio(node *BUFFER){//Atendendo requisição
if(BUFFER->prox == NULL){
    printf("\nLista vazia");
    return NULL;
}
else{
node *tmp=BUFFER->prox;
BUFFER->prox=tmp->prox;
return tmp;
}


}
