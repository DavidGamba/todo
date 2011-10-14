#include <stdio.h>
#include "utils.h"

#define MAX_LINE_LEGHT 256
int
main(int argc, char *argv[])
{
    int i = echo_args(argc, argv);
    int j = print_file(argc, argv);
    return 0;
    char line[MAX_LINE_LEGHT];
    while(get_line(line, MAX_LINE_LEGHT) != EOF)
        printf("you typed '%s'\n", line);
    return 0;
}
