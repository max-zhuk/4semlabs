#include <stdio.h>
#include <stdlib.h>
#include <aio.h>
#include <dlfcn.h>
#define MAXLEN 1200
struct aiocb createIoRequest(int fd,  
                            off_t offset, 
                            volatile void * content, 
                            size_t length){
               
    struct aiocb status = {0};
    {
        // Дескриптор файла
        status.aio_fildes = fd;
        // Смещение файла
        status.aio_offset = offset;
        // Расположение буфера
        status.aio_buf = content;
        // Длина передачи
        status.aio_nbytes = length;
    }
    return status;
}

char* readFile(char* nameFile)
{
    FILE* file = fopen (nameFile, "r");                       
    int fd = fileno(file);                                      
    int status;                                              
    char* buf;

    buf = (char*)calloc(MAXLEN, sizeof(char));                     

    struct aiocb op  = createIoRequest(fd, 0, buf, MAXLEN);       

    status = aio_read(&op);                                     
    if(status) printf("Read ERROR: %d\n", status);

    const struct aiocb * aiolist[1];
    aiolist[0] = &op;

    status = aio_suspend(aiolist, 1, NULL);
    if (status) printf("Suspend ERROR: %d\n", status);

    status = aio_error(&op);
    if (status) printf("errno: %d\n", status);

    fclose(file);
    return buf;
}

int writeFile(char* nameFile, char* msg)
{
    FILE* file = fopen(nameFile,"a");
    int fd = fileno(file);
    
    int status = 0;
    int length = 0;

    while (msg[length++] != '\0');


    
    struct aiocb op  = createIoRequest(fd, 0, msg, length - 1);

    
    status = aio_write(&op);
    if (status) printf("aio_write: %d\n", status);

    const struct aiocb * aiolist[1];
    aiolist[0] = &op;

    status = aio_suspend(aiolist,1,NULL);
    if (status) printf("aio_suspend: %d\n",status);

    status = aio_error(&op);
    if (status) printf("errno 1: %d\n",status);
    
    fclose(file);
    return 0;
}