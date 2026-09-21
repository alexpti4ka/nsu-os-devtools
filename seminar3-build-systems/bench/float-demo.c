#include <math.h>
#include <stdio.h>

static double classify(double x)
{
    if (x != x)
        return 1.0;
    return 0.0;
}

int main(void)
{
    double x = NAN;
    double a = 1.0e16;
    double b = -1.0e16;
    double c = 1.0;

    printf("nan-detected=%.0f\n", classify(x));
    printf("(a+b)+c=%.17g\n", (a + b) + c);
    printf("a+(b+c)=%.17g\n", a + (b + c));
    return 0;
}
