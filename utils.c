#include "utils.h"
#include <stdio.h>
#include <errno.h>
#include <string.h>
/*Use posix inplementation of basename*/
#include <libgen.h>
#include <sys/types.h>
#include <dirent.h>
#include <error.h>

// error (exit, errno, message);

int
echo_args(int argc, char *argv[])
{
    int i;
    char *p_name = argv[0];

    for(i = 1; i < argc; i++)
        printf("%s: arg %d: %s\n", basename(p_name), i, argv[i]);
    return 0;
}

int
get_line(char line[], int max)
{
    int nch = 0;
    int c;
    max = max - 1; /* leave room for '\0' */

    while((c = getchar()) != EOF)
    {
        if(c == '\n')
            break;

        if(nch < max)
        {
            line[nch] = c;
            nch = nch + 1;
        }
    }

    if(c == EOF && nch == 0)
        return EOF;

    line[nch] = '\0';
    return nch;
}

int
print_file(int argc, char *argv[])
{
    int i;
    FILE *fp;
    int c;
    char *p_name = argv[0];

    for(i = 1; i < argc; i++)
    {
        errno = 0;
        fp = fopen(argv[i], "r");
        if(fp == NULL)
        {
            int err = errno;
            fprintf(stderr, "%s: can't open '%s': %s\n",
                basename(p_name), argv[i], strerror(err));
            continue;
        }
        while((c = getc(fp)) != EOF)
            putchar(c);
        fclose(fp);
    }
    return 0;
}
/*
int
print_dir(int argc, char *argv[])
{
    int i;
    FILE *dp;
    int c;
    char *p_name = argv[0];

    for(i = 1; i < argc; i++)
    {
        errno = 0;
        dp = opendir(argv[i]);
        if(dp == NULL)
        {
            int err = errno;
            fprintf(stderr, "%s: can't open '%s': %s\n",
                basename(p_name), argv[i], strerror(err));
            continue;
        }
        file = readdir(dp);
    }
    return 0;
}
*/
