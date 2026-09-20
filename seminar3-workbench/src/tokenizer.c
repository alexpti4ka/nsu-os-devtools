#include <ctype.h>
#include <stddef.h>
#include "tokenizer.h"

int tokenizer_collect(FILE *stream, TextStats *stats)
{
    int ch;
    int in_word = 0;
    size_t current_word = 0;

    if (stream == NULL || stats == NULL)
        return -1;

    stats->lines = 0;
    stats->words = 0;
    stats->characters = 0;
    stats->longest_word = 0;

    while ((ch = fgetc(stream)) != EOF)
    {
        stats->characters++;
        if (ch == '\n')
            stats->lines++;

        if (isspace((unsigned char) ch))
        {
            if (in_word)
            {
                stats->words++;
                if (current_word > stats->longest_word)
                    stats->longest_word = current_word;
                current_word = 0;
                in_word = 0;
            }
        }
        else
        {
            in_word = 1;
            current_word++;
        }
    }

    if (in_word)
    {
        stats->words++;
        if (current_word > stats->longest_word)
            stats->longest_word = current_word;
    }

    return ferror(stream) ? -1 : 0;
}
