
#include<stdio.h>
#include<stddef.h>
#include<string.h>


char memory[20000];

void *reqstack[10];
int stacksize=0;
int* mass[10];
int masssize=0;

int* match(void *ptr,void* mlock){
    masssize++;

    if(ptr==NULL){
       
            ptr=mlock;
            if(masssize<10)
            mass[masssize-1]=mlock;
    }
    else{

        for(int i=0;i<masssize;i++)
        {
          
        
            if (mass[i]==ptr){
            
            printf("Rewrite\n");
            ptr=mlock;
            mass[i] =mlock;
            }
        }   
            
    }  
}

void regreq(void* ptr)
{
    reqstack[stacksize++] = ptr;
    printf("req reged\n");
}


struct block{
int mark;
 size_t size; 
 int free; 
 struct block *next; 
};



struct block *freeList=(void*)memory;


void initialize();
void split(struct block *fitting_slot,size_t size);
void *mymalloc(size_t noOfBytes);
void merge();
void myfree(void* ptr);


void initialize(){
    freeList->mark=0;
 freeList->size=20000-sizeof(struct block);
 freeList->free=1;
 freeList->next=NULL;
}


void split(struct block *fitting_slot,size_t size){
 struct block *new=(void*)((void*)fitting_slot+size+sizeof(struct block));
 new->size=(fitting_slot->size)-size-sizeof(struct block);
 new->free=1;
 new->next=fitting_slot->next;
 fitting_slot->size=size;
 fitting_slot->free=0;
 fitting_slot->next=new;
}



void *mymalloc(size_t noOfBytes){
 struct block *curr,*prev;
 void *result;
 if(!(freeList->size)){
  initialize();
  printf("Memory initialized\n");
 }
 curr=freeList;
 while((((curr->size)<noOfBytes)||((curr->free)==0))&&(curr->next!=NULL)){
  prev=curr;
  curr=curr->next;
  //printf("One block checked\n");
 }
 if((curr->size)==noOfBytes){
  curr->free=0;
  result=(void*)(++curr);
  //printf("Exact fitting block allocated\n");
  return result;
 }
 else if((curr->size)>(noOfBytes+sizeof(struct block))){
  split(curr,noOfBytes);
  result=(void*)(++curr);
  //printf("Fitting block allocated with a split\n");
  return result;
 }
 else{
  result=NULL;
  //printf("Sorry. No sufficient memory to allocate\n");
  return result;
 }
}


void merge(){
 struct block *curr,*prev;
 curr=freeList;
 while((curr->next)!=NULL){
    // printf("\ndetected 2222!\n");
  if((curr->free) ){
      //printf("\ndetected!\n");
   curr->size+=(curr->next->size)+sizeof(struct block);
   curr->next=curr->next->next;
   printf("Block collected\n");
  }
  prev=curr;
  curr=curr->next;
 }
}


void myfree(void* ptr){
 if(((void*)memory<=ptr)&&(ptr<=(void*)(memory+20000))){
  struct block* curr=ptr;

  curr--;
  curr->free=1;

  merge();
  
 }
 else printf("Please provide a valid pointer allocated by MyMalloc\n");
}
void count(){
    int counter=0;
printf("Count blocks: ");
struct block *curr,*prev;
curr=freeList;
while((curr->next!=NULL)){

counter++;
prev=curr;
curr=curr->next;
}
printf("%d\n",counter);
}


void markAllAvalible(){
printf("StartMarking\n");
struct block *curr;
for(int i=0;i<stacksize;i++)
{
    if(((void*)memory<=reqstack[i])&&(reqstack[i]<=(void*)(memory+20000))){

    curr = reqstack[i];
    curr--;
    curr->mark=1;

    printf("%d\n",curr->mark);
    }
}
}


void marks()
{
     printf("StartMarking\n");
    struct block *curr;
for(int i=0;i<10;i++)
{
    if(((void*)memory<=mass[i])&&(mass[i]<=(void*)(memory+20000))){
         curr = mass[i];
         
        --curr;
        curr->mark=1;
        curr++;
       
    }
}}

void garbCollector(){
    
printf("Garbage detection started\n");
struct block *curr,*prev;
curr=freeList;
while((curr->next!=NULL)){

if(curr->mark==0) 
{
    printf("WARN: Garbage detected!\n");
}

//printf("iter\n");
prev=curr;
curr=curr->next;
}

}

void garbColl(){
printf("Garbage collection started\n");
struct block *curr,*prev;
curr=freeList;
while((curr->next!=NULL)){

if(curr->mark==0) 
{
   if(curr->next->mark==0) 
    //  curr->size+=(curr->next->size)+sizeof(struct block);
    // curr->next=curr->next->next;
    curr->free=1;
    myfree(curr);
    
    
}

//printf("iter\n");
prev=curr;
curr=curr->next;
}
}
//TEST
int main(){
 
 int *p=NULL;
 int *q=NULL;
 int *r=NULL;  
 int* s=NULL;
 int *t=NULL;  
 int* u=NULL;  
    int konst=42;


   p = match(p,mymalloc(100*sizeof(int)));
    q = match(q,mymalloc(250*sizeof(int)));
    r = match(r,mymalloc(100*sizeof(int)));
   s = match(s,mymalloc(250*sizeof(int)));
   t = match(t,mymalloc(100*sizeof(int)));
   u = match(u,mymalloc(250*sizeof(int)));

    printf("--------\n");

    count();

    myfree(q);
    myfree(r);

    count();

    printf("--------\n");
    
    q = match(q,mymalloc(250*sizeof(int)));
    r = match(r,mymalloc(100*sizeof(int)));

    p = match(p,&konst);
    s=match(s,&konst);
  
    

count();
    

  printf("--------\n");
  marks();
  garbCollector();
  printf("--------\n");
  garbColl();
  printf("--------\n");
  count();
}