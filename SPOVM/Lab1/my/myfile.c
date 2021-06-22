#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <ncurses.h>
#include <time.h>

int main()
{   
    initscr();


    long int times2;
    int height,width,start_y, start_x;

        height = 5;
        width = 36;
        start_y=start_x=5;

         WINDOW * win1 = newwin(height,width,start_y, start_x);

    move(3,15);
    printw("%d",getpid());
    refresh();

    while (1)
    {
    sleep(1);
    times2 = time(NULL);   
    box(win1,0,0);
    mvwprintw(win1,2,3,ctime(&times2)); //
    wrefresh(win1);
    }
}