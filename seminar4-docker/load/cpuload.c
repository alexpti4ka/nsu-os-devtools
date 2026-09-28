#include <stdio.h>

int main(void)
{
    volatile long x = 0;
    for (;;)
        x += 1;
    return 0;
}
