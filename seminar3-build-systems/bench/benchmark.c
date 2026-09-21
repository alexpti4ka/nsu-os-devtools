#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static uint64_t mix(uint64_t x)
{
    x ^= x >> 13;
    x *= UINT64_C(0xff51afd7ed558ccd);
    x ^= x >> 17;
    return x;
}

int main(int argc, char **argv)
{
    uint64_t n = UINT64_C(150000000);
    uint64_t acc = 0;

    if (argc == 2)
        n = strtoull(argv[1], NULL, 10);

    for (uint64_t i = 1; i <= n; ++i)
        acc += mix(i);

    printf("result=%" PRIu64 "\n", acc);
    return 0;
}
