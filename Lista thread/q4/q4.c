#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#define N 2
#define P 10
#define T 2

pthread_barrier_t barrier;//Barrier utilizado na questão

float A[N][N] = {{2 , 1}, {5 , 7 }};
float b[N] = {11, 13};
float x[N] = {1, 1};
float temp[N];

void *Jacobi(void *threadid);

int main(){
	int i, *tid[T], rc;
	pthread_t threads[T];
	pthread_barrier_init(&barrier, NULL, T);//Inicializando barriers

	for(i = 0; i < T; i++) {
		tid[i]=(int*)malloc(sizeof(int));
        *tid[i]=i;
	    rc=pthread_create(&threads[i], NULL, Jacobi, (void*)tid[i]);

	    if (rc){
        printf("ERRO; código de retorno é %d\n", rc);
        exit(1);
        }

	}

	for (i = 0; i < T; i++){//Esperando threads termianarem
		  pthread_join(threads[i], NULL);
	}
    printf("x1 = %.4f, x2 = %.4f\n", x[0], x[1]);//imprimindo resultado

   	pthread_barrier_destroy(&barrier);//Destruindo o barrier

    pthread_exit((void*)NULL);
}

void *Jacobi(void *threadid){
	int tid=*((int*)threadid);
	int i , j, k;
	float res;

	for (k = 0; k < P; k++){// Quanto maior o numero de interações maior a aproximação
		for (i =tid; i < N; i = i + T){
			res = 0;
			for (j = 0; j < N; j++)			 // Fazendo o somatório
				if (i != j)
					res = res + A[i][j]*x[j];
			temp[i] = (1/A[i][i])*(b[i] - res);
		}

		pthread_barrier_wait(&barrier);	    //  esperando threads
		for (i = 0; i < N; i++)
			x[i] = temp[i];
		pthread_barrier_wait(&barrier);	    // Se não houver espera para começar a calcular o próximo k
	}

	pthread_exit((void*)NULL);
}

