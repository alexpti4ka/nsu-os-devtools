#include <stdio.h>
#include <unistd.h>
#include "stats.h"

int main(void)
{
    char path[128];
    FILE *f;
    TextStats stats;

    snprintf(path, sizeof(path), "/tmp/textstat-test-%ld.txt", (long)getpid());
    f = fopen(path, "w");
    if (!f) return 2;
    fputs("alpha beta\ngamma\n", f);
    fclose(f);

    if (stats_from_file(path, &stats) != 0) return 3;
    unlink(path);
    if (stats.lines != 2 || stats.words != 3 || stats.longest_word != 5) return 1;
    sleep(2);
    puts("test_stats: OK");
    return 0;
}
