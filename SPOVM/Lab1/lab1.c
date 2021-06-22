#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <ncurses.h>
#include <time.h>


int main() {
    long int times1;
    char *args[]={"./myfile",NULL};
initscr();
int height1 = 5;
        int width1 = 36;
        int start_y1 = 5;
        int start_x1=50;

       
        WINDOW * win2 = newwin(height1,width1,start_y1, start_x1);
       
        refresh();
int pid = fork();

    

switch(pid) 
{

case -1:
    perror("fork");
    return -1;
case 0:
    
    execvp(args[0],args);

    
    getch();
    break;
default:


    sleep(1);

    move(0,0);
    printw("   %d   ",getpid());
    refresh();

    while (1)
    {
    sleep(2);
        
        start_color();
        init_pair(0,COLOR_GREEN,COLOR_GREEN);
        wattron(win2,COLOR_PAIR);
        box(win2,0,0);
        wattroff(win2,COLOR_PAIR);
        times1 = time(NULL); 
        mvwprintw(win2,2,3,ctime(&times1));
        
        wrefresh(win2);
        
        
    }
    getch();
        break;
} 

getch();

endwin();

return 0;
}
