#include <stdio.h>

#define SQUARE(x) ((x) * (x))
#define LIMIT 5

int sum_squares(int n) {
    int s = 0;
    for (int i = 1; i <= n; i++) {
        s += SQUARE(i);
    }
    return s;
}

int main(void) {
    printf("%d\n", sum_squares(LIMIT));
    return 0;
}
