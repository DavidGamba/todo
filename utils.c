#include "utils.h"
#include <stdio.h>
#include <errno.h>
#include <string.h>
/*Use posix inplementation of basename*/
#include <libgen.h>
#include <sys/types.h>
#include <dirent.h>
#include <error.h>
#include <stdarg.h>

// error (exit, errno, message);

void echo_args(int argc, char *argv[])
{
    int i;
    char *p_name = argv[0];
    for(i = 0; i < argc; i++)
        printf("%s: arg %d: %s\n", basename(p_name), i, argv[i]);
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

int print_file(int argc, char *argv[])
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

int print_dir(int argc, char *argv[])
{
    DIR           *dip;
    struct dirent *dit;
    int i = 0;

    /* check to see if user entered a directory name */
    if (argc < 2)
    {
        printf("Usage: %s <directory>\n", argv[0]);
        return 0;
    }

    /* DIR *opendir(const char *name);
     *
     * Open a directory stream to argv[1] and make sure
     * it's a readable and valid (directory) */
    if ((dip = opendir(argv[1])) == NULL)
    {
        int err = errno;
        print_error("opendir",
            "can't open '%s': %s\n", argv[1], strerror(err));
        return 0;
    }

    printf("Directory stream is now open\n");

    /*  struct dirent *readdir(DIR *dir);
     *
     * Read in the files from argv[1] and print */
    while ((dit = readdir(dip)) != NULL)
    {
        i++;
        printf("\n%s", dit->d_name);
    }

    printf("\n\nreaddir() found a total of %i files\n", i);

    /* int closedir(DIR *dir);
     *
     * Close the stream to argv[1]. And check for errors. */
    if (closedir(dip) == -1)
    {
        perror("closedir");
        return 0;
    }

    printf("\nDirectory stream is now closed\n");
    return 1;
}

void debug(char *str)
{
#ifdef DEBUG
    printf("D| %s", str);
#endif
}

void print_error(char *function, const char *format, ...)
{
    va_list args;
    char *f_name = function;
    fprintf(stderr, "%s: ", basename(f_name));
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
}
