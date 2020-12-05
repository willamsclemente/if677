#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#define P 5 //Números de produtores
#define C 5 //Números de consumidore
#define B 5 //Tamanho do buffer

typedef struct elem{
	int value;
	struct elem* prox;
}Elem;

typedef struct blockingQueue{
	unsigned sizeBuffer, statusBuffer;
	Elem* head, *last;
}BlockingQueue;

pthread_mutex_t mutex;
pthread_cond_t empty;
pthread_cond_t fill;

void putBlockingQueue(BlockingQueue* Q, int newValue);
int takeBlockingQueue(BlockingQueue* Q);
BlockingQueue* newBlockingQueue(unsigned inSizeBuffer);
void *Producer(void* arg);
void *Consumer(void* arg);


int main(){
    int i , rc;
    pthread_mutex_init(&mutex, NULL); //Inicializando mutexes e condicionais
    pthread_cond_init(&empty, NULL);
    pthread_cond_init(&fill, NULL);

    BlockingQueue *Q = newBlockingQueue(B);
    pthread_t producer_thread[P];
    pthread_t consumer_thread[C];

    for(i = 0; i < P; i++){
        rc=pthread_create(&producer_thread[i], NULL, Producer, (void*)Q);

        if (rc){
        printf("ERRO; código de retorno é %d\n", rc);
        exit(1);
        }
    }

    for(i = 0; i < C; i++){
        rc=pthread_create(&consumer_thread[i], NULL, Consumer, (void*)Q);

        if (rc){
        printf("ERRO; código de retorno é %d\n", rc);
        exit(1);
        }
    }
    for(i = 0; i < P; i++){
        pthread_join(producer_thread[i], NULL);//Esperando produtores terminarem
    }

    for(i = 0; i < C; i++){
        pthread_join(consumer_thread[i], NULL);//Esperando consumidores terminarem
    }

    pthread_mutex_destroy(&mutex);//Destruindo mutexes e condicionais
    pthread_cond_destroy(&empty);
    pthread_cond_destroy(&fill);

    pthread_exit((void*)exit);
}

void putBlockingQueue(BlockingQueue* Q, int newValue){
	Elem* NewElem = (Elem*)malloc(sizeof(Elem));//Criando uma novo elemento
	NewElem->value = newValue;
	NewElem->prox = NULL;

	pthread_mutex_lock(&mutex);//Enquanto a fila estiver cheia os produtores dormem
    while(Q->statusBuffer == Q->sizeBuffer){
        printf("\nFILA CHEIA");
        pthread_cond_wait(&empty, &mutex);
    }

    if(Q->statusBuffer == 0){//Acordando os consumidores se statusBuffer for 0 e newelem é o primeiro elemento da fila
        pthread_cond_broadcast(&fill);
        Q->head = NewElem;
    }
	else
		Q->last->prox = NewElem;//Se não newelem é o ultimo elemento da fila
	Q->last = NewElem;
    Q->statusBuffer++;

    pthread_mutex_unlock(&mutex);
}

int takeBlockingQueue(BlockingQueue* Q){
	pthread_mutex_lock(&mutex);

    while(Q->statusBuffer == 0){
         printf("\nFILA VAZIA");
        pthread_cond_wait(&fill, &mutex);
    }

    if(Q->statusBuffer == Q->sizeBuffer)//Se fila estiver cheia acorda os produtores
        pthread_cond_broadcast(&empty);

	int temp_val = Q->head->value;//Lendo primeiro elemento da fila
	Elem* temp = Q->head;
	Q->head = Q->head->prox;
	free(temp);
	Q->statusBuffer--;
	pthread_mutex_unlock(&mutex);

	return temp_val;//retornando o primeiro elemento da fila

}

BlockingQueue* newBlockingQueue(unsigned inSizeBuffer){
	BlockingQueue* temp = malloc(sizeof(BlockingQueue));
	temp->sizeBuffer = inSizeBuffer;
	temp->statusBuffer = 0;
	return temp;
}

void *Producer(void* arg) {//Função produtores
	BlockingQueue* Q = arg;
    int v;
    while(1){
        v = rand();//Produzindo um item aleatorio
        putBlockingQueue(Q, v);
    }

    pthread_exit((void*)NULL);
}

void *Consumer(void* arg){//Função consumidores
	BlockingQueue* Q = arg;
    int v;
    while(1)
        v = takeBlockingQueue(Q);//Consumindo um item

    pthread_exit((void*)NULL);
}

