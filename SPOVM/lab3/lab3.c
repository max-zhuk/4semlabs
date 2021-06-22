#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <time.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>

int rd = 0;
int dn = 0;
struct sigaction ready;
struct sigaction done; 

void changeReady(int signo)
{
  rd = 1;
}
 
void changeDone(int signo)
{
  dn = 1;
}

pid_t pids[2];



int    main()
        {

                initscr();
                refresh();
                int y=0;
                int c = 0;
                ready.sa_handler = changeReady;
                     sigaction(SIGUSR1,&ready,NULL);
 
                done.sa_handler = changeDone;
                    sigaction(SIGUSR2,&done,NULL);


                int     fd[2], nbytes;
                pid_t   childpid;
                char    string[30];
                char    readbuffer[80];

                pipe(fd);
                
                pids[0]=getpid();
                pids[1] = fork();

                switch (pids[1])
                {
                case 0:
                   
                    close(fd[1]);
                        while(1)
                        {
                            if(rd==1)
                            {   usleep(2000);
                                rd = 0;
                                nbytes = read(fd[0], readbuffer, sizeof(readbuffer));
                                move(c++,20);
                                printw("Received string: %s\n", readbuffer);
                                refresh();
                                kill(pids[0],SIGUSR2);
                            }
                        }
                    break;
                
                default:
                     close(fd[0]);
                        dn=1;
                        while(1)
                        {   
                            if(dn==1)
                            {   
                                dn=0;
                                move(y++,0);
                                scanw("%s",&string);
                                if(string[0]=='q') 
                                {    
                                    printw("\nThe program was stoped\n\n");
                                    refresh();
                                     kill(pids[1],SIGKILL);
                                     waitpid(pids[1],NULL,0);
                                    
                                     return 0;    

                                }
                                kill(pids[1],SIGUSR1);
                                write(fd[1], string, (strlen(string)+1));
                                
                            }
                        }
                        exit(0);
                    break;
                }
                
                
                       
                            
                    

                
                endwin();
                return 0;
        }