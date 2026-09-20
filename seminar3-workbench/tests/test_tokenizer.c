#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "tokenizer.h"

int main(void)
{
    TextStats stats;
    FILE *f = tmpfile();
    if (!f) return 2;
    fputs("one two\nthree\n", f);
    rewind(f);
    if (tokenizer_collect(f, &stats) != 0) return 3;
    fclose(f);
    if (stats.lines != 2 || stats.words != 3 || stats.longest_word != 5) return 1;
    sleep(2);
    puts("test_tokenizer: OK");
    return 0;
}
