#include <stdio.h>
#include <errno.h>

main(int argc, char *argv[])
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
