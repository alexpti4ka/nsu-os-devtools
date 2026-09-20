#ifndef TEXTSTAT_H
#define TEXTSTAT_H

#include <stddef.h>

typedef struct TextStats
{
    size_t lines;
    size_t words;
    size_t characters;
    size_t longest_word;
} TextStats;

#endif
