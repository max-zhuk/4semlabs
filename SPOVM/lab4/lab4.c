#include <pthread.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <time.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#define NUM_THREADS     5



int tids[NUM_THREADS];

void *PrintHello(void *threadid)
{   
    
   long tid;
   
   tid = (long)threadid;
   int count=0;
    tids[tid]=gettid();
  
  
       sleep(1);
while(1)
{   
      // move(tid,40);
   printw("Thread #%ld!\n", tid);
   refresh();
   sleep(1);
  
}
   
}

int kbhit()
{
    fd_set rfds;
    struct timeval tv;
 
    FD_ZERO(&rfds);
    FD_SET(0,&rfds);
    tv.tv_sec=0;
    tv.tv_usec=100;
 
    return select(1,&rfds,NULL,NULL,&tv);
}

int flagExit =0;
int active=0;
void CheckMode(int signo)
{
  active = 1;
}
 
void FlagFin(int signo)
{
  flagExit = 1;
}



int main (int argc, char *argv[])
{   
    initscr();
    refresh();


   pthread_t threads[NUM_THREADS];
   int rc;
   long t;
   long size=0;
   char c=0;

    while(c!='q')
      { 
          if(kbhit>0)
          {
              switch(c=getchar())
              {   usleep(20000);
                  case '=':
                  {
                      if(size < NUM_THREADS)
                      {
                          size++;
                      }

                        
                        // move(size,0);
                        // printw("In main: creating thread %ld\n", size);
                        // refresh();
                        rc = pthread_create(&threads[size], NULL, PrintHello, (void *)size);
                        
                        
                           
                       
                  }
                  break;
 
                  case '-':
                  {      
                        
                       
                        // move(size,40);
                        // printw("                            \n");
                        // move(size,0);
                        // printw("                             \n");
                        refresh();
                        pthread_cancel(threads[size--]);
                        
                        sleep(1);
                                                
                        
                         
                  }
                  break;
              }
          }







       
      
      
   }
   
}