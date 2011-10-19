#include <stdio.h>
#include <string.h>
#include <errno.h>

int echo_args(int argc, char *argv[])
{
    int i;
    for(i = 0; i < argc; i++)

        printf("arg %d: %s\n", i, argv[i]);
    return 0;
}

int print_file(int argc, char *argv[])
{
    int i;
    FILE *fp;
    int c;

    for(i = 1; i < argc; i++)
    {
        fp = fopen(argv[i], "r");
        if(fp == NULL)
        {
            fprintf(stderr, "%s: can't open '%s': %s\n",
                argv[0], argv[i], strerror(errno));
            continue;
        }
        while((c = getc(fp)) != EOF)
            putchar(c);
        fclose(fp);
    }
    return 0;
}

int get_line(char line[], int max)
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

int debug(char *str)
{
#ifdef DEBUG
    printf("D| %s", str);
#endif
    return 0;
}
