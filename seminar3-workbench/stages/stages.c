#include <stdio.h>
#include "config.h"

#define SQUARE(x) ((x) * (x))

int calculate(int x)
{
    return SQUARE(scaled_value(x + 1));
}

int main(void)
{
    int value = calculate(4);
    printf("%s: %d\n", GREETING, value);
    return 0;
}
