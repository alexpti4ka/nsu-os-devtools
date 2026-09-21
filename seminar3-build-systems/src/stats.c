#include <stdio.h>
#include "stats.h"
#include "tokenizer.h"

int stats_from_file(const char *path, TextStats *stats)
{
    FILE *stream = fopen(path, "r");
    int rc;

    if (stream == NULL)
        return -1;

    rc = tokenizer_collect(stream, stats);
    fclose(stream);
    return rc;
}
