#include <stdio.h>
#include "formatter.h"

void formatter_print(const char *path, const TextStats *stats, long score, const char *policy)
{
    printf("File: %s\n", path);
    printf("Lines: %zu\n", stats->lines);
    printf("Words: %zu\n", stats->words);
    printf("Characters: %zu\n", stats->characters);
    printf("Longest word: %zu\n", stats->longest_word);
    printf("Policy: %s\n", policy);
    printf("Score: %ld\n", score);
}
