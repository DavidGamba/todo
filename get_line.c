#include <stdio.h>

/* Read one line from standard input, */
/* copying it to line array (but no more than max chars). */
/* Does not place terminating \n in line array. */
/* Returns line length, or 0 for empty line, or EOF for end-of-file. */

int get_line(char line[], int max)
{
    int nch = 0;
    int c;
    max = max - 1;          /* leave room for '\0' */

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
