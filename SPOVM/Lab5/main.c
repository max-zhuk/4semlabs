#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/shm.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <dirent.h>
#include <pthread.h>
#include <string.h>


#define LIBADRESS  "/home/kali/Desktop/Lab_5/lib.so"
#define FILENAME  "Result.txt"
#define SEM_ID	1999     
#define SHM_ID	1998     
#define PERMS	0667    
#define MAXLENGTH 1200

typedef struct
{
    char string [MAXLENGTH];
} message_t; 


void* fileReader(void*);
void* fileWriter(void*);
pthread_t addThread(void* (*)(void*));

int checkTxt (char*);


int main () {
   

    //Инициализация
   int semid = semget (SEM_ID, 3, PERMS | IPC_CREAT); //инициализируем семафор
   int shmid = shmget(SHM_ID, sizeof (message_t), PERMS | IPC_CREAT);  //инициализируем сегменты памяти

    
    semctl(semid, 0, SETVAL, 0);                                    
    semctl(semid, 1, SETVAL, 0);
    semctl(semid, 2, SETVAL, 0);
    
    
    pthread_t readThread = addThread (fileReader); //создаём поток читаля                 
    pthread_t writeThread  = addThread (fileWriter);   //создаёт поток писателя               
    
    
    pthread_join(writeThread, NULL); // ставим поток писателя на ожидание
    
   
    pthread_cancel(readThread); //завершие потоков
    pthread_cancel(writeThread);

   
    semctl(semid, 0, IPC_RMID, (struct semid_ds *) 0); //удаляет семафоры         
    shmctl(shmid, IPC_RMID, (struct shmid_ds *) 0);    //уд сегм памяти         
    
    printf("Result.txt"); 

    return 0; //канец
}

void* fileReader(void* a){
    int semid;
    int shmid;
    void* handle;
    char* (*fun) (char*);
    message_t *sharedMemory; 
    DIR * dir;      //структура для открытия директории
    char fileName[20]; //имя файла

    struct dirent *de = NULL;  // сюда получим файлы из директории DIR

    semid = semget (SEM_ID, 3, 0);  //получаем доступ к уже созданным семафорам
    shmid = shmget (SHM_ID, sizeof (message_t), 0);//и сегментам памяти

    sharedMemory = (message_t *) shmat (shmid, 0, 0); //получаем содержание сегмента памяти размером со структуру с нашей строкой

    dir = opendir("."); //открываем текущую директорию

    
    handle = dlopen(LIBADRESS, RTLD_LAZY); //подключаем библиотку 


    fun = dlsym (handle, "readFile"); //передаём ДЕСКРИПТОР и имя функции и получаем указатель на эту функцию в fun

    
    while ( de = readdir(dir) ) {       //читаем по файлу ищ директории
        if (checkTxt(de->d_name) == 0 &&    //чекаем чтоб файл был тхт
            strcmp(de->d_name, FILENAME) != 0) {    //смотрим чтоб не записать файл с результатом

           
            while (semctl(semid, 0, GETVAL, 0) ||   //проверяем открыты ли семафоры
                   semctl(semid, 1, GETVAL, 0) );

            
            semctl(semid, 0, SETVAL, 1);    //занимаем семафор

            strncpy(fileName, de->d_name, 20);  //заполяем 
            char* msg = (*fun) (fileName);
            strncpy (sharedMemory->string, msg, MAXLENGTH);

          
            semctl(semid, 1, SETVAL, 1);
           
            semctl(semid, 0, SETVAL, 0);
            free (msg);
        }
    }
    //Закрыть writer
    semctl(semid, 2, SETVAL, 1);
    
    shmdt (sharedMemory);
    closedir(dir);
    
    return (void*) NULL;
}

void* fileWriter (void* a){
    int semid;
    int shmid;
    void* handle;
    int (*fun) (char*, char*);
    message_t *sharedMemory;
    DIR * dir;

    struct dirent * de;

    semid = semget (SEM_ID, 3, 0);
    shmid = shmget (SHM_ID, sizeof (message_t), 0);
    sharedMemory = (message_t *) shmat (shmid, 0, 0);

    dir = opendir(".");

    
    handle = dlopen (LIBADRESS, RTLD_LAZY);
    fun = dlsym (handle, "writeFile");

    while ( de = readdir(dir) ){
        if (strcmp(de->d_name, FILENAME))
            remove(FILENAME);
    }
    
    while (!semctl(semid, 2, GETVAL, 0)){
      
        if(!semctl(semid, 0, GETVAL, 0) && semctl(semid, 1, GETVAL, 0) ){
          
            semctl(semid, 0, SETVAL, 1);
            
            (*fun) (FILENAME, sharedMemory->string);

            //обработанно
            semctl(semid, 1, SETVAL, 0);
            semctl(semid, 0, SETVAL, 0);
            
        }
    }
    shmdt (sharedMemory);
    return (void*) NULL;
}


pthread_t addThread (void* (*fun)(void*)){
    pthread_t thread;
    pthread_attr_t attr;
    pthread_attr_init (&attr);
    pthread_create (&thread, &attr, fun, NULL);
    return thread;
}


int checkTxt (char* str){
    int length = 0;
    while (str[length++] != '\0');
    if (str[length- 4] == 't' &&
        str[length- 3] == 'x' &&
        str[length- 2] == 't')
        return 0;
    return -1;
}