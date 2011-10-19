#include <stdio.h>
#include "utils.h"
#include <time.h>

#define MAX_LINE_LEGHT 256
#define Autor "David Gamba"


void date();
int help();

int
main(int argc, char *argv[])
{
    help();
    echo_args(argc, argv);
    print_file(argc, argv);
    return 0;
    char line[MAX_LINE_LEGHT];
    while(get_line(line, MAX_LINE_LEGHT) != EOF)
        printf("you typed '%s'\n", line);
    return 0;
}

int help()
{
    date();
    debug("hola\n");
    printf("This is the C version of my todo perl script\n");
    printf("Made by: %s\n", Autor);
    return 0;
}

void date()
{
    char str[80];
    struct tm *ptr;
    time_t lt;
    lt = time(NULL);
    ptr = localtime(&lt);

    strftime(str, 100, "It is now %l:%M %p.",ptr);
    printf("date: %s\n", str);
}

/* POINTERS

int * a; // *: Pointer-to int
int * b; //Pointer b will point to a variable of type int
int i;
int j;
a = &i; // &: Address-of i
*a = 5; // *: Contents-of a

*/
