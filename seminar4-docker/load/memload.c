#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv)
{
    unsigned long gb = argc > 1 ? atol(argv[1]) : 1;
    size_t n = gb * 1024UL * 1024UL * 1024UL;
    volatile char *p = malloc(n);

    if (!p)
    {
        fprintf(stderr, "alloc failed\n");
        return 1;
    }

    printf("filling %lu GB...\n", (unsigned long)gb);
    for (size_t i = 0; i < n; i++)
        p[i] = 1;

    printf("held %lu GB\n", (unsigned long)gb);
    for (;;) { }
}
