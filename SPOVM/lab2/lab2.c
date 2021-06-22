#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <time.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
 
#define AMOUNT 10
 

    

int clflag = 0;
int flag = 1;
int cur = 1;
int size = 0;
int active = 0;
int fext = 0;

 
void checkEnd()
{
    if(flag)
    {
          kill(getppid(),SIGUSR2);
          exit(0);
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

pid_t childs[AMOUNT];

void upclflag()
{
    clflag = 1;
}
void changeMode(int signo)
{
  active = 1;
}
 
void FlagFin(int signo)
{
  flag = 1;
}

struct sigaction printSignal;
struct sigaction endSignal;

int main(void)
{
      initscr();
      clear();
      noecho();
      refresh();
 
      


      printSignal.sa_handler = changeMode;
            sigaction(SIGUSR1,&printSignal,NULL);
 
      endSignal.sa_handler = FlagFin;
            sigaction(SIGUSR2,&endSignal,NULL);
 
      char c = 0; int i = 0;
      
 
      childs[0]=getpid();
 
      while(c!='q')
      { 
          if(kbhit>0)
          {
              switch(c=getchar())
              {   usleep(20000);
                  case '=':
                  {
                      if(size < AMOUNT)
                      {
                          size++;
                          childs[size] = fork();
                      }
 
                      switch(childs[size])
                      {
                          case 0: //child process
                          {
                              flag = 0;
                              while(!flag)
                              {     
                                    usleep(200000);
                                    if(active)
                                    {   
                                        
                            
                                        
                                        
                                        printf("Process #%d, my pid is %d\n\r",size,getpid());
                                        
                                        usleep(400000);
                                     
                                        checkEnd();
                                       
                                        active = 0;
                                        kill(getppid(),SIGUSR2); //signal to parent about finish of printing
                                        
                                    }
                                    
                                    checkEnd();
                              }
                           }
                           break;
 
                           case -1:
                           {
                               printf("Error  (pr [%d])\n",size);
                           }
                           break;
                      }
                  }
                  break;
 
                  case '-':
                  {      
                        
                         printf("Process #%d killed\n",size);
                        
                        
                                        
                        
                         
                        if(size==0)
                        {
                           
                          
                           break;
                        }
                        sleep(1);
                         kill(childs[size],SIGKILL);
                         active = 1; 
                        waitpid(childs[size],NULL,0);
                       
                        if(cur == size) cur = 1;
                        size--;
                       
                        
                        
                         
                  }
                  break;
              }
          }
          
          if(flag && size>0)       
          {
              flag = 0;
              kill(childs[cur++],SIGUSR1); 
              if(cur > size)    
                  cur = 1;                  
          }
          refresh();
      }
 
    
      if(childs[size]!=0)
      {
         for(;size>0;size--)
         {     
             
             kill(childs[size],SIGUSR2);
             
             waitpid(childs[size],NULL,0);
         }
      }
      clear();
      endwin();
 
      return 0;
}