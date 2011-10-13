#include <stdio.h>
#include "get_line.h"

#define MAX_LINE_LEGHT 256
main(int argc, char *argv[])
{
    char line[MAX_LINE_LEGHT];
    while(get_line(line, MAX_LINE_LEGHT) != EOF)
        printf("you typed '%s'\n", line);
    return 0;
}
